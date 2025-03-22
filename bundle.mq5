//+------------------------------------------------------------------+
//|                                                       bundle.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

//+------------------------------------------------------------------+
//| bundle Description                                               |
//+------------------------------------------------------------------+

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
input double PriceRange = 2; // Price range
input int MaxOrders = NULL;  // Max orders

input group "Buy Stop";
input double BuyStopLot = 0.01;       // Lot size
input double BuyStopGapSize = 0.5;    // Gap size
input double BuyStopMaxPrice = 75;    // Max price
input double BuyStopMinPrice = 65;    // Min price
input bool FillInBuyStopLots = false; // Fill in lots

input group "Buy Limit";
input double BuyLimitLot = 0.01;       // Lot size
input double BuyLimitGapSize = 0.5;    // Gap size
input double BuyLimitMaxPrice = 75;    // Max price
input double BuyLimitMinPrice = 65;    // Min price
input bool FillInBuyLimitLots = false; // Fill in lots

input group "Sell Limit";
input double SellLimitLot = 0.01;       // Lot size
input double SellLimitGapSize = 0.5;    // Gap size
input double SellLimitMaxPrice = 75;    // Max price
input double SellLimitMinPrice = 65;    // Min price
input bool FillInSellLimitLots = false; // Fill in lots

input group "Sell Stop";
input double SellStopLot = 0.01;       // Lot size
input double SellStopGapSize = 0.5;    // Gap size
input double SellStopMaxPrice = 75;    // Max price
input double SellStopMinPrice = 65;    // Min price
input bool FillInSellStopLots = false; // Fill in lots

input group "Misc.";
input bool useNotification = false;   // Use notification
input bool clearOrderAndExit = false; // Clear all orders and exit

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double priceRange = NULL;
int maxOrders = NULL;

double buyStopLot = NULL;
double buyStopGapSize = NULL;
double buyStopMaxPrice = NULL;
double buyStopMinPrice = NULL;
bool fillInBuyStopLots = false;

double buyLimitLot = NULL;
double buyLimitGapSize = NULL;
double buyLimitMaxPrice = NULL;
double buyLimitMinPrice = NULL;
bool fillInBuyLimitLots = false;

double sellLimitLot = NULL;
double sellLimitGapSize = NULL;
double sellLimitMaxPrice = NULL;
double sellLimitMinPrice = NULL;
bool fillInSellLimitLots = false;

double sellStopLot = NULL;
double sellStopGapSize = NULL;
double sellStopMaxPrice = NULL;
double sellStopMinPrice = NULL;
bool fillInSellStopLots = false;

int limitOrders;
CArrayDouble buyStopArrayPrices;
CArrayDouble buyStopArrayTP;
CArrayDouble buyLimitArrayPrices;
CArrayDouble buyLimitArrayTP;
CArrayDouble sellLimitArrayPrices;
CArrayDouble sellLimitArrayTP;
CArrayDouble sellStopArrayPrices;
CArrayDouble sellStopArrayTP;

