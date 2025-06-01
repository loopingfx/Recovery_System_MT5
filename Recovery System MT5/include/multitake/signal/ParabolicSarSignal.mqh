#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <multitake\BasicTradeClass.mqh>
#include <Indicators\Trend.mqh>

//+------------------------------------------------------------------+
//| Parabolic SAR Signal                                             |
//+------------------------------------------------------------------+
class CParabolicSarSignal : public CIndicator
  {
protected:
   ENUM_TIMEFRAMES   m_timeframe;
   double            m_step;
   double            m_maximum;

public:
                     CParabolicSarSignal(void);
                    ~CParabolicSarSignal(void);
   //--- initialization
   void              Step(double step) { m_step=step; }
   void              Maximum(double maximum) { m_maximum=maximum; }
   //--- get signal
   virtual int       GetSignal(void);
   //--- get indicator handle
   int               GetHandle(int index);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CParabolicSarSignal::CParabolicSarSignal(void) : m_timeframe(_Period),
                                                m_step(0.02),
                                                m_maximum(0.2)
  {
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CParabolicSarSignal::~CParabolicSarSignal(void)
  {
  }

//+------------------------------------------------------------------+
//| Get indicator handle                                             |
//+------------------------------------------------------------------+
int CParabolicSarSignal::GetHandle(int index)
  {
   if(index == 0) // Parabolic SAR
      return iSAR(m_symbol, m_timeframe, m_step, m_maximum);
   return INVALID_HANDLE;
  }

//+------------------------------------------------------------------+
//| Get signal                                                       |
//+------------------------------------------------------------------+
int CParabolicSarSignal::GetSignal(void)
  {
   double sar[];
   int handle;
   //--- copy data
   handle=GetHandle(0);
   if(CopyBuffer(handle,0,0,3,sar)<=0) return 0;
   //--- check signals
   double price_bid=iClose(m_symbol,m_timeframe,1);
   double price_ask=iClose(m_symbol,m_timeframe,1);
   //---
   if(sar[2]>price_bid && sar[1]<price_ask) return 1; // Buy signal
   if(sar[2]<price_bid && sar[1]>price_ask) return -1; // Sell signal
   //---
   return 0;
  }
//+------------------------------------------------------------------+
