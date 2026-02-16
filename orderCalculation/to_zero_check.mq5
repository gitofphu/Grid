//+------------------------------------------------------------------+
//|                                                to_zero_check.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include "../Utility.mqh"
MyUtility Utility;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  // double totalDrawdown = 0;

  // for (int i = 0; i < PositionsTotal(); i++) {
  //   ulong positionTicket = PositionGetTicket(i);
  //   if (PositionSelectByTicket(positionTicket)) {
  //     double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
  //     string symbol = PositionGetString(POSITION_SYMBOL);
  //     long positionType = PositionGetInteger(POSITION_TYPE);
  //     double positionVolume = PositionGetDouble(POSITION_VOLUME);

  //     if (symbol != _Symbol || positionType != POSITION_TYPE_BUY)
  //       continue;

  //     double drawdown = cAccountInfo.OrderProfitCheck(
  //         _Symbol, ORDER_TYPE_BUY, positionVolume, positionPrice, _Point);

  //     Print("positionPrice: ", positionPrice,
  //           ", positionVolume: ", positionVolume, ", drawdown: ", drawdown);

  //     totalDrawdown =
  //         Utility.NormalizeDoubleTwoDigits(totalDrawdown + drawdown);
  //   }
  // }

  // double balance = cAccountInfo.Balance();

  // Print("balance: ", balance);

  // Print("totalDrawdown: ", totalDrawdown);

  // double equity = Utility.NormalizeDoubleTwoDigits(balance + totalDrawdown);

  double equity = Utility.GetRealizeBalance();

  if (equity > 0) {
    Print("Balance is surlplus by: ", DoubleToString(equity, 2));
  } else {
    Print("Balance is short of by: ", DoubleToString(equity, 2));
  }

  Print("*margin require are not include in this calculation.");

  Utility.AlertAndExit("Script Ended.");

  return (INIT_SUCCEEDED);
}
