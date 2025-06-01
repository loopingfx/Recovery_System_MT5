//+------------------------------------------------------------------+
//|                                                   CoreSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#resource "\\Indicators\\Examples\\Alligator.ex5"
#include <Indicators\Custom.mqh>
#include <multitake\RecoveryParameterGroup.mqh>
#include <multitake\StdNotification.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAlligatorSignal
  {
private:
   CiCustom          m_alligator;
public:
   void              Initialize(trade_info &info,
                                indicator_alligator_setting &setting,
                                recovery_order_setting &order_setting,
                                time_trade_setting &time_setting,
                                notification_setting &notify_setting);
   void              Refresh(trade_info &info,
                             indicator_alligator_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              Release(trade_info &info,
                             indicator_alligator_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              AttachToChart(trade_info &info,
                                   indicator_alligator_setting &setting,
                                   recovery_order_setting &order_setting,
                                   time_trade_setting &time_setting,
                                   notification_setting &notify_setting);
                    ~CAlligatorSignal()
     {
      IndicatorRelease(m_alligator.Handle());
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAlligatorSignal::Initialize(trade_info &info,
                                  indicator_alligator_setting &setting,
                                  recovery_order_setting &order_setting,
                                  time_trade_setting &time_setting,
                                  notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Alligator) return;
   static int last_jaw_period=setting.jaw_period;
   static int last_jaw_shift=setting.jaw_shift;
   static int last_teeth_period=setting.teeth_period;
   static int last_teeth_shift=setting.teeth_shift;
   static int last_lips_period=setting.lips_period;
   static int last_lips_shift=setting.lips_shift;
   static ENUM_MA_METHOD last_ma_method_Alligator=setting.ma_method_Alligator;
   static ENUM_APPLIED_PRICE last_applied_price_Alligator=setting.applied_price_Alligator;
//---
   if(last_jaw_period!=setting.jaw_period
      || last_jaw_shift!=setting.jaw_shift
      || last_teeth_period!=setting.teeth_period
      || last_teeth_shift!=setting.teeth_shift
      || last_lips_period!=setting.lips_period
      || last_lips_shift!=setting.lips_shift
      || last_ma_method_Alligator!=setting.ma_method_Alligator
      || last_applied_price_Alligator!=setting.applied_price_Alligator) IndicatorRelease(m_alligator.Handle());
//---
   if(m_alligator.Handle()!=INVALID_HANDLE) return;
//---
   MqlParam          ma_param[9];
   info.alligator_signal=0;
   ma_param[0].type=TYPE_STRING;
   ma_param[1].type=TYPE_INT;
   ma_param[2].type=TYPE_INT;
   ma_param[3].type=TYPE_INT;
   ma_param[4].type=TYPE_INT;
   ma_param[5].type=TYPE_INT;
   ma_param[6].type=TYPE_INT;
   ma_param[7].type=TYPE_INT;
   ma_param[8].type=TYPE_INT;
   ENUM_INDICATOR indicator_type=IND_CUSTOM;
//---    
   ma_param[0].string_value="::Indicators\\Examples\\Alligator.ex5";
   ma_param[1].integer_value=setting.jaw_period;
   ma_param[2].integer_value=setting.jaw_shift;
   ma_param[3].integer_value=setting.teeth_period;
   ma_param[4].integer_value=setting.teeth_shift;
   ma_param[5].integer_value=setting.lips_period;
   ma_param[6].integer_value=setting.lips_shift;
   ma_param[7].integer_value=setting.ma_method_Alligator;
   ma_param[8].integer_value=setting.applied_price_Alligator;
   if(m_alligator.Handle()==INVALID_HANDLE)
     {
      m_alligator.Create(info.symbol,setting.Alligator_Timeframe,indicator_type,9,ma_param);
      last_jaw_period=setting.jaw_period;
      last_jaw_shift=setting.jaw_shift;
      last_teeth_period=setting.teeth_period;
      last_teeth_shift=setting.teeth_shift;
      last_lips_period=setting.lips_period;
      last_lips_shift=setting.lips_shift;
      last_ma_method_Alligator=setting.ma_method_Alligator;
      last_applied_price_Alligator=setting.applied_price_Alligator;
     }
//---
   if(m_alligator.Handle()!=INVALID_HANDLE)
     {
      string messege=StringFormat("[%s]Alligator Indicator Period %s were initialized successfully.",
                                  info.symbol,EnumToString(setting.Alligator_Timeframe));
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAlligatorSignal::Refresh(trade_info &info,
                               indicator_alligator_setting &setting,
                               recovery_order_setting &order_setting,
                               time_trade_setting &time_setting,
                               notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Alligator) return;
   static int alligator_signal=0;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.Alligator_Timeframe,1)) return;
   time=iTime(info.symbol,setting.Alligator_Timeframe,1);
   info.alligator_signal=alligator_signal;
   m_alligator.Refresh();
//---
   double jaws_Buff[],teeths_Buff[],lips_Buff[];
   ArraySetAsSeries(jaws_Buff,true);
   ArraySetAsSeries(teeths_Buff,true);
   ArraySetAsSeries(lips_Buff,true);
//---
   int res[3];
   res[0]=CopyBuffer(m_alligator.Handle(),0,1,3,jaws_Buff);
   res[1]=CopyBuffer(m_alligator.Handle(),1,1,3,teeths_Buff);
   res[2]=CopyBuffer(m_alligator.Handle(),2,1,3,lips_Buff);
//---
   if(!setting.reverse_signal)
     {
      if(lips_Buff[1]>teeths_Buff[1]&& teeths_Buff[1]>jaws_Buff[1]) info.alligator_signal=+1;
      if(lips_Buff[1]<teeths_Buff[1] && teeths_Buff[1]<jaws_Buff[1])info.alligator_signal=-1;
     }
   else
     {
      if(lips_Buff[1]>teeths_Buff[1]&& teeths_Buff[1]>jaws_Buff[1]) info.alligator_signal=-1;
      if(lips_Buff[1]<teeths_Buff[1] && teeths_Buff[1]<jaws_Buff[1])info.alligator_signal=+1;
     }
//---
   if(alligator_signal!=info.alligator_signal)
     {
      string signal="NEUTRAL";
      if(info.alligator_signal>0) signal="BUY";
      if(info.alligator_signal<0) signal="SELL";
      string messege=StringFormat("[%s]Alligator Signal Period %s Change to %s.",
                                  info.symbol,EnumToString(setting.Alligator_Timeframe),signal);
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
   alligator_signal=info.alligator_signal;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CAlligatorSignal::Release(trade_info &info,
                               indicator_alligator_setting &setting,
                               recovery_order_setting &order_setting,
                               time_trade_setting &time_setting,
                               notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids==Filtering_via_Alligator) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.Alligator_Timeframe,1)) return;
   time=iTime(info.symbol,setting.Alligator_Timeframe,1);
   if(m_alligator.Handle()!=INVALID_HANDLE) IndicatorRelease(m_alligator.Handle());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAlligatorSignal::AttachToChart(trade_info &info,
                                     indicator_alligator_setting &setting,
                                     recovery_order_setting &order_setting,
                                     time_trade_setting &time_setting,
                                     notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Alligator) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.Alligator_Timeframe,1)) return;
   time=iTime(info.symbol,setting.Alligator_Timeframe,1);
   if(m_alligator.Handle()==INVALID_HANDLE) return;
   if(EnumToString(setting.Alligator_Timeframe)==EnumToString(ChartPeriod()))
     {
      m_alligator.AddToChart(ChartID(),0);
      return;
     }
//---
   long currChart,prevChart=ChartFirst();
   int i=0,limit=100;
   while(i<limit)// We have certainly not more than 100 open charts 
     {
      if(EnumToString((ENUM_TIMEFRAMES)ChartPeriod(prevChart))==
         EnumToString((ENUM_TIMEFRAMES)setting.Alligator_Timeframe)
         && ChartSymbol(prevChart)==info.symbol)
        {
         m_alligator.AddToChart(prevChart,0);
         return;
        }
      currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID 
      if(currChart<0) break;          // Have reached the end of the chart list          
      prevChart=currChart;// let's save the current chart ID for the ChartNext() 
      i++;// Do not forget to increase the counter 
     }
   currChart=ChartOpen(info.symbol,setting.Alligator_Timeframe);
   m_alligator.AddToChart(currChart,0);
  }
//+------------------------------------------------------------------+
