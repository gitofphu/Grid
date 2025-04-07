//+------------------------------------------------------------------+
//|                                dynamic_grid_four_way_fill_in.mq5 |
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
input double PriceRange = 5;  // Price range
input int LimitOrders = NULL; // Limit orders

input group "Buy Stop";
input double BuyStopLot = NULL;       // Lot size
input double BuyStopGapSize = NULL;   // Gap size
input double BuyStopTP = NULL;        // Take profit
input double BuyStopMaxPrice = NULL;  // Max price
input double BuyStopMinPrice = NULL;  // Min price
input bool FillInBuyStopLots = false; // Fill in lots

input group "Buy Limit";
input double BuyLimitLot = NULL;       // Lot size
input double BuyLimitGapSize = NULL;   // Gap size
input double BuyLimitTP = NULL;        // Take profit
input double BuyLimitMaxPrice = NULL;  // Max price
input double BuyLimitMinPrice = NULL;  // Min price
input bool FillInBuyLimitLots = false; // Fill in lots

input group "Sell Limit";
input double SellLimitLot = NULL;       // Lot size
input double SellLimitGapSize = NULL;   // Gap size
input double SellLimitTP = NULL;        // Take profit
input double SellLimitMaxPrice = NULL;  // Max price
input double SellLimitMinPrice = NULL;  // Min price
input bool FillInSellLimitLots = false; // Fill in lots

input group "Sell Stop";
input double SellStopLot = NULL;       // Lot size
input double SellStopGapSize = NULL;   // Gap size
input double SellStopTP = NULL;        // Take profit
input double SellStopMaxPrice = NULL;  // Max price
input double SellStopMinPrice = NULL;  // Min price
input bool FillInSellStopLots = false; // Fill in lots

input group "Misc.";
input bool UseNotification = false;   // Use notification
input bool ClearOrderAndExit = false; // Clear all orders and exit

input group "Draw Input Summary";
input bool DrawInputSummary = true;                 // Draw input summary
input color BuyStopColor = clrAqua;                 // Buy Stop Color
input color BuyLimitColor = clrYellow;              // Buy Limit Color
input color SellLimitColor = clrOrange;             // Sell Limit Color
input color SellStopColor = clrDeepPink;            // Sell Stop Color
input ENUM_BASE_CORNER Corner = CORNER_RIGHT_LOWER; // corner

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double priceRange = NULL;
int limitOrders = NULL;

double buyStopLot = NULL;
double buyStopGapSize = NULL;
double buyStopTP = NULL;
double buyStopMaxPrice = NULL;
double buyStopMinPrice = NULL;
bool fillInBuyStopLots = false;

double buyLimitLot = NULL;
double buyLimitGapSize = NULL;
double buyLimitTP = NULL;
double buyLimitMaxPrice = NULL;
double buyLimitMinPrice = NULL;
bool fillInBuyLimitLots = false;

double sellLimitLot = NULL;
double sellLimitGapSize = NULL;
double sellLimitTP = NULL;
double sellLimitMaxPrice = NULL;
double sellLimitMinPrice = NULL;
bool fillInSellLimitLots = false;

double sellStopLot = NULL;
double sellStopGapSize = NULL;
double sellStopTP = NULL;
double sellStopMaxPrice = NULL;
double sellStopMinPrice = NULL;
bool fillInSellStopLots = false;

CArrayDouble buyStopArrayPrices;
CArrayDouble buyLimitArrayPrices;
CArrayDouble sellLimitArrayPrices;
CArrayDouble sellStopArrayPrices;

bool drawInputSummary = NULL;
ENUM_BASE_CORNER corner = NULL;

