//+------------------------------------------------------------------+
//|                                                         grid_buy.mq5 |
//|                                                  Watsadonramai.W |
//|                                       Link inMQLHeadStandard |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

#include <Trade/AccountInfo.mqh>
CAccountInfo AccountInfo;

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

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
// [ ] Check if MaxOrder or OrderNumbers exceed limit orders
// [x] Create array list all price in range
// [x] Check if can trade
// [ ] Check if possible to place entry on every price in range
// [ ] Create function to place order on every price in range
// [ ] Create function to re-place order on tp price
// [ ] Create function to modify in case of cannot place all order in price
// range

//+------------------------------------------------------------------+
//| input                                                            |
//+------------------------------------------------------------------+
input double MaxPrice = 100;
input double MinPrice = 0;
input int MaxOrders = NULL;
input double PriceRange = 5;
int limitOrders;

double ArrayPrices[];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit() {

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  ValidateInput();

  GetArrayPrice(ArrayPrices);

  for (int i = 0; i < ArraySize(ArrayPrices); i++) {
    Print("Price ", i, ": ", ArrayPrices[i]);
  }

  double lotSize = GetLotsSize(ArrayPrices);

  // //--- get the number of decimal places for the current chart symbol
  // int digits = Digits();

  // //--- send the obtained data to the journal
  // Print("Number of decimal digits for the current chart symbol: ", digits);

  //   printf("ACCOUNT_BALANCE =  %G", AccountInfoDouble(ACCOUNT_BALANCE));
  // printf("ACCOUNT_EQUITY =  %G", AccountInfoDouble(ACCOUNT_EQUITY));
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

  ExpertRemove();

  return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

  if (TradeAllowed() == false)
    return;
}

//+------------------------------------------------------------------+

void ValidateInput() {

  Print("MaxPrice ", MaxPrice);
  Print("MinPrice ", MinPrice);
  Print("MaxOrders ", MaxOrders);

  if (MinPrice < 0)
    AlertAndExit("MinPrice cannot be less than 0.");

  if (MaxPrice > 0 && MinPrice >= MaxPrice)
    AlertAndExit("MinPrice must be less than MaxPrice.");

  if (PriceRange == 0)
    AlertAndExit("PriceRange cannot be 0.");

  const int accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  Print("accoutnLimitOrders ", accoutnLimitOrders);
  Print("MaxOrders == NULL ", MaxOrders == NULL);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }

  Print("limitOrders ", limitOrders);
}

void AlertAndExit(string message) {
  Alert(message);
  ExpertRemove();
  return;
}

int TradeAllowed() { return MQLInfoInteger(MQL_TRADE_ALLOWED); }

void GetArrayPrice(double &array[]) {
  double prices[];
  int arraySize = NormalizeDouble((MaxPrice - MinPrice) / PriceRange, _Digits);

  ArrayResize(array, arraySize);

  int index;
  double price;
  for (index = 0, price = MinPrice; index < arraySize;
       index++, price += PriceRange) {
    if (index == 0 && price == 0) {
      array[0] = _Point;
      continue;
    }
    array[index] = price;
  }
}

double GetLotsSize(double &array[]) {

  int OrderNumbers = ArraySize(array);

  double averagePrice = 0;

  for (int i = 0; i < OrderNumbers; i++) {
    averagePrice += array[i];
  }

  averagePrice = NormalizeDouble(averagePrice / OrderNumbers, _Digits);
  Print("averagePrice: ", averagePrice);

  double minPrice = MinPrice > 0 ? MinPrice : _Point;

  double maxLot =
      AccountInfo.MaxLotCheck(_Symbol, ORDER_TYPE_BUY, averagePrice, 100);
  Print("MaxLotCheck ", maxLot);

  double marginRequire =
      AccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY, maxLot, averagePrice);
  Print("marginRequire: ", marginRequire);

  double profit =
      AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, maxLot, 50, 49.99);
  Print("profit: ", profit);

  // double maximunDrawdown =

  // Print("Margin: ", AccountInfo.Margin());
  // Print("FreeMargin: ", AccountInfo.FreeMargin());
  // Print("MarginLevel: ", AccountInfo.MarginLevel());
  // Print("MarginCall: ", AccountInfo.MarginCall());
  // Print("MarginStopOut: ", AccountInfo.MarginStopOut());

  // double maxLot = Utility.CalculateLot(_Symbol, ORDER_TYPE_BUY_LIMIT, profit,
  //                                      averagePrice, minPrice);

  // double profit = AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
  // maxLot,
  //                                              averagePrice, 0);

  // profit = NormalizeDouble(profit, _Digits);

  // Print("OrderProfitCheck ", profit);

  // Print("OrderProfitCheck ",
  //       AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
  //                                    OrderNumbers * 0.01, averagePrice,
  //                                    0.01));

  // Define order parameters
  double lotSize = 0.1; // Lot size

  double price = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Current market price

  // Calculate margin
  double margin = 0;
  if (OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, lotSize, price, margin)) {
    Print("Margin required: ", margin);
  } else {
    AlertAndExit("Error calculating margin: " + GetLastError());
  }

  return 0;
}

// double profit = 100;
// double openPrice = 50;
// double closePrice = 60;

// double lots = Utility.CalculateLot(_Symbol, ORDER_TYPE_BUY_LIMIT, profit,
//                                     openPrice, closePrice);
// Print("lots: ", lots);

// Print("OrderProfitCheck ",
//       AccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lots, openPrice,
//                                    closePrice));