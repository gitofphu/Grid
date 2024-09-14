
void OnStart() {
  // Print("MQL_HANDLES_USED: ", MQLInfoInteger(MQL_HANDLES_USED));
  // Print("MQL_MEMORY_LIMIT: ", MQLInfoInteger(MQL_MEMORY_LIMIT));
  // Print("MQL_MEMORY_USED: ", MQLInfoInteger(MQL_MEMORY_USED));
  // Print("MQL_PROGRAM_TYPE: ", MQLInfoInteger(MQL_PROGRAM_TYPE));
  // Print("MQL_DLLS_ALLOWED: ", MQLInfoInteger(MQL_DLLS_ALLOWED));
  // Print("MQL_TRADE_ALLOWED: ", MQLInfoInteger(MQL_TRADE_ALLOWED));
  // Print("MQL_SIGNALS_ALLOWED: ", MQLInfoInteger(MQL_SIGNALS_ALLOWED));
  // Print("MQL_DEBUG: ", MQLInfoInteger(MQL_DEBUG));
  // Print("MQL_PROFILER: ", MQLInfoInteger(MQL_PROFILER));
  // Print("MQL_TESTER: ", MQLInfoInteger(MQL_TESTER));
  // Print("MQL_FORWARD: ", MQLInfoInteger(MQL_FORWARD));
  // Print("MQL_OPTIMIZATION: ", MQLInfoInteger(MQL_OPTIMIZATION));
  // Print("MQL_VISUAL_MODE: ", MQLInfoInteger(MQL_VISUAL_MODE));
  // Print("MQL_FRAME_MODE: ", MQLInfoInteger(MQL_FRAME_MODE));
  // Print("MQL_LICENSE_TYPE: ", MQLInfoInteger(MQL_LICENSE_TYPE));
  // Print("MQL_STARTED_FROM_CONFIG: ",
  // MQLInfoInteger(MQL_STARTED_FROM_CONFIG));

  const bool allowed = MQLInfoInteger(MQL_TRADE_ALLOWED);

  Print("allowed ", allowed);
}
