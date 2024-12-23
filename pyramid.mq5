//+------------------------------------------------------------------+
//|                                                      pyramid.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

double currentPrice = 70;
double maxPrice = 130;
double minPrice = 60;
double gridGap = 0.5;
double lot = 0.01;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  CArrayDouble arrayPrices;

  for (double price = currentPrice; price > minPrice;
       price = Utility.NormalizeDoubleTwoDigits(price - gridGap)) {
    arrayPrices.Add(Utility.NormalizeDoubleTwoDigits(price));

    double drawdown = 0;

    for (int i = 0; i < arrayPrices.Total(); i++) {
      double loss = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, lot * (i + 1), arrayPrices[i], price);

      Print("From: ", Utility.NormalizeDoubleTwoDigits(arrayPrices[i]),
            ", To: ", Utility.NormalizeDoubleTwoDigits(price),
            ", lot: ", lot * (i + 1),
            ", loss: ", Utility.NormalizeDoubleTwoDigits(loss));

      drawdown = Utility.NormalizeDoubleTwoDigits(drawdown + loss);
    }
    Print("drawdown: ", drawdown);
    Print("-------------------");
  }
}
