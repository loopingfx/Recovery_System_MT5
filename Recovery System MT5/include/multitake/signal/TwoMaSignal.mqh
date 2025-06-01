#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <multitake\BasicTradeClass.mqh>
#include <Indicators\Trend.mqh>

//+------------------------------------------------------------------+
//| Two Moving Averages Signal                                       |
//+------------------------------------------------------------------+
class CTwoMaSignal : public CIndicator
  {
protected:
   ENUM_TIMEFRAMES   m_timeframe;  // Local declaration to ensure availability
   int               m_fast_period;
   int               m_slow_period;
   ENUM_MA_METHOD    m_fast_method;
   ENUM_MA_METHOD    m_slow_method;
   ENUM_APPLIED_PRICE m_price;

public:
                     CTwoMaSignal(void);
                    ~CTwoMaSignal(void);
   //--- initialization
   void              FastPeriod(int period) { m_fast_period=period; }
   void              SlowPeriod(int period) { m_slow_period=period; }
   void              FastMethod(ENUM_MA_METHOD method) { m_fast_method=method; }
   void              SlowMethod(ENUM_MA_METHOD method) { m_slow_method=method; }
   void              AppliedPrice(ENUM_APPLIED_PRICE price) { m_price=price; }
   //--- get signal
   virtual int       GetSignal(void);
   virtual int       GetSignalOpen(void);
   //--- get indicator handle
   int               GetHandle(int index);
  };

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTwoMaSignal::CTwoMaSignal(void) : m_timeframe(_Period),  // Initialize local m_timeframe
                                   m_fast_period(10),
                                   m_slow_period(20),
                                   m_fast_method(MODE_SMA),
                                   m_slow_method(MODE_SMA),
                                   m_price(PRICE_CLOSE)
  {
  }

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTwoMaSignal::~CTwoMaSignal(void)
  {
  }

//+------------------------------------------------------------------+
//| Get indicator handle                                             |
//+------------------------------------------------------------------+
int CTwoMaSignal::GetHandle(int index)
  {
   if(index == 0) // Fast MA
      return iMA(m_symbol, m_timeframe, m_fast_period, 0, m_fast_method, m_price);  // m_symbol is inherited
   if(index == 1) // Slow MA
      return iMA(m_symbol, m_timeframe, m_slow_period, 0, m_slow_method, m_price);  // m_symbol is inherited
   return INVALID_HANDLE;
  }

//+------------------------------------------------------------------+
//| Get signal                                                       |
//+------------------------------------------------------------------+
int CTwoMaSignal::GetSignal(void)
  {
   double fast[],slow[];
   int fast_handle,slow_handle;
   //--- copy data
   fast_handle=GetHandle(0);
   slow_handle=GetHandle(1);
   if(CopyBuffer(fast_handle,0,0,3,fast)<=0) return 0;
   if(CopyBuffer(slow_handle,0,0,3,slow)<=0) return 0;
   //--- check signals
   if(fast[2]<slow[2] && fast[1]>=slow[1]) return 1; // Buy signal
   if(fast[2]>slow[2] && fast[1]<=slow[1]) return -1; // Sell signal
   //---
   return 0;
  }

//+------------------------------------------------------------------+
//| Get signal for open                                              |
//+------------------------------------------------------------------+
int CTwoMaSignal::GetSignalOpen(void)
  {
   double fast[],slow[];
   int fast_handle,slow_handle;
   //--- copy data
   fast_handle=GetHandle(0);
   slow_handle=GetHandle(1);
   if(CopyBuffer(fast_handle,0,0,3,fast)<=0) return 0;
   if(CopyBuffer(slow_handle,0,0,3,slow)<=0) return 0;
   //--- check signals
   if(fast[2]<slow[2] && fast[1]>=slow[1]) return 1; // Buy signal
   if(fast[2]>slow[2] && fast[1]<=slow[1]) return -1; // Sell signal
   //---
   return 0;
  }
//+------------------------------------------------------------------+
