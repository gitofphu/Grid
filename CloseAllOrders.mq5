#include <Trade/Trade.mqh>
CTrade Ctrade;

#include <Arrays/ArrayLong.mqh>
CArrayLong Carray;

void OnStart() { CloseAllOrders2(); }

void CloseAllOrders1() {
  Print("CloseAllOrders1");

  int ordersTotal = OrdersTotal();

  Ctrade.SetAsyncMode(true);
  /*
  true:Async, false:Sync
  if false ordersTotal will be refesh cause orderTicket to be 0
  and couse error 4756 due to invalue orderTicket upon OrderDelete
  */

  if (ordersTotal > 0) {
    for (int i = 0; i < ordersTotal; i++) {
      ulong orderTicket = OrderGetTicket(i);

      Print("orderTicket: ", orderTicket);

      deleteOrder(orderTicket);
    }
  }
}

void CloseAllOrders2() {
  Print("CloseAllOrders2");

  Ctrade.SetAsyncMode(false);
  int ordersTotal = OrdersTotal();
  CArrayLong tickets;

  if (ordersTotal > 0) {
    for (int i = 0; i < ordersTotal; i++) {
      ulong orderTicket = OrderGetTicket(i);
      tickets.Add(orderTicket);
    }

    for (int i = 0; i < tickets.Total(); i++) {
      Print("ticket: ", tickets[i]);

      deleteOrder(tickets[i]);
    }
  }
}

void deleteOrder(ulong ticket) {
  if (Ctrade.OrderDelete(ticket)) {

    Print("Order ", ticket, " deleted.");

    uint retcode = Ctrade.ResultRetcode();
    Print("retcode: ", retcode);

  } else {

    Print("Failed to delete order ", ticket, ". Error: ", GetLastError());

    uint retcode = Ctrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}