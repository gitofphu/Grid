//+------------------------------------------------------------------+
//|                                                test_script_6.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

// Define a structure to hold price and volume data
struct PriceVolume {
  double price;  // Price value
  double volume; // Volume value
};

void OnStart() {
  // Declare an array of the PriceVolume structure
  PriceVolume data[];

  // Populate the array with data
  PriceVolume item1;
  item1.price = 200;
  item1.volume = 10;
  ArrayResize(data, ArraySize(data) + 1);
  data[ArraySize(data) - 1] = item1;

  PriceVolume item2;
  item2.price = 100;
  item2.volume = 5;
  ArrayResize(data, ArraySize(data) + 1);
  data[ArraySize(data) - 1] = item2;

  // Print the data
  for (int i = 0; i < ArraySize(data); i++) {
    Print("Price: ", data[i].price, ", Volume: ", data[i].volume);
  }
}
