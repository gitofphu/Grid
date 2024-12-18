//+------------------------------------------------------------------+
//|                                                 dynamic_grid.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

//+------------------------------------------------------------------+
//| EA Dynamic Buy Grid                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| input                                                            |
//+------------------------------------------------------------------+
input double GridGapSize = 0.5;
input double GridRange = 10;
input int MaxOrders = NULL;
input double LotSize = 0.01;

bool isInit = false;

int limitOrders;
CArrayDouble ArrayPrices;
string comment = "dynamic_grid";

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

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }

  ValidateInputAndVariables();

  Utility.CloseOrderOutsideArrayPrices(ArrayPrices, comment, LotSize);

  CheckAndPlaceOrders();

  isInit = true;

  return (INIT_SUCCEEDED);
}

/**
 * Validate input and Variables
 */
void ValidateInputAndVariables() {

  if (GridGapSize == 0)
    Utility.AlertAndExit("GridGapSize cannot be 0.");

  const int accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }

  Print("limitOrders: ", limitOrders);

  if ((ArrayPrices.Total() * 2) > limitOrders)
    Utility.AlertAndExit("Array Prices exceed ACCOUNT_LIMIT_ORDERS.");

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("Basic info SYMBOL_VOLUME_LIMIT: ", volumeLimit,
        ", Total Orders: ", ArrayPrices.Total() * 2);

  if (volumeLimit != 0) {
    if (ArrayPrices.Total() > volumeLimit) {
      Utility.AlertAndExit("Number of grid exceeded volume limit.");
    }
  }

  double volumeMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);

  if (LotSize < volumeMin) {
    Utility.AlertAndExit("Invalid lotPerGrid. min lot: " + volumeMin);
  }
}

/**
 * Check orders and positions
 */
void CheckAndPlaceOrders() {

  bool OrderPriceInvalid = false;
  int errors = 0;

  do {

    CArrayDouble buyLimitPrices;
    CArrayDouble buyStopPrices;
    Utility.FilterOpenBuyOrderAndPosition(ArrayPrices, GridGapSize, comment,
                                          buyLimitPrices, buyStopPrices);
    Print("Basic info: buyLimitPrices = ", buyLimitPrices.Total());
    Print("Basic info: buyStopPrices = ", buyStopPrices.Total());

    for (int i = 0; i < buyLimitPrices.Total(); i++) {
      Print("buyLimitPrices: ", buyLimitPrices[i]);
    }
    for (int i = 0; i < buyStopPrices.Total(); i++) {
      Print("buyStopPrices: ", buyStopPrices[i]);
    }

    CArrayDouble sellLimitPrices;
    CArrayDouble sellStopPrices;
    Utility.FilterOpenSellOrderAndPosition(ArrayPrices, GridGapSize, comment,
                                           sellLimitPrices, sellStopPrices);
    Print("Basic info: sellLimitPrices = ", sellLimitPrices.Total());
    Print("Basic info: sellStopPrices = ", sellStopPrices.Total());

    for (int i = 0; i < sellLimitPrices.Total(); i++) {
      Print("sellLimitPrices: ", sellLimitPrices[i]);
    }
    for (int i = 0; i < sellStopPrices.Total(); i++) {
      Print("sellStopPrices: ", sellStopPrices[i]);
    }

    Utility.PlaceBuyOrders(buyLimitPrices, buyStopPrices, LotSize,
    GridGapSize,
                           comment, OrderPriceInvalid);

    Utility.PlaceSellOrders(sellLimitPrices, sellStopPrices, LotSize,
                            GridGapSize, comment, OrderPriceInvalid);

    if (OrderPriceInvalid)
      errors++;
  } while (OrderPriceInvalid && errors < 3);
  if (errors >= 3) {
    Utility.AlertAndExit("Place order error.");
  }
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {

  //--- get transaction type as enumeration value
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
    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL)
      Alert("Stop Loss activation");
    else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {
      Alert("Take Profit activation");

      Utility.CloseOrderOutsideArrayPrices(ArrayPrices, comment, LotSize);

      CheckAndPlaceOrders();
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
void OnTick() {}

//+------------------------------------------------------------------+