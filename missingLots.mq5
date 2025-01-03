//+------------------------------------------------------------------+
//|                                                  missingLots.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

input double GridGapSize = 0.1;
input double GridRange = 10;
input int MaxOrders = NULL;
input double LotSize = 0.03;

CArrayDouble ArrayPrices;
string comment = "dynamic_grid";

#include <Generic/HashMap.mqh>

struct PriceVolume {
  double price;
  double volume;
};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  Print("OnInit");

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double currentPrice = MathRound(NormalizeDouble((ask + bid) / 2, _Digits));
  Print("currentPrice: ", currentPrice);

  double maxPrice =
      NormalizeDouble(currentPrice + (GridGapSize * GridRange), _Digits);
  double minPrice =
      NormalizeDouble(currentPrice - (GridGapSize * GridRange) > _Point
                          ? currentPrice - (GridGapSize * GridRange)
                          : _Point,
                      _Digits);

  Print("maxPrice: ", maxPrice);
  Print("minPrice: ", minPrice);

  if (ArrayPrices.Total() == 0)
    Utility.GetArrayPrice(minPrice, maxPrice, GridGapSize, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  PriceVolume buyLimitPrices[];
  PriceVolume buyStopPrices[];

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double positionVolume = PositionGetDouble(POSITION_VOLUME);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);

      if (positionComment != comment || symbol != _Symbol ||
          positionType != POSITION_TYPE_BUY)
        continue;

      Print("positionPrice: ", positionPrice);
      Print("positionVolume: ", positionVolume);
      Print("LotSize: ", LotSize);

      getMisMatchDeals(ArrayPrices, GridGapSize, positionPrice, positionVolume,
                       LotSize, buyLimitPrices, buyStopPrices);
    }
  }

  for (int i = 0; i < ArraySize(buyLimitPrices); i++) {
    Print("buyLimitPrices Price: ", buyLimitPrices[i].price,
          ", Volume: ", buyLimitPrices[i].volume);
  }
  for (int i = 0; i < ArraySize(buyStopPrices); i++) {
    Print("buyStopPrices Price: ", buyStopPrices[i].price,
          ", Volume: ", buyStopPrices[i].volume);
  }
}
//+------------------------------------------------------------------+

void getMisMatchDeals(CArrayDouble &arrayPrices, double gridGapSize,
                      double price, double volume, double lotSize,
                      PriceVolume &buyLimitPrices[],
                      PriceVolume &buyStopPrices[]) {

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  for (int j = 0; j < arrayPrices.Total(); j++) {
    if (price >= arrayPrices[j] &&
        price <= arrayPrices[j] + gridGapSize - _Point) {

      if (volume < lotSize) {
        PriceVolume item;
        item.price = arrayPrices[j];
        item.volume = Utility.NormalizeDoubleTwoDigits(lotSize - volume);

        if (arrayPrices[j] < ask) {
          ArrayResize(buyLimitPrices, ArraySize(buyLimitPrices) + 1);
          buyLimitPrices[ArraySize(buyLimitPrices) - 1] = item;
        }
        if (arrayPrices[j] > ask) {
          ArrayResize(buyStopPrices, ArraySize(buyStopPrices) + 1);
          buyStopPrices[ArraySize(buyStopPrices) - 1] = item;
        }
      }
    }
  }
}