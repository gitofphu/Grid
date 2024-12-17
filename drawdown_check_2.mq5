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

  CArrayDouble ArrayPrices;
  Utility.GetArrayPrice(MinPrice, CurrentPrice, GridGapSize, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    // Print("i: ", ArrayPrices[i]);

    double balance = 100;
    double drawdown = 0;

    for (int j = 0; j <= i; j++) {
      // Print("j: ", ArrayPrices[j]);

      double profit = 0;

      if (i - j == 1) {
        profit =
            cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_SELL, lotPerGrid,
                                          ArrayPrices[j], ArrayPrices[i]);
      }

      double loss = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, lotPerGrid, ArrayPrices[j], ArrayPrices[i]);

      double marginRequire = cAccountInfo.MarginCheck(
          _Symbol, ORDER_TYPE_BUY, lotPerGrid, ArrayPrices[i]);

      marginRequire = 0;

      // Print("profit: ", profit, ", loss: ", loss,
      //       ", marginRequire: ", marginRequire);

      Print("From ", ArrayPrices[j], " to ", ArrayPrices[i], " drawdown ",
            NormalizeDouble(loss - marginRequire, 2));

      balance = NormalizeDouble(balance + profit, 2);

      drawdown = NormalizeDouble(drawdown + loss - marginRequire, 2);

      // double equity = NormalizeDouble(balance + drawdown, 2);
      // Print("balance: ", balance);
      // Print("equity: ", equity);
      // Print("drawdown: ", drawdown);
      Print("------------------------------------");

      // if (balance + drawdown <= 0)
      //   break;
    }

    double equity = NormalizeDouble(balance + drawdown, 2);
    Print("balance: ", balance);
    Print("equity: ", equity);
    Print("drawdown: ", drawdown);
    Print("++++++++++++++++++++++++++++++++++++");

    // if (balance + drawdown <= 0)
    //   break;
  }
}
