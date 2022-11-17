
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
