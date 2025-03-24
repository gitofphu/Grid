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
input double BuyStopLot = NULL;       // Lot size
input double BuyStopGapSize = NULL;   // Gap size
input double BuyStopMaxTPSize = NULL; // Max TP size
input double BuyStopMaxPrice = NULL;  // Max price
input double BuyStopMinPrice = NULL;  // Min price
input bool FillInBuyStopLots = false; // Fill in lots

input group "Buy Limit";
input double BuyLimitLot = NULL;       // Lot size
input double BuyLimitGapSize = NULL;   // Gap size
input double BuyLimitMaxTPSize = NULL; // Max TP size
input double BuyLimitMaxPrice = NULL;  // Max price
input double BuyLimitMinPrice = NULL;  // Min price
input bool FillInBuyLimitLots = false; // Fill in lots

input group "Sell Limit";
input double SellLimitLot = NULL;       // Lot size
input double SellLimitGapSize = NULL;   // Gap size
input double SellLimitMaxTPSize = NULL; // Max TP size
input double SellLimitMaxPrice = NULL;  // Max price
input double SellLimitMinPrice = NULL;  // Min price
input bool FillInSellLimitLots = false; // Fill in lots

input group "Sell Stop";
input double SellStopLot = NULL;       // Lot size
input double SellStopGapSize = NULL;   // Gap size
input double SellStopMaxTPSize = NULL; // Max TP size
input double SellStopMaxPrice = NULL;  // Max price
input double SellStopMinPrice = NULL;  // Min price
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
double buyStopMaxTPSize = NULL;
double buyStopMaxPrice = NULL;
double buyStopMinPrice = NULL;
bool fillInBuyStopLots = false;

double buyLimitLot = NULL;
double buyLimitGapSize = NULL;
double buyLimitMaxTPSize = NULL;
double buyLimitMaxPrice = NULL;
double buyLimitMinPrice = NULL;
bool fillInBuyLimitLots = false;

double sellLimitLot = NULL;
double sellLimitGapSize = NULL;
double sellLimitMaxTPSize = NULL;
double sellLimitMaxPrice = NULL;
double sellLimitMinPrice = NULL;
bool fillInSellLimitLots = false;

double sellStopLot = NULL;
double sellStopGapSize = NULL;
double sellStopMaxTPSize = NULL;
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
      BuyStopMaxTPSize == buyStopMaxTPSize &&
      BuyStopMaxPrice == buyStopMaxPrice &&
      BuyStopMinPrice == buyStopMinPrice &&
      FillInBuyStopLots == fillInBuyStopLots && BuyLimitLot == buyLimitLot &&
      BuyLimitGapSize == buyLimitGapSize &&
      BuyLimitMaxTPSize == buyLimitMaxTPSize &&
      BuyLimitMaxPrice == buyLimitMaxPrice &&
      BuyLimitMinPrice == buyLimitMinPrice &&
      FillInBuyLimitLots == fillInBuyLimitLots &&
      SellLimitLot == sellLimitLot && SellLimitGapSize == sellLimitGapSize &&
      SellLimitMaxTPSize == sellLimitMaxTPSize &&
      SellLimitMaxPrice == sellLimitMaxPrice &&
      SellLimitMinPrice == sellLimitMinPrice &&
      FillInSellLimitLots == fillInSellLimitLots &&
      SellStopLot == sellStopLot && SellStopGapSize == sellStopGapSize &&
      SellStopMaxTPSize == sellStopMaxTPSize &&
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
  buyStopMaxTPSize = BuyStopMaxTPSize;
  buyStopMaxPrice = BuyStopMaxPrice;
  buyStopMinPrice = BuyStopMinPrice;
  fillInBuyStopLots = FillInBuyStopLots;

  buyLimitLot = BuyLimitLot;
  buyLimitGapSize = BuyLimitGapSize;
  buyLimitMaxTPSize = BuyLimitMaxTPSize;
  buyLimitMaxPrice = BuyLimitMaxPrice;
  buyLimitMinPrice = BuyLimitMinPrice;
  fillInBuyLimitLots = FillInBuyLimitLots;

  sellLimitLot = SellLimitLot;
  sellLimitGapSize = SellLimitGapSize;
  sellLimitMaxTPSize = SellLimitMaxTPSize;
  sellLimitMaxPrice = SellLimitMaxPrice;
  sellLimitMinPrice = SellLimitMinPrice;
  fillInSellLimitLots = FillInSellLimitLots;

  sellStopLot = SellStopLot;
  sellStopGapSize = SellStopGapSize;
  sellStopMaxTPSize = SellStopMaxTPSize;
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

  CloseOrderOutSideArray();

  CheckAndPlaceOrders();

  return (INIT_SUCCEEDED);
}

