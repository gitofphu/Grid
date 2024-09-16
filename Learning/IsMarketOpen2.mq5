// HACK might work

void OnStart() {
  bool isOpen = IsMarketOpen(_Symbol);
  Print("isOpen: ", isOpen);
}

bool IsMarketOpen(const string symbol) {
  datetime from, to;
  datetime serverTime = TimeTradeServer();
  Print("serverTime: ", serverTime);
  MqlDateTime dt;
  TimeToStruct(serverTime, dt);
  const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)dt.day_of_week;
  const int time = (int)MathMod(serverTime, PeriodSeconds(PERIOD_D1));
  int session = 0;
  while (SymbolInfoSessionTrade(symbol, day_of_week, session, from, to)) {
    if (time >= from && time <= to) {
      return true;
    }
    session++;
  }
  return false;
}