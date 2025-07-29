#include <Trade/AccountInfo.mqh>
CAccountInfo AccountInfo;

void OnStart() {

  // Access to integer type properties
  //   Print("Login ", AccountInfo.Login());
  //   Print("TradeMode ", AccountInfo.TradeMode());
  //   Print("TradeModeDescription ", AccountInfo.TradeModeDescription());
  //   Print("Leverage ", AccountInfo.Leverage());
  //   Print("StopoutMode ", AccountInfo.StopoutMode());
  //   Print("StopoutModeDescription ", AccountInfo.StopoutModeDescription());
  //   Print("TradeAllowed ", AccountInfo.TradeAllowed());
  //   Print("TradeExpert ", AccountInfo.TradeExpert());
  //   Print("LimitOrders ", AccountInfo.LimitOrders());
  //   Print("MarginMode ", AccountInfo.MarginMode());
  //   Print("MarginModeDescription ", AccountInfo.MarginModeDescription());

  // Access to double type properties
  Print("Balance ", AccountInfo.Balance());
  Print("Credit ", AccountInfo.Credit());
  Print("Profit ", AccountInfo.Profit());
  Print("Equity ", AccountInfo.Equity());
  Print("Margin ", AccountInfo.Margin());
  Print("FreeMargin ", AccountInfo.FreeMargin());
  Print("MarginLevel ", AccountInfo.MarginLevel());
  Print("MarginCall ", AccountInfo.MarginCall());
  Print("MarginStopOut ", AccountInfo.MarginStopOut());

  // Access to text properties
  //   Print("Name ", AccountInfo.Name());
  //   Print("Server ", AccountInfo.Server());
  //   Print("Currency ", AccountInfo.Currency());
  //   Print("Company ", AccountInfo.Company());

  // Access to MQL5 API functions
  //   Print("InfoInteger ", AccountInfo.InfoInteger());
  //   Print("InfoDouble ", AccountInfo.InfoDouble());
  //   Print("InfoString ", AccountInfo.InfoString());

  // Additional methodss
  Print("OrderProfitCheck ",
        AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, 0.01, 58.37, 60));
  Print("MarginCheck ",
        AccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY, 0.01, 58.37));
  Print("FreeMarginCheck ",
        AccountInfo.FreeMarginCheck(_Symbol, ORDER_TYPE_BUY, 0.01, 58.37));
  Print("MaxLotCheck ",
        AccountInfo.MaxLotCheck(_Symbol, ORDER_TYPE_BUY, 58.37, 100));

  //   double margin = EMPTY_VALUE;
  //   OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 0.01, 58.37, margin);
  //   Print("OrderCalcMargin ", margin);

  double contract_size = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
  Print("Contract size: ", contract_size);
  double leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
  Print("Leverage: ", leverage);

  double required_margin = (contract_size * 0.01 * 58.37) / leverage;
  Print("Required margin: ", required_margin);
}
