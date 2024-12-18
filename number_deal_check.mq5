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
      long orderType = OrderGetInteger(ORDER_TYPE);
      string symbol = OrderGetString(ORDER_SYMBOL);

      if (symbol != _Symbol)
        continue;

      Print("orderTicket: ", orderTicket, ", orderPrice: ", orderPrice,
            ", orderTP: ", orderTP, ", type: ", GetOrderTypeString(orderType));
    }
  }
}

string GetOrderTypeString(long orderType) {
  string str = "";
  switch (orderType) {
  case ORDER_TYPE_BUY:
    str = ("ORDER_TYPE_BUY");
    break;
  case ORDER_TYPE_SELL:
    str = ("ORDER_TYPE_SELL");
    break;
  case ORDER_TYPE_BUY_LIMIT:
    str = ("ORDER_TYPE_BUY_LIMIT");
    break;
  case ORDER_TYPE_SELL_LIMIT:
    str = ("ORDER_TYPE_SELL_LIMIT");
    break;
  case ORDER_TYPE_BUY_STOP:
    str = ("ORDER_TYPE_BUY_STOP");
    break;
  case ORDER_TYPE_SELL_STOP:
    str = ("ORDER_TYPE_SELL_STOP");
    break;
  case ORDER_TYPE_BUY_STOP_LIMIT:
    str = ("ORDER_TYPE_BUY_STOP_LIMIT");
    break;
  case ORDER_TYPE_SELL_STOP_LIMIT:
    str = ("ORDER_TYPE_SELL_STOP_LIMIT");
    break;
  case ORDER_TYPE_CLOSE_BY:
    str = ("ORDER_TYPE_CLOSE_BY");
    break;
  default:
    str = ("Unknow Type");
    break;
  }
  return str;
}