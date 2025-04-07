//+------------------------------------------------------------------+
//|                                           checkBuyBundleSize.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
input int LimitOrders = NULL; // Limit orders
input double Banalce = 100;   // Balance
input double Lot = 0.01;      // Lot size
input double MaxPrice = 80;   // Max price
input double MinPrice = 0;    // Min price

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int limitOrders = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  if (Banalce == NULL || Lot == NULL || MaxPrice == NULL) {
    Utility.AlertAndExit("All parameters are required.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  const int accoutnLimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (LimitOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (LimitOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("LimitOrders must be less than ACCOUNT_LIMIT_ORDERS.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  for (double gapSize = 0.01;
       gapSize <= Utility.NormalizeDoubleTwoDigits(MaxPrice - MinPrice);
       gapSize = Utility.NormalizeDoubleTwoDigits(gapSize + 0.01)) {

    int numberOrders =
        Utility.GetBundleNumberOfPossibleOrders(MinPrice, MaxPrice, gapSize);

    if (numberOrders > limitOrders)
      continue;

    CArrayDouble Prices;
    CArrayDouble TPs;

    for (double i = MinPrice; i <= MaxPrice;
         i = Utility.NormalizeDoubleTwoDigits(i + gapSize)) {

      double entry = i == 0 ? _Point : i;

      for (double j = i + gapSize; j <= MaxPrice;
           j = Utility.NormalizeDoubleTwoDigits(j + gapSize)) {

        Prices.Add(Utility.NormalizeDoubleTwoDigits(entry));
        TPs.Add(Utility.NormalizeDoubleTwoDigits(j));
      }
    }

    if (Prices.Total() == 1)
      break;

    double maximumDrawdown = 0;

    for (int i = 0; i < Prices.Total(); i++) {
      // Print("Price: ", Prices[i], ", TP: ", TPs[i]);

      double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, Lot,
                                                  Prices[i], _Point);

      maximumDrawdown =
          Utility.NormalizeDoubleTwoDigits(maximumDrawdown + loss);
    }

    Print("gapSize: ", gapSize, ", Prices.Total(): ", Prices.Total(),
          ", maximumDrawdown: ", maximumDrawdown);

    Print("+++++++++++++++++++++++++++++++++");
  }

  Utility.AlertAndExit("Test Ended.");

  return (INIT_SUCCEEDED);
}
