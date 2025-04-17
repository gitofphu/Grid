//+------------------------------------------------------------------+
//|                                       checkBuyBundleDrawdown.mq5 |
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
input double Lot = 0.01;      // Lot size
input double MaxPrice = 80;   // Max price
input double MinPrice = 0;    // Min price
input double gapSize = 5;     // Gap size

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
int limitOrders = NULL;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  if (Lot == NULL || MaxPrice == NULL) {
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

  Print("LimitOrders: ", limitOrders, ", Lot: ", Lot, ", MaxPrice: ", MaxPrice,
        ", MinPrice: ", MinPrice);

  int numberOrders =
      Utility.GetBundleNumberOfPossibleOrders(MinPrice, MaxPrice, gapSize);

  Print("numberOrders: ", numberOrders, ", limitOrders: ", limitOrders);

  if (numberOrders > limitOrders) {
    Utility.AlertAndExit("numberOrders exceeded limitOrders.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  CArrayDouble PricesBelowAsk;
  CArrayDouble TPsBelowAsk;
  CArrayDouble PricesAboveAsk;
  CArrayDouble TPsAboveAsk;

  for (double i = MinPrice; i <= MaxPrice;
       i = Utility.NormalizeDoubleTwoDigits(i + gapSize)) {

    double entry = i == 0 ? _Point : i;

    for (double j = i + gapSize; j <= MaxPrice;
         j = Utility.NormalizeDoubleTwoDigits(j + gapSize)) {

      if (entry > ask) {
        PricesAboveAsk.Add(Utility.NormalizeDoubleTwoDigits(entry));
        TPsAboveAsk.Add(Utility.NormalizeDoubleTwoDigits(j));
      } else {
        PricesBelowAsk.Add(Utility.NormalizeDoubleTwoDigits(entry));
        TPsBelowAsk.Add(Utility.NormalizeDoubleTwoDigits(j));
      }
    }
  }

  Print("PricesAboveAsk.Total(): ", PricesAboveAsk.Total());

  for (int i = 0; i < PricesAboveAsk.Total(); i++) {
    Print("Price: ", PricesAboveAsk[i], ", TP: ", TPsAboveAsk[i]);
  }

  Print("PricesBelowAsk.Total(): ", PricesBelowAsk.Total());

  double maximumDrawdown = 0;

  for (int i = 0; i < PricesBelowAsk.Total(); i++) {
    Print("Price: ", PricesBelowAsk[i], ", TP: ", TPsBelowAsk[i]);

    double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, Lot,
                                                PricesBelowAsk[i], _Point);

    maximumDrawdown = Utility.NormalizeDoubleTwoDigits(maximumDrawdown + loss);
  }

  Print("gapSize: ", gapSize, ", Ask: ", ask,
        ", PricesBelowAsk.Total(): ", PricesBelowAsk.Total(),
        ", maximumDrawdown: ", maximumDrawdown);

  Print("+++++++++++++++++++++++++++++++++");

  Utility.AlertAndExit("Test Ended.");

  return (INIT_SUCCEEDED);
}
