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
input double GridGapSize = 0.1;
input int MaxOrders = NULL;
input bool TradeAnywaywithMinimunLot = false;
input bool ClearOrdersOnInit = false;
input double LotSize = 0.1;
// input double MinLot = NULL;
// input bool TradeBuy = true;
// input bool TradeSell = true;

bool isInit = false;

int limitOrders;
CArrayDouble ArrayPrices;
// double lotPerGrid;
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

  maxPrice = NormalizeDouble(currentPrice + GridGapSize, _Digits);
  minPrice = NormalizeDouble(
      currentPrice - GridGapSize > _Point ? currentPrice - GridGapSize : _Point,
      _Digits);

  Print("maxPrice: ", maxPrice);
  Print("minPrice: ", minPrice);

  if (ArrayPrices.Total() == 0)
    Utility.GetArrayPrice(0.01, 70, 0.2, ArrayPrices);

  Print("ArrayPrices.Total(): ", ArrayPrices.Total());

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);
  }

  ValidateInputAndVariables();

  TwoWayDrawdownCheck(currentPrice);

  // if (ClearOrdersOnInit) {
  //   Utility.CloseAllOrder(ArrayPrices, comment);
  // }

  // CheckAndPlaceOrders();

  // isInit = true;

  Utility.AlertAndExit("Test ended.");

  return (INIT_SUCCEEDED);
}

/**
 * Validate input and Variables
 */
void ValidateInputAndVariables() {

  // if (!TradeBuy && !TradeSell)
  //   Utility.AlertAndExit("At lease TradeBuy or TradeSell must be true.");

  if (GridGapSize == 0)
    Utility.AlertAndExit("GridGapSize cannot be 0.");

  const int accoutnLimitOrders = AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  if (MaxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (MaxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("MaxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
  } else {
    limitOrders = MaxOrders;
  }

  Print("limitOrders: ", limitOrders);

  // if (ArrayPrices.Total() > limitOrders ||
  //     (TradeBuy && TradeSell && ((ArrayPrices.Total() * 2) > limitOrders)))
  //   Utility.AlertAndExit("Array Prices exceed ACCOUNT_LIMIT_ORDERS.");

  if ((ArrayPrices.Total() * 2) > limitOrders)
    Utility.AlertAndExit("Array Prices exceed ACCOUNT_LIMIT_ORDERS.");

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("Basic info: SYMBOL_VOLUME_LIMIT= ", volumeLimit);

  if (volumeLimit != 0) {
    if (ArrayPrices.Total() > volumeLimit) {
      Utility.AlertAndExit("Number of grid exceeded volume limit.");
    }
  }

  // if (TradeBuy && TradeSell && MinLot == NULL) {
  //   Utility.AlertAndExit("Must provide MinLot.");
  // } else

  //     if (MinLot != NULL) {
  //   lotPerGrid = MinLot;
  // } else {
  //   lotPerGrid = Utility.GetGirdLotSize(ArrayPrices);
  // }
  // if (lotPerGrid == 0) {
  //   if (TradeAnywaywithMinimunLot) {
  //     lotPerGrid = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  //   } else {
  //     Utility.AlertAndExit("Invalid lotPerGrid.");
  //   }
  // }
  // Print("Basic info: lotPerGrid = ", lotPerGrid);

  if (LotSize <= 0) {
    Utility.AlertAndExit("Invalid lotPerGrid.");
  }
}

void TwoWayDrawdownCheck(double currentPrice) {
  Print("TwoWayDrawdownCheck: ", currentPrice);

  return;

  // double balance = cAccountInfo.Balance();

  double balance = 660;
  currentPrice = 70;
  double GridGapSize = 0.2;
  double LotSize = 0.02;

  CArrayDouble arrayPrices;
  for (double price = currentPrice; price > 0;
       price = NormalizeDouble(price - GridGapSize, _Digits)) {
    Print("price: ", price);
    arrayPrices.Add(price);
  }
  arrayPrices.Add(_Point);

  return;

  for (int i = 0; i < arrayPrices.Total(); i++) {

    double drawdown = 0;

    for (int j = 0; j < arrayPrices.Total(); j++) {

      if (arrayPrices[i] <= arrayPrices[j])
        continue;

      Print("arrayPrices i: ", i, " = ", arrayPrices[i], ", arrayPrices j: ", j,
            " = ", arrayPrices[j]);

      if (j != 0) {
        double profit =
            cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_SELL, LotSize,
                                          arrayPrices[j - 1], arrayPrices[j]);

        Print("From ", arrayPrices[j - 1], " to ", arrayPrices[j], " profit ",
              NormalizeDouble(profit, 2));

        balance = NormalizeDouble(balance + profit, 2);
      }

      double loss = cAccountInfo.OrderProfitCheck(
          _Symbol, ORDER_TYPE_BUY, LotSize, arrayPrices[i], arrayPrices[j]);

      double marginRequire = cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY,
                                                      LotSize, arrayPrices[i]);

      Print("From ", arrayPrices[i], " to ", arrayPrices[j], " loss ",
            NormalizeDouble(loss - marginRequire, 2));

      drawdown = NormalizeDouble(
          drawdown + NormalizeDouble(loss - marginRequire, 2), 2);

      double equity = NormalizeDouble(balance + drawdown, 2);

      Print("balance: ", balance);
      Print("equity: ", equity);
      Print("drawdown: ", drawdown);

      Print("------------------------------------");

      if (equity <= 0)
        break;
    }

    Print("total drawdown: ", drawdown);
    Print("++++++++++++++++++++++++++++++++++++++");

    if (balance + drawdown <= 0)
      break;
  }
}

/**
 * Check orders and positions
 */
void CheckAndPlaceOrders() {

  bool OrderPriceInvalid = false;
  int errors = 0;

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

  //   PlaceBuyOrders(buyLimitPrices, buyStopPrices, OrderPriceInvalid);
  if (OrderPriceInvalid)
    errors++;
  // } while (OrderPriceInvalid && errors < 3);
  if (errors >= 3) {
    Utility.AlertAndExit("Place order error.");
  }
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