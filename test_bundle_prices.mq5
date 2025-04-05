//+------------------------------------------------------------------+
//|                                           test_bundle_prices.mq5 |
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

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double maxPrice = 100;
  double minPrice = 0;
  double gapSize = 5;

  double priceRange = 20;

  double maxTPSize = 10;

  Print("ask: ", ask, ", bid: ", bid, ", maxPrice: ", maxPrice,
        ", minPrice: ", minPrice, ", gapSize: ", gapSize,
        ", priceRange: ", priceRange);

  CArrayDouble buyStopPrices;
  CArrayDouble buyStopTPs;
  CArrayDouble buyLimitPrices;
  CArrayDouble buyLimitTPs;
  CArrayDouble sellLimitPrices;
  CArrayDouble sellLimitTPs;
  CArrayDouble sellStopPrices;
  CArrayDouble sellStopTPs;

  for (double i = minPrice; i <= maxPrice; i += gapSize) {

    if (i < ask || i > ask + priceRange)
      continue;

    double entry = i == 0 ? _Point : i;

    for (double j = i + gapSize; j <= maxPrice; j += gapSize) {

      if (j > entry + maxTPSize)
        break;

      buyStopPrices.Add(Utility.NormalizeDoubleTwoDigits(entry));
      buyStopTPs.Add(Utility.NormalizeDoubleTwoDigits(j));
    }
  }

  for (double i = minPrice; i <= maxPrice; i += gapSize) {

    if (i > bid || i < bid - priceRange)
      continue;

    double entry = i == 0 ? _Point : i;

    for (double j = i + gapSize; j <= maxPrice; j += gapSize) {

      if (j > entry + maxTPSize)
        break;

      buyLimitPrices.Add(Utility.NormalizeDoubleTwoDigits(entry));
      buyLimitTPs.Add(Utility.NormalizeDoubleTwoDigits(j));
    }
  }

  for (double i = maxPrice; i > minPrice; i -= gapSize) {

    if (i < ask || i > ask + priceRange)
      continue;

    for (double j = i - gapSize; j >= minPrice; j -= gapSize) {

      double tp = j == 0 ? _Point : j;

      if (tp < i - maxTPSize)
        break;

      sellLimitPrices.Add(Utility.NormalizeDoubleTwoDigits(i));
      sellLimitTPs.Add(Utility.NormalizeDoubleTwoDigits(tp));
    }
  }

  for (double i = maxPrice; i > minPrice; i -= gapSize) {

    if (i > bid || i < bid - priceRange)
      continue;

    for (double j = i - gapSize; j >= minPrice; j -= gapSize) {

      double tp = j == 0 ? _Point : j;

      if (tp < i - maxTPSize)
        break;

      sellStopPrices.Add(Utility.NormalizeDoubleTwoDigits(i));
      sellStopTPs.Add(Utility.NormalizeDoubleTwoDigits(tp));
    }
  }

  for (int i = 0; i < buyStopPrices.Total(); i++) {
    Print("buyStopPrices: ", i, " = ", buyStopPrices[i],
          ", TP: ", buyStopTPs[i]);
  }

  for (int i = 0; i < buyLimitPrices.Total(); i++) {
    Print("buyLimitPrices: ", i, " = ", buyLimitPrices[i],
          ", TP: ", buyLimitTPs[i]);
  }

  for (int i = 0; i < sellLimitPrices.Total(); i++) {
    Print("sellLimitPrices: ", i, " = ", sellLimitPrices[i],
          ", TP: ", sellLimitTPs[i]);
  }

  for (int i = 0; i < sellStopPrices.Total(); i++) {
    Print("sellStopPrices: ", i, " = ", sellStopPrices[i],
          ", TP: ", sellStopTPs[i]);
  }
}
