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

double CalculateLotSize2(double profit, double openPrice, double closePrice,
                         int direction) {
  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT); // Get the point size
  Print("point: ", point);

  double contractSize = SymbolInfoDouble(
      _Symbol,
      SYMBOL_TRADE_CONTRACT_SIZE); // Contract size (e.g., 100,000 for Forex)
  Print("contractSize: ", contractSize);

  // Calculate the lot size (volume)
  double volume =
      profit / (direction * (closePrice - openPrice) / point * contractSize);
  Print("volume: ", volume);

  return NormalizeDouble(volume, 2); // Normalize the volume to 2 decimal places
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

  /* ------------------------------------------- */

  //   Print("SYMBOL_TRADE_TICK_SIZE: ",
  //         SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));

  //   double point_value = SymbolInfoDouble(_Symbol, SYMBOL_POINT) *
  //                        SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE) /
  //                        SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);

  //   double TakeProfit = -100; // in $
  //   Print("TakeProfit: ", TakeProfit);

  //   double open_price = 50;
  //   double close_price = 0.01;
  //   double pointDiff = (close_price - open_price) / _Point;

  //   Print("pointDiff: ", pointDiff);

  //   //   double TargetSize = 100; // in point
  //   double TargetSize = pointDiff; // in point
  //   double LotSize = (TakeProfit / (TargetSize * point_value));
  //   LotSize = NormalizeDouble(LotSize, _Digits);

  //   Print("SYMBOL_VOLUME_MIN: ", SymbolInfoDouble(_Symbol,
  //   SYMBOL_VOLUME_MIN));

  //   Print("LotSize: ", LotSize);

  //   double profit2;

  //   OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, LotSize, open_price,
  //   close_price,
  //                   profit2);
  //   Print("OrderCalcProfit: ", profit2);

  //   Print("OrderProfitCheck ",
  //         AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, LotSize,
  //                                      open_price, close_price));

  /* ------------------------------------------- */

  double profit = 100;    // Example profit value
  double openPrice = 50;  // Example open price
  double closePrice = 70; // Example close price
  // int direction = 1;      // 1 for buy, -1 for sell

  // Print("profit: ", profit);
  // Print("openPrice: ", openPrice);
  // Print("closePrice: ", closePrice);

  // // double lotSize2 = CalculateLotSize2(profit, openPrice, closePrice,
  // // direction); Print("CalculateLotSize2: ", lotSize2);

  // Print("OrderProfitCheck ",
  //       AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, 1, openPrice,
  //                                    closePrice));

  // Print("CalculateProfit: ", CalculateProfit(openPrice, closePrice, 1));

  // double lotSize3 = CalculateLots3(2000, openPrice, closePrice);
  // Print("CalculateLots3: ", lotSize3);

  // Print("Point: ", SymbolInfoDouble(_Symbol, SYMBOL_POINT));
  // Print("Tick Value: ", SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
  // Print("Contract Size: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE));

  double profit4 = CalculateProfit(openPrice, closePrice, 1);
  Print("profit4: ", profit4);

  double lots = CalculateLots4(profit4, openPrice, closePrice);
  Print("lots4: ", lots);

  double profit5 = CalculateProfit(openPrice, closePrice, lots);
  Print("profit5: ", profit5);
}

double CalculateLots3(double profit, double open_price, double close_price) {
  // double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  // double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  // double lots = profit / ((close_price - open_price) * point * tick_value);
  // return lots;

  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double contract_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);

  // Adjust the profit calculation
  double lots = profit / ((close_price - open_price) * point * tick_value *
                          contract_size);
  return lots;
}

double CalculateProfit(double open_price, double close_price, double lots) {
  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double profit = (close_price - open_price) * lots / point * tick_value;
  return profit;
}

double CalculateProfit4(double open_price, double close_price, double lots) {
  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double contract_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);

  double profit =
      (close_price - open_price) * lots * contract_size * tick_value;
  return profit;
}

double CalculateLots4(double profit, double open_price, double close_price) {
  double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
  double tick_value = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double contract_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);

  double lots =
      profit / ((close_price - open_price) * contract_size * tick_value);
  return lots;
}
