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

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

//+------------------------------------------------------------------+
//| Input                                                            |
//+------------------------------------------------------------------+
input double PriceRange = 5;
input int MaxOrders = NULL;

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

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double priceRange = NULL;
int maxOrders = NULL;

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

input bool useNotification = false;

int limitOrders;
CArrayDouble buyStopArrayPrices;
CArrayDouble buyLimitArrayPrices;
CArrayDouble sellLimitArrayPrices;
CArrayDouble sellStopArrayPrices;
string Comment = "dynamic_grid";
// comment pattern: <ea_name>|<IsFillIn>

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (PriceRange == priceRange && MaxOrders == maxOrders &&
      BuyStopLot == buyStopLot && BuyStopGapSize == buyStopGapSize &&
      BuyStopTP == buyStopTP && BuyStopMaxPrice == buyStopMaxPrice &&
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
      FillInSellStopLots == fillInSellStopLots) {
    Print("Parameters are already set.");
    return (INIT_SUCCEEDED);
  }

  priceRange = PriceRange;
  maxOrders = MaxOrders;

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
      (buyStopLot == NULL && buyStopGapSize != NULL) ||
      (buyStopLot == NULL && buyStopGapSize == NULL && buyStopTP != NULL)) {
    Utility.AlertAndExit("buyStopLot and buyStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((buyStopMaxPrice != NULL && buyStopMinPrice == NULL) ||
      (buyStopMaxPrice == NULL && buyStopMinPrice != NULL)) {
    Utility.AlertAndExit("buyStopMaxPrice and buyStopMinPrice is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyStopMaxPrice < buyStopMinPrice) {
    Utility.AlertAndExit(
        "buyStopMaxPrice must be greater than buyStopMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((buyLimitLot != NULL && buyLimitGapSize == NULL) ||
      (buyLimitLot == NULL && buyLimitGapSize != NULL) ||
      (buyLimitLot == NULL && buyLimitGapSize == NULL && buyLimitTP != NULL)) {
    Utility.AlertAndExit("buyLimitLot and buyLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((buyLimitMaxPrice != NULL && buyLimitMinPrice == NULL) ||
      (buyLimitMaxPrice == NULL && buyLimitMinPrice != NULL)) {
    Utility.AlertAndExit("buyLimitMaxPrice and buyLimitMinPrice is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (buyLimitMaxPrice < buyLimitMinPrice) {
    Utility.AlertAndExit(
        "buyLimitMaxPrice must be greater than buyLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((sellLimitLot != NULL && sellLimitGapSize == NULL) ||
      (sellLimitLot == NULL && sellLimitGapSize != NULL) ||
      (sellLimitLot == NULL && sellLimitGapSize == NULL &&
       sellLimitTP != NULL)) {
    Utility.AlertAndExit("sellLimitLot and sellLimitGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((sellLimitMaxPrice != NULL && sellLimitMinPrice == NULL) ||
      (sellLimitMaxPrice == NULL && sellLimitMinPrice != NULL)) {
    Utility.AlertAndExit(
        "sellLimitMaxPrice and sellLimitMinPrice is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellLimitMaxPrice < sellLimitMinPrice) {
    Utility.AlertAndExit(
        "sellLimitMaxPrice must be greater than sellLimitMinPrice!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((sellStopLot != NULL && sellStopGapSize == NULL) ||
      (sellStopLot == NULL && sellStopGapSize != NULL) ||
      (sellStopLot == NULL && sellStopGapSize == NULL && sellStopTP != NULL)) {
    Utility.AlertAndExit("sellStopLot and sellStopGapSize is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if ((sellStopMaxPrice != NULL && sellStopMinPrice == NULL) ||
      (sellStopMaxPrice == NULL && sellStopMinPrice != NULL)) {
    Utility.AlertAndExit("sellStopMaxPrice and sellStopMinPrice is required!");
    return (INIT_PARAMETERS_INCORRECT);
  }

  if (sellStopMaxPrice < sellStopMinPrice) {
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

  Print("limitOrders: ", limitOrders);

  GetArrayPrices();

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

    double startPrice = 0;
    double endPrice = 0;

    Print("buyStopMaxPrice: ", buyStopMaxPrice,
          ", buyStopMinPrice: ", buyStopMinPrice);

    if (buyStopMaxPrice && buyStopMinPrice) {

      if (Utility.IsInRange(ask, buyStopMinPrice, buyStopMaxPrice)) {

        startPrice = Utility.Clamp(ask + buyStopGapSize, buyStopMinPrice,
                                   buyStopMaxPrice);
        endPrice =
            Utility.Clamp(ask + priceRange, buyStopMinPrice, buyStopMaxPrice);
      }

    } else {
      startPrice = ask + buyStopGapSize;
      endPrice = ask + priceRange;
    }

    Print("buyStopArrayPrices startPrice: ", startPrice,
          ", endPrice: ", endPrice);

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), buyStopGapSize,
                            buyStopArrayPrices);

    // for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
    //   Print("buyStopArrayPrices: ", i, " = ", buyStopArrayPrices[i]);
    // }
  }

  if (buyLimitGapSize) {

    double startPrice = 0;
    double endPrice = 0;

    if (buyLimitMaxPrice && buyLimitMinPrice) {

      if (Utility.IsInRange(bid, buyLimitMinPrice, buyLimitMaxPrice)) {

        startPrice =
            Utility.Clamp(bid - priceRange, buyLimitMinPrice, buyLimitMaxPrice);
        endPrice = Utility.Clamp(bid - buyLimitGapSize, buyLimitMinPrice,
                                 buyLimitMaxPrice);
      }

    } else {
      startPrice = bid - priceRange;
      endPrice = bid - buyLimitGapSize;
    }

    Print("buyLimitArrayPrices startPrice: ", startPrice,
          ", endPrice: ", endPrice);

    if (startPrice && endPrice)
      Utility.GetArrayPrice(startPrice, endPrice, buyLimitGapSize,
                            buyLimitArrayPrices);

    // for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
    //   Print("buyLimitArrayPrices: ", i, " = ", buyLimitArrayPrices[i]);
    // }
  }

  if (sellLimitGapSize) {

    double startPrice = 0;
    double endPrice = 0;

    if (sellLimitMaxPrice && sellLimitMinPrice) {

      if (Utility.IsInRange(ask, sellLimitMinPrice, sellLimitMaxPrice)) {

        startPrice = Utility.Clamp(ask + sellLimitGapSize, sellLimitMinPrice,
                                   sellLimitMaxPrice);
        endPrice = Utility.Clamp(ask + priceRange, sellLimitMinPrice,
                                 sellLimitMaxPrice);
      }
    } else {
      startPrice = ask + sellLimitGapSize;
      endPrice = ask + priceRange;
    }

    Print("sellLimitArrayPrices startPrice: ", startPrice,
          ", endPrice: ", endPrice);

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), sellLimitGapSize,
                            sellLimitArrayPrices);

    // for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
    //   Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    // }
  }

  if (sellStopGapSize) {

    double startPrice = 0;
    double endPrice = 0;

    if (sellStopMaxPrice && sellStopMinPrice) {

      if (Utility.IsInRange(bid, sellStopMinPrice, sellStopMaxPrice)) {

        startPrice =
            Utility.Clamp(bid - priceRange, sellStopMinPrice, sellStopMaxPrice);
        endPrice = Utility.Clamp(bid - sellStopGapSize, sellStopMinPrice,
                                 sellStopMaxPrice);
      }
    } else {
      startPrice = bid - priceRange;
      endPrice = bid - sellStopGapSize;
    }

    Print("sellStopArrayPrices startPrice: ", startPrice,
          ", endPrice: ", endPrice);

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), sellStopGapSize,
                            sellStopArrayPrices);

    // for (int i = 0; i < sellStopArrayPrices.Total(); i++) {
    //   Print("sellStopArrayPrices: ", i, " = ", sellStopArrayPrices[i]);
    // }
  }
}

/**
 * Check orders and positions
 */
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
      double orderPrice = OrderGetDouble(ORDER_PRICE_OPEN);
      double orderVolume = OrderGetDouble(ORDER_VOLUME_CURRENT);
      string symbol = OrderGetString(ORDER_SYMBOL);
      string orderComment = OrderGetString(ORDER_COMMENT);
      long orderType = OrderGetInteger(ORDER_TYPE);

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

      else if (symbol != _Symbol || orderType != type) {
        continue;
      }
      Utility.getExistDealsWithLots(arrayPrices, gridGapSize, orderPrice,
                                    orderVolume, existOrders, existOrdersLots);
    }
  }

  CArrayDouble existPositions;
  CArrayDouble existPositionsLots;

  for (int i = 0; i < PositionsTotal(); i++) {
    ulong positionTicket = PositionGetTicket(i);
    if (PositionSelectByTicket(positionTicket)) {
      double positionPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double positionVolume = PositionGetDouble(POSITION_VOLUME);
      string symbol = PositionGetString(POSITION_SYMBOL);
      string positionComment = PositionGetString(POSITION_COMMENT);
      long positionType = PositionGetInteger(POSITION_TYPE);

      // Print("positionPrice: ", positionPrice,
      //       ", positionVolume: ", positionVolume,
      //       ", positionComment: ", positionComment,
      //       ", positionType: ", positionType,
      //       ", positionTicket: ", positionTicket);

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

      else if (symbol != _Symbol) {
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
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick() {
  double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  if (buyStopLot && buyStopGapSize &&
      Utility.NormalizeDoubleTwoDigits(
          buyStopArrayPrices[buyStopArrayPrices.Total() - 1] - ask) >
          buyStopGapSize) {

    Print("buyStop ask: ", ask,
          ", last price: ", buyStopArrayPrices[buyStopArrayPrices.Total() - 1],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(
              buyStopArrayPrices[buyStopArrayPrices.Total() - 1] - ask),
          ", gap: ", buyStopGapSize, ", buyStop maxPrice: ", buyStopMaxPrice,
          ", buyStop minPrice: ", buyStopMinPrice);

    double startPrice = 0;
    double endPrice = 0;

    if (buyStopMaxPrice && buyStopMinPrice) {

      if (Utility.IsInRange(ask, buyStopMinPrice, buyStopMaxPrice)) {

        startPrice = Utility.Clamp(ask + buyStopGapSize, buyStopMinPrice,
                                   buyStopMaxPrice);
        endPrice =
            Utility.Clamp(ask + priceRange, buyStopMinPrice, buyStopMaxPrice);
      }

    } else {
      startPrice = ask + buyStopGapSize;
      endPrice = ask + priceRange;
    }

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), buyStopGapSize,
                            buyStopArrayPrices);

    for (int i = 0; i < buyStopArrayPrices.Total(); i++) {
      Print("buyStopArrayPrices: ", i, " = ", buyStopArrayPrices[i]);
    }

    Print("startPrice: ", startPrice, ", endPrice: ", endPrice);

    Utility.CloseOrderOutsideArrayPricesByType(buyStopArrayPrices, Comment,
                                               buyStopLot, ORDER_TYPE_BUY_STOP);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(buyStopArrayPrices, buyStopGapSize, Comment,
                            ORDER_TYPE_BUY_STOP, buyStopLot, fillInBuyStopLots,
                            orderPriceInvalid);
  }

  if (buyLimitLot && buyLimitGapSize &&
      Utility.NormalizeDoubleTwoDigits(bid - buyLimitArrayPrices[0]) >
          buyLimitGapSize) {

    Print("buyLimit bid: ", bid, ", first price: ", buyLimitArrayPrices[0],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(bid - buyLimitArrayPrices[0]),
          ", gap: ", buyLimitGapSize, ", buyLimit maxPrice: ", buyLimitMaxPrice,
          ", buyLimit minPrice: ", buyLimitMinPrice);

    double startPrice = 0;
    double endPrice = 0;

    if (buyLimitMaxPrice && buyLimitMinPrice) {

      if (Utility.IsInRange(bid, buyLimitMinPrice, buyLimitMaxPrice)) {

        startPrice =
            Utility.Clamp(bid - priceRange, buyLimitMinPrice, buyLimitMaxPrice);
        endPrice = Utility.Clamp(bid - buyLimitGapSize, buyLimitMinPrice,
                                 buyLimitMaxPrice);
      }

    } else {
      startPrice = bid - priceRange;
      endPrice = bid - buyLimitGapSize;
    }

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), buyLimitGapSize,
                            buyLimitArrayPrices);

    for (int i = 0; i < buyLimitArrayPrices.Total(); i++) {
      Print("buyLimitArrayPrices: ", i, " = ", buyLimitArrayPrices[i]);
    }

    Print("startPrice: ", startPrice, ", endPrice: ", endPrice);

    Utility.CloseOrderOutsideArrayPricesByType(
        buyLimitArrayPrices, Comment, buyLimitLot, ORDER_TYPE_BUY_LIMIT);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(buyLimitArrayPrices, buyLimitGapSize, Comment,
                            ORDER_TYPE_BUY_LIMIT, buyLimitLot,
                            fillInBuyLimitLots, orderPriceInvalid);
  }

  if (sellLimitLot && sellLimitGapSize &&
      Utility.NormalizeDoubleTwoDigits(
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask) >
          sellLimitGapSize) {

    Print("sellLimit ask: ", ask, ", last price: ",
          sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1], ", diff: ",
          Utility.NormalizeDoubleTwoDigits(
              sellLimitArrayPrices[sellLimitArrayPrices.Total() - 1] - ask),
          ", gap: ", sellLimitGapSize,
          ", sellLimit maxPrice: ", sellLimitMaxPrice,
          ", sellLimit minPrice: ", sellLimitMinPrice);

    double startPrice = 0;
    double endPrice = 0;

    if (sellLimitMaxPrice && sellLimitMinPrice) {

      if (Utility.IsInRange(ask, sellLimitMinPrice, sellLimitMaxPrice)) {

        startPrice = Utility.Clamp(ask + sellLimitGapSize, sellLimitMinPrice,
                                   sellLimitMaxPrice);
        endPrice = Utility.Clamp(ask + priceRange, sellLimitMinPrice,
                                 sellLimitMaxPrice);
      }

    } else {
      startPrice = ask + sellLimitGapSize;
      endPrice = ask + priceRange;
    }

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), sellLimitGapSize,
                            sellLimitArrayPrices);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    }

    Print("startPrice: ", startPrice, ", endPrice: ", endPrice);

    Utility.CloseOrderOutsideArrayPricesByType(
        sellLimitArrayPrices, Comment, sellLimitLot, ORDER_TYPE_SELL_LIMIT);

    bool orderPriceInvalid = false;
    PlaceMissingDealsByType(sellLimitArrayPrices, sellLimitGapSize, Comment,
                            ORDER_TYPE_SELL_LIMIT, sellLimitLot,
                            fillInSellLimitLots, orderPriceInvalid);
  }

  if (sellStopLot && sellStopGapSize &&
      Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]) >
          sellStopGapSize) {

    Print("sellStop bid: ", bid, ", first price: ", sellStopArrayPrices[0],
          ", diff: ",
          Utility.NormalizeDoubleTwoDigits(bid - sellStopArrayPrices[0]),
          ", gap: ", sellStopGapSize, ", sellStop maxPrice: ", sellStopMaxPrice,
          ", sellStop minPrice: ", sellStopMinPrice);

    double startPrice = 0;
    double endPrice = 0;

    if (sellStopMaxPrice && sellStopMinPrice) {

      if (Utility.IsInRange(bid, sellStopMinPrice, sellStopMaxPrice)) {

        startPrice =
            Utility.Clamp(bid - priceRange, sellStopMinPrice, sellStopMaxPrice);
        endPrice = Utility.Clamp(bid - sellStopGapSize, sellStopMinPrice,
                                 sellStopMaxPrice);
      }

    } else {
      startPrice = bid - priceRange;
      endPrice = bid - sellStopGapSize;
    }

    if (startPrice && endPrice)
      Utility.GetArrayPrice(NormalizeDouble(startPrice, 1),
                            NormalizeDouble(endPrice, 1), sellStopGapSize,
                            sellStopArrayPrices);

    for (int i = 0; i < sellLimitArrayPrices.Total(); i++) {
      Print("sellLimitArrayPrices: ", i, " = ", sellLimitArrayPrices[i]);
    }

    Print("startPrice: ", startPrice, ", endPrice: ", endPrice);

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