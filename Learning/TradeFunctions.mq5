
void OnStart() {

  // double profit;
  // OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1, 50, profit);
  // Print("OrderCalcMargin: ", profit);

  // OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1, 50, 40, profit);
  // Print("OrderCalcProfit: ", profit);

  Print("PositionsTotal: ", PositionsTotal());
  Print("PositionSelect: ", PositionSelect(_Symbol));
  Print("POSITION_VOLUME: ", PositionGetDouble(POSITION_VOLUME));
  Print("POSITION_PRICE_OPEN: ", PositionGetDouble(POSITION_PRICE_OPEN));
  Print("POSITION_SL: ", PositionGetDouble(POSITION_SL));
  Print("POSITION_TP: ", PositionGetDouble(POSITION_TP));
  Print("POSITION_PRICE_CURRENT: ", PositionGetDouble(POSITION_PRICE_CURRENT));
  Print("POSITION_SWAP: ", PositionGetDouble(POSITION_SWAP));
  Print("POSITION_PROFIT: ", PositionGetDouble(POSITION_PROFIT));

  Print("OrdersTotal: ", OrdersTotal());
  ulong orderTicket = OrderGetTicket(0);
  Print("OrderGetTicket: ", orderTicket);
  Print("OrderSelect: ", OrderSelect(orderTicket));
  Print("ORDER_VOLUME_INITIAL: ", OrderGetDouble(ORDER_VOLUME_INITIAL));
  Print("ORDER_VOLUME_CURRENT: ", OrderGetDouble(ORDER_VOLUME_CURRENT));
  Print("ORDER_PRICE_OPEN: ", OrderGetDouble(ORDER_PRICE_OPEN));
  Print("ORDER_SL: ", OrderGetDouble(ORDER_SL));
  Print("ORDER_TP: ", OrderGetDouble(ORDER_TP));
  Print("ORDER_PRICE_CURRENT: ", OrderGetDouble(ORDER_PRICE_CURRENT));
  Print("ORDER_PRICE_STOPLIMIT: ", OrderGetDouble(ORDER_PRICE_STOPLIMIT));
  Print("OrderGetInteger: ", OrderGetInteger(ORDER_TICKET));

  Print("HistorySelect: ", HistorySelect(0, TimeCurrent()));
  Print("HistoryOrdersTotal: ", HistoryOrdersTotal());
  Print("HistoryDealsTotal: ", HistoryDealsTotal());
  ulong dealTicket = HistoryDealGetTicket(0);
  Print("HistoryDealGetTicket: ", dealTicket);
  Print("HistoryDealGetInteger: ",
        HistoryDealGetInteger(dealTicket, DEAL_TICKET));
}
