//+------------------------------------------------------------------+
//|                         current_position_drawdown_check_sell.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include "./Utility.mqh"
MyUtility Utility;

struct PriceVolume {
  double price;
  double volume;
};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {

  PriceVolume data[];

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);
      double positionVolume = PositionGetDouble(POSITION_VOLUME);

      if (symbol != _Symbol || positionType != POSITION_TYPE_BUY)
        continue;

      Print("positionPrice: ", positionPrice,
            ", positionVolume: ", positionVolume);

      PriceVolume item;
      item.price = positionPrice;
      item.volume = positionVolume;
      ArrayResize(data, ArraySize(data) + 1);
      data[ArraySize(data) - 1] = item;
    }
  }

  double price = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double gridGap = 0.1;

  double balance = cAccountInfo.Balance();
  double totalDrawdown = 0;

  double totalProfit = 0;
  double sellLot = 0.1;

  do {

    double drawdown = 0;

    for (int i = 0; i < ArraySize(data); i++) {
      double loss = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, data[i].volume, data[i].price, price);

      drawdown = Utility.NormalizeDoubleTwoDigits(drawdown + loss);
    }

    double profit = cAccountInfo.OrderProfitCheck(
        _Symbol, ORDER_TYPE_SELL, sellLot, price + gridGap, price);

    Print("price: ", price, ", drawdown: ", drawdown, ", profit: ", profit);

    totalDrawdown = Utility.NormalizeDoubleTwoDigits(drawdown);
    price = Utility.NormalizeDoubleTwoDigits(price - gridGap);
    totalProfit = Utility.NormalizeDoubleTwoDigits(totalProfit + profit);
  } while (balance + totalDrawdown + totalProfit > 0 && price > 0);

  Print("balance: ", balance, ", totalDrawdown: ", totalDrawdown,
        ", totalProfit: ", totalProfit);
}
//+------------------------------------------------------------------+