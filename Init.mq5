

// [ ] Get account info
// [ ] ACCOUNT_BALANCE
// [ ] ACCOUNT_EQUITY
// [ ] ACCOUNT_MARGIN
// [ ] ACCOUNT_MARGIN_FREE
// [ ] ACCOUNT_MARGIN_LEVEL
// [ ] ACCOUNT_MARGIN_SO_CALL
// [ ] ACCOUNT_MARGIN_SO_SO
// [ ] ACCOUNT_LEVERAGE
// [ ] ACCOUNT_LIMIT_ORDERS
// [ ] Calculate maximum drawdown
// [ ] Calcualte Pip value
// [ ] Define Min-Max price range
// [ ] Define Entry distant
// [ ] Calcualte maximun lot size
// [ ] Create array list all price in range
// [ ] Check if possible to place entry on every price in range
// [ ] Create function to place order on every price in range
// [ ] Create function to re-place order on tp price
// [ ] Create function to modify in case of cannot place all order in price
// range

int OnInit() {

  printf("ACCOUNT_CURRENCY_DIGITS= % d ",
         AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS));

  return (INIT_SUCCEEDED);
}
