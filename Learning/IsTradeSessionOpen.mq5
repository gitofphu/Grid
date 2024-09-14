
void OnStart() {
  // Example of usage
  if (IsTradeSessionOpen()) {
    Print("Trade session is currently open for the symbol.");
  } else {
    Print("Trade session is currently closed for the symbol.");
  }
}

// Function to check if the trade session is currently open
bool IsTradeSessionOpen() {
  datetime current_time = TimeCurrent(); // Get the current server time

  MqlDateTime time_struct;
  TimeToStruct(current_time,
               time_struct); // Convert current time to a structure

  // Convert the day_of_week (0 = Sunday, 1 = Monday, etc.) to ENUM_DAY_OF_WEEK
  ENUM_DAY_OF_WEEK day_of_week = ENUM_DAY_OF_WEEK(time_struct.day_of_week);

  // Loop through all sessions for the current day
  for (int session_index = 0; session_index < 10;
       session_index++) // 10 is an arbitrary upper limit for sessions
  {
    datetime session_start, session_end;
    if (SymbolInfoSessionTrade(_Symbol, day_of_week, session_index,
                               session_start, session_end)) {
      // Check if current time is within the session
      if (current_time >= session_start && current_time <= session_end) {
        return true; // Session is open
      }
    } else {
      break; // No more sessions available
    }
  }

  return false; // No session is currently open
}