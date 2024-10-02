# grid
MT5 grid EA

| Input                     | Type   | Description                                                                                   | Default |
|---------------------------|--------|-----------------------------------------------------------------------------------------------|---------|
| MaxPrice                  | double | Max price of range to determine grid levels                                                   | 100     |
| MinPrice                  | double | Min price of range to determine grid levels                                                   | 0       |
| MaxOrder                  | int    | Limit number of order can be place by EA                                                      | NULL    |
| PriceRange                | double | Grid and TP size                                                                              | 10      |
| TradeAnywaywithMinimunLot | bool   | If calculated lot size is less then SYMBOL_VOLUME_MIN,  continue trade with SYMBOL_VOLUME_MIN | false   |
| ClearOrdersOnInit         | bool   | remove pending order of current symbol                                                        | false   |