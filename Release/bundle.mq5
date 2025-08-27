//+------------------------------------------------------------------+
//|                                                       bundle.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

//+------------------------------------------------------------------+
//| bundle Description                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
input double PriceRange = 2;  // Price range
input int LimitOrders = NULL; // Limit orders

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
input bool UseNotification = false;   // Use notification
input bool ClearOrderAndExit = false; // Clear all orders and exit
input bool OnlyCheckOrders = false;   // Only check orders

input group "Draw Input Summary";
input bool DrawInputSummary = true;      // Draw input summary
input color BuyStopColor = clrAqua;      // Buy Stop Color
input color BuyLimitColor = clrYellow;   // Buy Limit Color
input color SellLimitColor = clrOrange;  // Sell Limit Color
input color SellStopColor = clrDeepPink; // Sell Stop Color
input color RealizeBalancePositiveColor =
    clrSpringGreen; // Realize Balance Positive Color
input color RealizeBalanceNegativeColor =
    clrRed; // Realize Balance Negative Color
input ENUM_BASE_CORNER Corner = CORNER_RIGHT_LOWER; // corner

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double priceRange = NULL;
int limitOrders = NULL;

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

CArrayDouble buyStopArrayPrices;
CArrayDouble buyStopArrayTP;
CArrayDouble buyLimitArrayPrices;
CArrayDouble buyLimitArrayTP;
CArrayDouble sellLimitArrayPrices;
CArrayDouble sellLimitArrayTP;
CArrayDouble sellStopArrayPrices;
CArrayDouble sellStopArrayTP;

bool drawInputSummary = NULL;
ENUM_BASE_CORNER corner = NULL;

