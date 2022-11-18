//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "forextradingvn.top"
#property link        "https://forextradingvn.top"
#property description "Api connect EA"

#include "../../Include\\Socket.mqh";

input string hostname = "127.0.0.1";
input ushort port = 8000;

ClientSocket * glbConnection = NULL;
string data = " {msg}";
string history_order[];

void OnTick()
   {
      // Create a socket if none already exists
      if (!glbConnection) glbConnection = new ClientSocket(hostname, port);
      
      if (glbConnection.IsSocketConnected()) {
         data = glbConnection.Receive();
         
         if(data != ""){
            string data_recv = MsgSocket(data);
            Print(data_recv);
            if(data_recv != ""){
               if(data_recv == "0"){
                  for (int i = 0; i < ArraySize(history_order); i++)
                  {
                     Print(history_order[i]);
                     glbConnection.Send(history_order[i]);
                  }
                  glbConnection.Send("@end");
                  
               }else{
                  glbConnection.Send(data_recv);
               }
               
            }
         }
         
      }
      
      // Socket may already have been dead, or now detected as failed
      // following the attempt above at sending or receiving.
      // If so, delete the socket and try a new one on the next call to OnTick()
      if (!glbConnection.IsSocketConnected()) {
         delete glbConnection;
         glbConnection = NULL;            
      }
   }

string MsgSocket(string msg){
   string result[];
   int length = StringSplit(msg, StringGetCharacter("|", 0),result);
   string controller = "";
   if(length > 0){
      controller = result[0];
   }else{
      controller = msg;
   }
   
   Print(controller);
   if(controller == "history_order"){
      // return history_order();
      history_order_byte_line();
      return "0";
   }

   if(controller == "symbol_total"){
      return symbol_total();
   }

   if(controller == "open_order"){
      return open_order(result);
   }

   return "";
}

void history_order_byte_line(){
   int i, hstTotal=OrdersHistoryTotal();
   string list_order = "";
   ArrayResize(history_order, hstTotal);
   for(i=0;i<hstTotal;i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false){
         Print("Access to history failed with error (",GetLastError(),")");
         break;
      }else{
        history_order[i] = "{\"order_ticket\" : \""+OrderTicket()+"\", \"order_symbol\" : \""+OrderSymbol()+"\", \"order_lots\" : \""+OrderLots()+"\", \"order_open_price\" : \""+OrderOpenPrice()+"\", \"order_open_time\" : \""+OrderOpenTime()+"\", \"order_profit\" : \""+OrderProfit()+"\", \"order_take_profit\" : \""+OrderTakeProfit()+"\", \"order_stop_loss\" : \""+OrderStopLoss()+"\", \"order_magic_number\" : \""+OrderMagicNumber()+"\"}";
      }
   }
}


string open_order(string &order[]){
   int ListLength = ArraySize(order);
   string symbol;
   string variable[];
   int cmd, slippage, magic = 1;
   double volume, price, stoploss, takeprofit;
   datetime expiration = 0;

   int check_order = 0;

   for(int i = 1; i < ArraySize(order); i++){
      StringSplit(order[i], StringGetCharacter("=", 0),variable);
      if(variable[0] == "symbol"){
         symbol = variable[1];
      }else
      if(variable[0] == "cmd"){
         cmd = StrToInteger(variable[1]);
      }else
      if(variable[0] == "slippage"){
         slippage = StrToInteger(variable[1]);
      }else
      if(variable[0] == "volume"){
         volume = StrToDouble(variable[1]);
      }else
      if(variable[0] == "price"){
         price = StrToDouble(variable[1]);
      }else
      if(variable[0] == "stoploss"){
         stoploss = StrToDouble(variable[1]);
      }else
      if(variable[0] == "takeprofit"){
         takeprofit = StrToDouble(variable[1]);
      }else
      if(variable[0] == "expiration"){
         if(variable[1] != "0") expiration = StrToTime(variable[1]);
      }else if(variable[0] == "magic_number"){
         magic = StrToInteger(variable[1]);
      }
   }
   Print(Symbol()+"|"+cmd+"|"+slippage+"|"+volume+"|"+price+"|"+stoploss+"|"+takeprofit+ "|");
   for(int pos = OrdersTotal()-1; pos >= 0 ; pos--){
      if (OrderSelect(pos, SELECT_BY_POS) && OrderMagicNumber() == magic){
         check_order++;
         break;
      }
   }
   int status;
   if(check_order == 0){
      status = OrderSend(symbol,cmd,volume,price,slippage,stoploss,takeprofit,"CongMinhOrder",magic,expiration,clrGreen);
   }else{
      status = -1;
   }
   if(status < 0) return "{\"status\" : "+GetLastError()+"}";
   return "{\"status\" : "+status+"}";
   
}

string symbol_total(){
   int total=SymbolsTotal(true)-1;
   string data = "";
   for(int i=total-1;i>=0;i--)
   {
      string Sembol=SymbolName(i,true);
      if(i == 0){
         data = data + "{\"number\" : \""+string(i)+"\",  \"name\" : \""+Sembol+"\"}";
      }else{
          data = data + "{\"number\" : \""+string(i)+"\",  \"name\" : \""+Sembol+"\"},";
      }
   }
   return "["+data+"]";
}

string history_order(){
   int i, hstTotal=OrdersHistoryTotal();
   string list_order = "";
   for(i=0;i<hstTotal;i++){
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false){
         Print("Access to history failed with error (",GetLastError(),")");
         break;
      }else{
         if(i == hstTotal -1){
            list_order = list_order + "{\"order_ticket\" : \""+OrderTicket()+"\", \"order_symbol\" : \""+OrderSymbol()+"\", \"order_lots\" : \""+OrderLots()+"\", \"order_open_price\" : \""+OrderOpenPrice()+"\", \"order_open_time\" : \""+OrderOpenTime()+"\", \"order_profit\" : \""+OrderProfit()+"\", \"order_take_profit\" : \""+OrderTakeProfit()+"\", \"order_stop_loss\" : \""+OrderStopLoss()+"\", \"order_magic_number\" : \""+OrderMagicNumber()+"\"}";
         }else{
            list_order = list_order + "{\"order_ticket\" : \""+OrderTicket()+"\", \"order_symbol\" : \""+OrderSymbol()+"\", \"order_lots\" : \""+OrderLots()+"\", \"order_open_price\" : \""+OrderOpenPrice()+"\", \"order_open_time\" : \""+OrderOpenTime()+"\", \"order_profit\" : \""+OrderProfit()+"\", \"order_take_profit\" : \""+OrderTakeProfit()+"\", \"order_stop_loss\" : \""+OrderStopLoss()+"\", \"order_magic_number\" : \""+OrderMagicNumber()+"\"},";
         }
      }
   }
   return "["+list_order+"]\n\r";
}

string convert_array_to_json(string &list_order[]){
   int ListLength = sizeof(list_order) / sizeof(int);
   string json = "[";
   for(int i = 0; i < ListLength ; i++){
      if(i == ListLength -1){
         json = json + list_order[i];
      }else{
         json = json + list_order[i] + ",";
      }
   }
   return json + "]\n\r";
}