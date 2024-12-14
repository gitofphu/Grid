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
  double GetGirdLotSize(const CArrayDouble &arrayPrices);
  void CloseAllOrder(const CArrayDouble &arrayPrices, const string comment);
  void FilterOpenBuyOrderAndPosition(CArrayDouble &arrayPrices,
                                     double gridGapSize, string comment,
                                     CArrayDouble &buyLimitPrices,
                                     CArrayDouble &buyStopPrices);
  void FilterOpenSellOrderAndPosition(CArrayDouble &arrayPrices,
                                      double gridGapSize, string comment,
                                      CArrayDouble &sellLimitPrices,
                                      CArrayDouble &sellStopPrices);
  void GetAllTimeHighLow(double &all_time_high, double &all_time_low);
  void GetFibonacciArrayPrices(double maxPrice, CArrayDouble &ArrayPrices);
  void GetExpandArrayPrices(double minPrice, double maxPrice,
                            CArrayDouble &arrayPrices);
  void GetArrayPrice(double minPrice, double maxPrice, double gridGapSize,
                     CArrayDouble &ArrayPrices);

private:
  void getExistDeals(CArrayDouble &arrayPrices, double gridGapSize,
                     double price, CArrayDouble &existDeals);
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
double MyUtility::GetGirdLotSize(const CArrayDouble &arrayPrices) {

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
  Print("maxDrowdownNumberOfGrid: ", maxDrowdownNumberOfGrid);

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

    Print("lot: ", lot, " from ", maxDrawdownPrice, " to ", arrayPrices[0],
          ", maximum drawdown: ", drawdown);

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
        ", lotPerGrid: ", NormalizeDouble(lotPerGrid, 2),
        ", profitPerLot: ", profitPerLot);

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
//|         gridGapSize     - grid gap size,                         |
//|         price           - current price,                         |
//|         existDeals      - existing deal array,                   |
//+------------------------------------------------------------------+
void MyUtility::getExistDeals(CArrayDouble &arrayPrices, double gridGapSize,
                              double price, CArrayDouble &existDeals) {
  for (int j = 0; j < arrayPrices.Total(); j++) {
    if (price >= arrayPrices[j] &&
        price <= arrayPrices[j] + gridGapSize - _Point) {
      existDeals.Add(arrayPrices[j]);
    }
  }
}

/**
 * ORDER_TYPE_BUY
 * ORDER_TYPE_SELL
 * ORDER_TYPE_BUY_LIMIT
 * ORDER_TYPE_SELL_LIMIT
 * ORDER_TYPE_BUY_STOP
 * ORDER_TYPE_SELL_STOP
 * ORDER_TYPE_BUY_STOP_LIMIT
 * ORDER_TYPE_SELL_STOP_LIMIT
 * ORDER_TYPE_CLOSE_BY
 */

/**
 * POSITION_TYPE_BUY
 * POSITION_TYPE_SELL
 */

