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
//| input                                                            |
//+------------------------------------------------------------------+
input int lotRange = 10;
input double PriceRange = 10;
input bool TradeAnywaywithMinimunLot = false;
input double MinLot = NULL;

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

  //   if (SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN) !=
  //       SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT)) {
  //     Utility.AlertAndExit("EA Cannot be use with this product!");
  //     return (INIT_PARAMETERS_INCORRECT);
  //   }

  double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);

  double currentPrice =
      MathCeil(NormalizeDouble((bid / PriceRange) * PriceRange, 1));

  Print("currentPrice: ", currentPrice);
  Print("_Point: ", _Point);

  ArrayPrices.Add(currentPrice);

  for (int i = 1; i < lotRange; i++) {
    ArrayPrices.Add(currentPrice + (PriceRange * i));
  }

  for (int i = 1; i < lotRange; i++) {
    double price = currentPrice - (PriceRange * i);

    if (price < _Point) {
      ArrayPrices.Add(_Point);
      break;
    }

    ArrayPrices.Add(price);
  }

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", ArrayPrices[i]);
  }

  int ordersTotal = OrdersTotal();
  for (int i = 0; i < ordersTotal; i++) {
    ulong orderTicket = OrderGetTicket(i);
    if (OrderSelect(orderTicket)) {
      string symbol = OrderGetString(ORDER_SYMBOL);
      Print("symbol: ", symbol);
      string comment = OrderGetString(ORDER_COMMENT);
      Print("comment: ", comment);
    }
  }

  Utility.AlertAndExit("Test ended.");

  return (INIT_SUCCEEDED);
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