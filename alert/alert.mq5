//+------------------------------------------------------------------+
//|                                                        alert.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#resource "buy_entry_alert.wav"
#define BUY_ENTRY_ALERT_FILE "::buy_entry_alert.wav"

#resource "buy_tp_alert.wav"
#define BUY_TP_ALERT_FILE "::buy_tp_alert.wav"

#resource "sell_entry_alert.wav"
#define SELL_ENTRY_ALERT_FILE "::sell_entry_alert.wav"

#resource "sell_tp_alert.wav"
#define SELL_TP_ALERT_FILE "::sell_tp_alert.wav"

#resource "sl_alert.wav"
#define SL_ALERT_FILE "::sl_alert.wav"

input group "Averange Price Settings";
input bool drawAveragePrice = false;
input ENUM_BASE_CORNER corner = CORNER_RIGHT_LOWER; // Corner
input color averageBuyPriceColor = clrGreen;        // Buy Color
input color averageSellPriceColor = clrRed;         // Sell Color

ENUM_BASE_CORNER Corner;
ENUM_ANCHOR_POINT anchor;

color AverageBuyPriceColor = NULL;
color AverageSellPriceColor = NULL;
string buyLineName = "averageBuyPrice";
string sellLineName = "averageSellPrice";

int totalPositions = 0;
double averageBuyPrice = NULL;
double totalBuyLots = NULL;
double totalBuyProfit = NULL;
double averageSellPrice = NULL;
double totalSellLots = NULL;
double totalSellProfit = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  Print("Alert initialized");

  if (AverageBuyPriceColor == averageBuyPriceColor &&
      AverageSellPriceColor == averageSellPriceColor && Corner == corner) {
    Print("Parameters are already set.");

    return (INIT_SUCCEEDED);
  }

  AverageBuyPriceColor = averageBuyPriceColor;
  AverageSellPriceColor = averageSellPriceColor;
  Corner = corner;

  switch (Corner) {
  case CORNER_LEFT_UPPER:
    anchor = ANCHOR_LEFT_UPPER;
    break;
  case CORNER_LEFT_LOWER:
    anchor = ANCHOR_LEFT_LOWER;
    break;
  case CORNER_RIGHT_UPPER:
    anchor = ANCHOR_RIGHT_UPPER;
    break;
  case CORNER_RIGHT_LOWER:
    anchor = ANCHOR_RIGHT_LOWER;
    break;
  }

  ObjectDelete(0, buyLineName + "Text");
  ObjectDelete(0, sellLineName + "Text");
  ObjectDelete(0, "summaryText");

  ReCalculateAveragePrice();

  return (INIT_SUCCEEDED);
}

