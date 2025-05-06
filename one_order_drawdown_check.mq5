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

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  double entryPrice = 57; // Entry price for the order
  double minPrice = 0.01; // Minimum price for the order
  double lotSize = 0.01;  // Lot size for the order

  double volumeMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  Print("volumeMin: ", volumeMin);

  double volumeStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
  Print("volumeStep: ", volumeStep);

  Print("FreeMargin: ", cAccountInfo.FreeMargin(),
        " ,MarginLevel: ", cAccountInfo.MarginLevel(),
        " ,Margin: ", cAccountInfo.Margin());

  double marginRequire =
      cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY, lotSize, entryPrice);
  Print("marginRequire: ", marginRequire);

  double freeMarginCheck = cAccountInfo.FreeMarginCheck(_Symbol, ORDER_TYPE_BUY,
                                                        lotSize, entryPrice);
  Print("freeMarginCheck: ", freeMarginCheck);

  double profit10 = cAccountInfo.OrderProfitCheck(
      _Symbol, ORDER_TYPE_BUY, lotSize, entryPrice,
      Utility.NormalizeDoubleTwoDigits(entryPrice + 10));
  Print("profit10: ", profit10);

  double drawdown = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
                                                  lotSize, entryPrice, 0.1);
  Print("drawdown: ", drawdown, ", total drawdown: ",
        Utility.NormalizeDoubleTwoDigits(drawdown - marginRequire));

  Utility.AlertAndExit("Test Ended.");

  return (INIT_SUCCEEDED);
}