void GetBuyStopArrayPrices(double aboveRangeStart, double aboveRangeEnd,
                           double ask) {

  buyStopArrayPrices.Shutdown();
  buyStopArrayTP.Shutdown();

  for (double i = Utility.NormalizeDoubleTwoDigits(aboveRangeStart);
       i < Utility.NormalizeDoubleTwoDigits(aboveRangeEnd);
       i = Utility.NormalizeDoubleTwoDigits(i + buyStopGapSize)) {

    if (i < buyStopMinPrice || i > buyStopMaxPrice)
      break;

    if (i <= ask) {
      continue;
    }

    for (double j = i + buyStopGapSize; j <= buyStopMaxPrice;
         j = Utility.NormalizeDoubleTwoDigits(j + buyStopGapSize)) {

      // Print("GetBuyStopArrayPrices i: ", i, ", j: ", j,
      //       ", buyStopMaxTPSize: ", buyStopMaxTPSize, ", MaxTP: ",
      //       Utility.NormalizeDoubleTwoDigits(i + buyStopMaxTPSize));

      if (buyStopMaxTPSize &&
          j > Utility.NormalizeDoubleTwoDigits(i + buyStopMaxTPSize)) {
        break;
      }

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

      // Print("GetBuyLimitArrayPrices i: ", i, ", j: ", j,
      //       ", buyLimitMaxTPSize: ", buyLimitMaxTPSize, ", MaxTP: ",
      //       Utility.NormalizeDoubleTwoDigits(i + buyLimitMaxTPSize));

      if (buyLimitMaxTPSize &&
          j > Utility.NormalizeDoubleTwoDigits(i + buyLimitMaxTPSize)) {
        break;
      }

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

      // Print("GetSellLimitArrayPrices i: ", i, ", j: ", j,
      //       ", sellLimitMaxTPSize: ", sellLimitMaxTPSize, ", MaxTP: ",
      //       Utility.NormalizeDoubleTwoDigits(i - sellLimitMaxTPSize));

      if (sellLimitMaxTPSize &&
          j < Utility.NormalizeDoubleTwoDigits(i - sellLimitMaxTPSize)) {
        break;
      }

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

      // Print("GetSellStopArrayPrices i: ", i, ", j: ", j,
      //       ", sellStopMaxTPSize: ", sellStopMaxTPSize, ", MaxTP: ",
      //       Utility.NormalizeDoubleTwoDigits(i - sellStopMaxTPSize));

      if (sellStopMaxTPSize &&
          j < Utility.NormalizeDoubleTwoDigits(i - sellStopMaxTPSize)) {
        break;
      }

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
      Print("buyStopArrayPrices: ", i, ", ", buyStopArrayPrices[i],
            ", tp: ", buyStopArrayTP[i]);
    }
  }

  if (buyLimitGapSize) {

    GetBuyLimitArrayPrices(belowRangeStart, belowRangeEnd, bid);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, ", ", buyLimitArrayPrices[i],
            ", tp: ", buyLimitArrayTP[i]);
    }
  }

  if (sellLimitGapSize) {

    GetSellLimitArrayPrices(aboveRangeStart, aboveRangeEnd, ask);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, ", ", sellLimitArrayPrices[i],
            ", tp: ", sellLimitArrayTP[i]);
    }
  }

  if (sellStopGapSize) {

    GetSellStopArrayPrices(belowRangeStart, belowRangeEnd, bid);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", i, ", ", sellStopArrayPrices[i],
            ", tp: ", sellStopArrayTP[i]);
    }
  }
}

