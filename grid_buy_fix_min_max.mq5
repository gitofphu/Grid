//+------------------------------------------------------------------+
//|                                                     grid_buy.mq5 |
//|                                                  Watsadonramai.W |
//|                                           Link inMQLHeadStandard |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.02"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

//+------------------------------------------------------------------+
//| EA Buy Grid                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| input                                                            |
//+------------------------------------------------------------------+
input double MaxPrice = 100;
input double MinPrice = 0;
input int MaxOrders = NULL;
input double GridGapSize = 10;
input bool TradeAnywaywithMinimunLot = false;
input bool ClearOrdersOnInit = false;
input double MinLot = NULL;

bool isInit = false;

int limitOrders;
CArrayDouble ArrayPrices;
double lotPerGrid;
string comment = "grid_buy_fix_min_max";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit() {
  Print("OnInit");

  if (isInit)
    return (INIT_SUCCEEDED);

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    Utility.AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  ValidateInput();

  if (ArrayPrices.Total() == 0)
    Utility.GetArrayPrice(MinPrice, MaxPrice, GridGapSize, ArrayPrices);

  if (ClearOrdersOnInit) {
    Utility.CloseAllOrder(ArrayPrices, comment);
  }

  if (ArrayPrices.Total() > limitOrders) {
    Utility.AlertAndExit("ArrayPrices exceed limitOrders.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("Basic info: SYMBOL_VOLUME_LIMIT= ", volumeLimit);

  if (volumeLimit != 0 && ArrayPrices.Total() > volumeLimit) {
    Utility.AlertAndExit("Number of grid exceeded volume limit.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (MinLot != NULL) {
    lotPerGrid = MinLot;
  } else {
    lotPerGrid = Utility.GetGirdLotSize(_Symbol, ArrayPrices);
  }

  if (lotPerGrid == 0) {
    if (TradeAnywaywithMinimunLot) {
      lotPerGrid = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    } else {
      return (INIT_PARAMETERS_INCORRECT);
    }
  }

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("Basic info: ArrayPrices ", i, " = ", ArrayPrices[i]);
  }

  Print("Basic info: lotPerGrid = ", lotPerGrid);

  CheckAndPlaceOrders();

  isInit = true;

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

  if (TradeAllowed() == false)
    return;
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {

  //--- get transaction type as enumeration value
  ENUM_TRADE_TRANSACTION_TYPE type = trans.type;
  //--- if transaction is result of addition of the transaction in history
  // Print("Deal: ", trans.deal, ", Order: ", trans.order,
  //       ", Symbol: ", trans.symbol, ", Type: ", trans.type,
  //       ", order_type: ", trans.order_type,
  //       ", order_state: ", trans.order_state, ", deal_type: ",
  //       trans.deal_type,
  //       ", time_type: ", trans.time_type,
  //       ", time_expiration: ", trans.time_expiration, ", Price: ",
  //       trans.price,
  //       ", price_trigger: ", trans.price_trigger, ", SL: ", trans.price_sl,
  //       ", TP: ", trans.price_tp, ", volume: ", trans.volume,
  //       ", position: ", trans.position, ", position_by: ",
  //       trans.position_by);

  if (type == TRADE_TRANSACTION_DEAL_ADD) {

    if (HistoryDealSelect(trans.deal)) {
      cDealInfo.Ticket(trans.deal);
    } else {
      Print(__FILE__, " ", __FUNCTION__, ", ERROR: HistoryDealSelect(",
            trans.deal, ")");
      return;
    }

    // Print("cDealInfo.Symbol(): ", cDealInfo.Symbol());
    // Print("_Symbol: ", _Symbol);

    // Print("cDealInfo.Comment(): ", cDealInfo.Comment());
    // Print("comment: ", comment);

    // if (cDealInfo.Symbol() != _Symbol) {
    //   return;
    // }
    // if (cDealInfo.Comment() != comment) {
    //   return;
    // }

    // if (HistoryOrderSelect(trans.order)) {
    //   if (HistoryOrderGetString(trans.order, ORDER_SYMBOL) != _Symbol)
    //     return;
    //   if (HistoryOrderGetString(trans.order, ORDER_COMMENT) != comment)
    //     return;
    // }

    //---
    long reason = -1;
    if (!cDealInfo.InfoInteger(DEAL_REASON, reason)) {
      Print(__FILE__, " ", __FUNCTION__,
            ", ERROR: InfoInteger(DEAL_REASON,reason)");
      return;
    }
    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL)
      Alert("Stop Loss activation");
    else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {
      Alert("Take Profit activation");

      CheckAndPlaceOrders();

      // long PositionId = cDealInfo.PositionId();
      // Print("PositionId: ", PositionId);
      // long deal;
      // cDealInfo.InfoInteger(DEAL_TICKET, deal);
      // Print("deal: ", deal);
      // long order;
      // cDealInfo.InfoInteger(DEAL_ORDER, order);
      // Print("order: ", order);
      // double price;
      // cDealInfo.InfoDouble(DEAL_PRICE, price);
      // Print("price: ", price);
      // double tp;
      // cDealInfo.InfoDouble(DEAL_TP, tp);
      // Print("tp: ", tp);
      // double profit;
      // cDealInfo.InfoDouble(DEAL_PROFIT, profit);
      // Print("profit: ", profit);
      // string symbol;
      // cDealInfo.InfoString(DEAL_SYMBOL, symbol);
      // Print("symbol: ", symbol);
      // string dealComment;
      // cDealInfo.InfoString(DEAL_COMMENT, dealComment);
      // Print("dealComment: ", dealComment);

      // ReplaceTpOrder(price);
    }
  }
}

//+------------------------------------------------------------------+

/**
 * Validate input
 */
void ValidateInput() {

  if (MinPrice < 0)
    Utility.AlertAndExit("MinPrice cannot be less than 0.");

  if (MaxPrice > 0 && MinPrice >= MaxPrice)
    Utility.AlertAndExit("MinPrice must be less than MaxPrice.");

  if (GridGapSize == 0)
    Utility.AlertAndExit("GridGapSize cannot be 0.");

  const int accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }
}

int TradeAllowed() {
  return (MQLInfoInteger(MQL_TRADE_ALLOWED) == 1 &&
          TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 1);
}

/**
 * Place pending order
 * @param  buyLimitPrices: Argument 1
 * @param  buyStopPrices: Argument 2
 * @param  OrderPriceInvalid: Argument 3
 */
void PlaceBuyOrders(CArrayDouble &buyLimitPrices, CArrayDouble &buyStopPrices,
                    bool &OrderPriceInvalid) {

  for (int i = 0; i < buyLimitPrices.Total(); i++) {
    double price = buyLimitPrices[i];
    PlaceBuyLimitOrder(price, OrderPriceInvalid);
  }

  for (int i = 0; i < buyStopPrices.Total(); i++) {
    double price = buyStopPrices[i];
    PlaceBuyStopOrder(price, OrderPriceInvalid);
  }
}

/**
 * Check orders and positions
 */
void CheckAndPlaceOrders() {

  bool OrderPriceInvalid = false;

  do {

    CArrayDouble buyLimitPrices;
    CArrayDouble buyStopPrices;

    Utility.FilterOpenBuyOrderAndPosition(ArrayPrices, GridGapSize, comment,
                                          buyLimitPrices, buyStopPrices);

    Print("Basic info: buyLimitPrices = ", buyLimitPrices.Total());
    Print("Basic info: buyStopPrices = ", buyStopPrices.Total());

    PlaceBuyOrders(buyLimitPrices, buyStopPrices, OrderPriceInvalid);
  } while (OrderPriceInvalid);
}

void ReplaceTpOrder(double price) {
  Print("ReplaceTpOrder: ", price);
  int ordersTotal = OrdersTotal();
  int positionsTotal = PositionsTotal();

  CArrayDouble existDeals;

  for (int i = 0; i < ordersTotal; i++) {
    ulong orderTicket = OrderGetTicket(i);

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

      existDeals.Add(orderPrice);
    }
  }

  for (int i = 0; i < positionsTotal; i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);

      existDeals.Add(positionPrice);
    }
  }

  existDeals.Sort();

  if (existDeals.Search(price) != -1) {
    return;
  }

  ENUM_ORDER_TYPE orderType;

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  if (price < ask) {
    orderType = ORDER_TYPE_BUY_LIMIT;
  }

  if (price > ask) {
    orderType = ORDER_TYPE_BUY_STOP;
  }

  bool OrderPriceInvalid = false;

  do {

    switch (orderType) {
    case ORDER_TYPE_BUY_LIMIT:
      PlaceBuyLimitOrder(price, OrderPriceInvalid);
      break;

    case ORDER_TYPE_BUY_STOP:
      PlaceBuyStopOrder(price, OrderPriceInvalid);
      break;

    default:
      OrderPriceInvalid = false;
      break;
    }

  } while (OrderPriceInvalid);
}

