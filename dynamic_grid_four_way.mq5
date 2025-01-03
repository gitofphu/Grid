//+------------------------------------------------------------------+
//|                                        dynamic_grid_four_way.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

input double PriceRange = 10;
input int MaxOrders = NULL;

input double buyStopLot = NULL;
input double buyStopGapSize = NULL;
input double buyLimitLot = NULL;
input double buyLimitGapSize = NULL;
input double sellLimitLot = NULL;
input double sellLimitGapSize = NULL;
input double sellStopLot = NULL;
input double sellStopGapSize = NULL;

bool isInit = false;

int limitOrders;
CArrayDouble buyStopArrayPrices;
CArrayDouble buyLimitArrayPrices;
CArrayDouble sellLimitArrayPrices;
CArrayDouble sellStopArrayPrices;
string Comment = "dynamic_grid";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  Print("OnInit");

  if (isInit)
    return (INIT_SUCCEEDED);

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    Utility.AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("ask: ", ask);
  Print("bid: ", bid);

  ValidateInputAndVariables();

  if (buyStopGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(ask + buyStopGapSize, 1),
                          NormalizeDouble(ask + PriceRange, 1), buyStopGapSize,
                          buyStopArrayPrices);

    // for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
    //   Print("buyStopArrayPrices: ", i, " = ", buyStopArrayPrices[i]);
    // }
  }

  if (buyLimitGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(bid - PriceRange, 1),
                          NormalizeDouble(bid - buyLimitGapSize, 1),
                          buyLimitGapSize, buyLimitArrayPrices);

    // for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
    //   Print("buyLimitArrayPrices: ", i, " = ", buyLimitArrayPrices[i]);
    // }
  }

  if (sellLimitGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(ask + sellLimitGapSize, 1),
                          NormalizeDouble(ask + PriceRange, 1),
                          sellLimitGapSize, sellLimitArrayPrices);

    // for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
    //   Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    // }
  }

  if (sellStopGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(bid - PriceRange, 1),
                          NormalizeDouble(bid - sellStopGapSize, 1),
                          sellStopGapSize, sellStopArrayPrices);

    // for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
    //   Print("sellStopArrayPrices: ", i, " = ", sellStopArrayPrices[i]);
    // }
  }

  if (limitOrders <
      (buyStopArrayPrices.Total() + buyLimitArrayPrices.Total() +
       sellLimitArrayPrices.Total() + sellStopArrayPrices.Total())) {
    Utility.AlertAndExit(
        "limitOrders must be greater than the sum of all orders.");
  }

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("volumeLimit: ", volumeLimit);

  if (volumeLimit < (buyStopArrayPrices.Total() * buyStopLot +
                     buyLimitArrayPrices.Total() * buyLimitLot +
                     sellLimitArrayPrices.Total() * sellLimitLot +
                     sellStopArrayPrices.Total() * sellStopLot)) {
    Utility.AlertAndExit("Totals lots must be less then volume limit.");
  }

  Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                             buyStopLot, ORDER_TYPE_BUY_STOP);
  Utility.CloseOrderOutsideArrayPricesByType(buyLimitArrayPrices, Comment,
                                             buyLimitLot, ORDER_TYPE_BUY_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(
      sellLimitArrayPrices, Comment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(sellStopArrayPrices, Comment,
                                             sellStopLot, ORDER_TYPE_SELL_STOP);

  Utility.AlertAndExit("Test exit");

  isInit = true;
  return (INIT_SUCCEEDED);
}

/**
 * Validate input and Variables
 */
void ValidateInputAndVariables() {

  if ((buyStopLot != NULL && buyStopGapSize == NULL) ||
      (buyStopLot == NULL && buyStopGapSize != NULL)) {
    Utility.AlertAndExit("buyStopLot andbuyStopGapSize is required!");
  }

  if ((buyLimitLot != NULL && buyLimitGapSize == NULL) ||
      (buyLimitLot == NULL && buyLimitGapSize != NULL)) {
    Utility.AlertAndExit("buyLimitLot and buyLimitGapSize is required!");
  }

  if ((sellLimitLot != NULL && sellLimitGapSize == NULL) ||
      (sellLimitLot == NULL && sellLimitGapSize != NULL)) {
    Utility.AlertAndExit("sellLimitLot and sellLimitGapSize is required!");
  }

  if ((sellStopLot != NULL && sellStopGapSize == NULL) ||
      (sellStopLot == NULL && sellStopGapSize != NULL)) {
    Utility.AlertAndExit("sellStopLot and sellStopGapSize is required!");
  }

  if (PriceRange < buyStopGapSize || PriceRange < buyLimitGapSize ||
      PriceRange < sellLimitGapSize || PriceRange < sellStopGapSize) {
    Utility.AlertAndExit("PriceRange must be greater than all gap sizes.");
  }

  double volumeMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  Print("volumeMin: ", volumeMin);

  if ((buyStopLot != NULL && buyStopLot < volumeMin) ||
      (buyLimitLot != NULL && buyLimitLot < volumeMin) ||
      (sellLimitLot != NULL && sellLimitLot < volumeMin) ||
      (sellStopLot != NULL && sellStopLot < volumeMin)) {
    Utility.AlertAndExit("Lots must be greater than volume min.");
  }

  const int accoutnLimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  Print("accoutnLimitOrders: ", accoutnLimitOrders);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }

  Print("limitOrders: ", limitOrders);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {}

//+------------------------------------------------------------------+