void CloseOrderOutSideArray() {
  Print("CloseOrderOutSideArray");
  Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                             buyStopLot, ORDER_TYPE_BUY_STOP);
  Utility.CloseOrderOutsideArrayPricesByType(buyLimitArrayPrices, Comment,
                                             buyLimitLot, ORDER_TYPE_BUY_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(
      sellLimitArrayPrices, Comment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(sellStopArrayPrices, Comment,
                                             sellStopLot, ORDER_TYPE_SELL_STOP);
}

void CheckAndPlaceOrders() {
  Print("CheckAndPlaceOrders");
  bool orderPriceInvalid = false;
  int errors = 0;

  do {

    if (buyStopArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(buyStopArrayPrices, buyStopArrayTP,
                              buyStopGapSize, Comment, ORDER_TYPE_BUY_STOP,
                              buyStopLot, fillInBuyStopLots, orderPriceInvalid);
    }

    if (buyLimitArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitArrayTP,
                              buyLimitGapSize, Comment, ORDER_TYPE_BUY_LIMIT,
                              buyLimitLot, fillInBuyLimitLots,
                              orderPriceInvalid);
    }

    if (sellLimitArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitArrayTP,
                              sellLimitGapSize, Comment, ORDER_TYPE_SELL_LIMIT,
                              sellLimitLot, fillInSellLimitLots,
                              orderPriceInvalid);
    }

    if (sellStopArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(sellStopArrayPrices, sellStopArrayTP,
                              sellStopGapSize, Comment, ORDER_TYPE_SELL_STOP,
                              sellStopLot, fillInSellStopLots,
                              orderPriceInvalid);
    }

  } while (orderPriceInvalid && errors < 3);

  // if (errors >= 3) {
  //   Utility.AlertAndExit("Place order error.");
  // }
}

void PlaceMissingDealsByType(CArrayDouble &arrayPrices, CArrayDouble &arrayTP,
                             double gridGapSize, string comment,
                             const ENUM_ORDER_TYPE type, double lot,
                             bool filInLots, bool &orderPriceInvalid) {
  CArrayDouble missingDeals;
  CArrayDouble missingDealsTP;
  CArrayDouble missingDealsLots;

  switch (type) {
  case ORDER_TYPE_BUY_STOP:
    FilterOpenOrdersAndPositionsByType(
        arrayPrices, arrayTP, gridGapSize, comment, type, buyStopLot,
        fillInBuyStopLots, missingDeals, missingDealsTP, missingDealsLots);
    break;
  case ORDER_TYPE_BUY_LIMIT:
    FilterOpenOrdersAndPositionsByType(
        arrayPrices, arrayTP, gridGapSize, comment, type, buyLimitLot,
        fillInBuyLimitLots, missingDeals, missingDealsTP, missingDealsLots);
    break;
  case ORDER_TYPE_SELL_LIMIT:
    FilterOpenOrdersAndPositionsByType(
        arrayPrices, arrayTP, gridGapSize, comment, type, sellLimitLot,
        fillInSellLimitLots, missingDeals, missingDealsTP, missingDealsLots);
    break;
  case ORDER_TYPE_SELL_STOP:
    FilterOpenOrdersAndPositionsByType(
        arrayPrices, arrayTP, gridGapSize, comment, type, sellStopLot,
        fillInSellStopLots, missingDeals, missingDealsTP, missingDealsLots);
    break;
  }

  Print("type: ", Utility.GetOrderTypeString(type),
        ", missingDeals: ", missingDeals.Total());

  for (int i = 0; i < missingDeals.Total(); i++) {
    // Print(Utility.GetOrderTypeString(type), ": ", missingDeals[i],
    //       ", lot: ",
    //       Utility.NormalizeDoubleTwoDigits(missingDealsLots[i]));

    switch (type) {

    case ORDER_TYPE_BUY_STOP:
      Utility.PlaceBuyStopOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == BuyStopLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_BUY_LIMIT:
      Utility.PlaceBuyLimitOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == BuyLimitLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_SELL_LIMIT:
      Utility.PlaceSellLimitOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == SellLimitLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_SELL_STOP:
      Utility.PlaceSellStopOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == SellStopLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;
    }
  }
}

