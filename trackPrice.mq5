//+------------------------------------------------------------------+
//|                                                   trackPrice.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  //---
  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

  string lineName = "BID";

  ObjectDelete(0, lineName);

  double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  // Print("price: ", price);

  DrawHorizontalLineWithText(price);

  //   ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price + 0.0020);

  //   // Set line color to lime
  //   ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrLime);

  //   // Make the line visible
  //   ObjectSetInteger(0, lineName, OBJPROP_RAY_RIGHT, true);
  //   ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2); // Optional: Set line
  //   width ObjectSetInteger(0, lineName, OBJPROP_STYLE,
  //                    STYLE_SOLID); // Optional: Set line style
}

//+------------------------------------------------------------------+

void DrawHorizontalLineWithText(double price) {
  string lineName = "MyHorizontalLine";
  string textName = "MyLineText";

  // Create the horizontal line
  if (!ObjectCreate(0, lineName, OBJ_HLINE, 0, 0, price + 0.0010)) {
    Print("Failed to create horizontal line. Error: ", GetLastError());
    return;
  }

  // Set line properties
  ObjectSetInteger(0, lineName, OBJPROP_COLOR, clrLime);
  ObjectSetInteger(0, lineName, OBJPROP_WIDTH, 2);
  ObjectSetInteger(0, lineName, OBJPROP_STYLE, STYLE_SOLID);

  // Get the current bar's time
  datetime currentTime = TimeCurrent();

  // Determine the next bar's time (1 bar ahead)
  datetime futureTime = currentTime + PeriodSeconds();

  // Create the text label slightly above the line
  if (!ObjectCreate(0, textName, OBJ_TEXT, 0, futureTime, price + 0.0015)) {
    Print("Failed to create text label. Error: ", GetLastError());
    return;
  }

  // Set text properties
  ObjectSetString(0, textName, OBJPROP_TEXT,
                  DoubleToString(price, _Digits)); // Display price
  ObjectSetInteger(0, textName, OBJPROP_COLOR, clrLime);
  ObjectSetInteger(0, textName, OBJPROP_ANCHOR,
                   ANCHOR_BOTTOM); // Position text above the line

  ChartRedraw(); // Refresh the chart
}