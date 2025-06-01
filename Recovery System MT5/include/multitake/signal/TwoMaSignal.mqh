//+------------------------------------------------------------------+
//|                                                   CoreSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Indicators\Trend.mqh>
#include <multitake\RecoveryParameterGroup.mqh>
#include <multitake\StdNotification.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTwoMaSignal
  {
private:
   CiMA              m_ma1,m_ma2;
public:
   void              Initialize(trade_info &info,
                                indicator_2ma_setting &setting,
                                recovery_order_setting &order_setting,
                                time_trade_setting &time_setting,
                                notification_setting &notify_setting);
   void              Refresh(trade_info &info,
                             indicator_2ma_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              Release(trade_info &info,
                             indicator_2ma_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              AttachToChart(trade_info &info,
                                   indicator_2ma_setting &setting,
                                   recovery_order_setting &order_setting,
                                   time_trade_setting &time_setting,
                                   notification_setting &notify_setting);
                    ~CTwoMaSignal()
     {
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoMaSignal::Initialize(trade_info &info,
                              indicator_2ma_setting &setting,
                              recovery_order_setting &order_setting,
                              time_trade_setting &time_setting,
                              //+------------------------------------------------------------------+
                              //|                                                                  |
                              //+------------------------------------------------------------------+
                              notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Two_MAs) return;
   static int last_period_MA1=setting.period_MA1;
   static ENUM_MA_METHOD last_ma_method_MA1=setting.ma_method_MA1;
   static ENUM_APPLIED_PRICE last_applied_price_MA1=setting.applied_price_MA1;
   static int last_period_MA2=setting.period_MA2;
   static ENUM_MA_METHOD last_ma_method_MA2=setting.ma_method_MA2;
   static ENUM_APPLIED_PRICE last_applied_price_MA2=setting.applied_price_MA2;
//---
   if(last_applied_price_MA1!=setting.applied_price_MA1
      || last_period_MA1!=setting.period_MA1
      || last_ma_method_MA1!=setting.ma_method_MA1) IndicatorRelease(m_ma1.Handle());
   if(last_applied_price_MA2!=setting.applied_price_MA2
      || last_period_MA2!=setting.period_MA2
      || last_ma_method_MA2!=setting.ma_method_MA2) IndicatorRelease(m_ma2.Handle());
//---
   if(m_ma1.Handle()!=INVALID_HANDLE && m_ma2.Handle()!=INVALID_HANDLE) return;
//---
   MqlParam  ma_param[4];
   info.two_ma_signal=0;
   ma_param[0].type=TYPE_INT;
   ma_param[1].type=TYPE_INT;
   ma_param[2].type=TYPE_INT;
   ma_param[3].type=TYPE_INT;
   ENUM_INDICATOR indicator_type=IND_MA;
//---    
   ma_param[0].integer_value=setting.period_MA1;
   ma_param[1].integer_value=0;
   ma_param[2].integer_value=setting.ma_method_MA1;
   ma_param[3].integer_value=setting.applied_price_MA1;
   if(m_ma1.Handle()==INVALID_HANDLE)
     {
      m_ma1.Create(info.symbol,setting.MAS_Timeframe,indicator_type,4,ma_param);
      last_period_MA1=setting.period_MA1;
      last_ma_method_MA1=setting.ma_method_MA1;
      last_applied_price_MA1=setting.applied_price_MA1;
     }
//--
   ma_param[0].integer_value=setting.period_MA2;
   ma_param[1].integer_value=0;
   ma_param[2].integer_value=setting.ma_method_MA2;
   ma_param[3].integer_value=setting.applied_price_MA2;
   if(m_ma2.Handle()==INVALID_HANDLE)
     {
      m_ma2.Create(info.symbol,setting.MAS_Timeframe,indicator_type,4,ma_param);
      last_period_MA2=setting.period_MA2;
      last_ma_method_MA2=setting.ma_method_MA2;
      last_applied_price_MA2=setting.applied_price_MA2;
     }
//---
   if(m_ma1.Handle()!=INVALID_HANDLE && m_ma2.Handle()!=INVALID_HANDLE)
     {
      string messege=StringFormat("[%s]Two MAs Indicator Period %s were initialized successfully.",
                                  info.symbol,EnumToString(setting.MAS_Timeframe));
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoMaSignal::Refresh(trade_info &info,
                           indicator_2ma_setting &setting,
                           recovery_order_setting &order_setting,
                           time_trade_setting &time_setting,
                           notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Two_MAs) return;
   static int two_ma_signal=0;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.MAS_Timeframe,1)) return;
   time=iTime(info.symbol,setting.MAS_Timeframe,1);
   info.two_ma_signal=two_ma_signal;
   m_ma1.Refresh();
   m_ma2.Refresh();
//---
   double ma1_Buff[],ma2_Buff[];
   ArraySetAsSeries(ma1_Buff,true);
   ArraySetAsSeries(ma1_Buff,true);
//---
   int res[2];
   res[0]=CopyBuffer(m_ma1.Handle(),0,1,3,ma1_Buff);
   res[1]=CopyBuffer(m_ma2.Handle(),0,1,3,ma2_Buff);
//---
   if(!setting.reverse_signal)
     {
      if(ma1_Buff[1]>ma2_Buff[1]) info.two_ma_signal=+1;
      if(ma1_Buff[1]<ma2_Buff[1]) info.two_ma_signal=-1;
     }
   else
     {
      if(ma1_Buff[1]>ma2_Buff[1]) info.two_ma_signal=-1;
      if(ma1_Buff[1]<ma2_Buff[1]) info.two_ma_signal=+1;
     }
//---
   if(two_ma_signal!=info.two_ma_signal)
     {
      string signal="NEUTRAL";
      if(info.two_ma_signal>0) signal="BUY";
      if(info.two_ma_signal<0) signal="SELL";
      string messege=StringFormat("[%s]Two MAs Signal Period %s Change to %s.",
                                  info.symbol,EnumToString(setting.MAS_Timeframe),signal);
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
   two_ma_signal=info.two_ma_signal;
  }
//+------------------------------------------------------------------+
void CTwoMaSignal::Release(trade_info &info,
                           indicator_2ma_setting &setting,
                           recovery_order_setting &order_setting,
                           time_trade_setting &time_setting,
                           notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids==Filtering_via_Two_MAs) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.MAS_Timeframe,1)) return;
   time=iTime(info.symbol,setting.MAS_Timeframe,1);
   if(m_ma1.Handle()!=INVALID_HANDLE) IndicatorRelease(m_ma1.Handle());
   if(m_ma2.Handle()!=INVALID_HANDLE) IndicatorRelease(m_ma2.Handle());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTwoMaSignal::AttachToChart(trade_info &info,
                                 indicator_2ma_setting &setting,
                                 recovery_order_setting &order_setting,
                                 time_trade_setting &time_setting,
                                 notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids!=Filtering_via_Two_MAs) return;
   if(m_ma1.Handle()==INVALID_HANDLE || m_ma2.Handle()==INVALID_HANDLE) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.MAS_Timeframe,1)) return;
   time=iTime(info.symbol,setting.MAS_Timeframe,1);
   if(EnumToString(setting.MAS_Timeframe)==EnumToString(ChartPeriod()))
     {
      m_ma1.AddToChart(ChartID(),0);
      m_ma2.AddToChart(ChartID(),0);
      return;
     }
//---
   long currChart,prevChart=ChartFirst();
   int i=0,limit=100;
   while(i<limit)// We have certainly not more than 100 open charts 
     {
      if(EnumToString((ENUM_TIMEFRAMES)ChartPeriod(prevChart))==
         EnumToString((ENUM_TIMEFRAMES)setting.MAS_Timeframe)
         && ChartSymbol(prevChart)==info.symbol)
        {
         m_ma1.AddToChart(prevChart,0);
         m_ma2.AddToChart(prevChart,0);
         return;
        }
      currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID 
      if(currChart<0) break;          // Have reached the end of the chart list             
      prevChart=currChart;// let's save the current chart ID for the ChartNext() 
      i++;// Do not forget to increase the counter 
     }
   currChart=ChartOpen(info.symbol,setting.MAS_Timeframe);
   m_ma1.AddToChart(currChart,0);
   m_ma2.AddToChart(currChart,0);
  }
//+------------------------------------------------------------------+
