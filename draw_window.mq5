//+------------------------------------------------------------------+
//|                                                  draw_window.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#property indicator_separate_window // Use sub-window
#property indicator_buffers 0       // No actual indicator buffers
#property indicator_color1 clrGreen
#property indicator_color2 clrRed

string short_name = "AskBidPrices_" + IntegerToString(rand());

// Initialization function
int OnInit() {
  // Indicator automatically uses sub-window, no need for extra code here

  IndicatorSetString(INDICATOR_SHORTNAME, short_name);

  return (INIT_SUCCEEDED);
}

// OnCalculate function: called on every new tick
int OnCalculate(const int rates_total,     // Total bars
                const int prev_calculated, // Bars previously calculated
                const datetime &time[],    // Time array
                const double &open[],      // Open prices array
                const double &high[],      // High prices array
                const double &low[],       // Low prices array
                const double &close[],     // Close prices array
                const long &tick_volume[], // Tick volume array
                const long &volume[],      // Real volume array
                const int &spread[])       // Spread array
{
  // Display the Ask and Bid prices on the chart
  string askText =
      "Ask: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_ASK), 5);
  string bidText =
      "Bid: " + DoubleToString(SymbolInfoDouble(_Symbol, SYMBOL_BID), 5);

  // We know it's in the first sub-window (sub-window 1)
  int subWindow = ChartWindowFind(0, short_name);

  // Create and update the Ask price label in the sub-window (chart_id = 0,
  // sub_window = 1)
  if (ObjectFind(0, "AskText") < 0) // chart_id = 0, dynamic sub-window
  {
    ObjectCreate(0, "AskText", OBJ_LABEL, subWindow, 0,
                 0); // Use sub-window = 1
    ObjectSetInteger(0, "AskText", OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, "AskText", OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, "AskText", OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, "AskText", OBJPROP_YDISTANCE, 20);
    ObjectSetInteger(0, "AskText", OBJPROP_COLOR, clrGreen);
  }
  ObjectSetString(0, "AskText", OBJPROP_TEXT, askText);

  // Create and update the Bid price label in the sub-window (chart_id = 0,
  // sub_window = 1)
  if (ObjectFind(0, "BidText") < 0) // chart_id = 0, dynamic sub-window
  {
    ObjectCreate(0, "BidText", OBJ_LABEL, subWindow, 0,
                 0); // Use sub-window = 1
    ObjectSetInteger(0, "BidText", OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, "BidText", OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, "BidText", OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, "BidText", OBJPROP_YDISTANCE, 40);
    ObjectSetInteger(0, "BidText", OBJPROP_COLOR, clrRed);
  }
  ObjectSetString(0, "BidText", OBJPROP_TEXT, bidText);

  return (rates_total);
}