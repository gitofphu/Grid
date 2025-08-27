//+------------------------------------------------------------------+
//|                                              RealiazeBalance.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
input color RealizeBalancePositiveColor =
    clrSpringGreen; // Realize Balance Positive Color
input color RealizeBalanceNegativeColor =
    clrRed; // Realize Balance Negative Color
input ENUM_BASE_CORNER Corner = CORNER_RIGHT_LOWER; // corner

ENUM_BASE_CORNER corner = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (Corner == corner) {
    Print("Parameters are already set.");
    return (INIT_SUCCEEDED);
  }

  corner = Corner;

  DrawSummary();

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  if (reason != REASON_CHARTCHANGE)
    ClearSummary();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
  DrawSummary();
}

//+------------------------------------------------------------------+

void DrawSummaryObject(string objectName, string text, int yDistance,
                       ENUM_ANCHOR_POINT anchor, long textColor) {

  if (ObjectFind(0, objectName) < 0) {
    ObjectCreate(0, objectName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objectName, OBJPROP_CORNER, corner);
    ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(0, objectName, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, objectName, OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, yDistance);
    ObjectSetInteger(0, objectName, OBJPROP_COLOR, textColor);
  }
  ObjectSetString(0, objectName, OBJPROP_TEXT, text);
}

void DrawSummary() {
  Print("Drawing summary...");

  ClearSummary();

  ENUM_ANCHOR_POINT anchor;

  switch (corner) {
  case CORNER_LEFT_UPPER:
    anchor = ANCHOR_LEFT_UPPER;
    break;
  case CORNER_LEFT_LOWER:
    anchor = ANCHOR_LEFT_LOWER;
    break;
  case CORNER_RIGHT_UPPER:
    anchor = ANCHOR_RIGHT_UPPER;
    break;
  default:
    anchor = ANCHOR_RIGHT_LOWER;
    break;
  }

  CArrayString objectNames;
  CArrayString texts;
  CArrayLong colors;

  double equity = Utility.GetRealizeBalance();
  string balanceText = "";

  if (equity > 0) {
    balanceText = "Balance is surplus by " + DoubleToString(equity, 2);
  } else {
    balanceText = "Balance is short of by " + DoubleToString(equity, 2);
  }

  texts.Add(balanceText);
  objectNames.Add("Balance_Summary");
  colors.Add(equity > 0 ? RealizeBalancePositiveColor
                        : RealizeBalanceNegativeColor);

  switch (corner) {
  case CORNER_LEFT_UPPER:
  case CORNER_RIGHT_UPPER:
    for (int i = 0; i < objectNames.Total(); i++) {
      DrawSummaryObject(objectNames[i], texts[i], (i * 25) + 25, anchor,
                        colors[i]);
    }
    break;
  case CORNER_LEFT_LOWER:
  case CORNER_RIGHT_LOWER:
    for (int i = 0, yDistance = objectNames.Total() * 25;
         i < objectNames.Total(); i++, yDistance -= 25) {
      DrawSummaryObject(objectNames[i], texts[i], yDistance, anchor, colors[i]);
    }
    break;
  }

  ChartRedraw();
}

void ClearSummary() {
  ObjectDelete(0, "Balance_Summary");

  ChartRedraw();
}