void OnTick() {
  Print("OnTick called.");

  ReCalculateAveragePrice();
  
  Print("drawAveragePrice", drawAveragePrice);

  if (drawAveragePrice) {
      Print("averageBuyPrice: ", averageBuyPrice, ", averageBuyPrice == NULL: " , averageBuyPrice == NULL);
      Print("totalBuyLots: ", totalBuyLots, ", totalBuyLots == NULL: ", totalBuyLots == NULL);
      Print("averageSellPrice: ", averageSellPrice, ", averageSellPrice == NULL: ", averageSellPrice == NULL);
      Print("totalSellLots: ", totalSellLots, ", totalSellLots == NULL: ", totalSellLots == NULL);

  //  if (averageBuyPrice == NULL || totalBuyLots == NULL ||
  //      averageSellPrice == NULL || totalSellLots == NULL)
  //    return;

    DrawHorizontalLine(averageBuyPrice, ORDER_TYPE_BUY, AverageBuyPriceColor,
                       totalBuyLots, totalBuyProfit);

    DrawHorizontalLine(averageSellPrice, ORDER_TYPE_SELL, AverageSellPriceColor,
                       totalSellLots, totalSellProfit);

    DrawSummary(totalBuyProfit + totalSellProfit);

    ChartRedraw(); // Refresh the chart
  }
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {

  ENUM_TRADE_TRANSACTION_TYPE type = trans.type;

  if (type == TRADE_TRANSACTION_DEAL_ADD) {

    if (HistoryDealSelect(trans.deal)) {
      cDealInfo.Ticket(trans.deal);
    } else {
      Print(__FILE__, " ", __FUNCTION__, ", ERROR: HistoryDealSelect(",
            trans.deal, ")");
      return;
    }

    long reason = -1;
    if (!cDealInfo.InfoInteger(DEAL_REASON, reason)) {
      Print(__FILE__, " ", __FUNCTION__,
            ", ERROR: InfoInteger(DEAL_REASON,reason)");
      return;
    }

    string strReason = Utility.GetDealReasonString((ENUM_DEAL_REASON)reason);

    Print("strReason: ", strReason);

    string strType = Utility.GetOrderTypeStringFromTransDeal(trans);

    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL) {

      PlaySound(SL_ALERT_FILE);

      string message = "SL " + strType + " " + (string)trans.volume;
      Print(message);

      ReCalculateAveragePrice();

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {

      long orderType = Utility.GetOrderTypeFromTransDeal(trans);

      if (orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT ||
          orderType == ORDER_TYPE_BUY_STOP) {
        PlaySound(BUY_TP_ALERT_FILE);
      } else if (orderType == ORDER_TYPE_SELL_LIMIT ||
                 orderType == ORDER_TYPE_SELL_STOP) {
        PlaySound(SELL_TP_ALERT_FILE);
      }

      string message = "TP " + strType + " " + (string)trans.volume;
      Print(message);

      ReCalculateAveragePrice();

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_EXPERT) {
      long orderType = Utility.GetOrderTypeFromTransDeal(trans);

      if (orderType == ORDER_TYPE_BUY_LIMIT ||
          orderType == ORDER_TYPE_BUY_STOP) {
        PlaySound(BUY_ENTRY_ALERT_FILE);
      } else if (orderType == ORDER_TYPE_SELL_LIMIT ||
                 orderType == ORDER_TYPE_SELL_STOP) {
        PlaySound(SELL_ENTRY_ALERT_FILE);
      }

      if (orderType != -1) {
        string message = "Entry " + strType + " " + (string)trans.volume;
        Print(message);
      }

      ReCalculateAveragePrice();
    }
  }
}

void OnDeinit(const int reason) {

  Print("OnDeinit reason: ", reason);

  if (reason != REASON_CHARTCHANGE && drawAveragePrice) {
    // Delete the horizontal line
    ObjectDelete(0, buyLineName);
    ObjectDelete(0, sellLineName);
    ObjectDelete(0, buyLineName + "Text");
    ObjectDelete(0, sellLineName + "Text");
    ObjectDelete(0, "summaryText");
  }
}

void ReCalculateAveragePrice() {
   Print("ReCalculateAveragePrice");
  if (drawAveragePrice) {
    Utility.GetAveragePriceAndLots(
        averageBuyPrice, totalBuyLots, totalBuyProfit, averageSellPrice,
        totalSellLots, totalSellProfit, totalPositions);
  }
}

void DrawHorizontalLine(double price, ENUM_ORDER_TYPE type, color lineColor,
                        double lot, double profit) {

  // Print("DrawHorizontalLine, Price: " + price + ", type: " + type +
  //       ", LineColor: " + lineColor + ", Lot: " + lot + ", Profit: " +
  //       profit);

  string lineName;

  if (type == ORDER_TYPE_BUY) {
    lineName = buyLineName;
  } else {
    lineName = sellLineName;
  }

  // Check if line already exists
  if (ObjectFind(0, lineName) != -1) {

    ObjectSetString(0, lineName, OBJPROP_TEXT,
                    "Price: " + DoubleToString(price, _Digits) +
                        " Lot: " + DoubleToString(lot, 2) +
                        " Profit: " + DoubleToString(profit, 2));

    // Move the existing horizontal line to the new price
    ObjectMove(0, lineName, 0, 0, price);

  } else {
    // Create a new horizontal line
    if (!ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price)) {
      Print("Failed to create horizontal line. Error: ", GetLastError());
      return;
    }

    // Set line properties
    ObjectSetInteger(0, lineName, OBJPROP_COLOR, lineColor);
    ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 3);
    ObjectSetInteger(0, lineName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, lineName, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, lineName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, lineName, OBJPROP_ZORDER, 3);
    // ObjectSetString(0, lineName, OBJPROP_TEXT,
    //                 "Price: " + DoubleToString(price, _Digits) +
    //                     " Lot: " + DoubleToString(lot, 2) +
    //                     " Profit: " + DoubleToString(profit, 2));
  }

  string message = "Lot: " + DoubleToString(lot, 2) +
                   " Price: " + DoubleToString(price, _Digits) +
                   " Profit: " + DoubleToString(profit, 2);

  string text;
  string objectName;
  int yDistance;

  if (type == ORDER_TYPE_BUY) {
    text = "Buy: " + message;
    objectName = buyLineName + "Text";
    yDistance = 60;
  } else {
    text = "Sell: " + message;
    objectName = sellLineName + "Text";
    yDistance = 40;
  }

  if (ObjectFind(0, objectName) < 0) {
    ObjectCreate(0, objectName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objectName, OBJPROP_CORNER, Corner);
    ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(0, objectName, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, objectName, OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, yDistance);
    ObjectSetInteger(0, objectName, OBJPROP_COLOR, lineColor);
  }
  ObjectSetString(0, objectName, OBJPROP_TEXT, text);
}

void DrawSummary(double totalProfit) {
   Print("DrawSummary ", totalProfit);

  string text =
      "Total Positions: " + IntegerToString(totalPositions) +
      " Net Lots: " + DoubleToString(totalBuyLots - totalSellLots, 2) +
      " Profit: " + DoubleToString(totalProfit, 2);

  string objectName = "summaryText";

  if (ObjectFind(0, objectName) < 0) {
    ObjectCreate(0, objectName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objectName, OBJPROP_CORNER, Corner);
    ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(0, objectName, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, objectName, OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, 20);
    ObjectSetInteger(0, objectName, OBJPROP_COLOR, Yellow);
  }
  ObjectSetString(0, objectName, OBJPROP_TEXT, text);
}