void FilterOpenOrdersAndPositionsByType(
    CArrayDouble &arrayPrices, CArrayDouble &arrayTP, double gridGapSize,
    string comment, const ENUM_ORDER_TYPE type, double lot, bool filInLots,
    CArrayDouble &missingDeals, CArrayDouble &missingDealsTP,
    CArrayDouble &missingDealsLots) {
  Print("FilterOpenOrdersAndPositionsByType comment: ", comment,
        ", type: ", Utility.GetOrderTypeString(type), ", lot: ", lot,
        ", filInLots: ", filInLots);

  CArrayDouble existOrders;
  CArrayDouble existOrdersLots;

  for (int i = 0; i < OrdersTotal(); i++) {
    ulong orderTicket = OrderGetTicket(i);

    if (OrderSelect(orderTicket)) {

      string symbol = OrderGetString(ORDER_SYMBOL);
      long orderType = OrderGetInteger(ORDER_TYPE);

      if (symbol != _Symbol || orderType != type) {
        continue;
      }

      string orderComment = OrderGetString(ORDER_COMMENT);
      string splitComment[];
      int count = StringSplit(orderComment, '|', splitComment);

      // Print("orderPrice: ", orderPrice, ", orderVolume: ", orderVolume,
      //       ", orderComment: ", orderComment, ", orderType: ", orderType,
      //       ", count: ", count, ", orderTicket: ", orderTicket);

      if (count == 0)
        continue;

      else if (count == 1 && orderComment != comment) {
        continue;
      }

      else if (count > 1 && splitComment[0] != comment) {
        continue;
      }

      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);

      Utility.getExistDealsWithLots(arrayPrices, gridGapSize, orderPrice,
                                    orderVolume, existOrders, existOrdersLots);
    }
  }

  CArrayDouble existPositions;
  CArrayDouble existPositionsLots;

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {

      string symbol = PositionGetString(POSITION_SYMBOL);

      if (symbol != _Symbol) {
        continue;
      }

      // Print("positionPrice: ", positionPrice,
      //       ", positionVolume: ", positionVolume,
      //       ", positionComment: ", positionComment,
      //       ", positionType: ", positionType,
      //       ", positionTicket: ", positionTicket);

      long positionType = PositionGetInteger(POSITION_TYPE);

      string positionComment = PositionGetString(POSITION_COMMENT);
      string splitComment[];
      int count = StringSplit(positionComment, '|', splitComment);

      if (count == 0)
        continue;

      else if (count == 1 && positionComment != comment) {
        continue;
      }

      else if (count > 1 && splitComment[0] != comment) {
        continue;
      }

      else if ((type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_BUY_STOP) &&
               positionType != POSITION_TYPE_BUY) {
        continue;
      }

      else if ((type == ORDER_TYPE_SELL_LIMIT ||
                type == ORDER_TYPE_SELL_STOP) &&
               positionType != POSITION_TYPE_SELL) {
        continue;
      }

      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double positionVolume = PositionGetDouble(POSITION_VOLUME);

      Utility.getExistDealsWithLots(arrayPrices, gridGapSize, positionPrice,
                                    positionVolume, existPositions,
                                    existPositionsLots);
    }
  }

  // for (int i = 0; i < existOrders.Total(); i++) {
  //   Print("existOrders: ", existOrders[i]);
  // }

  // for (int i = 0; i < existPositions.Total(); i++) {
  //   Print("existPositions: ", existPositions[i]);
  // }

  for (int i = 0; i < arrayPrices.Total(); i++) {
    int foundPositionIndex = existPositions.SearchLinear(arrayPrices[i]);
    int foundOrderIndex = existOrders.SearchLinear(arrayPrices[i]);

    // Print("arrayPrices[i]: ", arrayPrices[i],
    //       ", foundOrderIndex: ", foundOrderIndex,
    //       ", foundPositionIndex: ", foundPositionIndex);

    // if not found order and position add to missing deals
    if (foundOrderIndex == -1 && foundPositionIndex == -1) {
      // Print("case new order: ", arrayPrices[i], ", lot: ", lot);
      missingDeals.Add(arrayPrices[i]);
      missingDealsTP.Add(arrayTP[i]);
      missingDealsLots.Add(lot);
      continue;
    }

    // if found order continue, no need to check for position
    if (foundOrderIndex != -1) {
      // Print("case alreay have pending order: ", arrayPrices[i]);
      continue;
    }

    if (!filInLots)
      continue;

    // if found position check for lot size, if less than lot fill in
    double totalLots = 0;
    for (int j = 0; j < existPositions.Total(); j++) {
      if (existPositions[j] >= arrayPrices[i] &&
          existPositions[j] <= arrayPrices[i] + gridGapSize - _Point) {

        totalLots =
            Utility.NormalizeDoubleTwoDigits(totalLots + existPositionsLots[j]);
      }
    }

    if (totalLots < lot) {
      missingDeals.Add(arrayPrices[i]);
      missingDealsTP.Add(arrayTP[i]);
      missingDealsLots.Add(lot - totalLots);
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
void OnTick() {
  Print("OnTick, clearOrderAndExit: ", clearOrderAndExit);

  if (clearOrderAndExit) {
    Utility.CloseAllOrdersByComment(Comment);
    Utility.AlertAndExit("Clear all orders and exit.");
    return;
  }

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double aboveRangeStart = MathFloor(ask);
  double aboveRangeEnd = NormalizeDouble(aboveRangeStart + priceRange, 0);

  double belowRangeEnd = MathCeil(bid);
  double belowRangeStart = NormalizeDouble(belowRangeEnd - priceRange, 0);

  if (buyStopArrayPrices.Total() > 0) {
    Print("buyStop ask: ", ask, ", first price: ", buyStopArrayPrices[0],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(buyStopArrayPrices[0] - ask),
          ", gap: ", buyStopGapSize, ", buyStop maxPrice: ", buyStopMaxPrice,
          ", buyStop minPrice: ", buyStopMinPrice);
  }

  if (buyStopArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(buyStopArrayPrices[0] - ask) >
          buyStopGapSize) {

    GetBuyStopArrayPrices(aboveRangeStart, aboveRangeEnd, ask);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, ", ", buyStopArrayPrices[i],
            ", tp: ", buyStopArrayTP[i]);
    }

    Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                               buyStopLot, ORDER_TYPE_BUY_STOP);

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(buyStopArrayPrices, buyStopArrayTP, buyStopGapSize,
                            Comment, ORDER_TYPE_BUY_STOP, buyStopLot,
                            fillInBuyStopLots, orderPriceInvalid);
  }

  if (buyLimitArrayPrices.Total() > 0) {
    Print("buyLimit bid: ", bid, ", last price: ",
          buyLimitArrayPrices[buyLimitArrayPrices.Total() - 1], ", diff: ",
          Utility.NormalizeDoubleTwoDigits(
              bid - (buyLimitArrayPrices[buyLimitArrayPrices.Total() - 1])),
          ", gap: ", buyLimitGapSize, ", buyLimit maxPrice: ", buyLimitMaxPrice,
          ", buyLimit minPrice: ", buyLimitMinPrice);
  }

  if (buyLimitArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(
          bid - (buyLimitArrayPrices[buyLimitArrayPrices.Total() - 1])) >
          buyLimitGapSize) {

    GetBuyLimitArrayPrices(belowRangeStart, belowRangeEnd, bid);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, ", ", buyLimitArrayPrices[i],
            ", tp: ", buyLimitArrayTP[i]);
    }

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitArrayTP,
                            buyLimitGapSize, Comment, ORDER_TYPE_BUY_LIMIT,
                            buyLimitLot, fillInBuyLimitLots, orderPriceInvalid);
  }

  if (sellLimitArrayPrices.Total() > 0) {
    Print("sellLimit ask: ", ask, ", last price: ",
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1], ", diff: ",
          Utility.NormalizeDoubleTwoDigits(
              sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask),
          ", gap: ", sellLimitGapSize,
          ", sellLimit maxPrice: ", sellLimitMaxPrice,
          ", sellLimit minPrice: ", sellLimitMinPrice);
  }

  if (sellLimitArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask) >
          sellLimitGapSize) {

    GetSellLimitArrayPrices(aboveRangeStart, aboveRangeEnd, ask);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, ", ", sellLimitArrayPrices[i],
            ", tp: ", sellLimitArrayTP[i]);
    }

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitArrayTP,
                            sellLimitGapSize, Comment, ORDER_TYPE_SELL_LIMIT,
                            sellLimitLot, fillInSellLimitLots,
                            orderPriceInvalid);
  }

  if (sellStopArrayPrices.Total() > 0) {
    Print("sellStop bid: ", bid, ", first price: ", sellStopArrayPrices[0],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]),
          ", gap: ", sellStopGapSize, ", sellStop maxPrice: ", sellStopMaxPrice,
          ", sellStop minPrice: ", sellStopMinPrice);
  }

  if (sellStopArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]) >
          sellStopGapSize) {

    GetSellStopArrayPrices(belowRangeStart, belowRangeEnd, bid);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", i, ", ", sellStopArrayPrices[i],
            ", tp: ", sellStopArrayTP[i]);
    }

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(sellStopArrayPrices, sellStopArrayTP,
                            sellStopGapSize, Comment, ORDER_TYPE_SELL_STOP,
                            sellStopLot, fillInSellStopLots, orderPriceInvalid);
  }
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {

  ENUM_TRADE_TRANSACTION_TYPE type = trans.type;

  if (type == TRADE_TRANSACTION_DEAL_ADD) {

    if (HistoryDealSelect(trans.deal)) {
      cDealInfo.Ticket(trans.deal);
    } else {
      Print(__FILE__, " ", __FUNCTION__, ", ERROR: HistoryDealSelect(",
            trans.deal, ")");
      return;
    }

    long reason = -1;
    if (!cDealInfo.InfoInteger(DEAL_REASON, reason)) {
      Print(__FILE__, " ", __FUNCTION__,
            ", ERROR: InfoInteger(DEAL_REASON,reason)");
      return;
    }

    int orderType = (int)HistoryOrderGetInteger(trans.deal, ORDER_TYPE);

    string strReason = Utility.GetDealReasonString((ENUM_DEAL_REASON)reason);

    Print("strReason: ", strReason);

    string strType = Utility.GetOrderTypeStringFromTransDeal(trans);

    if ((ENUM_DEAL_REASON)reason == DEAL_REASON_SL) {
      string message = "SL " + strType + " " + (string)trans.volume;

      Alert(message);

      if (useNotification)
        SendNotification(message);

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {

      string message = "TP " + strType + " " + (string)trans.volume;

      Alert(message);

      if (useNotification)
        SendNotification(message);

      Order66();

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_EXPERT) {
      Order66();
    }
  }
}

void Order66() {
  GetArrayPrices();
  CloseOrderOutSideArray();
  CheckAndPlaceOrders();
}

//+------------------------------------------------------------------+