void PlaceBuyLimitOrder(double price, bool &OrderPriceInvalid) {

  Print("Basic info: PlaceBuyLimitOrder = ", price,
        ", TP = ", price + GridGapSize);

  if (cTrade.BuyLimit(lotPerGrid, price, _Symbol, 0, price + GridGapSize,
                      ORDER_TIME_GTC, 0, comment)) {

    uint retcode = cTrade.ResultRetcode();
    ulong orderTicket = cTrade.ResultOrder();

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      Print("BuyLimit result, retcode: ", retcode,
            ", orderTicket: ", orderTicket, ", orderPrice: ", orderPrice);

      if (orderPrice != price) {
        OrderPriceInvalid = true;
      }
    }

  } else {

    Print("Failed to place Buy Limit order. Error: ", GetLastError());

    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}

void PlaceBuyStopOrder(double price, bool &OrderPriceInvalid) {

  Print("Basic info: PlaceBuyStopOrder = ", price,
        ", TP = ", price + GridGapSize);

  if (cTrade.BuyStop(lotPerGrid, price, _Symbol, 0, price + GridGapSize,
                     ORDER_TIME_GTC, 0, comment)) {

    uint retcode = cTrade.ResultRetcode();
    ulong orderTicket = cTrade.ResultOrder();

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      Print("BuyStop result, retcode: ", retcode,
            ", orderTicket: ", orderTicket, ", orderPrice: ", orderPrice);

      if (orderPrice != price) {
        OrderPriceInvalid = true;
      }
    }

  } else {
    Print("Failed to place Buy Stop order. Error: ", GetLastError());

    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}