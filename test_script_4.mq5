//+------------------------------------------------------------------+
//|                                                test_script_4.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  if (IsMarketClosed()) {
    Print("Market is closed!");
    return;
  }
  // Your trading logic here
}
//+------------------------------------------------------------------+

bool IsMarketClosed() {
  // Get current symbol trading information
  MqlTick last_tick;
  SymbolInfoTick(_Symbol, last_tick);

  // Check if we can trade (market is open)
  bool isOpen = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
  Print("isOpen: ", isOpen);
  if (!isOpen)
    return true; // Market is closed

  // Check if trade is allowed at this time
  bool isAllowed = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_EXEMODE);
  Print("isAllowed: ", isAllowed);
  if (!isAllowed)
    return true; // Trading not allowed

  // Check trading session
  datetime local_time = TimeLocal();
  if (!IsTradeSessionActive())
    return true; // Outside of trading session

  return false; // Market is open
}

// Helper function to check trading session
bool IsTradeSessionActive() {
  datetime time_current = TimeCurrent();
  MqlDateTime time_struct;
  TimeToStruct(time_current, time_struct);

  Print("time_struct.day_of_week: ", time_struct.day_of_week);

  // Check if it's weekend
  if (time_struct.day_of_week == 0 || time_struct.day_of_week == 6)
    return false;

  return true;
}
