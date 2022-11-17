//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                   Copyright 2005-2014, MetaQuotes Software Corp. |
//|                                              http://www.mql4.com |
//+------------------------------------------------------------------+
#property copyright   "forextradingvn.top"
#property link        "https://forextradingvn.top"
#property description "Telegram notification"

#include "../../Include\\Socket.mqh";

input string hostname = "127.0.0.1";
input ushort port = 8000;

ClientSocket * glbConnection = NULL;
string data = " {msg}";

void OnTick()
   {
      // Create a socket if none already exists
      if (!glbConnection) glbConnection = new ClientSocket(hostname, port);
      
      if (glbConnection.IsSocketConnected()) {
         data = glbConnection.Receive();
         Print(data);
   
         if(data != ""){
            Print(MsgSocket(data));
            glbConnection.Send(MsgSocket(data));
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
   if(msg == "history_order"){
      return history_order();
   }

   return "";
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
            list_order = list_order + "{\"order_ticket\" : \""+OrderTicket()+"\", \"order_symbol\" : \""+OrderSymbol()+"\", \"order_lots\" : \""+OrderLots()+"\", \"order_open_price\" : \""+OrderOpenPrice()+"\", \"order_open_time\" : \""+OrderOpenTime()+"\", \"order_profit\" : \""+OrderProfit()+"\", \"order_take_profit\" : \""+OrderTakeProfit()+"\", \"order_stop_loss\" : \""+OrderStopLoss()+"\"}";
         }else{
            list_order = list_order + "{\"order_ticket\" : \""+OrderTicket()+"\", \"order_symbol\" : \""+OrderSymbol()+"\", \"order_lots\" : \""+OrderLots()+"\", \"order_open_price\" : \""+OrderOpenPrice()+"\", \"order_open_time\" : \""+OrderOpenTime()+"\", \"order_profit\" : \""+OrderProfit()+"\", \"order_take_profit\" : \""+OrderTakeProfit()+"\", \"order_stop_loss\" : \""+OrderStopLoss()+"\"},";
         }
      }
   }
   return "["+list_order+"]";
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
   return json + "]";
}