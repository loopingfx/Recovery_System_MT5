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
class CParabolicSarSignal
  {
private:
   CiSAR             m_sar;
public:
   void              Initialize(trade_info &info,
                                indicator_parabolic_sar_setting &setting,
                                recovery_order_setting &order_setting,
                                time_trade_setting &time_setting,
                                notification_setting &notify_setting);
   void              Refresh(trade_info &info,
                             indicator_parabolic_sar_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              Release(trade_info &info,
                             indicator_parabolic_sar_setting &setting,
                             recovery_order_setting &order_setting,
                             time_trade_setting &time_setting,
                             notification_setting &notify_setting);
   void              AttachToChart(trade_info &info,
                                   indicator_parabolic_sar_setting &setting,
                                   recovery_order_setting &order_setting,
                                   time_trade_setting &time_setting,
                                   notification_setting &notify_setting);
                    ~CParabolicSarSignal()
     {
      IndicatorRelease(m_sar.Handle());
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CParabolicSarSignal::Initialize(trade_info &info,
                                     indicator_parabolic_sar_setting &setting,
                                     recovery_order_setting &order_setting,
                                     time_trade_setting &time_setting,
                                     notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_PalabolicSAR) return;
   static ENUM_TIMEFRAMES last_SAR_Timeframe=setting.SAR_Timeframe;
   static double last_step_SAR=setting.step_SAR;
   static double last_maximum_SAR=setting.maximum_SAR;
//---
   if(last_SAR_Timeframe!=setting.SAR_Timeframe
      || last_step_SAR!=setting.step_SAR
      || last_maximum_SAR!=setting.maximum_SAR) IndicatorRelease(m_sar.Handle());
//---
   if(m_sar.Handle()!=INVALID_HANDLE) return;
//---
   MqlParam          sar_param[2];
   info.parabolic_sar_signal=0;
   sar_param[0].type=TYPE_DOUBLE;
   sar_param[1].type=TYPE_DOUBLE;
   ENUM_INDICATOR indicator_type=IND_SAR;
//---    
   sar_param[0].double_value=setting.step_SAR;
   sar_param[1].double_value=setting.maximum_SAR;
   if(m_sar.Handle()==INVALID_HANDLE)
     {
      m_sar.Create(info.symbol,setting.SAR_Timeframe,indicator_type,2,sar_param);
      last_SAR_Timeframe=setting.SAR_Timeframe;
      last_step_SAR=setting.step_SAR;
      last_maximum_SAR=setting.maximum_SAR;
     }
//---
   if(m_sar.Handle()!=INVALID_HANDLE)
     {
      string messege=StringFormat("[%s]Parabolic SAR Indicator Period %s was initialized successfully.",
                                  info.symbol,EnumToString(setting.SAR_Timeframe));
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CParabolicSarSignal::Refresh(trade_info &info,
                                  indicator_parabolic_sar_setting &setting,
                                  recovery_order_setting &order_setting,
                                  time_trade_setting &time_setting,
                                  notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   if(order_setting.Trend_Filter_Grids!=Filtering_via_PalabolicSAR) return;
   static int parabolic_sar_signal=0;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.SAR_Timeframe,1)) return;
   time=iTime(info.symbol,setting.SAR_Timeframe,1);
   info.parabolic_sar_signal=parabolic_sar_signal;
   m_sar.Refresh();
//---
   double sar_Buff[],price[];
   ArraySetAsSeries(sar_Buff,true);
   ArraySetAsSeries(price,true);
//---
   int res[2];
   res[0]=CopyBuffer(m_sar.Handle(),0,1,3,sar_Buff);
   res[1]=CopyClose(info.symbol,setting.SAR_Timeframe,1,3,price);
//---
   if(!setting.reverse_signal)
     {
      if(sar_Buff[1]<price[1]) info.parabolic_sar_signal=+1;
      if(sar_Buff[1]>price[1]) info.parabolic_sar_signal=-1;
     }
   else
     {
      if(sar_Buff[1]<price[1]) info.parabolic_sar_signal=-1;
      if(sar_Buff[1]>price[1]) info.parabolic_sar_signal=+1;
     }
//---
   if(parabolic_sar_signal!=info.parabolic_sar_signal)
     {
      string signal="NEUTRAL";
      if(info.parabolic_sar_signal>0) signal="BUY";
      if(info.parabolic_sar_signal<0) signal="SELL";
      string messege=StringFormat("[%s]Parabolic SAR Signal Period %s Change to %s.",
                                  info.symbol,EnumToString(setting.SAR_Timeframe),signal);
      //---
      CStdNotification note;
      note.SendNotify(messege,notify_setting,time_setting);
     }
   parabolic_sar_signal=info.parabolic_sar_signal;
  }
//+------------------------------------------------------------------+
void CParabolicSarSignal::Release(trade_info &info,
                                  indicator_parabolic_sar_setting &setting,
                                  recovery_order_setting &order_setting,
                                  time_trade_setting &time_setting,
                                  notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids==Filtering_via_PalabolicSAR) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.SAR_Timeframe,1)) return;
   time=iTime(info.symbol,setting.SAR_Timeframe,1);
   if(m_sar.Handle()!=INVALID_HANDLE) IndicatorRelease(m_sar.Handle());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CParabolicSarSignal::AttachToChart(trade_info &info,
                                        indicator_parabolic_sar_setting &setting,
                                        recovery_order_setting &order_setting,
                                        time_trade_setting &time_setting,
                                        notification_setting &notify_setting)
  {
   if(order_setting.Trend_Filter_Grids!=Filtering_via_PalabolicSAR) return;
   static datetime time=0;;
   if(time==iTime(info.symbol,setting.SAR_Timeframe,1)) return;
   time=iTime(info.symbol,setting.SAR_Timeframe,1);
   if(m_sar.Handle()==INVALID_HANDLE) return;
   if(EnumToString(setting.SAR_Timeframe)==EnumToString(ChartPeriod()))
     {
      m_sar.AddToChart(ChartID(),0);
      return;
     }
//---
   long currChart,prevChart=ChartFirst();
   int i=0,limit=100;
   while(i<limit)// We have certainly not more than 100 open charts 
     {
      if(EnumToString((ENUM_TIMEFRAMES)ChartPeriod(prevChart))==
         EnumToString((ENUM_TIMEFRAMES)setting.SAR_Timeframe)
         && ChartSymbol(prevChart)==info.symbol)
        {
         m_sar.AddToChart(prevChart,0);
         return;
        }
      currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID 
      if(currChart<0) break;          // Have reached the end of the chart list 
      prevChart=currChart;// let's save the current chart ID for the ChartNext() 
      i++;// Do not forget to increase the counter 
     }
   currChart=ChartOpen(info.symbol,setting.SAR_Timeframe);
   m_sar.AddToChart(currChart,0);
  }
//+------------------------------------------------------------------+
