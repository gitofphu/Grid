#include <Trade\TerminalInfo.mqh>

CTerminalInfo TerminalInfo;

// HACK migh work not sure

void OnStart() {
  Print("TerminalInfo.IsTradeAllowed(): ", TerminalInfo.IsTradeAllowed());
}
