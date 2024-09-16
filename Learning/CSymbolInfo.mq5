#include <Trade\SymbolInfo.mqh>

CSymbolInfo SymbolInfo;

void OnStart() {
  //   Print("SessionClose(): ", SymbolInfo.SessionClose());
  //   Print("TradeCalcMode(): ", EnumToString(SymbolInfo.TradeCalcMode()));
  //   Print("TradeCalcModeDescription(): ",
  //   SymbolInfo.TradeCalcModeDescription()); Print("TradeMode(): ",
  //   EnumToString(SymbolInfo.TradeMode())); Print("TradeModeDescription(): ",
  //   SymbolInfo.TradeModeDescription()); Print("TradeExecution(): ",
  //   EnumToString(SymbolInfo.TradeExecution()));
  //   Print("TradeExecutionDescription(): ",
  //         SymbolInfo.TradeExecutionDescription());

  //   Print("CurrencyBase(): ", SymbolInfo.CurrencyBase());
  //   Print("CurrencyProfit(): ", SymbolInfo.CurrencyProfit());
  //   Print("CurrencyMargin(): ", SymbolInfo.CurrencyMargin());
  //   Print("Bank(): ", SymbolInfo.Bank());
  //   Print("Description(): ", SymbolInfo.Description());
  //   Print("Path(): ", SymbolInfo.Path());

  Print("SessionOpen(): ", SymbolInfo.SessionOpen());
  Print("SessionClose(): ", SymbolInfo.SessionClose());
}