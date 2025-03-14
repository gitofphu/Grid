//+------------------------------------------------------------------+
//|                                                 averagePrice.mq5 |
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

  CArrayDouble sellPrices;
  CArrayDouble sellLots;

  CArrayDouble buyPrices;
  CArrayDouble buyLots;

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double positionLots = PositionGetDouble(POSITION_VOLUME);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);

      Print("symbol: ", symbol, " positionPrice: ", positionPrice,
            " positionComment: ", positionComment,
            " positionType: ", positionType, " positionLots: ", positionLots);

      if (symbol != _Symbol)
        continue;

      if (positionType == POSITION_TYPE_BUY) {
        buyPrices.Add(positionPrice);
        buyLots.Add(positionLots);
      } else if (positionType == POSITION_TYPE_SELL) {
        sellPrices.Add(positionPrice);
        sellLots.Add(positionLots);
      }
    }
  }

  double averageBuyPrice = 0;
  double totalBuyLots = 0;
  for (int i = 0; i < buyPrices.Total(); i++) {
    averageBuyPrice += buyPrices[i] * buyLots[i];
    totalBuyLots += buyLots[i];
  }
  averageBuyPrice /= totalBuyLots;

  Print("averageBuyPrice: ", NormalizeDouble(averageBuyPrice, 2));

  double buyProfit = cAccountInfo.OrderProfitCheck(
      _Symbol, ORDER_TYPE_BUY, totalBuyLots, averageBuyPrice,
      SymbolInfoDouble(_Symbol, SYMBOL_BID));

  Print("buyProfit: ", NormalizeDouble(buyProfit, 2),
        " totalBuyLots: ", NormalizeDouble(totalBuyLots, 2));

  double averageSellPrice = 0;
  double totalSellLots = 0;
  for (int i = 0; i < sellPrices.Total(); i++) {
    averageSellPrice += sellPrices[i] * sellLots[i];
    totalSellLots += sellLots[i];
  }
  averageSellPrice /= totalSellLots;

  Print("averageSellPrice: ", NormalizeDouble(averageSellPrice, 2));

  double sellProfit = cAccountInfo.OrderProfitCheck(
      _Symbol, ORDER_TYPE_SELL, totalSellLots, averageSellPrice,
      SymbolInfoDouble(_Symbol, SYMBOL_ASK));

  Print("sellProfit: ", NormalizeDouble(sellProfit, 2),
        " totalSellLots: ", NormalizeDouble(totalSellLots, 2));

  double totalProfit = buyProfit + sellProfit;

  Print("totalProfit: ", NormalizeDouble(totalProfit, 2));
}
//+------------------------------------------------------------------+