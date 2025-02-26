//+------------------------------------------------------------------+
//|                                                 averagePrice.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "Version = 1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {

  int ordersTotal = OrdersTotal();
  Print("Orders Total: ", ordersTotal);

  for (int i = 0; i < ordersTotal; i++) {
    ulong orderTicket = OrderGetTicket(i);

    if (OrderSelect(orderTicket)) {
      string symbol = OrderGetString(ORDER_SYMBOL);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      string orderComment = OrderGetString(ORDER_COMMENT);
      long orderType = OrderGetInteger(ORDER_TYPE);

      string splitComment[];
      int count = StringSplit(orderComment, '|', splitComment);

      Print("symbol: ", symbol, " orderPrice: ", orderPrice,
            " orderComment: ", orderComment, " orderType: ", orderType,
            " count: ", count);
    }
  }
}
//+------------------------------------------------------------------+