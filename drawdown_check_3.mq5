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
  Print("OnStart");
  double currentPrice = 100;
  double priceGap = 10;
  double lotPerGrid = 0.01;

  double balance = 100;
  double drawdown = 0;

  double lastPrice = balance;

  // down trend
  for (double j = currentPrice; j >= 0; j -= priceGap) {

    if (j >= currentPrice)
      continue;

    if (j == 0) {
      j = _Point;
    }

    Print("currentPrice: ", currentPrice, ", lastPrice: ", lastPrice,
          " j: ", j);

    double profit = 0;

    if (lastPrice > j) {
      // balance += 10;
      profit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_SELL,
                                             lotPerGrid, lastPrice, j);
    }
    lastPrice = j;

    double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
                                                lotPerGrid, currentPrice, j);

    double marginRequire = cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY,
                                                    lotPerGrid, currentPrice);

    Print("profit: ", profit, ", loss: ", loss,
          ", marginRequire: ", marginRequire);

    // Print("From ", j, " to ", lastPrice, " drawdown ",
    //       Utility.NormalizeDoubleTwoDigits(loss - marginRequire, 2));

    balance = Utility.NormalizeDoubleTwoDigits(balance + profit);
    drawdown =
        Utility.NormalizeDoubleTwoDigits(drawdown + loss - marginRequire);

    // drawdown -= currentPrice - j;

    double equity = Utility.NormalizeDoubleTwoDigits(balance + drawdown);
    Print("balance: ", balance);
    Print("equity: ", equity);
    Print("drawdown: ", drawdown);
    Print("-----------------------------------");

    if (balance + drawdown <= 0)
      break;
  }

  // for (double price = currentPrice; balance > 0;
  //      price += priceGap, balance -= 10) {
  //   Print("price", price);
  //   Print("balance", balance);
  // }
  // Print("balance", balance);
}
