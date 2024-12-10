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

#include <Trade\HistoryOrderInfo.mqh>
CHistoryOrderInfo cHistoryOrderInfo;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  //   cDealInfo.Ticket(305861114);
  //   Print("cDealInfo.Symbol(): ", cDealInfo.Symbol());
  //   Print("cDealInfo.Comment(): ", cDealInfo.Comment());

  // use this method
  // //  Order ticket
  if (HistoryOrderSelect(306590481)) {
    Print("Price: ", HistoryOrderGetDouble(306590481, ORDER_PRICE_OPEN));
    Print("TP: ", HistoryOrderGetDouble(306590481, ORDER_TP));
    Print("Symbol: ", HistoryOrderGetString(306590481, ORDER_SYMBOL));
    Print("Comment: ", HistoryOrderGetString(306590481, ORDER_COMMENT));
  }

  // Deal ticket
  //   if (HistoryDealSelect(313115050)) {
  //     Print("Price: ", HistoryDealGetDouble(313115050, DEAL_PRICE));
  //     Print("TP: ", HistoryDealGetDouble(313115050, DEAL_TP));
  //     Print("Symbol: ", HistoryDealGetString(313115050, DEAL_SYMBOL));
  //     Print("Comment: ", HistoryDealGetString(313115050, DEAL_COMMENT));
  //   }
}
