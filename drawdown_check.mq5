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
  double CurrentPrice = 100;
  double MinPrice = 0.01;
  double GridGapSize = 10;
  double lotPerGrid = 0.01;
  double balance = 1000;

  CArrayDouble ArrayPrices;
  Utility.GetArrayPrice(MinPrice, CurrentPrice, GridGapSize, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  // for (int i = 0; i < ArrayPrices.Total(); i++) {
  //   Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  // }

  Print("------------------------------------");

  for (int i = 0; i < ArrayPrices.Total(); i++) {

    double drawdown = 0;

    for (int j = 0; j < ArrayPrices.Total(); j++) {
      // Print("i: ", ArrayPrices[i], ", j: ", ArrayPrices[j]);

      if (ArrayPrices[i] <= ArrayPrices[j])
        continue;

      double loss = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, lotPerGrid, ArrayPrices[i], ArrayPrices[j]);

      double marginRequire = cAccountInfo.MarginCheck(
          _Symbol, ORDER_TYPE_BUY, lotPerGrid, ArrayPrices[j]);

      Print("loss: ", loss, ", marginRequire: ", marginRequire);

      Print("From ", ArrayPrices[i], " to ", ArrayPrices[j], " loss ",
            NormalizeDouble(loss + 0, 2));

      drawdown = NormalizeDouble(drawdown + NormalizeDouble(loss - 0, 2), 2);

      double equity = NormalizeDouble(balance + drawdown, 2);

      Print("balance: ", balance);
      Print("equity: ", equity);
      Print("drawdown: ", drawdown);
      Print("------------------------------------");

      if (balance + drawdown <= 0)
        break;
    }

    Print("total drawdown: ", drawdown);
    Print("++++++++++++++++++++++++++++++++++++");

    if (balance + drawdown <= 0)
      break;
  }
}
