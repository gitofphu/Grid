//+------------------------------------------------------------------+
//|                                                     grid_buy.mq5 |
//|                                                  Watsadonramai.W |
//|                                           Link inMQLHeadStandard |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

#include <Trade/Trade.mqh>
CTrade cTrade;

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

//+------------------------------------------------------------------+
//| EA Buy Grid                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| TODO List                                                        |
//+------------------------------------------------------------------+

// [x] Get account info
// [x] ACCOUNT_BALANCE
// [x] ACCOUNT_EQUITY
// [x] ACCOUNT_MARGIN
// [x] ACCOUNT_MARGIN_FREE
// [x] ACCOUNT_MARGIN_LEVEL
// [x] ACCOUNT_MARGIN_SO_CALL
// [x] ACCOUNT_MARGIN_SO_SO
// [x] ACCOUNT_LEVERAGE
// [x] ACCOUNT_LIMIT_ORDERS
// [x] Calculate maximum drawdown
// [ ] Calcualte Pip value
// [x] Define Min-Max price range
// [x] Define Entry distant
// [x] Calcualte maximun lot size
// [x] Check if MaxOrder or NumberOfGrid exceed limit orders
// [x] Create array list all price in range
// [x] Check if can trade
// [x] Check if possible to place entry on every price in range
// [x] Create function to place order on every price in range
// [ ] Create function to re-place order on tp price
// [ ] Create function to modify in case of cannot place all order in price
// range
// [ ] Create function to close order
// [ ] Create function to modify order in case of slippage

//+------------------------------------------------------------------+
//| input                                                            |
//+------------------------------------------------------------------+
input double MaxPrice = 50000;
input double MinPrice = 0;
input int MaxOrders = NULL;
input double PriceRange = 10000;
input bool TradeAnywaywithMinimunLog = false;
input bool ClearOrdersOnInit = false;

