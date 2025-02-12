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
  void CloseOrderOutsideArrayPrices(const CArrayDouble &arrayPrices,
                                    const string comment, const double lot);
  void CloseOrderOutsideArrayPricesByType(const CArrayDouble &arrayPrices,
                                          const string comment,
                                          const double lot,
                                          const ENUM_ORDER_TYPE type);
  void FilterOpenBuyOrderAndPosition(CArrayDouble &arrayPrices,
                                     double gridGapSize, string comment,
                                     CArrayDouble &buyLimitPrices,
                                     CArrayDouble &buyStopPrices);
  void FilterOpenSellOrderAndPosition(CArrayDouble &arrayPrices,
                                      double gridGapSize, string comment,
                                      CArrayDouble &sellLimitPrices,
                                      CArrayDouble &sellStopPrices);
  void GetAllTimeHighLow(double &all_time_high, double &all_time_low);
  void GetFibonacciArrayPrices(double maxPrice, CArrayDouble &arrayPrices);
  void GetExpandArrayPrices(double minPrice, double maxPrice,
                            CArrayDouble &arrayPrices);
  void GetArrayPrice(double minPrice, double maxPrice, double gridGapSize,
                     CArrayDouble &arrayPrices);
  double NormalizeDoubleTwoDigits(double num);
  void PlaceBuyOrders(CArrayDouble &buyLimitPrices, CArrayDouble &buyStopPrices,
                      double lot, double gridGapSize, string comment,
                      bool &orderPriceInvalid);
  void PlaceSellOrders(CArrayDouble &sellLimitPrices,
                       CArrayDouble &sellStopPrices, double lot,
                       double gridGapSize, string comment,
                       bool &orderPriceInvalid);
  void getExistDeals(CArrayDouble &arrayPrices, double gridGapSize,
                     double price, CArrayDouble &existDeals);
  void getExistDealsWithLots(CArrayDouble &arrayPrices, double gridGapSize,
                             double price, double lot, CArrayDouble &existDeals,
                             CArrayDouble &existDealsLots);

  void PlaceBuyLimitOrder(double price, double lot, double tp, string comment,
                          bool &orderPriceInvalid);
  void PlaceBuyStopOrder(double price, double lot, double tp, string comment,
                         bool &orderPriceInvalid);
  void PlaceSellLimitOrder(double price, double lot, double tp, string comment,
                           bool &orderPriceInvalid);
  void PlaceSellStopOrder(double price, double lot, double tp, string comment,
                          bool &orderPriceInvalid);
  void CloseAllOrders();
  double Clamp(double value, double min_value, double max_value);
  bool IsInRange(double value, double min_value, double max_value);

  string GetOrderTypeString(ENUM_ORDER_TYPE type);
  string GetDealReasonString(ENUM_DEAL_REASON reason);
  string GetOrderTypeStringFromTransDeal(const MqlTradeTransaction &trans);
  long GetOrderTypeFromTransDeal(const MqlTradeTransaction &trans);

private:
  void deleteOrder(ulong ticket);
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
//| INPUT:  arrayPrices     - grid price array,                      |
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

    lot = NormalizeDoubleTwoDigits(lot);

    double profit = cAccountInfo.OrderProfitCheck(
        _Symbol, ORDER_TYPE_BUY, lot, maxDrawdownPrice, arrayPrices[0]);

    double marginRequire = cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY,
                                                    lot, maxDrawdownPrice);

    double drawdown = NormalizeDoubleTwoDigits(profit - marginRequire);

    Print("lot: ", lot, " from ", maxDrawdownPrice, " to ", arrayPrices[0],
          ", maximum drawdown: ", drawdown);

    if (NormalizeDoubleTwoDigits(cAccountInfo.Balance() + drawdown) <= 0)
      break;

    totalLot = lot;
  }

  double lotPerGrid = totalLot / maxDrowdownNumberOfGrid;

  double profitPerLot = cAccountInfo.OrderProfitCheck(
      _Symbol, ORDER_TYPE_BUY, lotPerGrid, arrayPrices[arrayPrices.Total() - 2],
      arrayPrices[arrayPrices.Total() - 1]);

  Print("totalLot: ", totalLot,
        ", maxDrowdownNumberOfGrid: ", maxDrowdownNumberOfGrid,
        ", lotPerGrid: ", NormalizeDoubleTwoDigits(lotPerGrid),
        ", profitPerLot: ", profitPerLot);

  if (lotPerGrid < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
    string message = "MyUtility::GetGirdLotSize: Balance may not be enough for "
                     "all price range. "
                     "Please increase price range or deposit more balance.";
    Alert(message);
    return (0.0);
  }

  return NormalizeDoubleTwoDigits(lotPerGrid);
}

