//+------------------------------------------------------------------+
//|                                             test_StringSplit.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "Version = 1.00"

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  string str = "";
  string parts[];
  int count = StringSplit(str, '|', parts);
  Print("Count: ", count);
  //   Print("Part 1: ", parts[0]);
  //   Print("Part 2: ", parts[1]);
  //   Print("Part 3: ", parts[2]);
}
//+------------------------------------------------------------------+