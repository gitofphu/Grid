//+------------------------------------------------------------------+
//|                                                test_script_4.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

double currentPrice = 74;
double maxPrice = 80;
double minPrice = 60;
double gridGap = 0.1;
double lot = 0.01;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  Print("currentPrice: ", currentPrice, ", maxPrice: ", maxPrice,
        ", minPrice: ", minPrice, ", gridGap: ", gridGap, ", lot: ", lot);

  // UpTrendCheck();
  DownTrendCheck();
}
//+------------------------------------------------------------------+

void UpTrendCheck() {
  CArrayDouble arrayPrices;

  for (double price = currentPrice; price < maxPrice;
       price = Utility.NormalizeDoubleTwoDigits(price + gridGap)) {
    arrayPrices.Add(Utility.NormalizeDoubleTwoDigits(price));

    double drawdown = 0;

    for (int i = 0; i < arrayPrices.Total(); i++) {
      double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_SELL, lot,
                                                  arrayPrices[i], price);

      // Print("From: ", Utility.NormalizeDoubleTwoDigits(arrayPrices[i]),
      //       ", To: ", Utility.NormalizeDoubleTwoDigits(price),
      //       ", loss: ", Utility.NormalizeDoubleTwoDigits(loss));

      drawdown = Utility.NormalizeDoubleTwoDigits(drawdown + loss);
    }

    Print("price: ", price);
    Print("drawdown: ", drawdown);
    Print("-------------------");
  }
}

void DownTrendCheck() {
  CArrayDouble arrayPrices;

  for (double price = currentPrice; price > minPrice;
       price = Utility.NormalizeDoubleTwoDigits(price - gridGap)) {
    arrayPrices.Add(Utility.NormalizeDoubleTwoDigits(price));

    double drawdown = 0;

    for (int i = 0; i < arrayPrices.Total(); i++) {

      double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lot,
                                                  arrayPrices[i], price);

      // Print("From: ", Utility.NormalizeDoubleTwoDigits(arrayPrices[i]),
      //       ", To: ", Utility.NormalizeDoubleTwoDigits(price),
      //       ", loss: ", Utility.NormalizeDoubleTwoDigits(loss));

      drawdown = Utility.NormalizeDoubleTwoDigits(drawdown + loss);
    }

    Print("price: ", price);
    Print("drawdown: ", drawdown);
    Print("-------------------");
  }
}