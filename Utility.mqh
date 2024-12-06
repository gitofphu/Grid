//+------------------------------------------------------------------+
//|                                                      MyUtility.mqh |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Trade/Trade.mqh>
CTrade cTrade;

#include <Trade/AccountInfo.mqh>
CAccountInfo cAccountInfo;

#include <Arrays/ArrayDouble.mqh>
CArrayDouble;

#include <Arrays/ArrayLong.mqh>
CArrayLong;

class MyUtility {
public:
  MyUtility();
  ~MyUtility();
  void AlertAndExit(string message);
  double CalculateLot(const string symbol,
                      const ENUM_ORDER_TYPE trade_operation,
                      const double profit, const double open_price,
                      const double close_price);
  double GetGirdLotSize(const string symbol, const CArrayDouble &arrayPrices);
  void CloseAllOrder(const CArrayDouble &arrayPrices, const string comment);
  void FilterOpenOrderAndPosition(CArrayDouble &arrayPrices, double PriceRange,
                                  string comment, CArrayDouble &missingDeals);
  void GetAllTimeHighLow(double &all_time_high, double &all_time_low);

private:
  void getExistDeals(CArrayDouble &arrayPrices, double PriceRange, double price,
                     CArrayDouble &existDeals);
};

//+------------------------------------------------------------------+
//| Constructor(s):                                                  |
//+------------------------------------------------------------------+
MyUtility::MyUtility() {}

//+------------------------------------------------------------------+
//| Destructor:                                                      |
//+------------------------------------------------------------------+
MyUtility::~MyUtility() {}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Access functions AlertAndExit(...).                              |
//| INPUT:  message         - message                                |
//+------------------------------------------------------------------+
void MyUtility::AlertAndExit(string message) {
  Alert(message);
  ExpertRemove();
  return;
}

//+------------------------------------------------------------------+
//| Access functions CalculateLot(...).                              |
//| INPUT:  name            - symbol name,                           |
//|         trade_operation - trade operation,                       |
//|         profit          - expect profit,                         |
//|         price_open      - price of the opening position,         |
//|         price_close     - price of the closing position.         |
//+------------------------------------------------------------------+
double MyUtility::CalculateLot(const string symbol,
                               const ENUM_ORDER_TYPE trade_operation,
                               const double profit, const double open_price,
                               const double close_price) {
  double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
  double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
  double contract_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE);

  double price_diff = 0;

  switch (trade_operation) {
  case ORDER_TYPE_BUY:
    price_diff = close_price - open_price;
    break;
  case ORDER_TYPE_SELL:
    price_diff = open_price - close_price;
    break;
  default:
    Print("MyUtility::CalculateLot: Invalid order type");
    return (0.0);
  }

  double lots = profit / (price_diff * contract_size * tick_value);
  return lots;
}

//+------------------------------------------------------------------+
//| Access functions GetGirdLotSize(...).                            |
//| INPUT:  name            - symbol name,                           |
//|         arrayPrices     - grid price array,                      |
//+------------------------------------------------------------------+
double MyUtility::GetGirdLotSize(const string symbol,
                                 const CArrayDouble &arrayPrices) {

  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double maxDrawdownPrice = 0;
  int maxDrowdownNumberOfGrid = 0;
  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (arrayPrices[i] > bid)
      break;

    maxDrawdownPrice = arrayPrices[i];
    maxDrowdownNumberOfGrid = i;
  }

  Print("maxDrawdownPrice: ", maxDrawdownPrice);

  // calculate lot size base on balance
  double totalLot = 0.0;
  for (double lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
       lot <= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
       lot += SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)) {

    lot = NormalizeDouble(lot, 2);

    double profit = cAccountInfo.OrderProfitCheck(
        _Symbol, ORDER_TYPE_BUY, lot, maxDrawdownPrice, arrayPrices[0]);

    double marginRequire = cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY,
                                                    lot, maxDrawdownPrice);

    double drawdown = NormalizeDouble(profit - marginRequire, 2);

    Print("lot: ", lot, ", maximum drawdown: ", drawdown);

    if (NormalizeDouble(cAccountInfo.Balance() + drawdown, 2) <= 0)
      break;

    totalLot = lot;
  }

  double lotPerGrid = totalLot / maxDrowdownNumberOfGrid;

  double profitPerLot = cAccountInfo.OrderProfitCheck(
      _Symbol, ORDER_TYPE_BUY, lotPerGrid, arrayPrices[arrayPrices.Total() - 2],
      arrayPrices[arrayPrices.Total() - 1]);

  Print("totalLot: ", totalLot,
        ", maxDrowdownNumberOfGrid: ", maxDrowdownNumberOfGrid,
        ", lotPerGrid: ", lotPerGrid, ", profitPerLot: ", profitPerLot);

  if (lotPerGrid < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
    string message = "MyUtility::GetGirdLotSize: Balance may not be enough for "
                     "all price range. "
                     "Please increase price range or deposit more balance.";
    Alert(message);
    return (0.0);
  }

  return NormalizeDouble(lotPerGrid, 2);
}

