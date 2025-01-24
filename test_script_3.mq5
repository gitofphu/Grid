//+------------------------------------------------------------------+
//|                                                test_script_3.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

#include <Trade/HistoryOrderInfo.mqh>
CHistoryOrderInfo cHistoryOrderInfo;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  //   cDealInfo.Ticket(305861114);
  //   Print("cDealInfo.Symbol(): ", cDealInfo.Symbol());
  //   Print("cDealInfo.Comment(): ", cDealInfo.Comment());

  // use this method
  // History ticket
  ulong ticket = 311179958;
  if (HistoryOrderSelect(ticket)) {
    Print("Price: ", HistoryOrderGetDouble(ticket, ORDER_PRICE_OPEN));
    Print("TP: ", HistoryOrderGetDouble(ticket, ORDER_TP));
    Print("Volume: ", HistoryOrderGetDouble(ticket, ORDER_VOLUME_CURRENT));
    long orderType;
    HistoryOrderGetInteger(ticket, ORDER_TYPE, orderType);
    Print("ORDER_TYPE: ", orderType);
    Print("ORDER_TYPE: ", GetOrderType(orderType));
    Print("ORDER_TICKET: ", HistoryOrderGetInteger(ticket, ORDER_TICKET));
    Print("ORDER_POSITION_ID: ",
          HistoryOrderGetInteger(ticket, ORDER_POSITION_ID));
    Print("ORDER_POSITION_BY_ID: ",
          HistoryOrderGetInteger(ticket, ORDER_POSITION_BY_ID));
    Print("Symbol: ", HistoryOrderGetString(ticket, ORDER_SYMBOL));
    Print("Comment: ", HistoryOrderGetString(ticket, ORDER_COMMENT));
  }

  // Deal ticket
  //   if (HistoryDealSelect(313115050)) {
  //     Print("Price: ", HistoryDealGetDouble(313115050, DEAL_PRICE));
  //     Print("TP: ", HistoryDealGetDouble(313115050, DEAL_TP));
  //     Print("Symbol: ", HistoryDealGetString(313115050, DEAL_SYMBOL));
  //     Print("Comment: ", HistoryDealGetString(313115050, DEAL_COMMENT));
  //   }
}

string GetOrderType(long orderType) {
  string strType = "";

  switch (orderType) {
  case ORDER_TYPE_BUY:
    strType = "ORDER_TYPE_BUY";
    break;
  case ORDER_TYPE_SELL:
    strType = "ORDER_TYPE_SELL";
    break;
  case ORDER_TYPE_BUY_LIMIT:
    strType = "ORDER_TYPE_BUY_LIMIT";
    break;
  case ORDER_TYPE_SELL_LIMIT:
    strType = "ORDER_TYPE_SELL_LIMIT";
    break;
  case ORDER_TYPE_BUY_STOP:
    strType = "ORDER_TYPE_BUY_STOP";
    break;
  case ORDER_TYPE_SELL_STOP:
    strType = "ORDER_TYPE_SELL_STOP";
    break;
  case ORDER_TYPE_BUY_STOP_LIMIT:
    strType = "ORDER_TYPE_BUY_STOP_LIMIT";
    break;
  case ORDER_TYPE_SELL_STOP_LIMIT:
    strType = "ORDER_TYPE_SELL_STOP_LIMIT";
    break;
  default:
    strType = "UNKNOWN";
    break;
  }

  return strType;
}
