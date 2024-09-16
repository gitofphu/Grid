//+------------------------------------------------------------------+
//|                                         Test_MarketOpenHours.mq5 |
//|                                        Wolfgang Melz, wm1@gmx.de |
//|                                                 https://melz.one |
//+------------------------------------------------------------------+
#property copyright "Wolfgang Melz, wm1@gmx.de"
#property link "https://melz.one"
#property version "1.00"

#include "MarketOpenHours.mqh" // get source access

// HACK might work not sure

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  bool isOpen = MarketOpenHours(_Symbol);
  Print("Market is Open:=", isOpen);

  //--- create timer
  // EventSetTimer(PeriodSeconds(PERIOD_H1));

  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
  //--- destroy timer
  EventKillTimer();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer() {
  bool isOpen = MarketOpenHours(_Symbol);
  Print("Market is Open:=", isOpen);
}
//+------------------------------------------------------------------+
