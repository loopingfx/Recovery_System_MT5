//+------------------------------------------------------------------+
//|                                                   CoreSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#resource "\\Indicators\\Examples\\Heiken_Ashi.ex5"
#include <Indicators\Custom.mqh>
#include <multitake\RecoveryParameterGroup.mqh>
#include <multitake\StdNotification.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHeikenAshiSignal
  {
private:
   CiCustom          m_heiken;
public:
   void              Initialize(trade_info &info,
                                indicator_heiken_ashi_setting &setting,
                                recovery_order_setting &order_setting,
                                time_trade_setting &time_setting,
                                notification_setting &notify_setting);
   void              Refresh(trade_info &info,
                             indicator_heiken_ashi_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              Release(trade_info &info,
                             indicator_heiken_ashi_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              AttachToChart(trade_info &info,
                                   indicator_heiken_ashi_setting &setting,
                                   recovery_order_setting &order_setting,
                                   time_trade_setting &time_setting,
                                   notification_setting &notify_setting);
                    ~CHeikenAshiSignal()
     {
      IndicatorRelease(m_heiken.Handle());
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHeikenAshiSignal::Initialize(trade_info &info,
                                   indicator_heiken_ashi_setting &setting,
                                   recovery_order_setting &order_setting,
                                   time_trade_setting &time_setting,
                                   notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Heiken_Ashi) return;
   static ENUM_TIMEFRAMES last_HARSI_Timeframe=setting.HARSI_Timeframe;
//---
   if(last_HARSI_Timeframe!=setting.HARSI_Timeframe) IndicatorRelease(m_heiken.Handle());
//---
   if(m_heiken.Handle()!=INVALID_HANDLE) return;
//---
   MqlParam          ha_param[1];
   info.heiken_ashi_signal=0;
   ha_param[0].type=TYPE_STRING;
   ENUM_INDICATOR indicator_type=IND_CUSTOM;
//---    
   ha_param[0].string_value="::Indicators\\Examples\\Heiken_Ashi.ex5";
   if(m_heiken.Handle()==INVALID_HANDLE)
     {
      m_heiken.Create(info.symbol,setting.HARSI_Timeframe,indicator_type,1,ha_param);
      last_HARSI_Timeframe=setting.HARSI_Timeframe;
     }
//---
   if(m_heiken.Handle()!=INVALID_HANDLE)
     {
      string messege=StringFormat("[%s]Heiken Ashi Indicator Period %s was initialized successfully.",
                                  info.symbol,EnumToString(setting.HARSI_Timeframe));
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHeikenAshiSignal::Refresh(trade_info &info,
                                indicator_heiken_ashi_setting &setting,
                                recovery_order_setting &order_setting,
                                time_trade_setting &time_setting,
                                notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Heiken_Ashi) return;
   static int heiken_ashi_signal=0;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.HARSI_Timeframe,1)) return;
   time=iTime(info.symbol,setting.HARSI_Timeframe,1);
   info.heiken_ashi_signal=heiken_ashi_signal;
   m_heiken.Refresh();
//---
   double ha_open_Buff[],ha_close_Buff[];
   ArraySetAsSeries(ha_open_Buff,true);
   ArraySetAsSeries(ha_close_Buff,true);
//---
   int res[2];
   res[0]=CopyBuffer(m_heiken.Handle(),0,1,3,ha_open_Buff);
   res[1]=CopyBuffer(m_heiken.Handle(),3,1,3,ha_close_Buff);
//---
   if(!setting.reverse_signal)
     {
      if(ha_close_Buff[1]>ha_open_Buff[1]) info.heiken_ashi_signal=+1;
      if(ha_close_Buff[1]<ha_open_Buff[1]) info.heiken_ashi_signal=-1;
     }
   else
     {
      if(ha_close_Buff[1]>ha_open_Buff[1]) info.heiken_ashi_signal=-1;
      if(ha_close_Buff[1]<ha_open_Buff[1]) info.heiken_ashi_signal=+1;
     }
//---
   if(heiken_ashi_signal!=info.heiken_ashi_signal)
     {
      string signal="NEUTRAL";
      if(info.heiken_ashi_signal>0) signal="BUY";
      if(info.heiken_ashi_signal<0) signal="SELL";
      string messege=StringFormat("[%s]Heiken Ashi Signal Period %s Change to %s.",
                                  info.symbol,EnumToString(setting.HARSI_Timeframe),signal);
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
   heiken_ashi_signal=info.heiken_ashi_signal;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CHeikenAshiSignal::Release(trade_info &info,
                                indicator_heiken_ashi_setting &setting,
                                recovery_order_setting &order_setting,
                                time_trade_setting &time_setting,
                                notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids==Filtering_via_Heiken_Ashi) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.HARSI_Timeframe,1)) return;
   time=iTime(info.symbol,setting.HARSI_Timeframe,1);
   if(m_heiken.Handle()!=INVALID_HANDLE) IndicatorRelease(m_heiken.Handle());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHeikenAshiSignal::AttachToChart(trade_info &info,
                                      indicator_heiken_ashi_setting &setting,
                                      recovery_order_setting &order_setting,
                                      time_trade_setting &time_setting,
                                      notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Heiken_Ashi) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.HARSI_Timeframe,1)) return;
   time=iTime(info.symbol,setting.HARSI_Timeframe,1);
   if(m_heiken.Handle()==INVALID_HANDLE) return;
      if(EnumToString(setting.HARSI_Timeframe)==EnumToString(ChartPeriod()))
     {
      m_heiken.AddToChart(ChartID(),0);
      return;
     }
//---
   long currChart,prevChart=ChartFirst();
   int i=0,limit=100;
   while(i<limit)// We have certainly not more than 100 open charts 
     {

      if(EnumToString((ENUM_TIMEFRAMES)ChartPeriod(prevChart))==
         EnumToString((ENUM_TIMEFRAMES)setting.HARSI_Timeframe)
         && ChartSymbol(prevChart)==info.symbol)
        {
         m_heiken.AddToChart(prevChart,0);
         return;
        }
      currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID 
      if(currChart<0) break;          // Have reached the end of the chart list     
      prevChart=currChart;// let's save the current chart ID for the ChartNext() 
      i++;// Do not forget to increase the counter 
     }
   currChart=ChartOpen(info.symbol,setting.HARSI_Timeframe);
   m_heiken.AddToChart(currChart,0);
  }
//+------------------------------------------------------------------+
