//+------------------------------------------------------------------+
//|                                                   test_input.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

//--- input parameters
input int InpMAPeriod = 13;                   // Smoothing period
input int InpMAShift = 0;                     // Line horizontal shift
input ENUM_MA_METHOD InpMAMethod = MODE_SMMA; // Smoothing method

#property script_show_inputs
//--- day of week
enum dayOfWeek {
  S = 0,  // Sunday
  M = 1,  // Monday
  T = 2,  // Tuesday
  W = 3,  // Wednesday
  Th = 4, // Thursday
  Fr = 5, // Friday,
  St = 6, // Saturday
};
//--- input parameters
input dayOfWeek swapday = W;

static input int layers = 6; // Number of layers

input group "Signal";
input int ExtBBPeriod = 20;                     // Bollinger Bands period
input double ExtBBDeviation = 2.0;              // deviation
input ENUM_TIMEFRAMES ExtSignalTF = PERIOD_M15; // BB timeframe

input group "Trend";
input int ExtMAPeriod = 13;                    // Moving Average period
input ENUM_TIMEFRAMES ExtTrendTF = PERIOD_M15; // MA timeframe

input group "ExitRules";
input bool ExtUseSL = true;    // use StopLoss
input int Ext_SL_Points = 50;  // StopLoss in points
input bool ExtUseTP = false;   // use TakeProfit
input int Ext_TP_Points = 100; // TakeProfit in points
input bool ExtUseTS = true;    // use Trailing Stop
input int Ext_TS_Points = 30;  // Trailing Stop in points

input group "MoneyManagement";
sinput double ExtInitialLot = 0.1; // initial lot value
input bool ExtUseAutoLot = true;   // automatic lot calculation

input group "Auxiliary";
sinput int ExtMagicNumber = 123456; // EA Magic Number
sinput bool ExtDebugMessage = true; // print debug messages

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  Utility.AlertAndExit("EA exit.");

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