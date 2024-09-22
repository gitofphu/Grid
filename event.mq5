//+------------------------------------------------------------------+
//|                                                        event.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Arrays/ArrayDouble.mqh>
CArrayDouble;

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

#include <Trade/OrderInfo.mqh>
COrderInfo cOrderInfo;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  Print("OnInit");

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) { Print("OnDeinit"); }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  // Print("OnTick");
}

//+------------------------------------------------------------------+
//| Trade function                                                   |
//+------------------------------------------------------------------+
void OnTrade() { Print("OnTrade"); }

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
  Print("OnTradeTransaction");

  Print("trans.deal: ", trans.deal);
  Print("trans.order: ", trans.order);
  Print("trans.symbol: ", trans.symbol);
  Print("trans.type: ", trans.type);
  Print("trans.order_type: ", trans.order_type);
  Print("trans.order_state: ", trans.order_state);
  Print("trans.deal_type: ", trans.deal_type);
  Print("trans.time_type: ", trans.time_type);
  Print("trans.time_expiration: ", trans.time_expiration);
  Print("trans.price: ", trans.price);
  Print("trans.price_trigger: ", trans.price_trigger);
  Print("trans.price_sl: ", trans.price_sl);
  Print("trans.price_tp: ", trans.price_tp);
  Print("trans.volume: ", trans.volume);
  Print("trans.position: ", trans.position);
  Print("trans.position_by: ", trans.position_by);

  //--- get transaction type as enumeration value
  ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
  Print("type", type);
  //--- if transaction is result of addition of the transaction in history
  if (type == TRADE_TRANSACTION_DEAL_ADD) {
    if (HistoryDealSelect(trans.deal))
      cDealInfo.Ticket(trans.deal);
    else {
      Print(__FILE__, " ", __FUNCTION__, ", ERROR: HistoryDealSelect(",
            trans.deal, ")");
      return;
    }
    //---
    long reason = -1;
    if (!cDealInfo.InfoInteger(DEAL_REASON, reason)) {
      Print(__FILE__, " ", __FUNCTION__,
            ", ERROR: InfoInteger(DEAL_REASON,reason)");
      return;
    }
    Print("reason: ", reason);
    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL)
      Alert("Stop Loss activation");
    else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP)
      Alert("Take Profit activation");

    int orderType = HistoryOrderGetInteger(trans.deal, ORDER_TYPE);

    switch (orderType) {
    case ORDER_TYPE_BUY:
      Print("ORDER_TYPE_BUY");
      break;
    case ORDER_TYPE_SELL:
      Print("ORDER_TYPE_SELL");
      break;
    case ORDER_TYPE_BUY_LIMIT:
      Print("ORDER_TYPE_BUY_LIMIT");
      break;
    case ORDER_TYPE_SELL_LIMIT:
      Print("ORDER_TYPE_SELL_LIMIT");
      break;
    case ORDER_TYPE_BUY_STOP:
      Print("ORDER_TYPE_BUY_STOP");
      break;
    case ORDER_TYPE_SELL_STOP:
      Print("ORDER_TYPE_SELL_STOP");
      break;
    case ORDER_TYPE_BUY_STOP_LIMIT:
      Print("ORDER_TYPE_BUY_STOP_LIMIT");
      break;
    case ORDER_TYPE_SELL_STOP_LIMIT:
      Print("ORDER_TYPE_SELL_STOP_LIMIT");
      break;
    case ORDER_TYPE_CLOSE_BY:
      Print("ORDER_TYPE_CLOSE_BY");
      break;
    default:
      Print("Unknow Type");
      break;
    }
  }

  if (TRADE_TRANSACTION_ORDER_ADD == type) {
    Print("TRADE_TRANSACTION_ORDER_ADD");

    if (cOrderInfo.Select(trans.order)) {

      int orderType = cOrderInfo.OrderType();

      Print("orderType:", orderType);

      switch (orderType) {
      case ORDER_TYPE_BUY:
        Print("ORDER_TYPE_BUY");
        break;
      case ORDER_TYPE_SELL:
        Print("ORDER_TYPE_SELL");
        break;
      case ORDER_TYPE_BUY_LIMIT:
        Print("ORDER_TYPE_BUY_LIMIT");
        break;
      case ORDER_TYPE_SELL_LIMIT:
        Print("ORDER_TYPE_SELL_LIMIT");
        break;
      case ORDER_TYPE_BUY_STOP:
        Print("ORDER_TYPE_BUY_STOP");
        break;
      case ORDER_TYPE_SELL_STOP:
        Print("ORDER_TYPE_SELL_STOP");
        break;
      case ORDER_TYPE_BUY_STOP_LIMIT:
        Print("ORDER_TYPE_BUY_STOP_LIMIT");
        break;
      case ORDER_TYPE_SELL_STOP_LIMIT:
        Print("ORDER_TYPE_SELL_STOP_LIMIT");
        break;
      case ORDER_TYPE_CLOSE_BY:
        Print("ORDER_TYPE_CLOSE_BY");
        break;
      default:
        Print("Unknow Type");
        break;
      }
    }
  }
}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
  Print("OnTester");

  double ret = 0.0;

  return (ret);
}

//+------------------------------------------------------------------+
//| TesterInit function                                              |
//+------------------------------------------------------------------+
void OnTesterInit() { Print("OnTesterInit"); }

//+------------------------------------------------------------------+
//| TesterPass function                                              |
//+------------------------------------------------------------------+
void OnTesterPass() { Print("OnTesterPass"); }

//+------------------------------------------------------------------+
//| TesterDeinit function                                            |
//+------------------------------------------------------------------+
void OnTesterDeinit() { Print("OnTesterDeinit"); }

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam,
                  const string &sparam) {
  Print("OnChartEvent");
}

//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol) { Print("OnBookEvent"); }

//+------------------------------------------------------------------+