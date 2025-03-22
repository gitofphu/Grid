//+------------------------------------------------------------------+
//|                                                  test_bundle.mq5 |
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
  double maxPrice = 80;
  double minPrice = 65;
  double gridGap = 1;
  double lot = 0.01;

  Print("maxPrice: ", maxPrice, ", minPrice: ", minPrice,
        ", gridGap: ", gridGap, ", lot: ", lot);

  CArrayDouble prices;
  CArrayDouble tps;

  for (double i = minPrice; i < maxPrice; i += gridGap) {
    for (double j = i + gridGap; j <= maxPrice; j += gridGap) {
      prices.Add(Utility.NormalizeDoubleTwoDigits(i));
      tps.Add(Utility.NormalizeDoubleTwoDigits(j));
    }
  }

  Print("prices: ", prices.Total());

  for (int i = 0; i < prices.Total(); i++) {
    Print("price: ", prices[i], ", tp: ", tps[i]);
  }
}
//+------------------------------------------------------------------+