//+------------------------------------------------------------------+
//|                                     one_order_drawdown_check.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

input double entryPrice = NULL;
input double TPPrice = NULL;
input double minPrice = 0.01;
input double lotSize = 0.01;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (entryPrice == NULL || TPPrice == NULL) {
    Utility.AlertAndExit("entryPrice and TPPrice cannot be NULL.");
    return (INIT_PARAMETERS_INCORRECT);
  }
  if (minPrice < _Point) {
    Utility.AlertAndExit("minPrice cannot be less than _Point.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (lotSize < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
    Utility.AlertAndExit("lotSize cannot be less than SYMBOL_VOLUME_MIN.");
    return (INIT_PARAMETERS_INCORRECT);
  }
  if (lotSize > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX)) {
    Utility.AlertAndExit("lotSize cannot be greater than SYMBOL_VOLUME_MAX.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (entryPrice < minPrice) {
    Utility.AlertAndExit("entryPrice cannot be less than minPrice.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  Print("volumeMin: ", volumeMin);

  double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
  Print("volumeStep: ", volumeStep);

  double profit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
                                                lotSize, entryPrice, TPPrice);
  Print("profit: ", profit);

  double drawdown = cAccountInfo.OrderProfitCheck(
      _Symbol, ORDER_TYPE_BUY, lotSize, entryPrice, minPrice);
  Print("drawdown: ", drawdown);

  Utility.AlertAndExit("Test Ended.");

  return (INIT_SUCCEEDED);
}
