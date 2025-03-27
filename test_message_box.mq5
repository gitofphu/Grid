//+------------------------------------------------------------------+
//|                                             test_message_box.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() {

  if (!BuyStopMessageBox()) {
    Print("Buy Stop message box closed.");
    return INIT_FAILED; // Prevent EA from running
  }

  if (!SellStopMessageBox()) {
    Print("Sell Stop message box closed.");
    return INIT_FAILED; // Prevent EA from running
  }

  if (!BuyLimitMessageBox()) {
    Print("Buy Limit message box closed.");
    return INIT_FAILED; // Prevent EA from running
  }

  if (!SellLimitMessageBox()) {
    Print("Sell Limit message box closed.");
    return INIT_FAILED; // Prevent EA from running
  }

  Print("Continuing EA.");
  return INIT_SUCCEEDED; // Continue EA execution
}

bool BuyStopMessageBox() {
  string message = "Lot: 0.01\nGap: 10\nTP: 20\nMax: 60\nMin: 40";

  int result =
      MessageBox(message, "Confirm Buy Stop", MB_OKCANCEL | MB_ICONQUESTION);

  Print("Result: ", result);

  if (result == IDCANCEL) {
    Print("User closed the message box.");
    return false; // Prevent EA from running
  } else if (result == IDNO) {
    Print("User clicked No.");
    return false; // Prevent EA from running
  } else {
    Print("User clicked Yes.");
    return true; // Continue EA execution
  }
}

bool SellStopMessageBox() {
  string message = "Lot: 0.01\nGap: 10\nTP: 20\nMax: 60\nMin: 40";

  int result =
      MessageBox(message, "Confirm Sell Stop", MB_OKCANCEL | MB_ICONQUESTION);

  Print("Result: ", result);

  if (result == IDCANCEL) {
    Print("User closed the message box.");
    return false; // Prevent EA from running
  } else if (result == IDNO) {
    Print("User clicked No.");
    return false; // Prevent EA from running
  } else {
    Print("User clicked Yes.");
    return true; // Continue EA execution
  }
}

bool BuyLimitMessageBox() {
  string message = "Lot: 0.01\nGap: 10\nTP: 20\nMax: 60\nMin: 40";

  int result =
      MessageBox(message, "Confirm Buy Limit", MB_OKCANCEL | MB_ICONQUESTION);

  if (result == IDCANCEL) {
    return false; // Prevent EA from running
  } else if (result == IDNO) {
    return false; // Prevent EA from running
  } else {
    return true; // Continue EA execution
  }
}

bool SellLimitMessageBox() {
  string message = "Lot: 0.01\nGap: 10\nTP: 20\nMax: 60\nMin: 40";

  int result =
      MessageBox(message, "Confirm Sell Limit", MB_OKCANCEL | MB_ICONQUESTION);

  if (result == IDCANCEL) {
    return false; // Prevent EA from running
  } else if (result == IDNO) {
    return false; // Prevent EA from running
  } else {
    return true; // Continue EA execution
  }
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