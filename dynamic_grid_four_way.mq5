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

  GetArrayPrices();

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

  CloseOrderOutSideArray();

  CheckAndPlaceOrders();

  isInit = true;
  return (INIT_SUCCEEDED);
}

void CloseOrderOutSideArray() {
  Print("CloseOrderOutSideArray");
  Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                             buyStopLot, ORDER_TYPE_BUY_STOP);
  Utility.CloseOrderOutsideArrayPricesByType(buyLimitArrayPrices, Comment,
                                             buyLimitLot, ORDER_TYPE_BUY_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(
      sellLimitArrayPrices, Comment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(sellStopArrayPrices, Comment,
                                             sellStopLot, ORDER_TYPE_SELL_STOP);
}

void GetArrayPrices() {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("GetArrayPrices ask: ", ask);
  Print("GetArrayPrices bid: ", bid);

  if (buyStopGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(ask + buyStopGapSize, 1),
                          NormalizeDouble(ask + PriceRange, 1), buyStopGapSize,
                          buyStopArrayPrices);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, " = ", buyStopArrayPrices[i]);
    }
  }

  if (buyLimitGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(bid - PriceRange, 1),
                          NormalizeDouble(bid - buyLimitGapSize, 1),
                          buyLimitGapSize, buyLimitArrayPrices);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, " = ", buyLimitArrayPrices[i]);
    }
  }

  if (sellLimitGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(ask + sellLimitGapSize, 1),
                          NormalizeDouble(ask + PriceRange, 1),
                          sellLimitGapSize, sellLimitArrayPrices);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    }
  }

  if (sellStopGapSize) {
    Utility.GetArrayPrice(NormalizeDouble(bid - PriceRange, 1),
                          NormalizeDouble(bid - sellStopGapSize, 1),
                          sellStopGapSize, sellStopArrayPrices);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", i, " = ", sellStopArrayPrices[i]);
    }
  }
}

/**
 * Check orders and positions
 */
void CheckAndPlaceOrders() {
  Print("CheckAndPlaceOrders");
  bool orderPriceInvalid = false;
  int errors = 0;

  do {

    if (buyStopArrayPrices.Total() > 0) {
      CArrayDouble buyStopMissingDeals;
      FilterOpenOrdersAndPositionsByType(buyStopArrayPrices, buyStopGapSize,
                                         Comment, ORDER_TYPE_BUY_STOP,
                                         buyStopMissingDeals);

      Print("buyStopMissingDeals: ", buyStopMissingDeals.Total());

      for (int i = 0; i < buyStopMissingDeals.Total(); i++) {
        Print("PlaceBuyStopOrder: ", buyStopMissingDeals[i]);
        Utility.PlaceBuyStopOrder(buyStopMissingDeals[i], buyStopLot,
                                  buyStopGapSize, Comment, orderPriceInvalid);
      }
    }

    if (buyLimitArrayPrices.Total() > 0) {
      CArrayDouble buyLimitMissingDeals;
      FilterOpenOrdersAndPositionsByType(buyLimitArrayPrices, buyLimitGapSize,
                                         Comment, ORDER_TYPE_BUY_LIMIT,
                                         buyLimitMissingDeals);

      Print("buyLimitMissingDeals: ", buyLimitMissingDeals.Total());

      for (int i = 0; i < buyLimitMissingDeals.Total(); i++) {
        Print("PlaceBuyLimitOrder: ", buyLimitMissingDeals[i]);
        Utility.PlaceBuyLimitOrder(buyLimitMissingDeals[i], buyLimitLot,
                                   buyLimitGapSize, Comment, orderPriceInvalid);
      }
    }

    if (sellLimitArrayPrices.Total() > 0) {
      CArrayDouble sellLimitMissingDeals;
      FilterOpenOrdersAndPositionsByType(sellLimitArrayPrices, sellLimitGapSize,
                                         Comment, ORDER_TYPE_SELL_LIMIT,
                                         sellLimitMissingDeals);

      Print("sellLimitMissingDeals: ", sellLimitMissingDeals.Total());

      for (int i = 0; i < sellLimitMissingDeals.Total(); i++) {
        Print("PlaceSellLimitOrder: ", sellLimitMissingDeals[i]);
        Utility.PlaceSellLimitOrder(sellLimitMissingDeals[i], sellLimitLot,
                                    sellLimitGapSize, Comment,
                                    orderPriceInvalid);
      }
    }

    if (sellStopArrayPrices.Total() > 0) {
      CArrayDouble sellStopMissingDeals;
      FilterOpenOrdersAndPositionsByType(sellStopArrayPrices, sellStopGapSize,
                                         Comment, ORDER_TYPE_SELL_STOP,
                                         sellStopMissingDeals);

      Print("sellStopMissingDeals: ", sellStopMissingDeals.Total());

      for (int i = 0; i < sellStopMissingDeals.Total(); i++) {
        Print("PlaceSellStopOrder: ", sellStopMissingDeals[i]);
        Utility.PlaceSellStopOrder(sellStopMissingDeals[i], sellStopLot,
                                   sellStopGapSize, Comment, orderPriceInvalid);
      }
    }

  } while (orderPriceInvalid && errors < 3);

  if (errors >= 3) {
    Utility.AlertAndExit("Place order error.");
  }
}

