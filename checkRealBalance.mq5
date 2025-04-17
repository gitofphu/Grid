//+------------------------------------------------------------------+
//|                                             checkRealBalance.mq5 |
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

  double maximumDrawdown = 0;

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {

      string symbol = PositionGetString(POSITION_SYMBOL);

      if (symbol != _Symbol) {
        continue;
      }

      long positionType = PositionGetInteger(POSITION_TYPE);

      string positionComment = PositionGetString(POSITION_COMMENT);

      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double positionVolume = PositionGetDouble(POSITION_VOLUME);
      double positionTP = PositionGetDouble(POSITION_TP);

      if (positionType != POSITION_TYPE_BUY)
        continue;

      double drawdown = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, positionVolume, positionPrice, _Point);

      double marginRequire = cAccountInfo.MarginCheck(
          _Symbol, ORDER_TYPE_BUY, positionVolume, positionPrice);

      maximumDrawdown = Utility.NormalizeDoubleTwoDigits(
          maximumDrawdown + drawdown - marginRequire);
    }
  }

  Print("maximumDrawdown: ", Utility.NumberToString(maximumDrawdown, 2));

  Utility.AlertAndExit("Test Ended.");

  return (INIT_SUCCEEDED);
}
