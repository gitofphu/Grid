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
  Print("Digits(): ", SymbolInfo.Digits());
  Print("Digits(): ", Digits());
  Print("Point(): ", SymbolInfo.Point());
  Print("Point(): ", Point());
  Print("TickValue(): ", SymbolInfo.TickValue());
  Print("TickValueProfit(): ", SymbolInfo.TickValueProfit());
  Print("TickValueLoss(): ", SymbolInfo.TickValueLoss());
  Print("TickSize(): ", SymbolInfo.TickSize());
  Print("Spread(): ", SymbolInfo.Spread());
  Print("SpreadFloat(): ", SymbolInfo.SpreadFloat());
  Print("Bid(): ", SymbolInfo.Bid());
  Print("Ask(): ", SymbolInfo.Ask());
  Print("MarginInitial(): ", SymbolInfo.MarginInitial());
  Print("MarginMaintenance(): ", SymbolInfo.MarginMaintenance());
  Print("MarginLong(): ", SymbolInfo.MarginLong());
  Print("MarginShort(): ", SymbolInfo.MarginShort());
  Print("MarginLimit(): ", SymbolInfo.MarginLimit());
  Print("MarginStop(): ", SymbolInfo.MarginStop());
  Print("MarginStopLimit(): ", SymbolInfo.MarginStopLimit());
}