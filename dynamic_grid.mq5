//+------------------------------------------------------------------+
//|                                                 dynamic_grid.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Watsadonramai.W"
#property link "Link"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

//+------------------------------------------------------------------+
//| EA Dynamic Buy Grid                                                      |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| input                                                            |
//+------------------------------------------------------------------+
double maxPrice;
double minPrice;
input int PriceRange = 10;
input double GridGapSize = 0.1;
input int MaxOrders = NULL;
input bool TradeAnywaywithMinimunLot = false;
input bool ClearOrdersOnInit = false;
input double MinLot = NULL;
input bool TradeBuy = true;
input bool TradeSell = true;

bool isInit = false;

int limitOrders;
CArrayDouble ArrayPrices;
double lotPerGrid;
string comment = "dynamic_grid";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {
  Print("OnInit");

  if (isInit)
    return (INIT_SUCCEEDED);

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    Utility.AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double currentPrice = MathRound(NormalizeDouble((ask + bid) / 2, _Digits));
  Print("currentPrice: ", currentPrice);

  maxPrice = NormalizeDouble(currentPrice + PriceRange, _Digits);
  minPrice = NormalizeDouble(
      currentPrice - PriceRange > _Point ? currentPrice - PriceRange : _Point,
      _Digits);

  Print("maxPrice: ", maxPrice);
  Print("minPrice: ", minPrice);

  if (ArrayPrices.Total() == 0)
    Utility.GetArrayPrice(minPrice, maxPrice, GridGapSize, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  // for (int i = 0; i < ArrayPrices.Total(); i++) {
  //   Print("ArrayPrices: ", ArrayPrices[i]);
  // }

  ValidateInputAndVariables();

  if (ClearOrdersOnInit) {
    Utility.CloseAllOrder(ArrayPrices, comment);
  }

  CheckAndPlaceOrders();

  isInit = true;

  Utility.AlertAndExit("Test ended.");

  return (INIT_SUCCEEDED);
}

/**
 * Validate input and Variables
 */
void ValidateInputAndVariables() {

  if (!TradeBuy && !TradeSell)
    Utility.AlertAndExit("At lease TradeBuy or TradeSell must be true.");

  if (GridGapSize == 0)
    Utility.AlertAndExit("GridGapSize cannot be 0.");

  if (PriceRange == 0)
    Utility.AlertAndExit("PriceRange cannot be 0.");

  if (GridGapSize >= PriceRange)
    Utility.AlertAndExit("GridGapSize must be less than PriceRange.");

  const int accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }

  Print("limitOrders: ", limitOrders);

  if (ArrayPrices.Total() > limitOrders ||
      (TradeBuy && TradeSell && ((ArrayPrices.Total() * 2) > limitOrders)))
    Utility.AlertAndExit("Array Prices exceed ACCOUNT_LIMIT_ORDERS.");

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("Basic info: SYMBOL_VOLUME_LIMIT= ", volumeLimit);

  if (volumeLimit != 0) {
    if (ArrayPrices.Total() > volumeLimit) {
      Utility.AlertAndExit("Number of grid exceeded volume limit.");
    }
  }

  if (TradeBuy && TradeSell && MinLot == NULL) {
    Utility.AlertAndExit("Must provide MinLot.");
  } else if (MinLot != NULL) {
    lotPerGrid = MinLot;
  } else {
    lotPerGrid = Utility.GetGirdLotSize(ArrayPrices);
  }

  if (lotPerGrid == 0) {
    if (TradeAnywaywithMinimunLot) {
      lotPerGrid = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
    } else {
      Utility.AlertAndExit("Invalid lotPerGrid.");
    }
  }

  Print("Basic info: lotPerGrid = ", lotPerGrid);
}

/**
 * Check orders and positions
 */
void CheckAndPlaceOrders() {

  bool OrderPriceInvalid = false;

  // do {

  CArrayDouble buyLimitPrices;
  CArrayDouble buyStopPrices;
  Utility.FilterOpenBuyOrderAndPosition(ArrayPrices, GridGapSize, comment,
                                        buyLimitPrices, buyStopPrices);
  Print("Basic info: buyLimitPrices = ", buyLimitPrices.Total());
  Print("Basic info: buyStopPrices = ", buyStopPrices.Total());

  CArrayDouble sellLimitPrices;
  CArrayDouble sellStopPrices;
  Utility.FilterOpenSellOrderAndPosition(ArrayPrices, GridGapSize, comment,
                                         sellLimitPrices, sellStopPrices);
  Print("Basic info: sellLimitPrices = ", sellLimitPrices.Total());
  Print("Basic info: sellStopPrices = ", sellStopPrices.Total());

  //   PlaceOrders(buyLimitPrices, buyStopPrices, OrderPriceInvalid);
  // } while (OrderPriceInvalid);
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