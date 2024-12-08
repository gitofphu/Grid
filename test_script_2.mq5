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
  double max = 30;

  // Utility.GetFibonacciArrayPrices(max, ArrayPrices);

  // for(double price = _Point; price <= max;){

  // }

  float one = 1;
  float two = 2;

  // Print(one / 10);
  // Print(NormalizeDouble(one / 10, _Digits));
  // Print(one % 10);
  // Print(NormalizeDouble(one % 10, _Digits));
  // Print(two / 10);
  // Print(NormalizeDouble(two / 10, _Digits));
  // Print(two % 10);
  // Print(NormalizeDouble(two % 10, _Digits));

  // for (double i = 0; i <= 130; i += 10) {
  //   double price;
  //   if (i != 0) {
  //     price = i / 10;
  //   } else {
  //     price = 0.01;
  //   }

  //   Print(i, ", value:", price, ", MathRound:", MathRound(price),
  //         ", MathRound+NormalizeDouble:",
  //         MathRound(NormalizeDouble(price, _Digits)),
  //         ", MathCeil:", MathCeil(price), ", MathCeil+NormalizeDouble:",
  //         MathCeil(NormalizeDouble(price, _Digits)));

  //   ArrayPrices.Add(NormalizeDouble(price, _Digits));

  //   double addPrice = MathCeil(NormalizeDouble(price, _Digits)) * 0.1;

  //   Print("addPrice: ", addPrice);

  //   for (double j = price; j < price + 10;) {
  //     j = NormalizeDouble((j * 10) + addPrice, _Digits);
  //     Print("j: ", j);
  //     ArrayPrices.Add(j);
  //   }
  // }

  for (double i = 5; i <= 130; i++) {
    double price;
    price = i / 10;

    if (price == 0) {
      price = 0.1;
    }

    double addPrice = NormalizeDouble(
        MathCeil(NormalizeDouble(price, _Digits)) * 0.1, _Digits);

    for (double j = i; j < i + 1; j += addPrice) {
      ArrayPrices.Add(NormalizeDouble(j, _Digits));
    }
  }

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("price: ", ArrayPrices[i]);
  }
}