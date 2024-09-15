//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
void OnStart() {
  // Define order parameters
  double lotSize = 0.1; // Lot size

  double price = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Current market price

  // Calculate margin
  double margin = 0;
  if (OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, price, margin)) {
    Print("Margin required: ", margin);
  } else {
    Print("Error calculating margin: ", GetLastError());
  }
}
