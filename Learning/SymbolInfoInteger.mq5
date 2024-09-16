
void OnStart() { Check_SYMBOL_ORDER_MODE(_Symbol); }

void Check_SYMBOL_ORDER_MODE(string symbol) {
  // //--- receive the value of the property describing allowed order types
  // int symbol_order_mode = (int)SymbolInfoInteger(symbol, SYMBOL_ORDER_MODE);
  // //--- check for market orders (Market Execution)
  // if ((SYMBOL_ORDER_MARKET & symbol_order_mode) == SYMBOL_ORDER_MARKET)
  //   Print(symbol + ": Market orders are allowed (Buy and Sell)");
  // //--- check for Limit orders
  // if ((SYMBOL_ORDER_LIMIT & symbol_order_mode) == SYMBOL_ORDER_LIMIT)
  //   Print(symbol + ": Buy Limit and Sell Limit orders are allowed");
  // //--- check for Stop orders
  // if ((SYMBOL_ORDER_STOP & symbol_order_mode) == SYMBOL_ORDER_STOP)
  //   Print(symbol + ": Buy Stop and Sell Stop orders are allowed");
  // //--- check for Stop Limit orders
  // if ((SYMBOL_ORDER_STOP_LIMIT & symbol_order_mode) ==
  // SYMBOL_ORDER_STOP_LIMIT)
  //   Print(symbol + ": Buy Stop Limit and Sell Stop Limit orders are
  //   allowed");
  // //--- check if placing a Stop Loss orders is allowed
  // if ((SYMBOL_ORDER_SL & symbol_order_mode) == SYMBOL_ORDER_SL)
  //   Print(symbol + ": Stop Loss orders are allowed");
  // //--- check if placing a Take Profit orders is allowed
  // if ((SYMBOL_ORDER_TP & symbol_order_mode) == SYMBOL_ORDER_TP)
  //   Print(symbol + ": Take Profit orders are allowed");
  // //--- check if closing a position by an opposite one is allowed
  // if ((SYMBOL_ORDER_TP & symbol_order_mode) == SYMBOL_ORDER_CLOSEBY)
  //   Print(symbol + ": Close by allowed");
  // //---

  Print("SYMBOL_EXIST: ", SymbolInfoInteger(symbol, SYMBOL_EXIST));
  Print("SYMBOL_DIGITS: ", SymbolInfoInteger(symbol, SYMBOL_DIGITS));
  Print("SYMBOL_SPREAD_FLOAT: ",
        SymbolInfoInteger(symbol, SYMBOL_SPREAD_FLOAT));
  Print("SYMBOL_SPREAD: ", SymbolInfoInteger(symbol, SYMBOL_SPREAD));
  Print("SYMBOL_START_TIME: ", SymbolInfoInteger(symbol, SYMBOL_START_TIME));
  Print("SYMBOL_EXPIRATION_TIME: ",
        SymbolInfoInteger(symbol, SYMBOL_EXPIRATION_TIME));
  Print("SYMBOL_TRADE_CALC_MODE: ",
        SymbolInfoInteger(symbol, SYMBOL_TRADE_CALC_MODE));
}