// Function to populate an array
void FillArray(int &array[]) {
  // Set array size
  ArrayResize(array, 5);

  // Fill the array with values
  array[0] = 10;
  array[1] = 20;
  array[2] = 30;
  array[3] = 40;
  array[4] = 50;
}

// Test function in OnStart
void OnStart() {
  // Declare an array
  int resultArray[];

  // Call the function to populate the array
  FillArray(resultArray);

  // Print the array elements
  for (int i = 0; i < ArraySize(resultArray); i++) {
    Print("Element ", i, ": ", resultArray[i]);
  }
}