string Comment = "bundle";
// comment pattern: <ea_name>|<IsFillIn>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (PriceRange == priceRange && MaxOrders == maxOrders &&
      BuyStopLot == buyStopLot && BuyStopGapSize == buyStopGapSize &&
      BuyStopMaxPrice == buyStopMaxPrice &&
      BuyStopMinPrice == buyStopMinPrice &&
      FillInBuyStopLots == fillInBuyStopLots && BuyLimitLot == buyLimitLot &&
      BuyLimitGapSize == buyLimitGapSize &&
      BuyLimitMaxPrice == buyLimitMaxPrice &&
      BuyLimitMinPrice == buyLimitMinPrice &&
      FillInBuyLimitLots == fillInBuyLimitLots &&
      SellLimitLot == sellLimitLot && SellLimitGapSize == sellLimitGapSize &&
      SellLimitMaxPrice == sellLimitMaxPrice &&
      SellLimitMinPrice == sellLimitMinPrice &&
      FillInSellLimitLots == fillInSellLimitLots &&
      SellStopLot == sellStopLot && SellStopGapSize == sellStopGapSize &&
      SellStopMaxPrice == sellStopMaxPrice &&
      SellStopMinPrice == sellStopMinPrice &&
      FillInSellStopLots == fillInSellStopLots) {
    Print("Parameters are already set.");
    return (INIT_SUCCEEDED);
  }

  priceRange = PriceRange;
  maxOrders = MaxOrders;

  buyStopLot = BuyStopLot;
  buyStopGapSize = BuyStopGapSize;
  buyStopMaxPrice = BuyStopMaxPrice;
  buyStopMinPrice = BuyStopMinPrice;
  fillInBuyStopLots = FillInBuyStopLots;

  buyLimitLot = BuyLimitLot;
  buyLimitGapSize = BuyLimitGapSize;
  buyLimitMaxPrice = BuyLimitMaxPrice;
  buyLimitMinPrice = BuyLimitMinPrice;
  fillInBuyLimitLots = FillInBuyLimitLots;

  sellLimitLot = SellLimitLot;
  sellLimitGapSize = SellLimitGapSize;
  sellLimitMaxPrice = SellLimitMaxPrice;
  sellLimitMinPrice = SellLimitMinPrice;
  fillInSellLimitLots = FillInSellLimitLots;

  sellStopLot = SellStopLot;
  sellStopGapSize = SellStopGapSize;
  sellStopMaxPrice = SellStopMaxPrice;
  sellStopMinPrice = SellStopMinPrice;
  fillInSellStopLots = FillInSellStopLots;

  if (buyStopArrayPrices.Total() > 0) {
    buyStopArrayPrices.Shutdown();
    buyStopArrayTP.Shutdown();
  }

  if (buyLimitArrayPrices.Total() > 0) {
    buyLimitArrayPrices.Shutdown();
    buyLimitArrayTP.Shutdown();
  }

  if (sellLimitArrayPrices.Total() > 0) {
    sellLimitArrayPrices.Shutdown();
    sellLimitArrayTP.Shutdown();
  }

  if (sellStopArrayPrices.Total() > 0) {
    sellStopArrayPrices.Shutdown();
    sellStopArrayTP.Shutdown();
  }

  if (useNotification && !TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) {
    Utility.AlertAndExit("Error. The client terminal does not have permission "
                         "to send notifications");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    Utility.AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((buyStopLot != NULL && buyStopGapSize == NULL) ||
      (buyStopLot == NULL && buyStopGapSize != NULL)) {
    Utility.AlertAndExit("buyStopLot and buyStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyStopMaxPrice != NULL && buyStopMinPrice != NULL &&
      buyStopMaxPrice < buyStopMinPrice) {
    Utility.AlertAndExit(
        "buyStopMaxPrice must be greater than buyStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((buyLimitLot != NULL && buyLimitGapSize == NULL) ||
      (buyLimitLot == NULL && buyLimitGapSize != NULL)) {
    Utility.AlertAndExit("buyLimitLot and buyLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyLimitMaxPrice != NULL && buyLimitMinPrice != NULL &&
      buyLimitMaxPrice < buyLimitMinPrice) {
    Utility.AlertAndExit(
        "buyLimitMaxPrice must be greater than buyLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((sellLimitLot != NULL && sellLimitGapSize == NULL) ||
      (sellLimitLot == NULL && sellLimitGapSize != NULL)) {
    Utility.AlertAndExit("sellLimitLot and sellLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellLimitMaxPrice != NULL && sellLimitMinPrice != NULL &&
      sellLimitMaxPrice < sellLimitMinPrice) {
    Utility.AlertAndExit(
        "sellLimitMaxPrice must be greater than sellLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((sellStopLot != NULL && sellStopGapSize == NULL) ||
      (sellStopLot == NULL && sellStopGapSize != NULL)) {
    Utility.AlertAndExit("sellStopLot and sellStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellStopMaxPrice != NULL && sellStopMinPrice != NULL &&
      sellStopMaxPrice < sellStopMinPrice) {
    Utility.AlertAndExit(
        "sellStopMaxPrice must be greater than sellStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (priceRange < buyStopGapSize || priceRange < buyLimitGapSize ||
      priceRange < sellLimitGapSize || priceRange < sellStopGapSize) {
    Utility.AlertAndExit("priceRange must be greater than all gap sizes.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  Print("volumeMin: ", volumeMin);

  if ((buyStopLot != NULL && buyStopLot < volumeMin) ||
      (buyLimitLot != NULL && buyLimitLot < volumeMin) ||
      (sellLimitLot != NULL && sellLimitLot < volumeMin) ||
      (sellStopLot != NULL && sellStopLot < volumeMin)) {
    Utility.AlertAndExit("Lots must be greater than volume min.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  const int accoutnLimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  Print("accoutnLimitOrders: ", accoutnLimitOrders);

  if (maxOrders == NULL) {
    limitOrders = accoutnLimitOrders;
  } else if (maxOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("maxOrders must be less than ACCOUNT_LIMIT_ORDERS.");
    return (INIT_PARAMETERS_INCORRECT);
  } else {
    limitOrders = maxOrders;
  }

  GetArrayPrices();

  int totalBuyStopOrders = buyStopArrayPrices.Total();
  int totalBuyLimitOrders = buyLimitArrayPrices.Total();
  int totalSellLimitOrders = sellLimitArrayPrices.Total();
  int totalSellStopOrders = sellStopArrayPrices.Total();
  int totalOrders = totalBuyStopOrders + totalBuyLimitOrders +
                    totalSellLimitOrders + totalSellStopOrders;

  Print("limitOrders: ", limitOrders,
        ", totalBuyStopOrders: ", totalBuyStopOrders,
        ", totalBuyLimitOrders: ", totalBuyLimitOrders,
        ", totalSellLimitOrders: ", totalSellLimitOrders,
        ", totalSellStopOrders: ", totalSellStopOrders,
        ", totalOrders: ", totalOrders);

  if (limitOrders <
      (buyStopArrayPrices.Total() + buyLimitArrayPrices.Total() +
       sellLimitArrayPrices.Total() + sellStopArrayPrices.Total())) {
    Utility.AlertAndExit(
        "limitOrders must be greater than the sum of all orders.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  Print("volumeLimit: ", volumeLimit);

  if (volumeLimit < (buyStopArrayPrices.Total() * buyStopLot +
                     buyLimitArrayPrices.Total() * buyLimitLot +
                     sellLimitArrayPrices.Total() * sellLimitLot +
                     sellStopArrayPrices.Total() * sellStopLot)) {
    Utility.AlertAndExit("Totals lots must be less then volume limit.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  // CloseOrderOutSideArray();

  // CheckAndPlaceOrders();

  Utility.AlertAndExit("Test Ended.");

  return (INIT_SUCCEEDED);
}

int GetDecimalPlaces(double value) {
  string str =
      DoubleToString(value, 16);  // Convert to string with max precision
  int pos = StringFind(str, "."); // Find the decimal point
  if (pos == -1)
    return 0; // No decimal point means 0 decimals

  // Remove trailing zeros
  while (StringGetCharacter(str, StringLen(str) - 1) == '0')
    str = StringSubstr(str, 0, StringLen(str) - 1);

  return StringLen(str) - pos - 1; // Count digits after decimal
}

void GetBuyStopArrayPrices(double aboveRangeStart, double aboveRangeEnd,
                           double ask) {

  buyStopArrayPrices.Shutdown();
  buyStopArrayTP.Shutdown();

  for (double i = Utility.NormalizeDoubleTwoDigits(aboveRangeStart);
       i < Utility.NormalizeDoubleTwoDigits(aboveRangeEnd);
       i = Utility.NormalizeDoubleTwoDigits(i + buyStopGapSize)) {

    Print("i: ", i);

    if (i < buyStopMinPrice || i > buyStopMaxPrice)
      break;

    if (i <= ask) {
      continue;
    }

    for (double j = i + buyStopGapSize; j <= buyStopMaxPrice;
         j = Utility.NormalizeDoubleTwoDigits(j + buyStopGapSize)) {

      if (i != 0) {
        buyStopArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(i));
        buyStopArrayTP.Add(Utility.NormalizeDoubleTwoDigits(j));
      } else {
        buyStopArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(_Point));
        buyStopArrayTP.Add(
            Utility.NormalizeDoubleTwoDigits(_Point + buyStopGapSize));
      }
    }
  }
}

void GetBuyLimitArrayPrices(double belowRangeStart, double belowRangeEnd,
                            double bid) {

  buyLimitArrayPrices.Shutdown();
  buyLimitArrayTP.Shutdown();

  for (double i = Utility.NormalizeDoubleTwoDigits(belowRangeStart);
       i < Utility.NormalizeDoubleTwoDigits(belowRangeEnd);
       i = Utility.NormalizeDoubleTwoDigits(i + buyLimitGapSize)) {

    if (i < buyLimitMinPrice || i > buyLimitMaxPrice)
      break;

    if (i >= bid) {
      continue;
    }

    for (double j = i + buyLimitGapSize; j <= buyLimitMaxPrice;
         j = Utility.NormalizeDoubleTwoDigits(j + buyLimitGapSize)) {

      if (i != 0) {
        buyLimitArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(i));
        buyLimitArrayTP.Add(Utility.NormalizeDoubleTwoDigits(j));
      } else {
        buyLimitArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(_Point));
        buyLimitArrayTP.Add(
            Utility.NormalizeDoubleTwoDigits(_Point + buyLimitGapSize));
      }
    }
  }
}

void GetSellLimitArrayPrices(double aboveRangeStart, double aboveRangeEnd,
                             double ask) {

  sellLimitArrayPrices.Shutdown();
  sellLimitArrayTP.Shutdown();

  for (double i = Utility.NormalizeDoubleTwoDigits(aboveRangeEnd);
       i > Utility.NormalizeDoubleTwoDigits(aboveRangeStart);
       i = Utility.NormalizeDoubleTwoDigits(i - sellLimitGapSize)) {

    if (i < sellLimitMinPrice || i > sellLimitMaxPrice)
      break;

    if (i <= ask) {
      continue;
    }

    for (double j = i - sellLimitGapSize; j >= sellLimitMinPrice;
         j = Utility.NormalizeDoubleTwoDigits(j - sellLimitGapSize)) {

      if (i != 0) {
        sellLimitArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(i));
        sellLimitArrayTP.Add(Utility.NormalizeDoubleTwoDigits(j));
      } else {
        sellLimitArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(_Point));
        sellLimitArrayTP.Add(
            Utility.NormalizeDoubleTwoDigits(_Point + sellLimitGapSize));
      }
    }
  }
}

void GetSellStopArrayPrices(double belowRangeStart, double belowRangeEnd,
                            double bid) {

  sellStopArrayPrices.Shutdown();
  sellStopArrayTP.Shutdown();

  for (double i = Utility.NormalizeDoubleTwoDigits(belowRangeEnd);
       i > Utility.NormalizeDoubleTwoDigits(belowRangeStart);
       i = Utility.NormalizeDoubleTwoDigits(i - sellStopGapSize)) {

    if (i < sellStopMinPrice || i > sellStopMaxPrice)
      break;

    if (i >= bid) {
      continue;
    }

    for (double j = i - sellStopGapSize; j >= sellStopMinPrice;
         j = Utility.NormalizeDoubleTwoDigits(j - sellStopGapSize)) {

      if (i != 0) {
        sellStopArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(i));
        sellStopArrayTP.Add(Utility.NormalizeDoubleTwoDigits(j));
      } else {
        sellStopArrayPrices.Add(Utility.NormalizeDoubleTwoDigits(_Point));
        sellStopArrayTP.Add(
            Utility.NormalizeDoubleTwoDigits(_Point + sellStopGapSize));
      }
    }
  }
}

void GetArrayPrices() {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("GetArrayPrices ask: ", ask, ", bid: ", bid);

  double aboveRangeStart = MathFloor(ask);
  double aboveRangeEnd = NormalizeDouble(aboveRangeStart + priceRange, 0);

  double belowRangeEnd = MathCeil(bid);
  double belowRangeStart = NormalizeDouble(belowRangeEnd - priceRange, 0);

  Print("aboveRangeStart: ", aboveRangeStart,
        ", aboveRangeEnd: ", aboveRangeEnd,
        ", belowRangeStart: ", belowRangeStart,
        ", belowRangeEnd: ", belowRangeEnd);

  if (buyStopGapSize) {

    GetBuyStopArrayPrices(aboveRangeStart, aboveRangeEnd, ask);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", buyStopArrayPrices[i],
            ", tp: ", buyStopArrayTP[i]);
    }
  }

  if (buyLimitGapSize) {

    GetBuyLimitArrayPrices(belowRangeStart, belowRangeEnd, bid);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", buyLimitArrayPrices[i],
            ", tp: ", buyLimitArrayTP[i]);
    }
  }

  if (sellLimitGapSize) {

    GetSellLimitArrayPrices(aboveRangeStart, aboveRangeEnd, ask);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", sellLimitArrayPrices[i],
            ", tp: ", sellLimitArrayTP[i]);
    }
  }

  if (sellStopGapSize) {

    GetSellStopArrayPrices(belowRangeStart, belowRangeEnd, bid);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", sellStopArrayPrices[i],
            ", tp: ", sellStopArrayTP[i]);
    }
  }
}

void CheckProfit() {

  double maxPrice = 70;
  double minPrice = 65;
  double sl = 60;
  double gridGap = 1;
  double lot = 0.01;

  Print("maxPrice: ", maxPrice, ", minPrice: ", minPrice,
        ", gridGap: ", gridGap, ", lot: ", lot);

  CArrayDouble prices;
  CArrayDouble tps;

  CArrayDouble gridPrices;

  double profit = 0;

  double gridProfit = 0;

  for (double i = minPrice; i < maxPrice; i += gridGap) {

    gridPrices.Add(Utility.NormalizeDoubleTwoDigits(i));

    gridProfit = Utility.NormalizeDoubleTwoDigits(
        gridProfit + cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lot,
                                                   i, i + gridGap));

    for (double j = i + gridGap; j <= maxPrice; j += gridGap) {
      prices.Add(Utility.NormalizeDoubleTwoDigits(i));
      tps.Add(Utility.NormalizeDoubleTwoDigits(j));
    }
  }

  Print("prices: ", prices.Total());

  double drawdown = 0;

  for (int i = 0; i < prices.Total(); i++) {
    Print("price: ", prices[i], ", tp: ", tps[i]);

    double newProfit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
                                                     lot, prices[i], tps[i]);

    profit = Utility.NormalizeDoubleTwoDigits(profit + newProfit);

    double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lot,
                                                prices[i], sl);

    Print("newProfit: ", newProfit, ", loss: ", loss);

    drawdown = Utility.NormalizeDoubleTwoDigits(drawdown + loss);
  }

  double gridDrawdown = 0;

  for (int i = 0; i < gridPrices.Total(); i++) {
    Print("gridPrice: ", gridPrices[i]);

    double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY, lot,
                                                prices[i], sl);

    gridDrawdown = Utility.NormalizeDoubleTwoDigits(gridDrawdown + loss);
  }

  Print("drawdown: ", drawdown, ", profit: ", profit,
        " number of orders: ", prices.Total());
  Print("gridDrawdown: ", gridDrawdown, ", gridProfit: ", gridProfit,
        ", number of orders: ", gridPrices.Total());
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
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {}

//+------------------------------------------------------------------+