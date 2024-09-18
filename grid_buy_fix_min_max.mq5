//+------------------------------------------------------------------+
//|                                                     grid_buy.mq5 |
//|                                                  Watsadonramai.W |
//|                                           Link inMQLHeadStandard |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

#include <Trade\Trade.mqh>
CTrade trade;

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
// [x] Calculate maximum drawdown
// [ ] Calcualte Pip value
// [x] Define Min-Max price range
// [x] Define Entry distant
// [x] Calcualte maximun lot size
// [ ] Check if MaxOrder or NumberOfGrid exceed limit orders
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
double lotPerGrid;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit() {

  Print("TerminalInfoInteger(TERMINAL_TRADE_ALLOWED): ",
        TerminalInfoInteger(TERMINAL_TRADE_ALLOWED));
  Print("MQLInfoInteger(MQL_TRADE_ALLOWED): ",
        MQLInfoInteger(MQL_TRADE_ALLOWED));
  ExpertRemove();
  return (INIT_SUCCEEDED);

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

  if (ArraySize(ArrayPrices) > SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT)) {
    AlertAndExit("Number of grid exceeded volume limit.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  lotPerGrid = Utility.GetGirdLotSize(_Symbol, ArrayPrices, MinPrice);
  Print("lotPerGrid: ", lotPerGrid);

  // if (lotPerGrid == 0) {
  //   return (INIT_PARAMETERS_INCORRECT);
  // }

  double buyLimitPrices[];
  double buyStopPrices[];

  FilterPriceType(ArrayPrices, buyLimitPrices, buyStopPrices);

  for (int i = 0; i < ArraySize(buyLimitPrices); i++) {
    Print("buyLimitPrices: ", buyLimitPrices[i]);

    double price = buyLimitPrices[i];

    if (trade.BuyLimit(lotPerGrid, price, _Symbol)) {

      uint retcode = trade.ResultRetcode();
      Print("retcode: ", retcode);
      uint retcodeDescription = trade.ResultRetcodeDescription();
      Print("retcodeDescription: ", retcodeDescription);

    } else {
      Print("Failed to place Buy Limit order. Error: ", GetLastError());
    }
  }

  for (int i = 0; i < ArraySize(buyStopPrices); i++) {
    Print("buyStopPrices: ", buyStopPrices[i]);

    double price = buyStopPrices[i];

    if (trade.BuyStop(lotPerGrid, price, _Symbol)) {

      uint retcode = trade.ResultRetcode();
      Print("retcode: ", retcode);
      uint retcodeDescription = trade.ResultRetcodeDescription();
      Print("retcodeDescription: ", retcodeDescription);

    } else {
      Print("Failed to place Buy Limit order. Error: ", GetLastError());
    }
  }

  // ExpertRemove();

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

int TradeAllowed() {
  return (MQLInfoInteger(MQL_TRADE_ALLOWED) == 1 &&
          TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) == 1);
}

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

void FilterPriceType(double &arrayPrices[], double &buyLimitPrices[],
                     double &buyStopPrices[]) {
  // Buy Limit order is placed below the current market price.
  // Buy Stop order is placed above the current market price.

  ArrayResize(buyLimitPrices, 0);
  ArrayResize(buyStopPrices, 0);

  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("bid: ", bid);

  for (int i = 0; i < ArraySize(arrayPrices); i++) {

    if (arrayPrices[i] < bid) {
      int size = ArraySize(buyLimitPrices);
      ArrayResize(buyLimitPrices, size + 1);
      buyLimitPrices[size] = arrayPrices[i];
    }

    if (arrayPrices[i] > bid) {
      int size = ArraySize(buyStopPrices);
      ArrayResize(buyStopPrices, size + 1);
      buyStopPrices[size] = arrayPrices[i];
    }
  }
}