int limitOrders;
CArrayDouble ArrayPrices;
double lotPerGrid;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit() {

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  ValidateInput();



  GetArrayPrice(ArrayPrices);

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("Basic info: SYMBOL_VOLUME_LIMIT= ", volumeLimit);

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("Basic info: ArrayPrices ", i, " = ", ArrayPrices[i]);
  }

  if (volumeLimit != 0 && ArrayPrices.Total() > volumeLimit) {

    AlertAndExit("Number of grid exceeded volume limit.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  lotPerGrid = Utility.GetGirdLotSize(_Symbol, ArrayPrices, MinPrice);

  Print("Basic info: lotPerGrid = ", lotPerGrid);

  if (lotPerGrid == 0) {

    if (TradeAnywaywithMinimunLog) {
      lotPerGrid = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    } else {
      return (INIT_PARAMETERS_INCORRECT);
    }
  }

  CArrayDouble missingDeals;
  int ordersTotal = OrdersTotal();
  int positionsTotal = PositionsTotal();

  Print("Basic info: ordersTotal = ", ordersTotal);
  Print("Basic info: positionsTotal = ", positionsTotal);

  if (!ordersTotal || !positionsTotal) {
    FilterOpenOrderAndPosition(missingDeals, ordersTotal, positionsTotal);
  }

  CArrayDouble buyLimitPrices;
  CArrayDouble buyStopPrices;

  FilterPriceType(missingDeals, buyLimitPrices, buyStopPrices);

  for (int i = 0; i < buyLimitPrices.Total(); i++) {
    Print("Basic info: buyLimitPrices ", i, " = ", buyLimitPrices[i]);

    double price = buyLimitPrices[i];

    if (cTrade.BuyLimit(lotPerGrid, price, _Symbol, 0, price + PriceRange)) {

      uint retcode = cTrade.ResultRetcode();
      Print("retcode: ", retcode);

      ulong orderTicket = cTrade.ResultOrder();
      Print("BuyLimit orderTicket: ", orderTicket);

      if (OrderSelect(orderTicket)) {
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
        Print("BuyLimit orderPrice: ", orderPrice);
      }

    } else {

      Print("Failed to place Buy Limit order. Error: ", GetLastError());

      uint retcode = cTrade.ResultRetcode();
      Print("retcode: ", retcode);
    }
  }

  for (int i = 0; i < buyStopPrices.Total(); i++) {
    Print("Basic info: buyStopPrices ", i, " = ", buyStopPrices[i]);

    double price = buyStopPrices[i];

    if (cTrade.BuyStop(lotPerGrid, price, _Symbol, 0, price + PriceRange)) {

      uint retcode = cTrade.ResultRetcode();
      Print("retcode: ", retcode);

      ulong orderTicket = cTrade.ResultOrder();
      Print("BuyStop orderTicket: ", orderTicket);

      if (OrderSelect(orderTicket)) {
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
        Print("BuyStop orderPrice: ", orderPrice);
      }

    } else {
      Print("Failed to place Buy Stop order. Error: ", GetLastError());

      uint retcode = cTrade.ResultRetcode();
      Print("retcode: ", retcode);
    }
  }

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

void ValidateInput() {

  if (MinPrice < 0)
    AlertAndExit("MinPrice cannot be less than 0.");

  if (MaxPrice > 0 && MinPrice >= MaxPrice)
    AlertAndExit("MinPrice must be less than MaxPrice.");

  if (PriceRange == 0)
    AlertAndExit("PriceRange cannot be 0.");

  const int accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }
}

void AlertAndExit(string message) {
  Alert(message);
  ExpertRemove();
  return;
}

int TradeAllowed() {
  return (MQLInfoInteger(MQL_TRADE_ALLOWED) == 1 &&
          TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 1);
}

void GetArrayPrice(CArrayDouble &array) {
  double prices[];
  int arraySize = NormalizeDouble((MaxPrice - MinPrice) / PriceRange, _Digits);

  int index;
  double price;
  for (index = 0, price = MinPrice; index <= arraySize;
       index++, price += PriceRange) {
    if (index == 0 && price == 0) {
      array.Add(_Point);
      continue;
    }
    array.Add(price);
  }
}

void FilterPriceType(CArrayDouble &arrayPrices, CArrayDouble &buyLimitPrices,
                     CArrayDouble &buyStopPrices) {
  // Buy Limit order is placed below the current market price.
  // Buy Stop order is placed above the current market price.

  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  for (int i = 0; i < arrayPrices.Total(); i++) {

    if (arrayPrices[i] < bid) {
      buyLimitPrices.Add(arrayPrices[i]);
    }

    if (arrayPrices[i] > bid) {
      buyStopPrices.Add(arrayPrices[i]);
    }
  }
}

void FilterOpenOrderAndPosition(CArrayDouble &missingDeals, int ordersTotal,
                                int positionsTotal) {
  CArrayDouble existDeals;

  if (ordersTotal > 0) {
    for (int i = 0; i < ordersTotal; i++) {
      ulong orderTicket = OrderGetTicket(i);
      if (OrderSelect(orderTicket)) {
        double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

        int arrayPricesSize = ArrayPrices.Total();

        for (int j = 0; j < arrayPricesSize; j++) {
          if (orderPrice > ArrayPrices[j] &&
              orderPrice < ArrayPrices[j] + PriceRange - _Point) {
            existDeals.Add(ArrayPrices[j]);
          }
        }
      }
    }
  }

  if (positionsTotal > 0) {
    for (int i = 0; i < positionsTotal; i++) {
      ulong positionTicket = PositionGetTicket(i);
      if (PositionSelectByTicket(positionTicket)) {
        double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);

        int arrayPricesSize = ArrayPrices.Total();

        for (int j = 0; j < arrayPricesSize; j++) {

          if (positionPrice > ArrayPrices[j] &&
              positionPrice < ArrayPrices[j] + PriceRange - _Point) {
            existDeals.Add(ArrayPrices[j]);
          }
        }
      }
    }
  }

  existDeals.Sort();

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    if (existDeals.Search(ArrayPrices[i]) == -1) {
      missingDeals.Add(ArrayPrices[i]);
    }
  }
}