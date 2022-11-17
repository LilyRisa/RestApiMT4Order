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

void OnTick()
   {
      // Create a socket if none already exists
      if (!glbConnection) glbConnection = new ClientSocket(hostname, port);
      
      if (glbConnection.IsSocketConnected()) {
         Print(glbConnection.Receive());
      }
      
      // Socket may already have been dead, or now detected as failed
      // following the attempt above at sending or receiving.
      // If so, delete the socket and try a new one on the next call to OnTick()
      if (!glbConnection.IsSocketConnected()) {
         delete glbConnection;
         glbConnection = NULL;            
      }
   }