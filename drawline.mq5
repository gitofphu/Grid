//+------------------------------------------------------------------+
//|                                                     drawline.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <ChartObjects/ChartObject.mqh>
CChartObject object;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  double CurrentPrice = 80;
  double MinPrice = 70;
  double PriceRange = 1;

  CArrayDouble ArrayPrices;
  Utility.GetArrayPrice(MinPrice, CurrentPrice, PriceRange, ArrayPrices);

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);

    ObjectCreate(0, "My_Line_" + ArrayPrices[i], OBJ_HLINE, 0, 0,
                 ArrayPrices[i]);
  }
}
