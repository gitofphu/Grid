//+------------------------------------------------------------------+
//|                                           test_lot_and_range.mq5 |
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
  double MaxPrice = 70;
  double MinPrice = 0;
  double PriceRange = 10;
  double lotPerGrid = 0.01;
  double balance = 1000;

  CArrayDouble ArrayPrices;
  Utility.GetArrayPrice(MinPrice, MaxPrice, PriceRange, ArrayPrices);

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  Print("------------------------------------");

  for (int i = ArrayPrices.Total() - 1; i >= 0; i--) {
    Print("Current price", i, " = ", ArrayPrices[i]);

    if (i == ArrayPrices.Total() - 1)
      continue;

    double drawdown = 0;

    for (int j = ArrayPrices.Total() - 1; j > i; j--) {
      double profit = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, lotPerGrid, ArrayPrices[j], ArrayPrices[i]);

      double marginRequire = cAccountInfo.MarginCheck(
          _Symbol, ORDER_TYPE_BUY, lotPerGrid, ArrayPrices[j]);

      Print("From ", ArrayPrices[j], " to ", ArrayPrices[i], " profit ",
            NormalizeDouble(profit + marginRequire, 2));

      drawdown = NormalizeDouble(
          drawdown + NormalizeDouble(profit + marginRequire, 2), 2);

      if (balance + drawdown <= 0)
        break;
    }

    Print("drawdown: ", drawdown);
    Print("------------------------------------");

    if (balance + drawdown <= 0)
      break;
  }
}