string Comment = "dynamic_grid";
// comment pattern: <ea_name>|<IsFillIn>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (ClearOrderAndExit) {
    int result = MessageBox("Clear all orders and exit?", "Confirm",
                            MB_OKCANCEL | MB_ICONQUESTION);

    if (result == IDOK) {
      Utility.CloseAllOrdersByComment(Comment);
      Utility.AlertAndExit("Clear all orders and exit.");
    }
  }

  if (PriceRange == priceRange && BuyStopLot == buyStopLot &&
      BuyStopGapSize == buyStopGapSize && BuyStopTP == buyStopTP &&
      BuyStopMaxPrice == buyStopMaxPrice &&
      BuyStopMinPrice == buyStopMinPrice &&
      FillInBuyStopLots == fillInBuyStopLots && BuyLimitLot == buyLimitLot &&
      BuyLimitGapSize == buyLimitGapSize && BuyLimitTP == buyLimitTP &&
      BuyLimitMaxPrice == buyLimitMaxPrice &&
      BuyLimitMinPrice == buyLimitMinPrice &&
      FillInBuyLimitLots == fillInBuyLimitLots &&
      SellLimitLot == sellLimitLot && SellLimitGapSize == sellLimitGapSize &&
      SellLimitTP == sellLimitTP && SellLimitMaxPrice == sellLimitMaxPrice &&
      SellLimitMinPrice == sellLimitMinPrice &&
      FillInSellLimitLots == fillInSellLimitLots &&
      SellStopLot == sellStopLot && SellStopGapSize == sellStopGapSize &&
      SellStopTP == sellStopTP && SellStopMaxPrice == sellStopMaxPrice &&
      SellStopMinPrice == sellStopMinPrice &&
      FillInSellStopLots == fillInSellStopLots &&
      DrawInputSummary == drawInputSummary && Corner == corner) {
    Print("Parameters are already set.");
    return (INIT_SUCCEEDED);
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

  priceRange = PriceRange;

  buyStopLot = BuyStopLot;
  buyStopGapSize = BuyStopGapSize;
  buyStopTP = BuyStopTP;
  buyStopMaxPrice = BuyStopMaxPrice;
  buyStopMinPrice = BuyStopMinPrice;
  fillInBuyStopLots = FillInBuyStopLots;

  buyLimitLot = BuyLimitLot;
  buyLimitGapSize = BuyLimitGapSize;
  buyLimitTP = BuyLimitTP;
  buyLimitMaxPrice = BuyLimitMaxPrice;
  buyLimitMinPrice = BuyLimitMinPrice;
  fillInBuyLimitLots = FillInBuyLimitLots;

  sellLimitLot = SellLimitLot;
  sellLimitGapSize = SellLimitGapSize;
  sellLimitTP = SellLimitTP;
  sellLimitMaxPrice = SellLimitMaxPrice;
  sellLimitMinPrice = SellLimitMinPrice;
  fillInSellLimitLots = FillInSellLimitLots;

  sellStopLot = SellStopLot;
  sellStopGapSize = SellStopGapSize;
  sellStopTP = SellStopTP;
  sellStopMaxPrice = SellStopMaxPrice;
  sellStopMinPrice = SellStopMinPrice;
  fillInSellStopLots = FillInSellStopLots;

  drawInputSummary = DrawInputSummary;
  corner = Corner;

  if (buyStopArrayPrices.Total() > 0) {
    buyStopArrayPrices.Shutdown();
  }

  if (buyLimitArrayPrices.Total() > 0) {
    buyLimitArrayPrices.Shutdown();
  }

  if (sellLimitArrayPrices.Total() > 0) {
    sellLimitArrayPrices.Shutdown();
  }

  if (sellStopArrayPrices.Total() > 0) {
    sellStopArrayPrices.Shutdown();
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

  if ((buyStopLot != NULL && buyStopGapSize == NULL) ||
      (buyStopLot == NULL && buyStopGapSize != NULL) ||
      (buyStopLot == NULL && buyStopGapSize == NULL && buyStopTP != NULL)) {
    Utility.AlertAndExit("buyStopLot and buyStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyStopMaxPrice != NULL && buyStopMinPrice != NULL &&
      buyStopMaxPrice < buyStopMinPrice) {
    Utility.AlertAndExit(
        "buyStopMaxPrice must be greater than buyStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyStopLot && buyStopGapSize && BuyStopLot != buyStopLot &&
      BuyStopGapSize != buyStopGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_BUY_STOP, buyStopLot, buyStopGapSize, buyStopTP,
          buyStopMaxPrice, buyStopMinPrice, fillInBuyStopLots) == false) {
    return INIT_FAILED;
  }

  if ((buyLimitLot != NULL && buyLimitGapSize == NULL) ||
      (buyLimitLot == NULL && buyLimitGapSize != NULL) ||
      (buyLimitLot == NULL && buyLimitGapSize == NULL && buyLimitTP != NULL)) {
    Utility.AlertAndExit("buyLimitLot and buyLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyLimitMaxPrice != NULL && buyLimitMinPrice != NULL &&
      buyLimitMaxPrice < buyLimitMinPrice) {
    Utility.AlertAndExit(
        "buyLimitMaxPrice must be greater than buyLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyLimitLot && buyLimitGapSize && BuyLimitLot != buyLimitLot &&
      BuyLimitGapSize != buyLimitGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_BUY_LIMIT, buyLimitLot, buyLimitGapSize, buyLimitTP,
          buyLimitMaxPrice, buyLimitMinPrice, fillInBuyLimitLots) == false) {
    return INIT_FAILED;
  }

  if ((sellLimitLot != NULL && sellLimitGapSize == NULL) ||
      (sellLimitLot == NULL && sellLimitGapSize != NULL) ||
      (sellLimitLot == NULL && sellLimitGapSize == NULL &&
       sellLimitTP != NULL)) {
    Utility.AlertAndExit("sellLimitLot and sellLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellLimitMaxPrice != NULL && sellLimitMinPrice != NULL &&
      sellLimitMaxPrice < sellLimitMinPrice) {
    Utility.AlertAndExit(
        "sellLimitMaxPrice must be greater than sellLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellLimitLot && sellLimitGapSize && SellLimitLot != sellLimitLot &&
      SellLimitGapSize != sellLimitGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_SELL_LIMIT, sellLimitLot, sellLimitGapSize, sellLimitTP,
          sellLimitMaxPrice, sellLimitMinPrice, fillInSellLimitLots) == false) {
    return INIT_FAILED;
  }

  if ((sellStopLot != NULL && sellStopGapSize == NULL) ||
      (sellStopLot == NULL && sellStopGapSize != NULL) ||
      (sellStopLot == NULL && sellStopGapSize == NULL && sellStopTP != NULL)) {
    Utility.AlertAndExit("sellStopLot and sellStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellStopMaxPrice != NULL && sellStopMinPrice != NULL &&
      sellStopMaxPrice < sellStopMinPrice) {
    Utility.AlertAndExit(
        "sellStopMaxPrice must be greater than sellStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellStopLot && sellStopGapSize && SellStopLot != sellStopLot &&
      SellStopGapSize != sellStopGapSize &&
      Utility.ConfirmInputMessageBox(
          ORDER_TYPE_SELL_STOP, sellStopLot, sellStopGapSize, sellStopTP,
          sellStopMaxPrice, sellStopMinPrice, fillInSellStopLots) == false) {
    return INIT_FAILED;
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

  if ((limitOrders < totalOrders) &&
      MessageBox("Limit Orders: " + IntegerToString(limitOrders) +
                     "\nTotal Orders: " + IntegerToString(totalOrders) +
                     "\n\nAre you sure you want to continue?",
                 "Confirm", MB_OKCANCEL | MB_ICONQUESTION) != IDOK) {
    Utility.AlertAndExit(
        "limitOrders must be greater than the sum of all orders.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  double volumeLimit = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);

  double totalBuyStopLots =
      Utility.NormalizeDoubleTwoDigits(buyStopArrayPrices.Total() * buyStopLot);
  double totalBuyLimitLots = Utility.NormalizeDoubleTwoDigits(
      buyLimitArrayPrices.Total() * buyLimitLot);
  double totalSellLimitLots = Utility.NormalizeDoubleTwoDigits(
      sellLimitArrayPrices.Total() * sellLimitLot);
  double totalSellStopLots = Utility.NormalizeDoubleTwoDigits(
      sellStopArrayPrices.Total() * sellStopLot);
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
                     "\n\nAre you sure you want to continue?",
                 "Confirm", MB_OKCANCEL | MB_ICONQUESTION) != IDOK) {
    Utility.AlertAndExit("Totals lots must be less then volume limit.");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (drawInputSummary) {
    DrawSummary();
  } else {
    ClearSummary();
  }

  // Utility.CloseAllOrders();

  CloseOrderOutSideArray();

  CheckAndPlaceOrders();

  return (INIT_SUCCEEDED);
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

void GetArrayPrices() {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  Print("GetArrayPrices ask: ", ask, ", bid: ", bid);

  if (buyStopGapSize) {

    double startPrice = ask + buyStopGapSize;
    double endPrice = ask + priceRange;

    // TODO digits should be digit of gap size
    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), buyStopGapSize,
                          buyStopArrayPrices, buyStopMinPrice, buyStopMaxPrice);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, " = ", buyStopArrayPrices[i]);
    }
  }

  if (buyLimitGapSize) {

    double startPrice = bid - priceRange;
    double endPrice = bid - buyLimitGapSize;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), buyLimitGapSize,
                          buyLimitArrayPrices, buyLimitMinPrice,
                          buyLimitMaxPrice);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, " = ", buyLimitArrayPrices[i]);
    }
  }

  if (sellLimitGapSize) {

    double startPrice = ask + sellLimitGapSize;
    double endPrice = ask + priceRange;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), sellLimitGapSize,
                          sellLimitArrayPrices, sellLimitMinPrice,
                          sellLimitMaxPrice);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    }
  }

  if (sellStopGapSize) {

    double startPrice = bid - priceRange;
    double endPrice = bid - sellStopGapSize;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), sellStopGapSize,
                          sellStopArrayPrices, sellStopMinPrice,
                          sellStopMaxPrice);

    for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
      Print("sellStopArrayPrices: ", i, " = ", sellStopArrayPrices[i]);
    }
  }
}

