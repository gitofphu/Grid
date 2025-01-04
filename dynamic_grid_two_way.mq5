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
input bool TradeBuy = true;
input bool TradeSell = true;

bool isInit = false;

int limitOrders;
CArrayDouble ArrayPrices;
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

  GetArrayPrices();

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }

  ValidateInputAndVariables();

  Utility.CloseOrderOutsideArrayPrices(ArrayPrices, Comment, LotSize);

  CheckAndPlaceOrders();

  isInit = true;

  return (INIT_SUCCEEDED);
}

/**
 * Validate input and Variables
 */
void ValidateInputAndVariables() {

  if (TradeBuy == false && TradeSell == false)
    Utility.AlertAndExit(
        "TradeBuy and TradeSell cannot be false at the same time.");

  if (GridGapSize == 0)
    Utility.AlertAndExit("GridGapSize cannot be 0.");

  const int accoutnLimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }

  Print("limitOrders: ", limitOrders);

  if (TradeBuy == true && TradeSell == true &&
      (ArrayPrices.Total() * 2) > limitOrders) {
    Utility.AlertAndExit("Array Prices exceed ACCOUNT_LIMIT_ORDERS.");
  } else if ((TradeBuy == true || TradeSell == true) &&
             (ArrayPrices.Total()) > limitOrders) {
    Utility.AlertAndExit("Array Prices exceed ACCOUNT_LIMIT_ORDERS.");
  }

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("Basic info SYMBOL_VOLUME_LIMIT: ", volumeLimit, ", Total Orders: ",
        ArrayPrices.Total() * (TradeBuy == true && TradeSell == true ? 2 : 1));

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

void GetArrayPrices() {
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

  Utility.GetArrayPrice(minPrice, maxPrice, GridGapSize, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());
}

/**
 * Check orders and positions
 */
void CheckAndPlaceOrders() {
  bool OrderPriceInvalid = false;
  int errors = 0;

  do {

    if (TradeBuy) {
      CArrayDouble buyLimitPrices;
      CArrayDouble buyStopPrices;
      Utility.FilterOpenBuyOrderAndPosition(ArrayPrices, GridGapSize, Comment,
                                            buyLimitPrices, buyStopPrices);
      Print("Basic info: buyLimitPrices = ", buyLimitPrices.Total());
      Print("Basic info: buyStopPrices = ", buyStopPrices.Total());

      for (int i = 0; i < buyLimitPrices.Total(); i++) {
        Print("buyLimitPrices: ", buyLimitPrices[i]);
      }
      for (int i = 0; i < buyStopPrices.Total(); i++) {
        Print("buyStopPrices: ", buyStopPrices[i]);
      }

      Utility.PlaceBuyOrders(buyLimitPrices, buyStopPrices, LotSize,
                             GridGapSize, Comment, OrderPriceInvalid);
    }

    if (TradeSell) {
      CArrayDouble sellLimitPrices;
      CArrayDouble sellStopPrices;
      Utility.FilterOpenSellOrderAndPosition(ArrayPrices, GridGapSize, Comment,
                                             sellLimitPrices, sellStopPrices);
      Print("Basic info: sellLimitPrices = ", sellLimitPrices.Total());
      Print("Basic info: sellStopPrices = ", sellStopPrices.Total());

      for (int i = 0; i < sellLimitPrices.Total(); i++) {
        Print("sellLimitPrices: ", sellLimitPrices[i]);
      }
      for (int i = 0; i < sellStopPrices.Total(); i++) {
        Print("sellStopPrices: ", sellStopPrices[i]);
      }

      Utility.PlaceSellOrders(sellLimitPrices, sellStopPrices, LotSize,
                              GridGapSize, Comment, OrderPriceInvalid);
    }

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

  // Print("Deal: ", trans.deal, ", Order: ", trans.order,
  //       ", Symbol: ", trans.symbol, ", Type: ", trans.type,
  //       ", order_type: ", trans.order_type,
  //       ", order_state: ", trans.order_state, ", deal_type: ",
  //       trans.deal_type,
  //       ", time_type: ", trans.time_type,
  //       ", time_expiration: ", trans.time_expiration, ", Price: ",
  //       trans.price,
  //       ", price_trigger: ", trans.price_trigger, ", SL: ", trans.price_sl,
  //       ", TP: ", trans.price_tp, ", volume: ", trans.volume,
  //       ", position: ", trans.position, ", position_by: ",
  //       trans.position_by);

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

    // Print("reason: ", reason);

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

      GetArrayPrices();

      Utility.CloseOrderOutsideArrayPrices(ArrayPrices, Comment, LotSize);

      CheckAndPlaceOrders();
    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_EXPERT) {

      GetArrayPrices();

      Utility.CloseOrderOutsideArrayPrices(ArrayPrices, Comment, LotSize);

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