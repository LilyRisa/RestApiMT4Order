
# Rest Api MT4 Order

Tool executes functions in MT4 trading platform

Get order history, open order, close order,...

Use php server web built in to generate HTTP api and make incoming connection socket MT4

## Components

```
  ./include  - socket library for MT4. file inside must be moved in \\MQL4\\Include\\
  ./Web server - The directory contains the php source code, Use the built-in php web server to start
  ./socket.mq4 - Expert Advisor MT4
```

## Api


- ### Endpoint (GET)
```
  /api/history_order      // Get all order history

```
- #### Result:
```
[
  {
  "order_ticket": "50830127",
  "order_symbol": "",
  "order_lots": "0.01",
  "order_open_price": "0",
  "order_open_time": "2022.11.17 07:31:13",
  "order_profit": "100000",
  "order_take_profit": "0",
  "order_stop_loss": "0",
  "order_magic_number": "0"
  },
  {
  "order_ticket": "51013716",
  "order_symbol": "EURZARm",
  "order_lots": "1",
  "order_open_price": "18.06244",
  "order_open_time": "2022.11.17 15:48:59",
  "order_profit": "451.39",
  "order_take_profit": "0",
  "order_stop_loss": "0",
  "order_magic_number": "0"
  },
  ...
]

```

- ### Endpoint (GET)
```
  /api/symbol_total      // Get all symbol current in MT4

```
- #### Result:
```
[
  {
  "number": "14",
  "name": "USDCHFm"
  },
  {
  "number": "13",
  "name": "USDCADm"
  },
  {
  "number": "12",
  "name": "EURZARm"
  },
  ...
]

```

- ### Endpoint (POST)
```
  /api/open_order      // open order

```
- #### form-data
```
  symbol : (string)       // Symbol
  cmd : (int)             // 0 - buy | 1 - SELL | 2 - BUYLIMIT | 3 - SELLLIMIT | 4 - BUYSTOP | 5 - SELLSTOP
  volume : (double)       // Lots
  price : (double)        // Order price
  slippage : (int)        // Maximum price slippage for buy or sell orders
  stoploss : (double)     // Stop loss level
  takeprofit : (double)   // Take profit level
  expiration : (datetime) // Order expiration time (for pending orders only).
  magic_number : (int)    // Order magic number. each magic number can only max order

```
- #### Result:
```
{
    "status": 51256331  // Returns number of the ticket assigned to the order by the trade server or return number <= 150 if it fails 
}

```