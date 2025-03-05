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

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

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
double averageBuyPrice = NULL;
double totalBuyLots = NULL;
input color averageBuyPriceColor = clrGreen; // Buy Color
double averageSellPrice = NULL;
double totalSellLots = NULL;
input color averageSellPriceColor = clrRed; // Sell Color

color AverageBuyPriceColor = NULL;
color AverageSellPriceColor = NULL;
string buyLineName = "averageBuyPrice";
string sellLineName = "averageSellPrice";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  Print("Alert initialized");

  if (AverageBuyPriceColor == averageBuyPriceColor &&
      AverageSellPriceColor == averageSellPriceColor)
    return (INIT_SUCCEEDED);

  AverageBuyPriceColor = averageBuyPriceColor;
  AverageSellPriceColor = averageSellPriceColor;

  ReCalculateAveragePrice();

  return (INIT_SUCCEEDED);
}

void OnTick() {

  if (drawAveragePrice) {

    if (averageBuyPrice == NULL || totalBuyLots == NULL ||
        averageSellPrice == NULL || totalSellLots == NULL)
      return;

    double buyProfit = cAccountInfo.OrderProfitCheck(
        _Symbol, ORDER_TYPE_BUY, totalBuyLots, averageBuyPrice,
        SymbolInfoDouble(_Symbol, SYMBOL_BID));

    DrawHorizontalLine(averageBuyPrice, buyLineName, AverageBuyPriceColor,
                       totalSellLots, buyProfit);

    double sellProfit = cAccountInfo.OrderProfitCheck(
        _Symbol, ORDER_TYPE_SELL, totalSellLots, averageSellPrice,
        SymbolInfoDouble(_Symbol, SYMBOL_ASK));

    DrawHorizontalLine(averageSellPrice, sellLineName, AverageSellPriceColor,
                       totalSellLots, sellProfit);
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

  if (drawAveragePrice) {
    // Delete the horizontal line
    ObjectDelete(0, buyLineName);
    ObjectDelete(0, sellLineName);
  }
}

//+------------------------------------------------------------------+

void ReCalculateAveragePrice() {
  if (drawAveragePrice) {
    Utility.GetAveragePriceAndLots(averageBuyPrice, totalBuyLots,
                                   averageSellPrice, totalSellLots);
  }
}

void DrawHorizontalLine(double price, string lineName, color lineColor,
                        double lot, double profit) {

  // Print("Price: " + price + ", LineName: " + lineName +
  //       ", LineColor: " + lineColor + ", Lot: " + lot + ", Profit: " +
  //       profit);

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
    ObjectSetString(0, lineName, OBJPROP_TEXT,
                    "Price: " + DoubleToString(price, _Digits) +
                        " Lot: " + DoubleToString(lot, 2) +
                        " Profit: " + DoubleToString(profit, 2));
  }

  ChartRedraw(); // Refresh the chart
}