//+------------------------------------------------------------------+
//| Access functions CloseAllOrder().                                |
//+------------------------------------------------------------------+
void MyUtility::CloseAllOrder(const CArrayDouble &arrayPrices,
                              const string comment) {
  Print("CloseAllOrder comment: ", comment);

  int ordersTotal = OrdersTotal();
  CArrayLong tickets;

  if (ordersTotal > 0) {
    for (int i = 0; i < ordersTotal; i++) {
      ulong orderTicket = OrderGetTicket(i);

      if (OrderSelect(orderTicket)) {
        if (OrderGetString(ORDER_SYMBOL) == _Symbol &&
            OrderGetString(ORDER_COMMENT) == comment) {

          if (arrayPrices.Total()) {
            double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);

            int index = arrayPrices.SearchLinear(orderPrice);
            if (index != -1)
              continue;
          }

          tickets.Add(orderTicket);
        }
      }
    }

    Print("MyUtility::CloseAllOrder tickets.Total(): ", tickets.Total());

    for (int i = 0; i < tickets.Total(); i++) {
      Print("MyUtility::CloseAllOrder ticket: ", tickets[i]);

      if (cTrade.OrderDelete(tickets[i])) {

        Print("MyUtility::CloseAllOrder Order: ", tickets[i], " deleted.");
        uint retcode = cTrade.ResultRetcode();
        Print("MyUtility::CloseAllOrder retcode: ", retcode);

      } else {

        Print("MyUtility::CloseAllOrder Failed to delete order: ", tickets[i],
              ". Error: ", GetLastError());
        uint retcode = cTrade.ResultRetcode();
        Print("MyUtility::CloseAllOrder retcode: ", retcode);
      }
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions getExistDeals(...).                             |
//| INPUT:  arrayPrices     - grid price array,                      |
//|         priceRange      - grid gap size,                         |
//|         price           - current price,                         |
//|         existDeals      - existing deal array,                   |
//+------------------------------------------------------------------+
void MyUtility::getExistDeals(CArrayDouble &arrayPrices, double priceRange,
                              double price, CArrayDouble &existDeals) {
  for (int j = 0; j < arrayPrices.Total(); j++) {
    if (price >= arrayPrices[j] &&
        price <= arrayPrices[j] + priceRange - _Point) {
      existDeals.Add(arrayPrices[j]);
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions FilterOpenOrderAndPosition(...).                |
//| INPUT : arrayPrices     - grid price array,                      |
//|         priceRange      - grid gap size,                         |
//|         comment         - deal identier,                         |
//|         missingDeals    - missing deal array,                    |
//+------------------------------------------------------------------+
void MyUtility::FilterOpenOrderAndPosition(CArrayDouble &arrayPrices,
                                           double priceRange, string comment,
                                           CArrayDouble &missingDeals) {
  CArrayDouble existDeals;

  int arrayPricesSize = arrayPrices.Total();

  for (int i = 0; i < OrdersTotal(); i++) {
    ulong orderTicket = OrderGetTicket(i);
    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      string symbol = OrderGetString(ORDER_SYMBOL);
      string orderComment = OrderGetString(ORDER_COMMENT);

      if (orderComment != comment || symbol != _Symbol)
        continue;

      getExistDeals(arrayPrices, priceRange, orderPrice, existDeals);
    }
  }

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);

      if (positionComment != comment || symbol != _Symbol)
        continue;

      getExistDeals(arrayPrices, priceRange, positionPrice, existDeals);
    }
  }

  Print("existDeals: ", existDeals.Total());

  existDeals.Sort();

  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (existDeals.Search(arrayPrices[i]) == -1) {
      missingDeals.Add(arrayPrices[i]);
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions GetAllTimeHighLow(...).                         |
//| INPUT:  all_time_high     - return all time high value,          |
//|         all_time_low      - return all time low value,           |
//+------------------------------------------------------------------+
void MyUtility::GetAllTimeHighLow(double &all_time_high, double &all_time_low) {
  all_time_high = -DBL_MAX; // Initialize with the lowest possible value
  all_time_low = DBL_MAX;   // Initialize with the highest possible value

  // Get the total number of bars available
  long total_bars = SeriesInfoInteger(_Symbol, PERIOD_MN1, SERIES_BARS_COUNT);
  if (total_bars <= 0) {
    Print("No data available for the symbol: ", _Symbol,
          " Error: ", GetLastError());
    return;
  }

  // Loop through all bars to find the high and low
  for (long i = 0; i < total_bars; i++) {
    double high = iHigh(_Symbol, PERIOD_MN1, i);
    double low = iLow(_Symbol, PERIOD_MN1, i);

    if (high > all_time_high)
      all_time_high = high;
    if (low < all_time_low)
      all_time_low = low;
  }
}