//+------------------------------------------------------------------+
//| Access functions FilterOpenBuyOrderAndPosition(...).             |
//| INPUT : arrayPrices     - grid price array,                      |
//|         gridGapSize     - grid gap size,                         |
//|         comment         - deal identier,                         |
//|         buyLimitPrices  - return array of price,                 |
//|         buyStopPrices   - return array of price,                 |
//+------------------------------------------------------------------+
void MyUtility::FilterOpenBuyOrderAndPosition(CArrayDouble &arrayPrices,
                                              double gridGapSize,
                                              string comment,
                                              CArrayDouble &buyLimitPrices,
                                              CArrayDouble &buyStopPrices) {
  CArrayDouble existDeals;
  CArrayDouble missingDeals;

  int arrayPricesSize = arrayPrices.Total();

  for (int i = 0; i < OrdersTotal(); i++) {
    ulong orderTicket = OrderGetTicket(i);
    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      string symbol = OrderGetString(ORDER_SYMBOL);
      string orderComment = OrderGetString(ORDER_COMMENT);
      long orderType = OrderGetInteger(ORDER_TYPE);

      // Print("FilterOpenBuyOrderAndPosition orderTicket: ", orderTicket,
      //       ", orderType: ", orderType, ", orderPrice: ", orderPrice);

      if (orderComment != comment || symbol != _Symbol ||
          (orderType != ORDER_TYPE_BUY_LIMIT &&
           orderType != ORDER_TYPE_BUY_STOP))
        continue;

      getExistDeals(arrayPrices, gridGapSize, orderPrice, existDeals);
    }
  }

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);

      // Print("FilterOpenBuyOrderAndPosition positionTicket: ", positionTicket,
      //       ", positionType: ", positionType,
      //       ", positionPrice: ", positionPrice);

      if (positionComment != comment || symbol != _Symbol ||
          positionType != POSITION_TYPE_BUY)
        continue;

      getExistDeals(arrayPrices, gridGapSize, positionPrice, existDeals);
    }
  }

  Print("FilterOpenBuyOrderAndPosition existDeals: ", existDeals.Total());

  existDeals.Sort();

  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (existDeals.Search(arrayPrices[i]) == -1) {
      missingDeals.Add(arrayPrices[i]);
    }
  }

  Print("FilterOpenBuyOrderAndPosition missingDeals: ", missingDeals.Total());

  // Buy Stop order is placed above the current market price.
  // Buy Limit order is placed below the current market price.
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  // skip highest price
  for (int i = 0; i < arrayPrices.Total() - 1; i++) {
    if (missingDeals[i] < ask) {
      buyLimitPrices.Add(missingDeals[i]);
    }
    if (missingDeals[i] > ask) {
      buyStopPrices.Add(missingDeals[i]);
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions FilterOpenSellOrderAndPosition(...).            |
//| INPUT : arrayPrices     - grid price array,                      |
//|         gridGapSize     - grid gap size,                         |
//|         comment         - deal identier,                         |
//|         sellLimitPrices  - return array of price,                |
//|         sellStopPrices   - return array of price,                |
//+------------------------------------------------------------------+
void MyUtility::FilterOpenSellOrderAndPosition(CArrayDouble &arrayPrices,
                                               double gridGapSize,
                                               string comment,
                                               CArrayDouble &sellLimitPrices,
                                               CArrayDouble &sellStopPrices) {
  CArrayDouble existDeals;
  CArrayDouble missingDeals;

  int arrayPricesSize = arrayPrices.Total();

  for (int i = 0; i < OrdersTotal(); i++) {
    ulong orderTicket = OrderGetTicket(i);
    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      string symbol = OrderGetString(ORDER_SYMBOL);
      string orderComment = OrderGetString(ORDER_COMMENT);
      long orderType = OrderGetInteger(ORDER_TYPE);

      // Print("FilterOpenSellOrderAndPosition orderTicket: ", orderTicket,
      //       ", orderType: ", orderType, ", orderPrice: ", orderPrice);

      if (orderComment != comment || symbol != _Symbol ||
          (orderType != ORDER_TYPE_SELL_LIMIT &&
           orderType != ORDER_TYPE_SELL_STOP))
        continue;

      getExistDeals(arrayPrices, gridGapSize, orderPrice, existDeals);
    }
  }

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);

      // Print("FilterOpenSellOrderAndPosition positionTicket: ",
      // positionTicket,
      //       ", positionType: ", positionType,
      //       ", positionPrice: ", positionPrice);

      if (positionComment != comment || symbol != _Symbol ||
          positionType != POSITION_TYPE_SELL)
        continue;

      getExistDeals(arrayPrices, gridGapSize, positionPrice, existDeals);
    }
  }

  Print("FilterOpenSellOrderAndPosition existDeals: ", existDeals.Total());

  existDeals.Sort();

  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (existDeals.Search(arrayPrices[i]) == -1) {
      missingDeals.Add(arrayPrices[i]);
    }
  }

  Print("FilterOpenSellOrderAndPosition missingDeals: ", missingDeals.Total());

  // Sell Limit order is placed above the current market price.
  // Sell Stop order is placed below the current market price.
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  // skip lowest price
  for (int i = 1; i < arrayPrices.Total(); i++) {
    if (arrayPrices[i] > bid) {
      sellLimitPrices.Add(arrayPrices[i]);
    }
    if (arrayPrices[i] < bid) {
      sellStopPrices.Add(arrayPrices[i]);
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

//+------------------------------------------------------------------+
//| Access functions GetFibonacciArrayPrices(...).                   |
//| INPUT:  maxPrice          - max price of array,                  |
//|         arrayPrices       - return array of price,               |
//+------------------------------------------------------------------+
void MyUtility::GetFibonacciArrayPrices(double maxPrice,
                                        CArrayDouble &arrayPrices) {
  for (double price = _Point; price <= maxPrice;) {
    arrayPrices.Add(price);

    if (price != _Point) {
      price = NormalizeDouble(price + (arrayPrices[arrayPrices.Total() - 2]),
                              _Digits);
    } else {
      price = NormalizeDouble(price + _Point, _Digits);
    }
  }

  arrayPrices.Add(maxPrice);
}

//+------------------------------------------------------------------+
//| Access functions GetExpandArrayPrices(...).                      |
//| INPUT:  minPrice          - min price of array,                  |
//|         maxPrice          - max price of array,                  |
//|         arrayPrices       - return array of price,               |
//+------------------------------------------------------------------+
void MyUtility::GetExpandArrayPrices(double minPrice, double maxPrice,
                                     CArrayDouble &arrayPrices) {
  for (double i = minPrice; i <= maxPrice; i++) {
    double price;
    price = i / 10;

    if (price == 0) {
      price = 0.1;
    }

    double addPrice = NormalizeDouble(
        MathCeil(NormalizeDouble(price, _Digits)) * 0.1, _Digits);

    for (double j = i; j < i + 1; j += addPrice) {
      arrayPrices.Add(NormalizeDouble(j, _Digits));
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions GetArrayPrice(...).                             |
//| INPUT:  minPrice          - min price of array,                  |
//|         maxPrice          - max price of array,                  |
//|         gridGapSize       - grid gap size,                       |
//|         arrayPrices       - return array of price,               |
//+------------------------------------------------------------------+
void MyUtility::GetArrayPrice(double minPrice, double maxPrice,
                              double gridGapSize, CArrayDouble &ArrayPrices) {
  int arraySize = NormalizeDouble((maxPrice - minPrice) / gridGapSize, _Digits);

  int index;
  double price;
  for (index = 0, price = minPrice; index <= arraySize;
       index++, price += gridGapSize) {
    if (index == 0 && price == 0) {
      ArrayPrices.Add(NormalizeDouble(_Point, _Digits));
      continue;
    }
    ArrayPrices.Add(NormalizeDouble(price, _Digits));
  }
}
