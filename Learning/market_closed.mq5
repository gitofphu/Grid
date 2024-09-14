
void OnStart() { Print("The market is close? ", market_closed(_Symbol)); }

bool market_closed(string symbol) {
  datetime daytime = iTime(symbol, PERIOD_D1, 0);
  MqlDateTime tm;
  TimeCurrent(tm);
  MqlDateTime sm;
  TimeToStruct(daytime, sm);

  if (sm.day_of_week != tm.day_of_week) {
    return true;
  }
  return false;
}