void FilterOpenOrdersAndPositionsByType(CArrayDouble &arrayPrices,
                                        double gridGapSize, string comment,
                                        const ENUM_ORDER_TYPE type,
                                        CArrayDouble &missingDeals) {
  Print("FilterOpenOrdersAndPositionsByType comment: ", comment,
        ", type: ", Utility.GetOrderTypeString(type));

  CArrayDouble existDeals;

  for (int i = 0; i < OrdersTotal(); i++) {
    ulong orderTicket = OrderGetTicket(i);

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      string symbol = OrderGetString(ORDER_SYMBOL);
      string orderComment = OrderGetString(ORDER_COMMENT);
      long orderType = OrderGetInteger(ORDER_TYPE);

      if (orderComment != comment || symbol != _Symbol || orderType != type)
        continue;

      Utility.getExistDeals(arrayPrices, gridGapSize, orderPrice, existDeals);
    }
  }

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);

      if (positionComment != comment || symbol != _Symbol)
        continue;

      if ((type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) &&
          positionType != POSITION_TYPE_BUY)
        continue;

      if ((type == ORDER_TYPE_SELL_LIMIT || type == ORDER_TYPE_SELL_STOP) &&
          positionType != POSITION_TYPE_SELL)
        continue;

      Utility.getExistDeals(arrayPrices, gridGapSize, positionPrice,
                            existDeals);
    }
  }

  existDeals.Sort();

  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (existDeals.Search(arrayPrices[i]) == -1) {
      missingDeals.Add(arrayPrices[i]);
    }
  }
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("OnTick ask: ", ask, ", bid: ", bid);

  if (buyStopGapSize && Utility.NormalizeDoubleTwoDigits(
                            buyStopArrayPrices[buyStopArrayPrices.Total() - 1] -
                            ask) >= buyStopGapSize) {

    Print("buyStop ask: ", ask,
          ", last price: ", buyStopArrayPrices[buyStopArrayPrices.Total() - 1],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(
              buyStopArrayPrices[buyStopArrayPrices.Total() - 1] - ask),
          ", gap: ", buyStopGapSize);

    Utility.GetArrayPrice(NormalizeDouble(ask + buyStopGapSize, 1),
                          NormalizeDouble(ask + PriceRange, 1), buyStopGapSize,
                          buyStopArrayPrices);

    Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                               buyStopLot, ORDER_TYPE_BUY_STOP);

    CArrayDouble buyStopMissingDeals;
    FilterOpenOrdersAndPositionsByType(buyStopArrayPrices, buyStopGapSize,
                                       Comment, ORDER_TYPE_BUY_STOP,
                                       buyStopMissingDeals);

    bool orderPriceInvalid = false;

    for (int i = 0; i < buyStopMissingDeals.Total(); i++) {
      Utility.PlaceBuyStopOrder(buyStopMissingDeals[i], buyStopLot,
                                buyStopGapSize, Comment, orderPriceInvalid);
    }
  }

  if (buyLimitGapSize && Utility.NormalizeDoubleTwoDigits(
                             bid - buyLimitArrayPrices[0]) >= buyLimitGapSize) {

    Print("buyLimit bid: ", bid, ", first price: ", buyLimitArrayPrices[0],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(bid - buyLimitArrayPrices[0]),
          ", gap: ", buyLimitGapSize);

    Utility.GetArrayPrice(NormalizeDouble(bid - PriceRange, 1),
                          NormalizeDouble(bid - buyLimitGapSize, 1),
                          buyLimitGapSize, buyLimitArrayPrices);

    Utility.CloseOrderOutsideArrayPricesByType(
        buyLimitArrayPrices, Comment, buyLimitLot, ORDER_TYPE_BUY_LIMIT);

    CArrayDouble buyLimitMissingDeals;
    FilterOpenOrdersAndPositionsByType(buyLimitArrayPrices, buyLimitGapSize,
                                       Comment, ORDER_TYPE_BUY_LIMIT,
                                       buyLimitMissingDeals);

    bool orderPriceInvalid = false;

    for (int i = 0; i < buyLimitMissingDeals.Total(); i++) {
      Utility.PlaceBuyLimitOrder(buyLimitMissingDeals[i], buyLimitLot,
                                 buyLimitGapSize, Comment, orderPriceInvalid);
    }
  }

  if (sellLimitGapSize &&
      Utility.NormalizeDoubleTwoDigits(
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask) >=
          sellLimitGapSize) {

    Print("sellLimit ask: ", ask, ", last price: ",
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1], ", diff: ",
          Utility.NormalizeDoubleTwoDigits(
              sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask),
          ", gap: ", sellLimitGapSize);

    Utility.GetArrayPrice(NormalizeDouble(ask + sellLimitGapSize, 1),
                          NormalizeDouble(ask + PriceRange, 1),
                          sellLimitGapSize, sellLimitArrayPrices);

    Utility.CloseOrderOutsideArrayPricesByType(
        sellLimitArrayPrices, Comment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);

    CArrayDouble sellLimitMissingDeals;
    FilterOpenOrdersAndPositionsByType(sellLimitArrayPrices, sellLimitGapSize,
                                       Comment, ORDER_TYPE_SELL_LIMIT,
                                       sellLimitMissingDeals);

    bool orderPriceInvalid = false;

    for (int i = 0; i < sellLimitMissingDeals.Total(); i++) {
      Print("PlaceSellLimitOrder: ", sellLimitMissingDeals[i]);
      Utility.PlaceSellLimitOrder(sellLimitMissingDeals[i], sellLimitLot,
                                  sellLimitGapSize, Comment, orderPriceInvalid);
    }
  }

  if (sellStopGapSize && Utility.NormalizeDoubleTwoDigits(
                             bid - sellStopArrayPrices[0]) >= sellStopGapSize) {

    Print("sellStop bid: ", bid, ", first price: ", sellStopArrayPrices[0],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]),
          ", gap: ", sellStopGapSize);

    Utility.GetArrayPrice(NormalizeDouble(bid - PriceRange, 1),
                          NormalizeDouble(bid - sellStopGapSize, 1),
                          sellStopGapSize, sellStopArrayPrices);

    Utility.CloseOrderOutsideArrayPricesByType(
        sellStopArrayPrices, Comment, sellStopLot, ORDER_TYPE_SELL_STOP);

    CArrayDouble sellStopMissingDeals;
    FilterOpenOrdersAndPositionsByType(sellStopArrayPrices, sellStopGapSize,
                                       Comment, ORDER_TYPE_SELL_STOP,
                                       sellStopMissingDeals);

    bool orderPriceInvalid = false;

    for (int i = 0; i < sellStopMissingDeals.Total(); i++) {
      Utility.PlaceSellStopOrder(sellStopMissingDeals[i], sellStopLot,
                                 sellStopGapSize, Comment, orderPriceInvalid);
    }
  }
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
  ENUM_TRADE_TRANSACTION_TYPE type = trans.type;

  if (type == TRADE_TRANSACTION_DEAL_ADD) {

    if (HistoryDealSelect(trans.deal)) {
      cDealInfo.Ticket(trans.deal);
    } else {
      Print(__FILE__, " ", __FUNCTION__, ", ERROR: HistoryDealSelect(",
            trans.deal, ")");
      return;
    }

    long reason = -1;
    if (!cDealInfo.InfoInteger(DEAL_REASON, reason)) {
      Print(__FILE__, " ", __FUNCTION__,
            ", ERROR: InfoInteger(DEAL_REASON,reason)");
      return;
    }

    string strReason = "";

    switch (reason) {
    case DEAL_REASON_CLIENT:
      strReason = "The deal was executed as a result of activation of an order "
                  "placed from a desktop terminal.";
      break;
    case DEAL_REASON_MOBILE:
      strReason = "The deal was executed as a result of activation of an order "
                  "placed from a mobile application.";
      break;
    case DEAL_REASON_WEB:
      strReason = "The deal was executed as a result of activation of an order "
                  "placed from the web platform.";
      break;
    case DEAL_REASON_EXPERT:
      strReason =
          "The deal was executed as a result of activation of an order placed "
          "from an MQL5 program, i.e. an Expert Advisor or a script.";
      break;
    case DEAL_REASON_SL:
      strReason = "The deal was executed as a result of Stop Loss activation.";
      break;
    case DEAL_REASON_TP:
      strReason =
          "The deal was executed as a result of Take Profit activation.";
      break;
    case DEAL_REASON_SO:
      strReason = "The deal was executed as a result of the Stop Out event.";
      break;
    case DEAL_REASON_ROLLOVER:
      strReason = "The deal was executed due to a rollover.";
      break;
    case DEAL_REASON_VMARGIN:
      strReason = "The deal was executed after charging the variation margin.";
      break;
    case DEAL_REASON_SPLIT:
      strReason =
          "The deal was executed after the split (price reduction) of an "
          "instrument, which had an open position during split announcement.";
      break;
    case DEAL_REASON_CORPORATE_ACTION:
      strReason =
          "The deal was executed as a result of a corporate action: merging or "
          "renaming a security, transferring a client to another account, etc.";
      break;
    }

    Print("strReason: ", strReason);

    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL)
      Alert("Stop Loss activation");
    else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {
      Alert("Take Profit activation");
      Order66();
    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_EXPERT) {
      Order66();
    }
  }
}

void Order66() {
  GetArrayPrices();
  CloseOrderOutSideArray();
  CheckAndPlaceOrders();
}

//+------------------------------------------------------------------+