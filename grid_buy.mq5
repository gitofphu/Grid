//+------------------------------------------------------------------+
//|                                                         grid_buy.mq5 |
//|                                                  Watsadonramai.W |
//|                                       Link inMQLHeadStandard |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

//+------------------------------------------------------------------+
//| EA Buy Grid                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| TODO List                                                        |
//+------------------------------------------------------------------+

// [x] Get account info
// [x] ACCOUNT_BALANCE
// [x] ACCOUNT_EQUITY
// [x] ACCOUNT_MARGIN
// [x] ACCOUNT_MARGIN_FREE
// [x] ACCOUNT_MARGIN_LEVEL
// [x] ACCOUNT_MARGIN_SO_CALL
// [x] ACCOUNT_MARGIN_SO_SO
// [x] ACCOUNT_LEVERAGE
// [x] ACCOUNT_LIMIT_ORDERS
// [ ] Calculate maximum drawdown
// [ ] Calcualte Pip value
// [x] Define Min-Max price range
// [ ] Define Entry distant
// [ ] Calcualte maximun lot size
// [ ] Create array list all price in range
// [ ] Check if possible to place entry on every price in range
// [ ] Create function to place order on every price in range
// [ ] Create function to re-place order on tp price
// [ ] Create function to modify in case of cannot place all order in price
// range

//+------------------------------------------------------------------+
//| input                                                            |
//+------------------------------------------------------------------+
input double MaxPrice = NULL;
input double MinPrice = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit() {

  ValidateInput();

  //--- get the number of decimal places for the current chart symbol
  int digits = Digits();

  //--- send the obtained data to the journal
  Print("Number of decimal digits for the current chart symbol: ", digits);

  //   printf("ACCOUNT_BALANCE =  %G", AccountInfoDouble(ACCOUNT_BALANCE));
  //   printf("ACCOUNT_EQUITY =  %G", AccountInfoDouble(ACCOUNT_EQUITY));
  //   printf("ACCOUNT_MARGIN =  %G", AccountInfoDouble(ACCOUNT_MARGIN));
  //   printf("ACCOUNT_MARGIN_FREE =  %G",
  //   AccountInfoDouble(ACCOUNT_MARGIN_FREE)); printf("ACCOUNT_MARGIN_LEVEL =
  //   %G", AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
  //   printf("ACCOUNT_MARGIN_SO_CALL = %G",
  //          AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
  //   printf("ACCOUNT_MARGIN_SO_SO = %G",
  //   AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)); printf("ACCOUNT_LEVERAGE = %d",
  //   AccountInfoInteger(ACCOUNT_LEVERAGE)); printf("ACCOUNT_LIMIT_ORDERS =
  //   %d",
  //          AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));

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

void ValidateInput() {

  Print("MaxPrice", MaxPrice);
  Print("MinPrice", MinPrice);

  if (MinPrice < 0)
    AlertAndExit("MinPrice cannot be less than 0.");

  if (MaxPrice > 0 && MinPrice >= MaxPrice)
    AlertAndExit("MinPrice must be less than MaxPrice.");
}

void AlertAndExit(string message) {
  Alert(message);
  ExpertRemove();
  return;
}
