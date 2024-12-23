//+------------------------------------------------------------------+
//|                                                test_script_5.mq5 |
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

  double total = 0;

  for (double price = 100, lot = 0.01; price > 0;
       price = Utility.NormalizeDoubleTwoDigits(price - 10),
              lot = Utility.NormalizeDoubleTwoDigits(lot + 0.01)) {
    // Print("price: ", price, ", lot: ", lot);

    double profit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lot,
                                                  price, price + 10);

    Print("From: ", Utility.NormalizeDoubleTwoDigits(price),
          ", To: ", Utility.NormalizeDoubleTwoDigits(price + 10),
          ", lot: ", lot,
          ", profit: ", Utility.NormalizeDoubleTwoDigits(profit));

    total += profit;
  }

  Print("total: ", total);
  Print("-------------------");
}
