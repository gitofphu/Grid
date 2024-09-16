
void OnStart() {

  double profit;
  OrderCalcMargin(ORDER_TYPE_BUY, _Symbol, 1, 50, profit);
  Print("OrderCalcMargin: ", profit);

  OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1, 50, 40, profit);
  Print("OrderCalcProfit: ", profit);
}
