#include <Trade\OrderInfo.mqh>

COrderInfo OrderInfo;

void OnStart() {
  Print("Ticket ", OrderInfo.Ticket());
  Print("PriceOpen ", OrderInfo.PriceOpen());
}
