#include <Trade\AccountInfo.mqh>
CAccountInfo AccountInfo;

double CalculateLotSize(double open_price, double close_price, double profit,
                        double symbol_point, double contract_size) {
  // Calculate the difference between Close Price and Open Price
  double price_diff = close_price - open_price;

  // Calculate lot size
  double lot_size = profit / (price_diff * symbol_point * contract_size);

  return lot_size;
}

void OnStart() {

  //   // Example parameters (these would typically come from actual trade data)
  //   // Example Close Price
  //   double profit = 100.0;         // Example Profit
  //   double symbol_point = Point(); // The point value of the symbol
  //   double contract_size = SymbolInfoDouble(
  //       _Symbol, SYMBOL_TRADE_CONTRACT_SIZE); // Contract Size of the symbol

  //   // Calculate lot size
  //   double lot_size = CalculateLotSize(open_price, close_price, profit,
  //                                      symbol_point, contract_size);

  //   // Output the calculated lot size
  //   Print("Calculated Lot Size: ", lot_size);

  Print("SYMBOL_TRADE_TICK_SIZE: ",
        SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));

  double point_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT) *
                       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) /
                       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

  double TakeProfit = -100; // in $
  Print("TakeProfit: ", TakeProfit);

  double open_price = 50;
  double close_price = 0.01;
  double pointDiff = (close_price - open_price) / _Point;

  Print("pointDiff: ", pointDiff);

  //   double TargetSize = 100; // in point
  double TargetSize = pointDiff; // in point
  double LotSize = (TakeProfit / (TargetSize * point_value));
  LotSize = NormalizeDouble(LotSize, _Digits);

  Print("SYMBOL_VOLUME_MIN: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));

  Print("LotSize: ", LotSize);

  double profit2;

  OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, LotSize, open_price, close_price,
                  profit2);
  Print("OrderCalcProfit: ", profit2);

  Print("OrderProfitCheck ",
        AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, LotSize,
                                     open_price, close_price));
}
