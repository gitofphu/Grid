//+------------------------------------------------------------------+
//|                                            test_notification.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#define MESSAGE "Test Message"
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  //--- check permission to send notifications in the terminal
  if (!TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) {
    Print("Error. The client terminal does not have permission to send "
          "notifications");
    return;
  }
  //--- send notification
  ResetLastError();
  if (!SendNotification(MESSAGE))
    Print("SendNotification() failed. Error ", GetLastError());
}
//+------------------------------------------------------------------+