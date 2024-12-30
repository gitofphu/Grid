
//+------------------------------------------------------------------+
void OnStart() {
  // Variables for symbol volume conditions
  double dbLotsMinimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
         dbLotsMaximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
         dbLotsStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

  Print("dbLotsMinimum: ", dbLotsMinimum);
  Print("dbLotsMaximum: ", dbLotsMaximum);
  Print("dbLotsStep: ", dbLotsStep);

  // Print("SYMBOL_BID: ", SymbolInfoDouble(_Symbol, SYMBOL_BID));
  // Print("SYMBOL_BIDHIGH: ", SymbolInfoDouble(_Symbol, SYMBOL_BIDHIGH));
  // Print("SYMBOL_BIDLOW: ", SymbolInfoDouble(_Symbol, SYMBOL_BIDLOW));
  // Print("SYMBOL_ASK: ", SymbolInfoDouble(_Symbol, SYMBOL_ASK));
  // Print("SYMBOL_ASKHIGH: ", SymbolInfoDouble(_Symbol, SYMBOL_ASKHIGH));
  // Print("SYMBOL_ASKLOW: ", SymbolInfoDouble(_Symbol, SYMBOL_ASKLOW));

  // Print("SYMBOL_LAST: ", SymbolInfoDouble(_Symbol, SYMBOL_LAST));
  // Print("SYMBOL_LASTHIGH: ", SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH));
  // Print("SYMBOL_LASTLOW: ", SymbolInfoDouble(_Symbol, SYMBOL_LASTLOW));

  // Print("SYMBOL_VOLUME_REAL: ", SymbolInfoDouble(_Symbol,
  // SYMBOL_VOLUME_REAL)); Print("SYMBOL_VOLUMEHIGH_REAL: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_VOLUMEHIGH_REAL));
  // Print("SYMBOL_VOLUMELOW_REAL: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_VOLUMELOW_REAL));

  // Print("SYMBOL_POINT: ", SymbolInfoDouble(_Symbol, SYMBOL_POINT));
  // Print("SYMBOL_TRADE_TICK_VALUE: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
  // Print("SYMBOL_TRADE_TICK_VALUE_PROFIT: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT));
  // Print("SYMBOL_TRADE_TICK_VALUE_LOSS: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS));
  // Print("SYMBOL_TRADE_TICK_SIZE: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE));
  // Print("SYMBOL_TRADE_CONTRACT_SIZE: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE));

  // Print("SYMBOL_TRADE_ACCRUED_INTEREST: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_ACCRUED_INTEREST));
  // Print("SYMBOL_TRADE_FACE_VALUE: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_FACE_VALUE));
  // Print("SYMBOL_TRADE_LIQUIDITY_RATE: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_TRADE_LIQUIDITY_RATE));

  Print("SYMBOL_VOLUME_MIN: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN));
  Print("SYMBOL_VOLUME_MAX: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX));
  Print("SYMBOL_VOLUME_STEP: ", SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP));
  Print("SYMBOL_VOLUME_LIMIT: ",
        SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT));

  // Print("SYMBOL_SWAP_LONG: ", SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG));
  // Print("SYMBOL_SWAP_SHORT: ", SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT));
  // Print("SYMBOL_SWAP_SUNDAY: ", SymbolInfoDouble(_Symbol,
  // SYMBOL_SWAP_SUNDAY)); Print("SYMBOL_SWAP_MONDAY: ",
  // SymbolInfoDouble(_Symbol, SYMBOL_SWAP_MONDAY)); Print("SYMBOL_SWAP_TUESDAY:
  // ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_SWAP_TUESDAY));
  // Print("SYMBOL_SWAP_WEDNESDAY: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_SWAP_WEDNESDAY));
  // Print("SYMBOL_SWAP_THURSDAY: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_SWAP_THURSDAY));
  // Print("SYMBOL_SWAP_FRIDAY: ", SymbolInfoDouble(_Symbol,
  // SYMBOL_SWAP_FRIDAY)); Print("SYMBOL_SWAP_SATURDAY: ",
  //       SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SATURDAY));

  Print("SYMBOL_MARGIN_INITIAL: ",
        SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL));
  Print("SYMBOL_MARGIN_MAINTENANCE: ",
        SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_MAINTENANCE));
}
