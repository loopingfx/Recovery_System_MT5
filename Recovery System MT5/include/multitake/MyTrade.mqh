//+------------------------------------------------------------------+
//|                                                      MyTrade.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyTrade : public CTrade
  {
private:

public:
   ulong             GetExpertMagicNumber(){return(m_magic);}
                     CMyTrade();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CMyTrade::CMyTrade()
  {
   LogLevel(LOG_LEVEL_NO);
   SetDeviationInPoints(2);
  }
//+------------------------------------------------------------------+

