//+------------------------------------------------------------------+
//|                                           test_lot_and_range.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <Trade/AccountInfo.mqh>
CAccountInfo AccountInfo;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+

double balance = cAccountInfo.Balance();
// double balance = 20000;
double basePrice = 70;
double priceGap = 0.1;
double lotPerGrid = 0.02;

void OnStart() {
  Print("OnStart");

  Print("balance: ", balance, ", basePrice: ", basePrice,
        ", priceGap: ", priceGap, ", lotPerGrid: ", lotPerGrid);

  UpTrendCheck();

  DownTrendCheck();
}

void DownTrendCheck() {
  // down trend
  double drawdown = 0;
  double lastPrice = basePrice;

  for (double price = basePrice; price >= 0;
       price = Utility.NormalizeDoubleTwoDigits(price - priceGap)) {

    if (price >= basePrice)
      continue;

    if (price == 0) {
      price = _Point;
    }

    // Print("basePrice: ", basePrice, ", lastPrice: ", lastPrice,
    //       " price: ", price);

    double profit = 0;

    if (lastPrice > price) {
      profit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_SELL,
                                             lotPerGrid, lastPrice, price);
    }
    lastPrice = price;

    double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
                                                lotPerGrid, basePrice, price);

    double marginRequire = cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_BUY,
                                                    lotPerGrid, basePrice);

    // Print("profit: ", profit, ", loss: ", loss,
    //       ", marginRequire: ", marginRequire);

    // Print("From ", price, " to ", lastPrice, " drawdown ",
    //       Utility.NormalizeDoubleTwoDigits(loss - marginRequire));

    balance = Utility.NormalizeDoubleTwoDigits(balance + profit);
    drawdown =
        Utility.NormalizeDoubleTwoDigits(drawdown + loss - marginRequire);

    double equity = Utility.NormalizeDoubleTwoDigits(balance + drawdown);
    // Print("balance: ", balance);
    // Print("equity: ", equity);
    // Print("drawdown: ", drawdown);
    // Print("-----------------------------------");

    if (balance + drawdown <= 0) {
      Print("Down Trand last price: " + price + ", balance: " + balance +
            ", equity: " + equity + ", drawdown: " + drawdown);
      break;
    }
  }
}

void UpTrendCheck() {
  // up trend
  double drawdown = 0;
  double lastPrice = basePrice;

  for (double price = basePrice; balance > 0;
       price = Utility.NormalizeDoubleTwoDigits(price + priceGap)) {

    if (price <= basePrice)
      continue;

    // Print("basePrice: ", basePrice, ", lastPrice: ", lastPrice,
    //       " price: ", price);

    double profit = 0;

    if (lastPrice < price) {
      profit = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_BUY,
                                             lotPerGrid, lastPrice, price);
    }
    lastPrice = price;

    double loss = cAccountInfo.OrderProfitCheck(_Symbol, ORDER_TYPE_SELL,
                                                lotPerGrid, basePrice, price);

    double marginRequire = cAccountInfo.MarginCheck(_Symbol, ORDER_TYPE_SELL,
                                                    lotPerGrid, basePrice);

    // Print("profit: ", profit, ", loss: ", loss,
    //       ", marginRequire: ", marginRequire);

    balance = Utility.NormalizeDoubleTwoDigits(balance + profit);
    drawdown =
        Utility.NormalizeDoubleTwoDigits(drawdown + loss - marginRequire);

    double equity = Utility.NormalizeDoubleTwoDigits(balance + drawdown);

    // Print("balance: ", balance);
    // Print("equity: ", equity);
    // Print("drawdown: ", drawdown);
    // Print("-----------------------------------");

    if (balance + drawdown <= 0) {
      Print("Up Trand last price: " + price + ", balance: " + balance +
            ", equity: " + equity + ", drawdown: " + drawdown);
      break;
    }
  }
}