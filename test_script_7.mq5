//+------------------------------------------------------------------+
//|                                                test_script_7.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;


//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  CArrayDouble ArrayPrices;

  const double priceGap = 1;
  const double maxPrice = 60;
  const double priceRange = 10;
  const double minPrice = 50;

  Utility.GetArrayPrice(minPrice, minPrice + priceRange, priceGap, ArrayPrices);

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }

  const double currentPrice = 45;

  Print("Current Price: ", currentPrice);

  double lastPrice = ArrayPrices[ArrayPrices.Total() - 1];

  Print("Last Price: ", lastPrice);

  if (lastPrice - currentPrice >= priceGap) {
    Utility.GetArrayPrice(currentPrice, currentPrice + priceRange, priceGap,
                          ArrayPrices);
  }

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }
}
//+------------------------------------------------------------------+