//+------------------------------------------------------------------+
//|                                              StdNotification.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "RecoveryParameterGroup.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CStdNotification
  {
private:
public:
   void SendNotify(string message,notification_setting &setting,time_trade_setting &time_setting)
     {
      string VPS="";
      if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
      string time="[CURRENT:"+TimeToString(TimeCurrent())+"]";
      if(time_setting.mode==time_local)
         time="[GMT "+(string)int(TimeGMTOffset()/60/60)+"][LOCAL:"+TimeToString(TimeLocal())+"]";
      message=time+message+VPS;
      if(setting.Send_Mail)
        {
         if(TerminalInfoInteger(TERMINAL_EMAIL_ENABLED))
            SendMail(setting.Mail_Subject,message);
        }
      if(setting.Send_Push_Notifications)
        {
         if(TerminalInfoInteger(TERMINAL_MQID))
           {
            if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
               SendNotification(message);
           }
         else
            if(TerminalInfoInteger(TERMINAL_MQID)) Print("The MetaQuotes ID data is not presence.");
        }
      if(setting.Send_PopUp_Alerts) Alert(message);
      Print(message);
     }
  };
//+------------------------------------------------------------------+
