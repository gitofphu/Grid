//+------------------------------------------------------------------+
//|                                                test_script_2.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

#include <Trade/OrderInfo.mqh>
COrderInfo cOrderInfo;

#include <Trade/HistoryOrderInfo.mqh>
CHistoryOrderInfo cObject;

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <Trade/SymbolInfo.mqh>
CSymbolInfo cSymbolInfo;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  // HistorySelect(0, TimeCurrent());
  // int deals = HistoryDealsTotal();
  // Print("deals: ", deals);

  // ulong deal_ticket = HistoryDealGetTicket(129);
  // Print("deal_ticket: ", deal_ticket);

  // double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
  // Print("volume: ", volume);

  // ulong order_ticket = HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
  // Print("order_ticket: ", order_ticket);

  // long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
  // Print("deal_type: ", deal_type);

  // string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
  // Print("symbol: ", symbol);

  // //   cDealInfo.SelectByIndex(1);
  // //   Print("cDealInfo.Symbol()", cDealInfo.Symbol());

  // if (cOrderInfo.Select(order_ticket)) {
  //   Print("OrderType: ", cOrderInfo.OrderType());
  //   Print("Symbol: ", cOrderInfo.Symbol());

  //   double price;
  //   cOrderInfo.InfoDouble(ORDER_PRICE_OPEN, price);
  //   Print("price: ", price);
  // }

  // if (HistoryOrderSelect(order_ticket)) {
  //   double orderPrice;
  //   HistoryOrderGetDouble(order_ticket, ORDER_PRICE_OPEN, orderPrice);
  //   Print("orderPrice: ", orderPrice);
  // }

  CArrayDouble ArrayPrices;
  double max = 130;

  Utility.GetFibonacciArrayPrice(max, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("price: ", ArrayPrices[i]);
  }
}