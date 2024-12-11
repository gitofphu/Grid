//+------------------------------------------------------------------+
//|                                            number_deal_check.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Trade/AccountInfo.mqh>
CAccountInfo AccountInfo;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  //   long accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
  //   Print("accoutnLimitOrders: ", accoutnLimitOrders);

  Print("LimitOrders ", AccountInfo.LimitOrders());
  Print("OrdersTotal(): ", OrdersTotal());
  Print("PositionsTotal(): ", PositionsTotal());

  for (int i = 0; i < OrdersTotal(); i++) {
    ulong orderTicket = OrderGetTicket(i);
    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      double orderTP = OrderGetDouble(ORDER_TP);

      Print("orderTicket: ", orderTicket, ", orderPrice: ", orderPrice,
            ", orderTP: ", orderTP);
    }
  }
}
