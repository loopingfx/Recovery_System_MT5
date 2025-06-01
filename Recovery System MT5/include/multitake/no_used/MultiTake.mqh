//+------------------------------------------------------------------+
//|                                                    MultiTake.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "BasicTradeClass.mqh"
#include "MyTrade.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMultiTake
  {
private:
   struct order_info
     {
      ulong             ticket;
      uint              magic;
      string            symbol;
      double            open;
      double            stop;
      double            take;
      ENUM_POSITION_TYPE type;
      int               take1_pip;
      int               take2_pip;
      int               take3_pip;
      int               take4_pip;
      double            take1_lots;
      double            take2_lots;
      double            take3_lots;
      double            take4_lots;
      bool              take1_waiting;
      bool              take2_waiting;
      bool              take3_waiting;
      bool              take4_waiting;
      int               curr_take_pip;
      int               stop_pip;
      double            stop_lots;
      bool              stop_waiting;
      int               curr_stop_pip;
     };
   //---
   CBasicTradeClass  m_basic;
   int               m_take_pip;
   int               m_stop_pip;
   double            CalculateLots(string symbol_name,double lots,double percent,bool ceiling=true);
   void              CheckToTakeProfit(order_info &list[],CMyTrade *trade);
   void              GetMarketOrders(string symbol,int magic,order_info &list[]);
   void              CopyOrderInfoArray(order_info &dst[],order_info &src[]);
   void              GetHrMinSecFromString(int &Hr1,int &Min1,int &Sec1,string hoursStr);
public:
   bool              IsTimeCurrentInRange(string startHours,string stopHours);
   void              TakeProfit(CMyTrade *trade,string symbol,int magic)
     {
      order_info list[];
      GetMarketOrders(symbol,magic,list);
      CheckToTakeProfit(list,trade);
     }
   void              TrailingStop(CMyTrade *trade,string symbol,int trailing,int breakeven,int step);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiTake::CheckToTakeProfit(order_info &list[],CMyTrade *trade)
  {
   int curr_takepip=0;
   int curr_stoppip=0;
   for(int i=0; i<ArraySize(list); i++)
     {
      double pt=SymbolInfoDouble(list[i].symbol,SYMBOL_POINT);
      double ask=SymbolInfoDouble(list[i].symbol,SYMBOL_ASK);
      double bid=SymbolInfoDouble(list[i].symbol,SYMBOL_BID);
      //---
      if(pt==0) continue;
      if(list[i].type==POSITION_TYPE_SELL) {curr_takepip=int((list[i].open-ask)/pt);}
      if(list[i].type==POSITION_TYPE_BUY) {curr_takepip=int((bid-list[i].open)/pt);}
      if(list[i].type==POSITION_TYPE_SELL) {curr_stoppip=int((ask-list[i].open)/pt);}
      if(list[i].type==POSITION_TYPE_BUY) {curr_stoppip=int((list[i].open-bid)/pt);}

      //---
      if(list[i].take1_waiting
         && curr_takepip>list[i].take1_pip
         && list[i].take1_pip>0
         && list[i].take1_lots>0)
        {
         if(trade.PositionClosePartial(list[i].ticket,list[i].take1_lots))
            list[i].take1_waiting=false;
         //---
         order_structure param;
         param.magic=(int)list[i].magic;
         param.symbol=list[i].symbol;
         if(list[i].type==POSITION_TYPE_BUY)
           {
            m_basic.DeleteAllSell(trade,param);
            m_basic.CloseAllSell(trade,param);
           }
         if(list[i].type==POSITION_TYPE_SELL)
           {
            m_basic.DeleteAllBuy(trade,param);
            m_basic.CloseAllBuy(trade,param);
           }
        }
      if(list[i].take2_waiting
         && curr_takepip>list[i].take2_pip
         && list[i].take2_pip>0
         && list[i].take2_lots>0)
        {
         if(trade.PositionClosePartial(list[i].ticket,list[i].take2_lots))
            list[i].take2_waiting=false;
        }
      if(list[i].take3_waiting
         && curr_takepip>list[i].take3_pip
         && list[i].take3_pip>0
         && list[i].take3_lots>0)
        {
         if(trade.PositionClosePartial(list[i].ticket,list[i].take3_lots))
            list[i].take3_waiting=false;
        }
      if(list[i].take4_waiting
         && curr_takepip>list[i].take4_pip
         && list[i].take4_pip>0
         && list[i].take4_lots>0)
        {
         if(trade.PositionClose(list[i].ticket))
            list[i].take4_waiting=false;
        }
      //---
      if(list[i].stop_waiting
         && curr_stoppip>list[i].stop_pip
         && list[i].stop_pip>0
         && list[i].stop_lots>0)
        {
         if(trade.PositionClose(list[i].ticket))
            list[i].stop_waiting=false;
        }
      //---
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CMultiTake::GetMarketOrders(string symbol,int magic,order_info &list[])
  {
   order_info order[];
   ArrayResize(order,PositionsTotal(),10);
   int count=0;
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   for(int i=0; i<PositionsTotal(); i++)
      if(PositionSelectByTicket(PositionGetTicket(i)))
         if(PositionGetSymbol(i)==symbol || symbol=="")
            if(PositionGetInteger(POSITION_MAGIC)==magic || magic==0)
              {
               order[count].ticket=PositionGetTicket(i);
               order[count].magic=(int)PositionGetInteger(POSITION_MAGIC);
               order[count].open=PositionGetDouble(POSITION_PRICE_OPEN);
               order[count].stop=PositionGetDouble(POSITION_SL);
               order[count].take=PositionGetDouble(POSITION_TP);
               order[count].take4_lots=PositionGetDouble(POSITION_VOLUME);
               order[count].take3_lots=0;
               order[count].take2_lots=0;
               order[count].take1_lots=CalculateLots(order[count].symbol,order[count].take4_lots,25,false);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                  order[count].take4_pip=int((order[count].take-order[count].open)/pt);
               else
                  order[count].take4_pip=int((order[count].open-order[count].take)/pt);
               order[count].take3_pip=(int)MathFloor(order[count].take4_pip*0.75);
               order[count].take2_pip=(int)MathFloor(order[count].take4_pip*0.5);
               order[count].take1_pip=(int)MathFloor(order[count].take4_pip*0.25);
               order[count].take4_waiting=true;
               order[count].take3_waiting=true;
               order[count].take2_waiting=true;
               order[count].take1_waiting=true;
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                  order[count].take4_pip=int((order[count].open-order[count].stop)/pt);
               else
                  order[count].take4_pip=int((order[count].stop-order[count].open)/pt);
               order[count].stop_pip=m_stop_pip;
               order[count].stop_lots=PositionGetDouble(POSITION_VOLUME);
               order[count].stop_waiting=true;
               order[count].symbol=PositionGetSymbol(i);
               count++;
              }
   ArrayResize(order,count);
//---
   for(int i=0; i<ArraySize(order); i++)
      for(int j=0; j<ArraySize(list); j++)
         if(order[i].ticket==list[j].ticket)
           {
            order[i].take1_waiting=list[j].take1_waiting;
            order[i].take2_waiting=list[j].take2_waiting;
            order[i].take3_waiting=list[j].take3_waiting;
            order[i].take4_waiting=list[j].take4_waiting;
            //
            if(order[i].take3_waiting)
               order[count].take3_lots=CalculateLots(order[count].symbol,order[count].take4_lots,50,false);
            if(order[i].take2_waiting)
               order[count].take2_lots=CalculateLots(order[count].symbol,order[count].take4_lots,33,true);
            if(order[i].take1_waiting)
               order[count].take1_lots=CalculateLots(order[count].symbol,order[count].take4_lots,25,false);
           }
//---
   CopyOrderInfoArray(list,order);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double  CMultiTake::CalculateLots(string symbol_name,double lots,double percent,bool ceiling=true)
  {
   double order_lots=lots*percent/100;
   double ml=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
   double ln=NormalizeDouble(order_lots,int(ceil(fabs(log(ml)/log(10)))));
   double ml2=ml;
   if(!ceiling) ml2=0.0;
   return(ln<ml ? ml2 : ln>mx ? mx : ln);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CMultiTake::CopyOrderInfoArray(order_info &dst[],order_info &src[])
  {
   ArrayResize(dst,ArraySize(src));
   for(int i=0; i<ArraySize(src); i++)
      dst[i]=src[i];
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void    CMultiTake::GetHrMinSecFromString(int &Hr1,int &Min1,int &Sec1,string hoursStr)
  {
   if(StringFind(hoursStr,":")<0)
     {
      Hr1=(int)StringToInteger(hoursStr);
      Min1=0;
      Sec1=0;
      return;
     }
//---
   char CH[];
   StringToCharArray(hoursStr,CH);
   int A_=-1,B_=-1;
   for(int i=0; i<ArraySize(CH); i++)
     {
      if(CH[i]==':' && A_>=0 && B_<0) B_=i;
      if(CH[i]==':' && A_<0 && B_<0) A_=i;
     }
//---
   Hr1=(int)StringToInteger(StringSubstr(hoursStr,0,A_));
   if(B_>=0)
     {
      Min1=(int)StringToInteger(StringSubstr(hoursStr,A_+1,B_-A_));
      Sec1=(int)StringToInteger(StringSubstr(hoursStr,B_+1,StringLen(hoursStr)));
     }
   else
     {
      Min1=(int)StringToInteger(StringSubstr(hoursStr,A_+1,StringLen(hoursStr)));
      Sec1=0;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool  CMultiTake::IsTimeCurrentInRange(string startHours,string stopHours)
  {
   datetime start,stop;
   MqlDateTime startTime,stopTime;
   int Hr,Min,Sec;
   GetHrMinSecFromString(Hr,Min,Sec,startHours);
   TimeToStruct(TimeCurrent(),startTime);
   startTime.hour=Hr;
   startTime.min=Min;
   startTime.sec=Sec;
   start=StructToTime(startTime);
   TimeToStruct(TimeCurrent(),stopTime);
   GetHrMinSecFromString(Hr,Min,Sec,stopHours);
   stopTime.hour=Hr;
   stopTime.min=Min;
   stopTime.sec=Sec;
   stop=StructToTime(stopTime);
   return(TimeCurrent()>start && TimeCurrent()<stop);
  }
//+------------------------------------------------------------------+
void CMultiTake::TrailingStop(CMyTrade *trade,string symbol,int trailing,int breakeven,int step)
  {
   for(int i=0; i<PositionsTotal(); i++)
      if(PositionSelectByTicket(PositionGetTicket(i)))
        {
         long ticket=(long)PositionGetTicket(i);
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         double tp=PositionGetDouble(POSITION_TP);
         double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            double sl=price-trailing*pt;
            if(sl-PositionGetDouble(POSITION_SL)>step*pt || PositionGetDouble(POSITION_SL)==0)
               if(PositionGetDouble(POSITION_SL)-price>breakeven*pt || breakeven==0)
                  trade.OrderModify(ticket,price,sl,tp,0,0,0);
           }
         else
           {
            double sl=price+trailing*pt;
            if(PositionGetDouble(POSITION_SL)-sl>step*pt || PositionGetDouble(POSITION_SL)==0)
               if(price-PositionGetDouble(POSITION_SL)>breakeven*pt || breakeven==0)
                  trade.OrderModify(ticket,price,sl,tp,0,0,0);
           }
        }
  }
//+------------------------------------------------------------------+
