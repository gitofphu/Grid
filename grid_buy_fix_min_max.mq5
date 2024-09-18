//+------------------------------------------------------------------+
//|                                                     grid_buy.mq5 |
//|                                                  Watsadonramai.W |
//|                                           Link inMQLHeadStandard |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

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

  double lotSize = Utility.GetGirdLotSize(_Symbol, ArrayPrices, MinPrice);

  if (lotSize == 0) {
    return (INIT_PARAMETERS_INCORRECT);
  }

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