string MyComment = "bundle";
// comment pattern: <ea_name>|<IsFillIn>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (ClearOrderAndExit) {
    int result = MessageBox("Clear all orders and exit?", "Confirm",
                            MB_OKCANCEL | MB_ICONQUESTION);

    if (result == IDOK) {
      Utility.CloseAllOrdersByComment(MyComment);
      Utility.AlertAndExit("Clear all orders and exit.");
    }
  }

  if (PriceRange == priceRange && BuyStopLot == buyStopLot &&
      BuyStopGapSize == buyStopGapSize &&
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
      FillInSellStopLots == fillInSellStopLots &&
      DrawInputSummary == drawInputSummary && Corner == corner) {
    Print("Parameters are already set.");
    return (INIT_SUCCEEDED);
  }

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

  if (UseNotification && !TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) {
    Utility.AlertAndExit("Error. The client terminal does not have permission "
                         "to send notifications");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
      SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
    Utility.AlertAndExit("EA Cannot be use with this product!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((BuyStopLot != NULL && BuyStopGapSize == NULL) ||
      (BuyStopLot == NULL && BuyStopGapSize != NULL)) {
    Utility.AlertAndExit("BuyStopLot and BuyStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (BuyStopMaxPrice != NULL && BuyStopMinPrice != NULL &&
      BuyStopMaxPrice < BuyStopMinPrice) {
    Utility.AlertAndExit(
        "BuyStopMaxPrice must be greater than BuyStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (BuyStopLot && BuyStopGapSize && BuyStopLot != buyStopLot &&
      BuyStopGapSize != buyStopGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_BUY_STOP, BuyStopLot, BuyStopGapSize, BuyStopMaxTPSize,
          BuyStopMaxPrice, BuyStopMinPrice, FillInBuyStopLots) == false) {
    return INIT_FAILED;
  }

  if ((BuyLimitLot != NULL && BuyLimitGapSize == NULL) ||
      (BuyLimitLot == NULL && BuyLimitGapSize != NULL)) {
    Utility.AlertAndExit("BuyLimitLot and BuyLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (BuyLimitMaxPrice != NULL && BuyLimitMinPrice != NULL &&
      BuyLimitMaxPrice < BuyLimitMinPrice) {
    Utility.AlertAndExit(
        "BuyLimitMaxPrice must be greater than BuyLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (BuyLimitLot && BuyLimitGapSize && BuyLimitLot != buyLimitLot &&
      BuyLimitGapSize != buyLimitGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_BUY_LIMIT, BuyLimitLot, BuyLimitGapSize, BuyLimitMaxTPSize,
          BuyLimitMaxPrice, BuyLimitMinPrice, FillInBuyLimitLots) == false) {
    return INIT_FAILED;
  }

  if ((SellLimitLot != NULL && SellLimitGapSize == NULL) ||
      (SellLimitLot == NULL && SellLimitGapSize != NULL)) {
    Utility.AlertAndExit("SellLimitLot and SellLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (SellLimitMaxPrice != NULL && SellLimitMinPrice != NULL &&
      SellLimitMaxPrice < SellLimitMinPrice) {
    Utility.AlertAndExit(
        "SellLimitMaxPrice must be greater than SellLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (SellLimitLot && SellLimitGapSize && SellLimitLot != sellLimitLot &&
      SellLimitGapSize != sellLimitGapSize &&
      Utility.ConfirmInputMessageBox(ORDER_TYPE_SELL_LIMIT, SellLimitLot,
                                     SellLimitGapSize, SellLimitMaxTPSize,
                                     SellLimitMaxPrice, SellLimitMinPrice,
                                     FillInSellLimitLots) == false) {
    return INIT_FAILED;
  }

  if ((SellStopLot != NULL && SellStopGapSize == NULL) ||
      (SellStopLot == NULL && SellStopGapSize != NULL)) {
    Utility.AlertAndExit("SellStopLot and SellStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (SellStopMaxPrice != NULL && SellStopMinPrice != NULL &&
      SellStopMaxPrice < SellStopMinPrice) {
    Utility.AlertAndExit(
        "SellStopMaxPrice must be greater than SellStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (SellStopLot && SellStopGapSize && SellStopLot != sellStopLot &&
      SellStopGapSize != sellStopGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_SELL_STOP, SellStopLot, SellStopGapSize, SellStopMaxTPSize,
          SellStopMaxPrice, SellStopMinPrice, FillInSellStopLots) == false) {
    return INIT_FAILED;
  }

  Print("PriceRange: ", PriceRange, ", BuyStopGapSize: ", BuyStopGapSize,
        ", BuyLimitGapSize: ", BuyLimitGapSize,
        ", SellLimitGapSize: ", SellLimitGapSize,
        ", SellStopGapSize: ", SellStopGapSize);

  if (PriceRange != NULL &&
      (PriceRange < BuyStopGapSize || PriceRange < BuyLimitGapSize ||
       PriceRange < SellLimitGapSize || PriceRange < SellStopGapSize)) {
    Utility.AlertAndExit("PriceRange must be greater than all gap sizes.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeMin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  Print("volumeMin: ", volumeMin);

  if ((BuyStopLot != NULL && BuyStopLot < volumeMin) ||
      (BuyLimitLot != NULL && BuyLimitLot < volumeMin) ||
      (SellLimitLot != NULL && SellLimitLot < volumeMin) ||
      (SellStopLot != NULL && SellStopLot < volumeMin)) {
    Utility.AlertAndExit("Lots must be greater than volume min.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  const int accoutnLimitOrders = (int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);

  Print("accoutnLimitOrders: ", accoutnLimitOrders);

  if (LimitOrders && LimitOrders > accoutnLimitOrders) {
    Utility.AlertAndExit("limitOrders must be less than ACCOUNT_LIMIT_ORDERS.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (LimitOrders) {
    limitOrders = LimitOrders;
  } else {
    limitOrders = accoutnLimitOrders;
  }

  // Print("limitOrders: ", limitOrders);

  priceRange = PriceRange;

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

  drawInputSummary = DrawInputSummary;
  corner = Corner;

  int buyStopNumberOrders =
      !buyStopGapSize ? 0
                      : Utility.GetBundleNumberOfPossibleOrders(
                            buyStopMinPrice, buyStopMaxPrice, buyStopGapSize);

  int buyLimitNumberOrders =
      !buyLimitGapSize
          ? 0
          : Utility.GetBundleNumberOfPossibleOrders(
                buyLimitMinPrice, buyLimitMaxPrice, buyLimitGapSize);

  int sellLimitNumberOrders =
      !sellLimitGapSize
          ? 0
          : Utility.GetBundleNumberOfPossibleOrders(
                sellLimitMinPrice, sellLimitMaxPrice, sellLimitGapSize);

  int sellStopNumberOrders =
      !sellStopGapSize
          ? 0
          : Utility.GetBundleNumberOfPossibleOrders(
                sellStopMinPrice, sellStopMaxPrice, sellStopGapSize);

  int totalNumberOrders = buyStopNumberOrders + buyLimitNumberOrders +
                          sellLimitNumberOrders + sellStopNumberOrders;

  Print("buyStopNumberOrders: ", buyStopNumberOrders,
        ", buyLimitNumberOrders: ", buyLimitNumberOrders,
        ", sellLimitNumberOrders: ", sellLimitNumberOrders,
        ", sellStopNumberOrders: ", sellStopNumberOrders,
        ", totalNumberOrders: ", totalNumberOrders);

  if ((limitOrders < totalNumberOrders) &&
      MessageBox(
          "Limit Orders: " + IntegerToString(limitOrders) +
              "\nTotal Number Orders: " + IntegerToString(totalNumberOrders) +
              "\n\nAre you sure you want to continue?",
          "Confirm", MB_OKCANCEL | MB_ICONQUESTION) != IDOK) {
    Utility.AlertAndExit(
        "limitOrders must be greater than the sum of all orders.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  double totalBuyStopLots =
      Utility.NormalizeDoubleTwoDigits(buyStopNumberOrders * buyStopLot);
  double totalBuyLimitLots =
      Utility.NormalizeDoubleTwoDigits(buyStopNumberOrders * buyLimitLot);
  double totalSellLimitLots =
      Utility.NormalizeDoubleTwoDigits(sellLimitNumberOrders * sellLimitLot);
  double totalSellStopLots =
      Utility.NormalizeDoubleTwoDigits(sellStopNumberOrders * sellStopLot);
  double totalLots =
      Utility.NormalizeDoubleTwoDigits(totalBuyStopLots + totalBuyLimitLots +
                                       totalSellLimitLots + totalSellStopLots);

  Print("volumeLimit: ", volumeLimit,
        ", totalBuyStopLots: ", DoubleToString(totalBuyStopLots, 2),
        ", totalBuyLimitLots: ", DoubleToString(totalBuyLimitLots, 2),
        ", totalSellLimitLots: ", DoubleToString(totalSellLimitLots, 2),
        ", totalSellStopLots: ", DoubleToString(totalSellStopLots, 2),
        ", totalLots: ", DoubleToString(totalLots, 2));

  if ((volumeLimit < totalLots) &&
      MessageBox("Volume Limit: " + DoubleToString(volumeLimit, 2) +
                     "\nTotal Lots: " + DoubleToString(totalLots, 2) +
                     "\n Filled in not included!" +
                     "\n\nAre you sure you want to continue?",
                 "Confirm", MB_OKCANCEL | MB_ICONQUESTION) != IDOK) {
    Utility.AlertAndExit("Totals lots must be less then volume limit.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  GetArrayPrices();

  if (OnlyCheckOrders) {
    Utility.AlertAndExit("Check orders successfully.");
    return (INIT_SUCCEEDED);
  }

  if (drawInputSummary) {
    DrawSummary();
  } else {
    ClearSummary();
  }

  CloseOrderOutSideArray();

  CheckAndPlaceOrders();

  return (INIT_SUCCEEDED);
}

void GetArrayPrices() {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("GetArrayPrices ask: ", ask, ", bid: ", bid);

  if (buyStopGapSize) {

    Utility.GetBundleBuyStopArrayPrices(
        ask, buyStopGapSize, buyStopMaxTPSize, buyStopMaxPrice, buyStopMinPrice,
        priceRange, buyStopArrayPrices, buyStopArrayTP);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, ", Entry:", buyStopArrayPrices[i],
            ", TP: ", buyStopArrayTP[i]);
    }
  }

  if (buyLimitGapSize) {

    Utility.GetBundleBuyLimitArrayPrices(
        bid, buyLimitGapSize, buyLimitMaxTPSize, buyLimitMaxPrice,
        buyLimitMinPrice, priceRange, buyLimitArrayPrices, buyLimitArrayTP);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, ", Entry:", buyLimitArrayPrices[i],
            ", TP: ", buyLimitArrayTP[i]);
    }
  }

  if (sellLimitGapSize) {

    Utility.GetBundleSellLimitArrayPrices(
        ask, sellLimitGapSize, sellLimitMaxTPSize, sellLimitMaxPrice,
        sellLimitMinPrice, priceRange, sellLimitArrayPrices, sellLimitArrayTP);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, ", Entry:", sellLimitArrayPrices[i],
            ", TP: ", sellLimitArrayTP[i]);
    }
  }

  if (sellStopGapSize) {

    Utility.GetBundleSellStopArrayPrices(
        bid, sellStopGapSize, sellStopMaxTPSize, sellStopMaxPrice,
        sellStopMinPrice, priceRange, sellStopArrayPrices, sellStopArrayTP);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", i, ", Entry:", sellStopArrayPrices[i],
            ", TP: ", sellStopArrayTP[i]);
    }
  }
}

void CloseOrderOutSideArray() {
  Print("CloseOrderOutSideArray");
  Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, MyComment,
                                             buyStopLot, ORDER_TYPE_BUY_STOP);
  Utility.CloseOrderOutsideArrayPricesByType(buyLimitArrayPrices, MyComment,
                                             buyLimitLot, ORDER_TYPE_BUY_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(
      sellLimitArrayPrices, MyComment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);
  Utility.CloseOrderOutsideArrayPricesByType(sellStopArrayPrices, MyComment,
                                             sellStopLot, ORDER_TYPE_SELL_STOP);
}

void CheckAndPlaceOrders() {
  Print("CheckAndPlaceOrders");
  bool orderPriceInvalid = false;
  int errors = 0;

  do {

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("CheckAndPlaceOrders  buyStopArrayPrices: ", i, ", ",
            buyStopArrayPrices[i], ", tp: ", buyStopArrayTP[i]);
    }

    if (buyStopArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(buyStopArrayPrices, buyStopArrayTP,
                              buyStopGapSize, MyComment, ORDER_TYPE_BUY_STOP,
                              buyStopLot, fillInBuyStopLots, orderPriceInvalid);
    }

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("CheckAndPlaceOrders buyLimitArrayPrices: ", i, ", ",
            buyLimitArrayPrices[i], ", tp: ", buyLimitArrayTP[i]);
    }

    if (buyLimitArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitArrayTP,
                              buyLimitGapSize, MyComment, ORDER_TYPE_BUY_LIMIT,
                              buyLimitLot, fillInBuyLimitLots,
                              orderPriceInvalid);
    }

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("CheckAndPlaceOrders sellLimitArrayPrices: ", i, ", ",
            sellLimitArrayPrices[i], ", tp: ", sellLimitArrayTP[i]);
    }

    if (sellLimitArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitArrayTP,
                              sellLimitGapSize, MyComment, ORDER_TYPE_SELL_LIMIT,
                              sellLimitLot, fillInSellLimitLots,
                              orderPriceInvalid);
    }

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("CheckAndPlaceOrders sellStopArrayPrices: ", i, ", ",
            sellStopArrayPrices[i], ", tp: ", sellStopArrayTP[i]);
    }

    if (sellStopArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(sellStopArrayPrices, sellStopArrayTP,
                              sellStopGapSize, MyComment, ORDER_TYPE_SELL_STOP,
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
    Print("missingDeals, type: ", Utility.GetOrderTypeString(type), ": ",
          missingDeals[i],
          ", lot: ", Utility.NormalizeDoubleTwoDigits(missingDealsLots[i]),
          ", tp: ", missingDealsTP[i]);

    switch (type) {

    case ORDER_TYPE_BUY_STOP:
      Utility.PlaceBuyStopOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == BuyStopLot ? MyComment + "|F" : MyComment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_BUY_LIMIT:
      Utility.PlaceBuyLimitOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == BuyLimitLot ? MyComment + "|F" : MyComment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_SELL_LIMIT:
      Utility.PlaceSellLimitOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == SellLimitLot ? MyComment + "|F" : MyComment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_SELL_STOP:
      Utility.PlaceSellStopOrder(
          missingDeals[i], missingDealsLots[i], missingDealsTP[i],
          missingDealsLots[i] == SellStopLot ? MyComment + "|F" : MyComment + "|T",
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
  CArrayDouble existOrdersTP;

  Print("FilterOpenOrdersAndPositionsByType OrdersTotal: ", OrdersTotal());

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

      // Print("FilterOpenOrdersAndPositionsByType orderComment: ",
      // orderComment,
      //       ", orderType: ", orderType, ", count: ", count,
      //       ", orderTicket: ", orderTicket);

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
      double orderTP = OrderGetDouble(ORDER_TP);

      Print("FilterOpenOrdersAndPositionsByType orderPrice: ", orderPrice,
            ", orderVolume: ", orderVolume, ", orderTP: ", orderTP);

      Utility.getExistDealsWithLotsAndTP(
          arrayPrices, arrayTP, gridGapSize, orderPrice, orderVolume, orderTP,
          existOrders, existOrdersLots, existOrdersTP);
    }
  }

  CArrayDouble existPositions;
  CArrayDouble existPositionsLots;
  CArrayDouble existPositionsTP;

  Print("FilterOpenOrdersAndPositionsByType PositionsTotal: ",
        PositionsTotal());

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {

      string symbol = PositionGetString(POSITION_SYMBOL);

      if (symbol != _Symbol) {
        continue;
      }

      long positionType = PositionGetInteger(POSITION_TYPE);

      string positionComment = PositionGetString(POSITION_COMMENT);
      string splitComment[];
      int count = StringSplit(positionComment, '|', splitComment);

      // Print("FilterOpenOrdersAndPositionsByType positionComment: ",
      //       positionComment, ", positionType: ", positionType,
      //       ", positionTicket: ", positionTicket);

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
      double positionTP = PositionGetDouble(POSITION_TP);

      Print("FilterOpenOrdersAndPositionsByType positionPrice: ", positionPrice,
            ", positionVolume: ", positionVolume, ", positionTP: ", positionTP);

      Utility.getExistDealsWithLotsAndTP(
          arrayPrices, arrayTP, gridGapSize, positionPrice, positionVolume,
          positionTP, existPositions, existPositionsLots, existPositionsTP);
    }
  }

  for (int i = 0; i < existOrders.Total(); i++) {
    Print("existOrders: ", existOrders[i],
          ", existOrdersLots: ", existOrdersLots[i],
          ", existOrdersTP: ", existOrdersTP[i]);
  }

  for (int i = 0; i < existPositions.Total(); i++) {
    Print("existPositions: ", existPositions[i],
          ", existPositionsLots: ", existPositionsLots[i],
          ", existPositionsTP: ", existPositionsTP[i]);
  }

  for (int i = 0; i < arrayPrices.Total(); i++) {
    // Print("arrayPrices[i]: ", arrayPrices[i], ", arrayTP[i]: ",
    // arrayTP[i]);

    bool foundInExistOrders = false;

    for (int j = 0; j < existOrders.Total(); j++) {
      // Print("existOrders[j]: ", existOrders[j],
      //       ", existOrdersTP[j]: ", existOrdersTP[j]);

      // if exist order continue
      if (arrayPrices[i] == existOrders[j] && arrayTP[i] == existOrdersTP[j]) {
        foundInExistOrders = true;
        break;
      }
    }

    if (foundInExistOrders)
      continue;

    double totalLots = 0;

    bool foundInExistPositions = false;

    for (int j = 0; j < existPositions.Total(); j++) {
      // Print("existPositions[j]: ", existPositions[j],
      //       ", existPositionsTP[j]: ", existPositionsTP[j]);

      // if found position
      if (arrayPrices[i] == existPositions[j] &&
          arrayTP[i] == existPositionsTP[j]) {

        // if position lot size less than lot fill in
        if (filInLots && existPositionsLots[j] < lot) {
          totalLots = Utility.NormalizeDoubleTwoDigits(totalLots +
                                                       existPositionsLots[j]);
        }

        // if not fill in lot or Lot size are equal
        else {
          foundInExistPositions = true;
          break;
        }
      }
    }

    if (foundInExistPositions)
      continue;

    missingDeals.Add(arrayPrices[i]);
    missingDealsTP.Add(arrayTP[i]);
    missingDealsLots.Add(lot - totalLots);
  }
}

void DrawSummaryObject(string objectName, string text, int yDistance,
                       ENUM_ANCHOR_POINT anchor, long textColor) {

  if (ObjectFind(0, objectName) < 0) {
    ObjectCreate(0, objectName, OBJ_LABEL, 0, 0, 0);
    ObjectSetInteger(0, objectName, OBJPROP_CORNER, corner);
    ObjectSetInteger(0, objectName, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(0, objectName, OBJPROP_XSIZE, 200);
    ObjectSetInteger(0, objectName, OBJPROP_YSIZE, 20);
    ObjectSetInteger(0, objectName, OBJPROP_XDISTANCE, 10);
    ObjectSetInteger(0, objectName, OBJPROP_YDISTANCE, yDistance);
    ObjectSetInteger(0, objectName, OBJPROP_COLOR, textColor);
  }
  ObjectSetString(0, objectName, OBJPROP_TEXT, text);
}

void DrawSummary() {

  ClearSummary();

  ENUM_ANCHOR_POINT anchor;

  switch (corner) {
  case CORNER_LEFT_UPPER:
    anchor = ANCHOR_LEFT_UPPER;
    break;
  case CORNER_LEFT_LOWER:
    anchor = ANCHOR_LEFT_LOWER;
    break;
  case CORNER_RIGHT_UPPER:
    anchor = ANCHOR_RIGHT_UPPER;
    break;
  default:
    anchor = ANCHOR_RIGHT_LOWER;
    break;
  }

  CArrayString objectNames;
  CArrayString texts;
  CArrayLong colors;

  if (buyStopGapSize) {

    texts.Add("Buy Stop, Lot:" + DoubleToString(buyStopLot, 2) +
              ", Gap:" + DoubleToString(buyStopGapSize, 2) +
              ", TP:" + DoubleToString(buyStopMaxTPSize, 2));
    objectNames.Add("Buy_Stop_Summary_1");
    colors.Add(BuyStopColor);

    texts.Add(",Max:" + DoubleToString(buyStopMaxPrice, 2) +
              ", Min:" + DoubleToString(buyStopMinPrice, 2) +
              ", Fill In:" + (fillInBuyStopLots ? "True" : "False"));
    objectNames.Add("Buy_Stop_Summary_2");
    colors.Add(BuyStopColor);
  }

  if (buyLimitGapSize) {

    texts.Add("Buy Limit, Lot:" + DoubleToString(buyLimitLot, 2) +
              ", Gap:" + DoubleToString(buyLimitGapSize, 2) +
              ", TP:" + DoubleToString(buyLimitMaxTPSize, 2));
    objectNames.Add("Buy_Limit_Summary_1");
    colors.Add(BuyLimitColor);

    texts.Add(",Max:" + DoubleToString(buyLimitMaxPrice, 2) +
              ", Min:" + DoubleToString(buyLimitMinPrice, 2) +
              ", Fill In:" + (fillInBuyLimitLots ? "True" : "False"));
    objectNames.Add("Buy_Limit_Summary_2");
    colors.Add(BuyLimitColor);
  }

  if (sellLimitGapSize) {

    texts.Add("Sell Limit, Lot:" + DoubleToString(sellLimitLot, 2) +
              ", Gap:" + DoubleToString(sellLimitGapSize, 2) +
              ", TP:" + DoubleToString(sellLimitMaxTPSize, 2));
    objectNames.Add("Sell_Limit_Summary_1");
    colors.Add(SellLimitColor);

    texts.Add(",Max:" + DoubleToString(sellLimitMaxPrice, 2) +
              ", Min:" + DoubleToString(sellLimitMinPrice, 2) +
              ", Fill In:" + (fillInSellLimitLots ? "True" : "False"));
    objectNames.Add("Sell_Limit_Summary_2");
    colors.Add(SellLimitColor);
  }

  if (sellStopGapSize) {

    texts.Add("Sell Stop, Lot:" + DoubleToString(sellStopLot, 2) +
              ", Gap:" + DoubleToString(sellStopGapSize, 2) +
              ", TP:" + DoubleToString(sellStopMaxTPSize, 2));
    objectNames.Add("Sell_Stop_Summary_1");
    colors.Add(SellStopColor);

    texts.Add(",Max:" + DoubleToString(sellStopMaxPrice, 2) +
              ", Min:" + DoubleToString(sellStopMinPrice, 2) +
              ", Fill In:" + (fillInSellStopLots ? "True" : "False"));
    objectNames.Add("Sell_Stop_Summary_2");
    colors.Add(SellStopColor);
  }

  double equity = Utility.GetRealizeBalance();
  string balanceText = "";

  if (equity > 0) {
    balanceText = "Balance is surplus by " + DoubleToString(equity, 2);
  } else {
    balanceText = "Balance is short of by " + DoubleToString(equity, 2);
  }

  texts.Add(balanceText);
  objectNames.Add("Balance_Summary");
  colors.Add(equity > 0 ? RealizeBalancePositiveColor
                        : RealizeBalanceNegativeColor);

  switch (corner) {
  case CORNER_LEFT_UPPER:
  case CORNER_RIGHT_UPPER:
    for (int i = 0; i < objectNames.Total(); i++) {
      DrawSummaryObject(objectNames[i], texts[i], (i * 25) + 25, anchor,
                        colors[i]);
    }
    break;
  case CORNER_LEFT_LOWER:
  case CORNER_RIGHT_LOWER:
    for (int i = 0, yDistance = objectNames.Total() * 25;
         i < objectNames.Total(); i++, yDistance -= 25) {
      DrawSummaryObject(objectNames[i], texts[i], yDistance, anchor, colors[i]);
    }
    break;
  }

  ChartRedraw();
}

void ClearSummary() {
  ObjectDelete(0, "Buy_Stop_Summary_1");
  ObjectDelete(0, "Buy_Stop_Summary_2");
  ObjectDelete(0, "Buy_Limit_Summary_1");
  ObjectDelete(0, "Buy_Limit_Summary_2");
  ObjectDelete(0, "Sell_Limit_Summary_1");
  ObjectDelete(0, "Sell_Limit_Summary_2");
  ObjectDelete(0, "Sell_Stop_Summary_1");
  ObjectDelete(0, "Sell_Stop_Summary_2");
  ObjectDelete(0, "Balance_Summary");

  ChartRedraw();
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
void OnDeinit(const int reason) {
  if (reason != REASON_CHARTCHANGE && drawInputSummary) {
    ClearSummary();
  }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {

  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  if (buyStopArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(buyStopArrayPrices[0] - ask) >
          buyStopGapSize) {

    Utility.GetBundleBuyStopArrayPrices(
        ask, buyStopGapSize, buyStopMaxTPSize, buyStopMaxPrice, buyStopMinPrice,
        priceRange, buyStopArrayPrices, buyStopArrayTP);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, ", TP", buyStopArrayPrices[i],
            ", Entry:: ", buyStopArrayTP[i]);
    }

    Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, MyComment,
                                               buyStopLot, ORDER_TYPE_BUY_STOP);

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(buyStopArrayPrices, buyStopArrayTP, buyStopGapSize,
                            MyComment, ORDER_TYPE_BUY_STOP, buyStopLot,
                            fillInBuyStopLots, orderPriceInvalid);
  }

  if (buyLimitArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(
          bid - (buyLimitArrayPrices[buyLimitArrayPrices.Total() - 1])) >
          buyLimitGapSize) {

    Utility.GetBundleBuyLimitArrayPrices(
        bid, buyLimitGapSize, buyLimitMaxTPSize, buyLimitMaxPrice,
        buyLimitMinPrice, priceRange, buyLimitArrayPrices, buyLimitArrayTP);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, ", Entry:", buyLimitArrayPrices[i],
            ", TP: ", buyLimitArrayTP[i]);
    }

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitArrayTP,
                            buyLimitGapSize, MyComment, ORDER_TYPE_BUY_LIMIT,
                            buyLimitLot, fillInBuyLimitLots, orderPriceInvalid);
  }

  if (sellLimitArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask) >
          sellLimitGapSize) {

    Utility.GetBundleSellLimitArrayPrices(
        ask, sellLimitGapSize, sellLimitMaxTPSize, sellLimitMaxPrice,
        sellLimitMinPrice, priceRange, sellLimitArrayPrices, sellLimitArrayTP);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, ", Entry:", sellLimitArrayPrices[i],
            ", TP: ", sellLimitArrayTP[i]);
    }

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitArrayTP,
                            sellLimitGapSize, MyComment, ORDER_TYPE_SELL_LIMIT,
                            sellLimitLot, fillInSellLimitLots,
                            orderPriceInvalid);
  }

  if (sellStopArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]) >
          sellStopGapSize) {

    Utility.GetBundleSellStopArrayPrices(
        bid, sellStopGapSize, sellStopMaxTPSize, sellStopMaxPrice,
        sellStopMinPrice, priceRange, sellStopArrayPrices, sellStopArrayTP);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", i, ", Entry:", sellStopArrayPrices[i],
            ", TP: ", sellStopArrayTP[i]);
    }

    bool orderPriceInvalid = false;

    PlaceMissingDealsByType(sellStopArrayPrices, sellStopArrayTP,
                            sellStopGapSize, MyComment, ORDER_TYPE_SELL_STOP,
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

      if (UseNotification)
        SendNotification(message);

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_TP) {

      string message = "TP " + strType + " " + (string)trans.volume;

      Alert(message);

      if (UseNotification)
        SendNotification(message);

      Order66();

    } else if ((ENUM_DEAL_REASON)reason == DEAL_REASON_EXPERT) {
      Order66();
    }

    if (drawInputSummary)
      DrawSummary();
  }
}

void Order66() {
  GetArrayPrices();
  CloseOrderOutSideArray();
  CheckAndPlaceOrders();
}

//+------------------------------------------------------------------+