//+------------------------------------------------------------------+
//|                                                test_script_2.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <Trade/DealInfo.mqh>
CDealInfo cDealInfo;

#include <Trade/OrderInfo.mqh>
COrderInfo cOrderInfo;

#include <Trade\HistoryOrderInfo.mqh>
CHistoryOrderInfo cObject;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  // HistorySelect(0, TimeCurrent());
  // int deals = HistoryDealsTotal();
  // Print("deals: ", deals);

  // ulong deal_ticket = HistoryDealGetTicket(129);
  // Print("deal_ticket: ", deal_ticket);

  // double volume = HistoryDealGetDouble(deal_ticket, DEAL_VOLUME);
  // Print("volume: ", volume);

  // ulong order_ticket = HistoryDealGetInteger(deal_ticket, DEAL_ORDER);
  // Print("order_ticket: ", order_ticket);

  // long deal_type = HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
  // Print("deal_type: ", deal_type);

  // string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
  // Print("symbol: ", symbol);

  // //   cDealInfo.SelectByIndex(1);
  // //   Print("cDealInfo.Symbol()", cDealInfo.Symbol());

  // if (cOrderInfo.Select(order_ticket)) {
  //   Print("OrderType: ", cOrderInfo.OrderType());
  //   Print("Symbol: ", cOrderInfo.Symbol());

  //   double price;
  //   cOrderInfo.InfoDouble(ORDER_PRICE_OPEN, price);
  //   Print("price: ", price);
  // }

  // if (HistoryOrderSelect(order_ticket)) {
  //   double orderPrice;
  //   HistoryOrderGetDouble(order_ticket, ORDER_PRICE_OPEN, orderPrice);
  //   Print("orderPrice: ", orderPrice);
  // }

  // int iLL = iLowest(NULL, PERIOD_MN1, MODE_LOW);
  // Print("iLL: ", iLL);

  // int iHH = iHighest(NULL, PERIOD_MN1, MODE_HIGH);
  // Print("iHH: ", iHH);

  // Print("Current bar for _Symbol H1: ", iTime(_Symbol, PERIOD_MN1, 0), ", ",
  //       iOpen(_Symbol, PERIOD_MN1, 0), ", ", iHigh(_Symbol, PERIOD_MN1, 0),
  //       ", ", iLow(_Symbol, PERIOD_MN1, 0), ", ",
  //       iClose(_Symbol, PERIOD_MN1, 0), ", ", iVolume(_Symbol, PERIOD_MN1,
  //       0));

  double all_time_high, all_time_low;
  GetAllTimeHighLow(all_time_high, all_time_low);
  Print("All-Time High: ", all_time_high);
  Print("All-Time Low: ", all_time_low);
}

void GetAllTimeHighLow(double &all_time_high, double &all_time_low) {
  all_time_high = -DBL_MAX; // Initialize with the lowest possible value
  all_time_low = DBL_MAX;   // Initialize with the highest possible value

  // Get the total number of bars available
  long total_bars = SeriesInfoInteger(_Symbol, PERIOD_MN1, SERIES_BARS_COUNT);
  if (total_bars <= 0) {
    Print("No data available for the symbol: ", _Symbol,
          " Error: ", GetLastError());
    return;
  }

  // Loop through all bars to find the high and low
  for (long i = 0; i < total_bars; i++) {
    double high = iHigh(_Symbol, PERIOD_MN1, i);
    double low = iLow(_Symbol, PERIOD_MN1, i);

    if (high > all_time_high)
      all_time_high = high;
    if (low < all_time_low)
      all_time_low = low;
  }
}