
void OnStart() {

  // int isOpen = IsOpen();
  // Print("isOpen: ", isOpen);

  Print("_Digits: ", _Digits);
  Print("_Point: ", _Point);
}

int IsOpen() {
  Print("TerminalInfoInteger(TERMINAL_TRADE_ALLOWED): ",
        TerminalInfoInteger(TERMINAL_TRADE_ALLOWED));
  Print("MQLInfoInteger(MQL_TRADE_ALLOWED): ",
        MQLInfoInteger(MQL_TRADE_ALLOWED));
  if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) ||
      !MQLInfoInteger(MQL_TRADE_ALLOWED))
    return (0);

  return 1;
}