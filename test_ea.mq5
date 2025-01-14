//+------------------------------------------------------------------+
//|                                                      test_ea.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

input double LotSize = 0.0;

double lotPerGrid;
bool isInit = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  Print("lotPerGrid: ", lotPerGrid);
  Print("lotPerGrid == NULL: ", lotPerGrid == NULL);

  Print("LotSize: ", LotSize);
  Print("LotSize == NULL: ", LotSize == NULL);

  if (isInit && LotSize == lotPerGrid) {
    Print("lot size is already set to ", lotPerGrid);
    return (INIT_SUCCEEDED);
  }

  Print("set lot size to ", LotSize);
  lotPerGrid = LotSize;

  isInit = true;

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {}

//+------------------------------------------------------------------+