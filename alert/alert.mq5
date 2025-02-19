//+------------------------------------------------------------------+
//|                                                        alert.mq5 |
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

#resource "buy_entry_alert.wav"
#define BUY_ENTRY_ALERT_FILE "::buy_entry_alert.wav"

#resource "buy_tp_alert.wav"
#define BUY_TP_ALERT_FILE "::buy_tp_alert.wav"

#resource "sell_entry_alert.wav"
#define SELL_ENTRY_ALERT_FILE "::sell_entry_alert.wav"

#resource "sell_tp_alert.wav"
#define SELL_TP_ALERT_FILE "::sell_tp_alert.wav"

#resource "sl_alert.wav"
#define SL_ALERT_FILE "::sl_alert.wav"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  Print("Alert initialized");

  return (INIT_SUCCEEDED);
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

    string strReason = Utility.GetDealReasonString((ENUM_DEAL_REASON)reason);

    Print("strReason: ", strReason);

    string strType = Utility.GetOrderTypeStringFromTransDeal(trans);

    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL) {

      PlaySound(SL_ALERT_FILE);

      string message = "SL " + " " + strType + " " + (string)trans.volume;
      Print(message);

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {

      long orderType = Utility.GetOrderTypeFromTransDeal(trans);

      if (orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT ||
          orderType == ORDER_TYPE_BUY_STOP) {
        PlaySound(BUY_TP_ALERT_FILE);
      } else if (orderType == ORDER_TYPE_SELL_LIMIT ||
                 orderType == ORDER_TYPE_SELL_STOP) {
        PlaySound(SELL_TP_ALERT_FILE);
      }

      string message = "TP " + " " + strType + " " + (string)trans.volume;
      Print(message);
    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_EXPERT) {
      long orderType = Utility.GetOrderTypeFromTransDeal(trans);

      if (orderType == ORDER_TYPE_BUY_LIMIT ||
          orderType == ORDER_TYPE_BUY_STOP) {
        PlaySound(BUY_ENTRY_ALERT_FILE);
      } else if (orderType == ORDER_TYPE_SELL_LIMIT ||
                 orderType == ORDER_TYPE_SELL_STOP) {
        PlaySound(SELL_ENTRY_ALERT_FILE);
      }
    }
  }
}
//+------------------------------------------------------------------+
