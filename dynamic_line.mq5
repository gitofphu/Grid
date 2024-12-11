//+------------------------------------------------------------------+
//|                                                 dynamic_line.mq5 |
//|                                           Copyright 20XX, MyName |
//|                                          https://www.mysite.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 20XX, MyName"
#property link "https://www.mysite.com/"
#property version "1.00"

#include <../Experts/Grid/Utility.mqh>
MyUtility Utility;

#include <ChartObjects/ChartObject.mqh>
CChartObject object;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
  // DrawLine();
  FindAndDeleteHorizontalLinesWithPrefix();
}

void DrawLine() {
  double CurrentPrice = 80;
  double MinPrice = 70;
  double PriceRange = 1;

  CArrayDouble ArrayPrices;
  Utility.GetArrayPrice(MinPrice, CurrentPrice, PriceRange, ArrayPrices);

  for (int i = 0; i < ArrayPrices.Total(); i++) {
    Print("ArrayPrices: ", i, " = ", ArrayPrices[i]);

    ObjectCreate(0, "My_Line_" + i, OBJ_HLINE, 0, 0, ArrayPrices[i]);

    // ObjectDelete(0, "My_Line_" + i);
  }
}

void FindAndDeleteHorizontalLinesWithPrefix() {
  int totalObjects = ObjectsTotal(0); // Get total objects on the current chart
  Print("Total objects: ", totalObjects);

  for (int i = totalObjects - 1; i >= 0;
       i--) // Iterate in reverse to safely delete objects
  {
    string objectName = ObjectName(0, i); // Get the name of the object

    // Check if the object name contains "My_Line_"
    if (StringFind(objectName, "My_Line_") >= 0) {
      if (ObjectGetInteger(0, objectName, OBJPROP_TYPE) ==
          OBJ_HLINE) // Check if it's a horizontal line
      {
        double hlinePrice = ObjectGetDouble(
            0, objectName,
            OBJPROP_PRICE); // Get the price level of the horizontal line
        Print("Deleting horizontal line: Name=", objectName,
              ", Price=", hlinePrice);
        ObjectDelete(0, objectName); // Delete the object
      }
    }
  }
}