void CheckAndPlaceOrders() {
  Print("CheckAndPlaceOrders");
  bool orderPriceInvalid = false;
  int errors = 0;

  do {

    if (buyStopArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(buyStopArrayPrices, buyStopGapSize, Comment,
                              ORDER_TYPE_BUY_STOP, buyStopLot,
                              fillInBuyStopLots, orderPriceInvalid);
    }

    if (buyLimitArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitGapSize, Comment,
                              ORDER_TYPE_BUY_LIMIT, buyLimitLot,
                              fillInBuyLimitLots, orderPriceInvalid);
    }

    if (sellLimitArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitGapSize, Comment,
                              ORDER_TYPE_SELL_LIMIT, sellLimitLot,
                              fillInSellLimitLots, orderPriceInvalid);
    }

    if (sellStopArrayPrices.Total() > 0) {

      PlaceMissingDealsByType(sellStopArrayPrices, sellStopGapSize, Comment,
                              ORDER_TYPE_SELL_STOP, sellStopLot,
                              fillInSellStopLots, orderPriceInvalid);
    }

  } while (orderPriceInvalid && errors < 3);

  // if (errors >= 3) {
  //   Utility.AlertAndExit("Place order error.");
  // }
}

void FilterOpenOrdersAndPositionsByType(CArrayDouble &arrayPrices,
                                        double gridGapSize, string comment,
                                        const ENUM_ORDER_TYPE type, double lot,
                                        bool filInLots,
                                        CArrayDouble &missingDeals,
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
      missingDealsLots.Add(lot - totalLots);
    }
  }
}

