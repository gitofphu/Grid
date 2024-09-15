
//+------------------------------------------------------------------+
void OnStart() {
  // Variables for symbol volume conditions
  double dbLotsMinimum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN),
         dbLotsMaximum = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX),
         dbLotsStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

  Print("dbLotsMinimum: ", dbLotsMinimum);
  Print("dbLotsMaximum: ", dbLotsMaximum);
  Print("dbLotsStep: ", dbLotsStep);
}
