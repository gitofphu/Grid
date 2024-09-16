//+------------------------------------------------------------------+
//|                                                 IsMarketOpen.mq5 |
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
  bool isOpen = IsMarketOpen(_Symbol);
  Print("isOpen: ", isOpen);
}
//+------------------------------------------------------------------+

#define HR2400 (PERIOD_D1 * 60) // 86400 = 24 * 3600 = 1440 * 60

// Checks if market is currently open for specified symbol
bool IsMarketOpen(const string symbol, const bool debug = false) {
  datetime from = NULL;
  datetime to = NULL;
  datetime serverTime = TimeTradeServer();

  // Get the day of the week
  MqlDateTime dt;
  TimeToStruct(serverTime, dt);
  const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dt.day_of_week;

  // Get the time component of the current datetime
  const int time = (int)MathMod(serverTime, HR2400);

  if (debug)
    PrintFormat("%s(%s): Checking %s", __FUNCTION__, symbol,
                EnumToString(day_of_week));

  // Brokers split some symbols between multiple sessions.
  // One broker splits forex between two sessions (Tues thru Thurs on different
  // session). 2 sessions (0,1,2) should cover most cases.
  int session = 2;
  while (session > -1) {
    if (SymbolInfoSessionTrade(symbol, day_of_week, session, from, to)) {
      if (debug)
        PrintFormat("%s(%s): Checking %d>=%d && %d<=%d", __FUNCTION__, symbol,
                    time, from, time, to);
      if (time >= from && time <= to) {
        if (debug)
          PrintFormat("%s Market is open", __FUNCTION__);
        return true;
      }
    }
    session--;
  }
  if (debug)
    PrintFormat("%s Market not open", __FUNCTION__);
  return false;
}