void PlaceMissingDealsByType(CArrayDouble &arrayPrices, double gridGapSize,
                             string comment, const ENUM_ORDER_TYPE type,
                             double lot, bool filInLots,
                             bool &orderPriceInvalid) {
  CArrayDouble missingDeals;
  CArrayDouble missingDealsLots;

  switch (type) {
  case ORDER_TYPE_BUY_STOP:
    FilterOpenOrdersAndPositionsByType(arrayPrices, gridGapSize, comment, type,
                                       buyStopLot, fillInBuyStopLots,
                                       missingDeals, missingDealsLots);
    break;
  case ORDER_TYPE_BUY_LIMIT:
    FilterOpenOrdersAndPositionsByType(arrayPrices, gridGapSize, comment, type,
                                       buyLimitLot, fillInBuyLimitLots,
                                       missingDeals, missingDealsLots);
    break;
  case ORDER_TYPE_SELL_LIMIT:
    FilterOpenOrdersAndPositionsByType(arrayPrices, gridGapSize, comment, type,
                                       sellLimitLot, fillInSellLimitLots,
                                       missingDeals, missingDealsLots);
    break;
  case ORDER_TYPE_SELL_STOP:
    FilterOpenOrdersAndPositionsByType(arrayPrices, gridGapSize, comment, type,
                                       sellStopLot, fillInSellStopLots,
                                       missingDeals, missingDealsLots);
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
          missingDeals[i], missingDealsLots[i],
          buyStopTP != NULL ? missingDeals[i] + buyStopTP
                            : missingDeals[i] + buyStopGapSize,
          missingDealsLots[i] == BuyStopLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_BUY_LIMIT:
      Utility.PlaceBuyLimitOrder(
          missingDeals[i], missingDealsLots[i],
          buyLimitTP != NULL ? missingDeals[i] + buyLimitTP
                             : missingDeals[i] + buyLimitGapSize,
          missingDealsLots[i] == BuyLimitLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_SELL_LIMIT:
      Utility.PlaceSellLimitOrder(
          missingDeals[i], missingDealsLots[i],
          sellLimitTP != NULL ? missingDeals[i] - sellLimitTP
                              : missingDeals[i] - sellLimitGapSize,
          missingDealsLots[i] == SellLimitLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;

    case ORDER_TYPE_SELL_STOP:
      Utility.PlaceSellStopOrder(
          missingDeals[i], missingDealsLots[i],
          sellStopTP != NULL ? missingDeals[i] - sellStopTP
                             : missingDeals[i] - sellStopGapSize,
          missingDealsLots[i] == SellStopLot ? Comment + "|F" : Comment + "|T",
          orderPriceInvalid);
      break;
    }
  }
}

void DraySummaryObject(string objectName, string text, int yDistance,
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
              ", TP:" + DoubleToString(buyStopTP, 2));
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
              ", TP:" + DoubleToString(buyLimitTP, 2));
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
              ", TP:" + DoubleToString(sellLimitTP, 2));
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
              ", TP:" + DoubleToString(sellStopTP, 2));
    objectNames.Add("Sell_Stop_Summary_1");
    colors.Add(SellStopColor);

    texts.Add(",Max:" + DoubleToString(sellStopMaxPrice, 2) +
              ", Min:" + DoubleToString(sellStopMinPrice, 2) +
              ", Fill In:" + (fillInSellStopLots ? "True" : "False"));
    objectNames.Add("Sell_Stop_Summary_2");
    colors.Add(SellStopColor);
  }

  switch (corner) {
  case CORNER_LEFT_UPPER:
  case CORNER_RIGHT_UPPER:
    for (int i = 0; i < objectNames.Total(); i++) {
      DraySummaryObject(objectNames[i], texts[i], (i * 25) + 25, anchor,
                        colors[i]);
    }
    break;
  case CORNER_LEFT_LOWER:
  case CORNER_RIGHT_LOWER:
    for (int i = 0, yDistance = objectNames.Total() * 25;
         i < objectNames.Total(); i++, yDistance -= 25) {
      DraySummaryObject(objectNames[i], texts[i], yDistance, anchor, colors[i]);
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

  ChartRedraw();
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

  // if (buyStopArrayPrices.Total() > 0) {
  //   Print("buyStop ask: ", ask,
  //         ", last price: ", buyStopArrayPrices[buyStopArrayPrices.Total() -
  //         1],
  //         ", diff: ",
  //         Utility.NormalizeDoubleTwoDigits(
  //             buyStopArrayPrices[buyStopArrayPrices.Total() - 1] - ask),
  //         ", gap: ", buyStopGapSize, ", buyStop maxPrice: ", buyStopMaxPrice,
  //         ", buyStop minPrice: ", buyStopMinPrice);
  // }

  if (buyStopArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(
          buyStopArrayPrices[buyStopArrayPrices.Total() - 1] - ask) >
          buyStopGapSize) {

    double startPrice = ask + buyStopGapSize;
    double endPrice = ask + priceRange;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), buyStopGapSize,
                          buyStopArrayPrices, buyStopMinPrice, buyStopMaxPrice);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, " = ", buyStopArrayPrices[i]);
    }

    // Print("startPrice: ", Utility.NormalizeDoubleTwoDigits(startPrice),
    //       ", endPrice: ", Utility.NormalizeDoubleTwoDigits(endPrice));

    Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                               buyStopLot, ORDER_TYPE_BUY_STOP);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(buyStopArrayPrices, buyStopGapSize, Comment,
                            ORDER_TYPE_BUY_STOP, buyStopLot, fillInBuyStopLots,
                            orderPriceInvalid);
  }

  // if (buyLimitArrayPrices.Total() > 0) {
  //   Print("buyLimit bid: ", bid, ", first price: ", buyLimitArrayPrices[0],
  //         ", diff: ",
  //         Utility.NormalizeDoubleTwoDigits(bid - buyLimitArrayPrices[0]),
  //         ", gap: ", buyLimitGapSize, ", buyLimit maxPrice: ",
  //         buyLimitMaxPrice,
  //         ", buyLimit minPrice: ", buyLimitMinPrice);
  // }

  if (buyLimitArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(bid - buyLimitArrayPrices[0]) >
          buyLimitGapSize) {

    double startPrice = bid - priceRange;
    double endPrice = bid - buyLimitGapSize;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), buyLimitGapSize,
                          buyLimitArrayPrices, buyLimitMinPrice,
                          buyLimitMaxPrice);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, " = ", buyLimitArrayPrices[i]);
    }

    // Print("startPrice: ", Utility.NormalizeDoubleTwoDigits(startPrice),
    //       ", endPrice: ", Utility.NormalizeDoubleTwoDigits(endPrice));

    Utility.CloseOrderOutsideArrayPricesByType(
        buyLimitArrayPrices, Comment, buyLimitLot, ORDER_TYPE_BUY_LIMIT);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitGapSize, Comment,
                            ORDER_TYPE_BUY_LIMIT, buyLimitLot,
                            fillInBuyLimitLots, orderPriceInvalid);
  }

  // if (sellLimitArrayPrices.Total() > 0) {
  //   Print("sellLimit ask: ", ask, ", last price: ",
  //         sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1], ", diff: ",
  //         Utility.NormalizeDoubleTwoDigits(
  //             sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask),
  //         ", gap: ", sellLimitGapSize,
  //         ", sellLimit maxPrice: ", sellLimitMaxPrice,
  //         ", sellLimit minPrice: ", sellLimitMinPrice);
  // }

  if (sellLimitArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask) >
          sellLimitGapSize) {

    double startPrice = ask + sellLimitGapSize;
    double endPrice = ask + priceRange;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), sellLimitGapSize,
                          sellLimitArrayPrices, sellLimitMinPrice,
                          sellLimitMaxPrice);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    }

    // Print("startPrice: ", Utility.NormalizeDoubleTwoDigits(startPrice),
    //       ", endPrice: ", Utility.NormalizeDoubleTwoDigits(endPrice));

    Utility.CloseOrderOutsideArrayPricesByType(
        sellLimitArrayPrices, Comment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitGapSize, Comment,
                            ORDER_TYPE_SELL_LIMIT, sellLimitLot,
                            fillInSellLimitLots, orderPriceInvalid);
  }

  // if (sellStopArrayPrices.Total() > 0) {
  //   Print("sellStop bid: ", bid, ", first price: ", sellStopArrayPrices[0],
  //         ", diff: ",
  //         Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]),
  //         ", gap: ", sellStopGapSize, ", sellStop maxPrice: ",
  //         sellStopMaxPrice,
  //         ", sellStop minPrice: ", sellStopMinPrice);
  // }

  if (sellStopArrayPrices.Total() > 0 &&
      Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]) >
          sellStopGapSize) {

    double startPrice = bid - priceRange;
    double endPrice = bid - sellStopGapSize;

    Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                          NormalizeDouble(endPrice, 1), sellStopGapSize,
                          sellStopArrayPrices, sellStopMinPrice,
                          sellStopMaxPrice);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    }

    // Print("startPrice: ", Utility.NormalizeDoubleTwoDigits(startPrice),
    //       ", endPrice: ", Utility.NormalizeDoubleTwoDigits(endPrice));

    Utility.CloseOrderOutsideArrayPricesByType(
        sellStopArrayPrices, Comment, sellStopLot, ORDER_TYPE_SELL_STOP);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(sellStopArrayPrices, sellStopGapSize, Comment,
                            ORDER_TYPE_SELL_STOP, sellStopLot,
                            fillInSellStopLots, orderPriceInvalid);
  }
}

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {
  ENUM_TRADE_TRANSACTION_TYPE type = trans.type;

  // TODO: draw summary OnTradeTransaction

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
  }
}

void Order66() {
  GetArrayPrices();
  CloseOrderOutSideArray();
  CheckAndPlaceOrders();
}

//+------------------------------------------------------------------+