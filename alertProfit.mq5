//+------------------------------------------------------------------+
//|                                                  alertProfit.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  Print("Alert Profit initialized");
  return (INIT_SUCCEEDED);
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

    int orderType = (int)HistoryOrderGetInteger(trans.deal, ORDER_TYPE);

    string strType = "";

    switch (orderType) {
    case ORDER_TYPE_BUY:
      // Print("ORDER_TYPE_BUY");
      strType = "ORDER_TYPE_BUY";
      break;
    case ORDER_TYPE_SELL:
      // Print("ORDER_TYPE_SELL");
      strType = "ORDER_TYPE_SELL";
      break;
    case ORDER_TYPE_BUY_LIMIT:
      // Print("ORDER_TYPE_BUY_LIMIT");
      strType = "ORDER_TYPE_BUY_LIMIT";
      break;
    case ORDER_TYPE_SELL_LIMIT:
      // Print("ORDER_TYPE_SELL_LIMIT");
      strType = "ORDER_TYPE_SELL_LIMIT";
      break;
    case ORDER_TYPE_BUY_STOP:
      // Print("ORDER_TYPE_BUY_STOP");
      strType = "ORDER_TYPE_BUY_STOP";
      break;
    case ORDER_TYPE_SELL_STOP:
      // Print("ORDER_TYPE_SELL_STOP");
      strType = "ORDER_TYPE_SELL_STOP";
      break;
    case ORDER_TYPE_BUY_STOP_LIMIT:
      // Print("ORDER_TYPE_BUY_STOP_LIMIT");
      strType = "ORDER_TYPE_BUY_STOP_LIMIT";
      break;
    case ORDER_TYPE_SELL_STOP_LIMIT:
      // Print("ORDER_TYPE_SELL_STOP_LIMIT");
      strType = "ORDER_TYPE_SELL_STOP_LIMIT";
      break;
    case ORDER_TYPE_CLOSE_BY:
      // Print("ORDER_TYPE_CLOSE_BY");
      strType = "ORDER_TYPE_CLOSE_BY";
      break;
    default:
      // Print("Unknow Type");
      break;
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

    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL) {
      string message = "SL " + strType + " " + (string)trans.volume;

      Alert(message);

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {

      // Print("Deal: ", trans.deal, ", Order: ", trans.order,
      //       ", Symbol: ", trans.symbol, ", Type: ", trans.type,
      //       ", order_type: ", trans.order_type,
      //       ", order_state: ", trans.order_state,
      //       ", deal_type: ", trans.deal_type, ", time_type: ",
      //       trans.time_type,
      //       ", time_expiration: ", trans.time_expiration,
      //       ", Price: ", trans.price, ", price_trigger: ",
      //       trans.price_trigger,
      //       ", SL: ", trans.price_sl, ", TP: ", trans.price_tp,
      //       ", volume: ", trans.volume, ", position: ", trans.position,
      //       ", position_by: ", trans.position_by);

      string message = "TP " + strType + " " + (string)trans.volume;

      Alert(message);
    }
  }
}