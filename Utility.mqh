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
  double CalculateLot(const string symbol,
                      const ENUM_ORDER_TYPE trade_operation,
                      const double profit, const double open_price,
                      const double close_price);
  double GetGirdLotSize(const string symbol, const CArrayDouble &array,
                        const double min_price);
  void CloseAllOrder();

private:
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
//|         array           - grid price array,                      |
//|         min_price       - minimun price,                         |
//+------------------------------------------------------------------+
double MyUtility::GetGirdLotSize(const string symbol, const CArrayDouble &array,
                                 const double min_price) {
  int NumberOfGrid = array.Total();

  // calculate average price
  double averagePrice = 0;
  for (int i = 0; i < NumberOfGrid; i++) {
    averagePrice += array[i];
  }
  averagePrice = NormalizeDouble(averagePrice / NumberOfGrid, _Digits);

  double minPrice = min_price > 0 ? min_price : _Point;

  // calculate lot size base on balance
  double maxLot = 0.0;
  for (double lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
       lot <= SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
       lot += SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP)) {

    lot = NormalizeDouble(lot, 2);

    double profit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lot,
                                                  averagePrice, minPrice);

    double marginRequire =
        cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY, lot, averagePrice);

    double drawdown = NormalizeDouble(profit - marginRequire, 2);

    Print("lot: ", lot, ", maximum drawdown: ", drawdown);

    if (NormalizeDouble(cAccountInfo.Balance() + drawdown, 2) <= 0)
      break;

    maxLot = lot;
  }

  double lotPerGrid = maxLot / NumberOfGrid;

  Print("maxLot: ", maxLot, ", NumberOfGrid: ", NumberOfGrid,
        ", lotPerGrid: ", lotPerGrid);

  if (lotPerGrid < SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN)) {
    string message =
        "MyUtility::GetGirdLotSize: Balance are be enough for all price range. "
        "Please increase price range or deposit more balance.";
    Alert(message);
    return (0.0);
  }

  return NormalizeDouble(lotPerGrid, 2);
}

//+------------------------------------------------------------------+
//| Access functions CloseAllOrder().                             |
//+------------------------------------------------------------------+
void MyUtility::CloseAllOrder() {

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
      Print("MyUtility::CloseAllOrder ticket: ", tickets[i]);

      if (cTrade.OrderDelete(tickets[i])) {

        Print("MyUtility::CloseAllOrder Order ", tickets[i], " deleted.");
        uint retcode = cTrade.ResultRetcode();
        Print("MyUtility::CloseAllOrder retcode: ", retcode);

      } else {

        Print("MyUtility::CloseAllOrder Failed to delete order ", tickets[i],
              ". Error: ", GetLastError());
        uint retcode = cTrade.ResultRetcode();
        Print("MyUtility::CloseAllOrder retcode: ", retcode);
      }
    }
  }
}