//+------------------------------------------------------------------+
//| Access functions CloseOrderOutsideArrayPrices().                 |
//| INPUT:  arrayPrices     - grid price array,                      |
//|         comment         - comment,                               |
//|         lot             - lot size,                              |
//+------------------------------------------------------------------+
void MyUtility::CloseOrderOutsideArrayPrices(const CArrayDouble &arrayPrices,
                                             const string comment,
                                             const double lot) {
  Print("CloseOrderOutsideArrayPrices comment: ", comment, ", lot: ", lot);

  int ordersTotal = OrdersTotal();
  CArrayLong tickets;

  if (ordersTotal == 0)
    return;

  for (int i = 0; i < ordersTotal; i++) {
    ulong orderTicket = OrderGetTicket(i);

    if (OrderSelect(orderTicket)) {
      if (OrderGetString(ORDER_SYMBOL) == _Symbol &&
          OrderGetString(ORDER_COMMENT) == comment) {

        if (arrayPrices.Total()) {
          double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
          double currVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);

          int index = arrayPrices.SearchLinear(orderPrice);

          // remove if not found in array price order lot not match
          if (index != -1 && lot == currVolume)
            continue;
        }

        tickets.Add(orderTicket);
      }
    }
  }

  Print("MyUtility::CloseOrderOutsideArrayPrices tickets.Total(): ",
        tickets.Total());

  for (int i = 0; i < tickets.Total(); i++) {
    Print("MyUtility::CloseOrderOutsideArrayPrices ticket: ", tickets[i]);

    if (cTrade.OrderDelete(tickets[i])) {

      Print("MyUtility::CloseOrderOutsideArrayPrices Order: ", tickets[i],
            " deleted.");
      uint retcode = cTrade.ResultRetcode();
      Print("MyUtility::CloseOrderOutsideArrayPrices retcode: ", retcode);

    } else {

      Print("MyUtility::CloseOrderOutsideArrayPrices Failed to delete order: ",
            tickets[i], ". Error: ", GetLastError());
      uint retcode = cTrade.ResultRetcode();
      Print("MyUtility::CloseOrderOutsideArrayPrices retcode: ", retcode);
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions CloseOrderOutsideArrayPricesByType().           |
//| INPUT:  arrayPrices     - grid price array,                      |
//|         comment         - comment,                               |
//|         lot             - lot size,                              |
//|         type            - order type,                            |
//+------------------------------------------------------------------+
void MyUtility::CloseOrderOutsideArrayPricesByType(
    const CArrayDouble &arrayPrices, const string comment, const double lot,
    const ENUM_ORDER_TYPE type) {
  // comment pattern: <ea_name>|<IsFillIn>

  Print("CloseOrderOutsideArrayPricesByType arrayPrices.Total():",
        arrayPrices.Total(), ", comment: ", comment, ", lot: ", lot,
        ", type: ", GetOrderTypeString(type));

  int ordersTotal = OrdersTotal();
  CArrayLong tickets;

  if (ordersTotal == 0)
    return;

  for (int i = 0; i < ordersTotal; i++) {
    ulong orderTicket = OrderGetTicket(i);
    if (OrderSelect(orderTicket)) {
      string symbol = OrderGetString(ORDER_SYMBOL);
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      string orderComment = OrderGetString(ORDER_COMMENT);
      long orderType = OrderGetInteger(ORDER_TYPE);

      string splitComment[];
      int count = StringSplit(orderComment, '|', splitComment);

      if (count == 1 && orderComment != comment)
        continue;
      else if (count > 1 && splitComment[0] != comment)
        continue;
      else if (symbol != _Symbol || orderType != type)
        continue;

      bool isFillIn = false;

      if (count > 1) {
        isFillIn = splitComment[1] == "T";
      }

      double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);

      int index = arrayPrices.SearchLinear(orderPrice);

      // Print(
      //     "MyUtility::CloseOrderOutsideArrayPricesByType isFillIn: ",
      //     isFillIn,
      //     ", orderComment: ", orderComment, ", orderPrice: ", orderPrice,
      //     ", index: ", index, ", orderTicket: ", orderTicket);

      // if order not found in array price, remove
      if (index == -1) {
        tickets.Add(orderTicket);
      }
      // if order found in array price but lot not match, remove
      else if (index != -1 && (lot != orderVolume && !isFillIn)) {
        tickets.Add(orderTicket);
      }
    }
  }

  Print("MyUtility::CloseOrderOutsideArrayPricesByType tickets.Total(): ",
        tickets.Total());

  for (int i = 0; i < tickets.Total(); i++) {
    Print("MyUtility::CloseOrderOutsideArrayPricesByType ticket: ", tickets[i]);

    if (cTrade.OrderDelete(tickets[i])) {

      Print("MyUtility::CloseOrderOutsideArrayPricesByType Order: ", tickets[i],
            " deleted.");
      uint retcode = cTrade.ResultRetcode();
      Print("MyUtility::CloseOrderOutsideArrayPricesByType retcode: ", retcode);

    } else {

      Print("MyUtility::CloseOrderOutsideArrayPricesByType Failed to delete "
            "order: ",
            tickets[i], ". Error: ", GetLastError());
      uint retcode = cTrade.ResultRetcode();
      Print("MyUtility::CloseOrderOutsideArrayPricesByType retcode: ", retcode);
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

//+------------------------------------------------------------------+
//| Access functions getExistDealsWithLots(...).                     |
//| INPUT:  arrayPrices     - grid price array,                      |
//|         gridGapSize     - grid gap size,                         |
//|         price           - current price,                         |
//|         lot             - current price lot,                     |
//|         existDeals      - existing deal array,                   |
//|         existDealsLots  - existing deal lots array,              |
//+------------------------------------------------------------------+
void MyUtility::getExistDealsWithLots(CArrayDouble &arrayPrices,
                                      double gridGapSize, double price,
                                      double lot, CArrayDouble &existDeals,
                                      CArrayDouble &existDealsLots) {
  for (int j = 0; j < arrayPrices.Total(); j++) {
    if (price >= arrayPrices[j] &&
        price <= arrayPrices[j] + gridGapSize - _Point) {
      existDeals.Add(arrayPrices[j]);
      existDealsLots.Add(lot);
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

  // for (int i = 0; i < existDeals.Total(); i++) {
  //   Print("buy existDeals:", existDeals[i]);
  // }

  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (existDeals.Search(arrayPrices[i]) == -1) {
      missingDeals.Add(arrayPrices[i]);
    }
  }

  Print("FilterOpenBuyOrderAndPosition missingDeals: ", missingDeals.Total());

  // for (int i = 0; i < missingDeals.Total(); i++) {
  //   Print("buy missingDeals:", missingDeals[i]);
  // }

  // Buy Stop order is placed above the current market price.
  // Buy Limit order is placed below the current market price.
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);

  for (int i = 0; i < missingDeals.Total(); i++) {
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

  // for (int i = 0; i < existDeals.Total(); i++) {
  //   Print("sell existDeals:", existDeals[i]);
  // }

  for (int i = 0; i < arrayPrices.Total(); i++) {
    if (existDeals.Search(arrayPrices[i]) == -1) {
      missingDeals.Add(arrayPrices[i]);
    }
  }

  Print("FilterOpenSellOrderAndPosition missingDeals: ", missingDeals.Total());

  // for (int i = 0; i < missingDeals.Total(); i++) {
  //   Print("sell missingDeals:", missingDeals[i]);
  // }

  // Sell Limit order is placed above the current market price.
  // Sell Stop order is placed below the current market price.
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  for (int i = 0; i < missingDeals.Total(); i++) {
    if (missingDeals[i] > bid) {
      sellLimitPrices.Add(missingDeals[i]);
    }
    if (missingDeals[i] < bid) {
      sellStopPrices.Add(missingDeals[i]);
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
      price = NormalizeDoubleTwoDigits(price +
                                       (arrayPrices[arrayPrices.Total() - 2]));
    } else {
      price = NormalizeDoubleTwoDigits(price + _Point);
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

    double addPrice = NormalizeDoubleTwoDigits(
        MathCeil(NormalizeDoubleTwoDigits(price)) * 0.1);

    for (double j = i; j < i + 1; j += addPrice) {
      arrayPrices.Add(NormalizeDoubleTwoDigits(j));
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions GetArrayPrice(...).                             |
//| INPUT:  startPrice        - start price of array,                |
//|         endPrice          - end price of array,                  |
//|         gridGapSize       - grid gap size,                       |
//|         arrayPrices       - return array of price,               |
//+------------------------------------------------------------------+
void MyUtility::GetArrayPrice(double startPrice, double endPrice,
                              double gridGapSize, CArrayDouble &arrayPrices) {
  Print("startPrice: ", startPrice, ", endPrice: ", endPrice,
        ", gridGapSize: ", gridGapSize);

  if (arrayPrices.Total() > 0) {
    arrayPrices.Shutdown();
  }

  for (double price = endPrice; price >= startPrice;
       price = NormalizeDoubleTwoDigits(price - gridGapSize)) {
    if (price != 0) {
      arrayPrices.Add(NormalizeDoubleTwoDigits(price));
    } else {
      arrayPrices.Add(NormalizeDoubleTwoDigits(_Point));
    }
  }
}

//+------------------------------------------------------------------+
//| Access functions NormalizeDoubleTwoDigits(...).                  |
//| INPUT:  number          - double number,                         |
//+------------------------------------------------------------------+
double MyUtility::NormalizeDoubleTwoDigits(double number) {
  return NormalizeDouble(number, 2);
}

//+------------------------------------------------------------------+
//| Access functions PlaceBuyOrders(...).                            |
//| INPUT:  buyLimitPrices    - array of buy limit price,            |
//|         buyStopPrices     - array of buy stop price,             |
//|         lot               - lot size,                            |
//|         gridGapSize       - grid gap size,                       |
//|         comment           - order identification,                |
//|         orderPriceInvalid - check if order place at wrong price, |
//+------------------------------------------------------------------+
void MyUtility::PlaceBuyOrders(CArrayDouble &buyLimitPrices,
                               CArrayDouble &buyStopPrices, double lot,
                               double gridGapSize, string comment,
                               bool &orderPriceInvalid) {

  for (int i = 0; i < buyLimitPrices.Total(); i++) {
    PlaceBuyLimitOrder(buyLimitPrices[i], lot, buyLimitPrices[i] + gridGapSize,
                       comment, orderPriceInvalid);
  }

  for (int i = 0; i < buyStopPrices.Total(); i++) {
    PlaceBuyStopOrder(buyStopPrices[i], lot, buyStopPrices[i] + gridGapSize,
                      comment, orderPriceInvalid);
  }
}

//+------------------------------------------------------------------+
//| Access functions PlaceBuyLimitOrder(...).                        |
//| INPUT:  price             - price,                               |
//|         lot               - lot size,                            |
//|         tp                - tp price,                            |
//|         comment           - order identification,                |
//|         orderPriceInvalid - check if order place at wrong price, |
//+------------------------------------------------------------------+
void MyUtility::PlaceBuyLimitOrder(double price, double lot, double tp,
                                   string comment, bool &orderPriceInvalid) {

  Print("Basic info: PlaceBuyLimitOrder = ", price,
        ", TP = ", NormalizeDoubleTwoDigits(tp));

  if (cTrade.BuyLimit(lot, price, _Symbol, 0, NormalizeDoubleTwoDigits(tp),
                      ORDER_TIME_GTC, 0, comment)) {

    uint retcode = cTrade.ResultRetcode();
    ulong orderTicket = cTrade.ResultOrder();

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      Print("BuyLimit result, retcode: ", retcode,
            ", orderTicket: ", orderTicket, ", orderPrice: ", orderPrice);

      if (orderPrice != price) {
        orderPriceInvalid = true;
      }
    }

  } else {

    Print("Failed to place Buy Limit order. Error: ", GetLastError());

    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}

//+------------------------------------------------------------------+
//| Access functions PlaceBuyStopOrder(...).                         |
//| INPUT:  price             - price,                               |
//|         lot               - lot size,                            |
//|         tp                - tp price,                            |
//|         comment           - order identification,                |
//|         orderPriceInvalid - check if order place at wrong price, |
//+------------------------------------------------------------------+
void MyUtility::PlaceBuyStopOrder(double price, double lot, double tp,
                                  string comment, bool &orderPriceInvalid) {

  Print("Basic info: PlaceBuyStopOrder = ", price,
        ", TP = ", NormalizeDoubleTwoDigits(tp));

  if (cTrade.BuyStop(lot, price, _Symbol, 0, NormalizeDoubleTwoDigits(tp),
                     ORDER_TIME_GTC, 0, comment)) {

    uint retcode = cTrade.ResultRetcode();
    ulong orderTicket = cTrade.ResultOrder();

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      Print("BuyStop result, retcode: ", retcode,
            ", orderTicket: ", orderTicket, ", orderPrice: ", orderPrice);

      if (orderPrice != price) {
        orderPriceInvalid = true;
      }
    }

  } else {
    Print("Failed to place Buy Stop order. Error: ", GetLastError());

    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}

//+------------------------------------------------------------------+
//| Access functions PlaceSellOrders(...).                           |
//| INPUT:  sellLimitPrices    - array of sell limit price,          |
//|         sellStopPrices     - array of sell stop price,           |
//|         lot               - lot size,                            |
//|         gridGapSize       - grid gap size,                       |
//|         comment           - order identification,                |
//|         orderPriceInvalid - check if order place at wrong price, |
//+------------------------------------------------------------------+
void MyUtility::PlaceSellOrders(CArrayDouble &sellLimitPrices,
                                CArrayDouble &sellStopPrices, double lot,
                                double gridGapSize, string comment,
                                bool &orderPriceInvalid) {

  for (int i = 0; i < sellLimitPrices.Total(); i++) {
    PlaceSellLimitOrder(sellLimitPrices[i], lot,
                        sellLimitPrices[i] - gridGapSize, comment,
                        orderPriceInvalid);
  }

  for (int i = 0; i < sellStopPrices.Total(); i++) {
    PlaceSellStopOrder(sellStopPrices[i], lot, sellStopPrices[i] - gridGapSize,
                       comment, orderPriceInvalid);
  }
}

//+------------------------------------------------------------------+
//| Access functions PlaceSellLimitOrder(...).                       |
//| INPUT:  price             - price,                               |
//|         lot               - lot size,                            |
//|         tp                - tp price,                            |
//|         comment           - order identification,                |
//|         orderPriceInvalid - check if order place at wrong price, |
//+------------------------------------------------------------------+
void MyUtility::PlaceSellLimitOrder(double price, double lot, double tp,
                                    string comment, bool &orderPriceInvalid) {

  Print("Basic info: PlaceSellLimitOrder = ", price,
        ", TP = ", NormalizeDoubleTwoDigits(tp));

  if (cTrade.SellLimit(lot, price, _Symbol, 0, NormalizeDoubleTwoDigits(tp),
                       ORDER_TIME_GTC, 0, comment)) {

    uint retcode = cTrade.ResultRetcode();
    ulong orderTicket = cTrade.ResultOrder();

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      Print("SellLimit result, retcode: ", retcode,
            ", orderTicket: ", orderTicket, ", orderPrice: ", orderPrice);

      if (orderPrice != price) {
        orderPriceInvalid = true;
      }
    }

  } else {

    Print("Failed to place Sell Limit order. Error: ", GetLastError());

    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}

//+------------------------------------------------------------------+
//| Access functions PlaceSellStopOrder(...).                        |
//| INPUT:  price             - price,                               |
//|         lot               - lot size,                            |
//|         tp                - tp,                                  |
//|         comment           - order identification,                |
//|         orderPriceInvalid - check if order place at wrong price, |
//+------------------------------------------------------------------+
void MyUtility::PlaceSellStopOrder(double price, double lot, double tp,
                                   string comment, bool &orderPriceInvalid) {

  Print("Basic info: PlaceSellStopOrder = ", price,
        ", TP = ", NormalizeDoubleTwoDigits(tp));

  if (cTrade.SellStop(lot, price, _Symbol, 0, NormalizeDoubleTwoDigits(tp),
                      ORDER_TIME_GTC, 0, comment)) {

    uint retcode = cTrade.ResultRetcode();
    ulong orderTicket = cTrade.ResultOrder();

    if (OrderSelect(orderTicket)) {
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      Print("SellStop result, retcode: ", retcode,
            ", orderTicket: ", orderTicket, ", orderPrice: ", orderPrice);

      if (orderPrice != price) {
        orderPriceInvalid = true;
      }
    }

  } else {
    Print("Failed to place Sell Stop order. Error: ", GetLastError());

    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}

//+------------------------------------------------------------------+
//| Access functions GetOrderTypeString().                           |
//| INPUT:  type     - enum order type,                              |
//+------------------------------------------------------------------+
string MyUtility::GetOrderTypeString(ENUM_ORDER_TYPE type) {
  switch (type) {
  case ORDER_TYPE_BUY:
    return "ORDER_TYPE_BUY";
  case ORDER_TYPE_SELL:
    return "ORDER_TYPE_SELL";
  case ORDER_TYPE_BUY_LIMIT:
    return "ORDER_TYPE_BUY_LIMIT";
  case ORDER_TYPE_SELL_LIMIT:
    return "ORDER_TYPE_SELL_LIMIT";
  case ORDER_TYPE_BUY_STOP:
    return "ORDER_TYPE_BUY_STOP";
  case ORDER_TYPE_SELL_STOP:
    return "ORDER_TYPE_SELL_STOP";
  case ORDER_TYPE_BUY_STOP_LIMIT:
    return "ORDER_TYPE_BUY_STOP_LIMIT";
  case ORDER_TYPE_SELL_STOP_LIMIT:
    return "ORDER_TYPE_SELL_STOP_LIMIT";
  case ORDER_TYPE_CLOSE_BY:
    return "ORDER_TYPE_CLOSE_BY";
  default:
    return "UNKNOWN";
  }
}

//+------------------------------------------------------------------+
//| Access functions GetDealReasonString().                          |
//| INPUT:  type     - enum deal reason,                             |
//+------------------------------------------------------------------+
string MyUtility::GetDealReasonString(ENUM_DEAL_REASON reason) {
  switch (reason) {
  case DEAL_REASON_CLIENT:
    return "The deal was executed as a result of activation of an order "
           "placed from a desktop terminal.";
  case DEAL_REASON_MOBILE:
    return "The deal was executed as a result of activation of an order "
           "placed from a mobile application.";
  case DEAL_REASON_WEB:
    return "The deal was executed as a result of activation of an order "
           "placed from the web platform.";
  case DEAL_REASON_EXPERT:
    return "The deal was executed as a result of activation of an order placed "
           "from an MQL5 program, i.e. an Expert Advisor or a script.";
  case DEAL_REASON_SL:
    return "The deal was executed as a result of Stop Loss activation.";
  case DEAL_REASON_TP:
    return "The deal was executed as a result of Take Profit activation.";
  case DEAL_REASON_SO:
    return "The deal was executed as a result of the Stop Out event.";
  case DEAL_REASON_ROLLOVER:
    return "The deal was executed due to a rollover.";
  case DEAL_REASON_VMARGIN:
    return "The deal was executed after charging the variation margin.";
  case DEAL_REASON_SPLIT:
    return "The deal was executed after the split (price reduction) of an "
           "instrument, which had an open position during split announcement.";
  case DEAL_REASON_CORPORATE_ACTION:
    return "The deal was executed as a result of a corporate action: merging "
           "or "
           "renaming a security, transferring a client to another account, "
           "etc.";
  default:
    return "UNKNOWN";
  }
}

//+------------------------------------------------------------------+
//| Access functions GetOrderTypeStringFromTransDeal().              |
//| INPUT:  trans     - &trans,                                      |
//+------------------------------------------------------------------+
string
MyUtility::GetOrderTypeStringFromTransDeal(const MqlTradeTransaction &trans) {
  string strType = "";

  if (HistoryDealSelect(trans.deal)) {
    long deal_pos_id = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);

    if (HistoryOrderSelect(deal_pos_id)) {
      long orderType;
      HistoryOrderGetInteger(deal_pos_id, ORDER_TYPE, orderType);

      strType = GetOrderTypeString((ENUM_ORDER_TYPE)orderType);
    }
  }

  return strType;
}

//+------------------------------------------------------------------+
//| Access functions GetOrderTypeFromTransDeal().                    |
//| INPUT:  trans     - &trans,                                      |
//+------------------------------------------------------------------+
long MyUtility::GetOrderTypeFromTransDeal(const MqlTradeTransaction &trans) {
  long orderType = -1;

  if (HistoryDealSelect(trans.deal)) {
    long deal_pos_id = HistoryDealGetInteger(trans.deal, DEAL_POSITION_ID);

    if (HistoryOrderSelect(deal_pos_id)) {
      HistoryOrderGetInteger(deal_pos_id, ORDER_TYPE, orderType);
    }
  }

  return orderType;
}

//+------------------------------------------------------------------+
//| Access functions CloseAllOrders().                               |
//+------------------------------------------------------------------+
void MyUtility::CloseAllOrders() {
  Print("CloseAllOrders: ", _Symbol);
  cTrade.SetAsyncMode(false);
  int ordersTotal = OrdersTotal();
  CArrayLong tickets;
  if (ordersTotal > 0) {
    for (int i = 0; i < ordersTotal; i++) {
      ulong orderTicket = OrderGetTicket(i);
      if (OrderSelect(orderTicket))
        if (OrderGetString(ORDER_SYMBOL) == _Symbol)
          tickets.Add(orderTicket);
    }
    for (int i = 0; i < tickets.Total(); i++) {
      Print("ticket: ", tickets[i]);
      deleteOrder(tickets[i]);
    }
  }
}

//+------------------------------------------------------------------+
//| Private functions deleteOrder().                                 |
//| INPUT:  ticket     - ticket,                                     |
//+------------------------------------------------------------------+
void MyUtility::deleteOrder(ulong ticket) {
  if (cTrade.OrderDelete(ticket)) {
    Print("Order ", ticket, " deleted.");
    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  } else {
    Print("Failed to delete order ", ticket, ". Error: ", GetLastError());
    uint retcode = cTrade.ResultRetcode();
    Print("retcode: ", retcode);
  }
}

//+------------------------------------------------------------------+
//| Access functions Clamp(...).                                     |
//| INPUT:  value             - value,                               |
//|         min_value         - min_value,                           |
//|         max_value         - max_value,                           |
//+------------------------------------------------------------------+
double MyUtility::Clamp(double value, double min_value, double max_value) {
  if (value < min_value)
    return min_value;
  if (value > max_value)
    return max_value;
  return value;
}

//+------------------------------------------------------------------+
//| Access functions Clamp(...).                                     |
//| INPUT:  value             - value,                               |
//|         min_value         - min_value,                           |
//|         max_value         - max_value,                           |
//+------------------------------------------------------------------+
bool MyUtility::IsInRange(double value, double min_value, double max_value) {
  return (value >= min_value && value <= max_value);
}