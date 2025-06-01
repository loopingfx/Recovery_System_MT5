//+------------------------------------------------------------------+
//|                                                        Hedge.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <Object.mqh>
#include "MyTrade.mqh"
#include "RecoveryParameterGroup.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHedge : public CObject
  {
private:
   //---
   close_info        lock_list[],group_list[],restore_list[],posible_lock_list[],posible_restore_list[];
   //---
   uint              m_AdditionMagicNumber;
   uint              m_LockMagicNumber;
   uint              m_RestoreMagicNumber;
   //---
   long              m_MaxSpread;
   bool              m_IsECNBroker;
   int               m_MaxTries;
   //---
   double            m_buy_open_high;
   double            m_buy_open_low;
   double            m_sell_open_high;
   double            m_sell_open_low;
   //---
   bool              IsOrderExit(int ticket2);
   int               GetTicketFrom(string comment,string prefix="");
   void              AddLongToArray(long value,long &list[]);
   //---
   my_order_info     AllHedgeList[];
   //---
   long              myOrderSend(CMyTrade *trade,string symbol,ENUM_ORDER_TYPE order_type,double volume,
                                 double order_price,double stop_price,double take_price,
                                 string comment="");
   //---
   int               GetHedgeOrders(my_order_info &list[],int magic,string prefix);
   bool              IsHedgeOrderFound(long ord_ticket,my_order_info &hedge_order[]);
   void              CleanHedgeOrder(CMyTrade *trade,my_order_info &hedge_order[]);
   double            NormalizePrice(const string symbol,const double price);
   //---                        
   void              CleanLockOrderSLTP(CMyTrade *trade,main_recovery_and_launch_setting &setting);
   void              GetTicketByProfitSort(long &list_buy[],long &list_sell[],string symbol);
   void              GetLockedOrder(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting);
   void              GetRestoreOrder(long &ticket_buy[],long &ticket_sell[],trade_info &info);
   void              GetGroupOrder(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting);
   //---
   void              GetPosibleLock(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting);
   void              CalculateProfitForLock(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting);
   void              GrtPosibleRestore(long &ticket_buy[],long &ticket_sell[],trade_info &info);
   void              CalculateProfitForRestore(long &ticket_buy[],long &ticket_sell[],trade_info &info);
   void              DrawProfit(double value);
   void              HideSellZone(bool value);
   void              HideBuyZone(bool value);
   void              DrawBuyZone1(double price_low,double price_high);
   void              DrawSellZone1(double price_low,double price_high);
public:
   void              ProcessTradeInfo(trade_info &info,main_recovery_and_launch_setting &setting)
     {
      long ticket_buy[],ticket_sell[];
      string symbol=info.symbol;
      GetTicketByProfitSort(ticket_buy,ticket_sell,symbol);
      GetLockedOrder(ticket_buy,ticket_sell,info,setting);
      GetRestoreOrder(ticket_buy,ticket_sell,info);
      GetGroupOrder(ticket_buy,ticket_sell,info,setting);
      GetPosibleLock(ticket_buy,ticket_sell,info,setting);
      GrtPosibleRestore(ticket_buy,ticket_sell,info);
     }
   //---
   void              CloseGroup(trade_info &info,main_recovery_and_launch_setting &setting);
   void              CloseAll(trade_info &info,main_recovery_and_launch_setting &setting);
   void              ClosePosibleLock(trade_info &info,main_recovery_and_launch_setting &setting);
   void              ClosePosibleRestore(trade_info &info);
   //---
   void              SetHedgeMagicNumber(uint AdditionMagic,uint LockMagic,uint RecoveryMagic)
     {
      m_AdditionMagicNumber=AdditionMagic;
      m_LockMagicNumber=LockMagic;
      m_RecoveryMagicNumber=RecoveryMagic;
     }
   void              AddRestoringOrder(CMyTrade *trade,trade_info &info,int step);
   void              ProcessLockPosition(CMyTrade *trade,trade_info &order,main_recovery_and_launch_setting &setting);
   void              ProcessHedgeOrder(CMyTrade *trade,
                                       string symbol,
                                       int HedgeDistance,
                                       int NextHedgeDistance,
                                       int HedgeTakeDistance,
                                       bool UseDigitsPipsAdjusment,
                                       string prefix="",
                                       string infilter="",
                                       bool isECN=true);
   //---
                     CHedge():m_IsECNBroker(true),m_MaxTries(5){}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CHedge::GetHedgeOrders(my_order_info &list[],int magic,string prefix)
  {
   int count=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(OrderGetTicket(i)))
         if(OrderGetString(ORDER_SYMBOL)==Symbol()
            && (OrderGetInteger(ORDER_MAGIC)==magic || magic==0))
           {
            ArrayResize(list,count+1);
            list[count].myordertime=(datetime)OrderGetInteger(ORDER_TIME_SETUP);
            list[count].mylot=OrderGetDouble(ORDER_VOLUME_CURRENT);
            list[count].myType=OrderGetInteger(ORDER_TYPE);
            list[count].mySL=OrderGetDouble(ORDER_SL);
            list[count].myTP=OrderGetDouble(ORDER_TP);
            list[count].myOpen=OrderGetDouble(ORDER_PRICE_OPEN);
            list[count].myCommission=0.0;
            list[count].myTicket=OrderGetInteger(ORDER_TICKET);
            list[count].myComment=OrderGetString(ORDER_COMMENT);
            list[count].myTicketFrom=GetTicketFrom(OrderGetString(ORDER_COMMENT),prefix);
            count++;
           }
     }
   return (count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CHedge::GetTicketFrom(string comment,string prefix="")
  {
   int res=0;
   if(StringFind(comment,prefix)==0 || prefix=="")
     {
      if(prefix=="") res=(int)StringToInteger(comment);
      else
        {
         string text=comment;
         text=StringSubstr(text,StringLen(prefix),StringLen(text)-StringLen(prefix));
         res=(int)StringToInteger(text);
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedge::IsHedgeOrderFound(long ord_ticket,my_order_info &hedge_order[])
  {
   for(int i=0; i<ArraySize(hedge_order); i++)
      if(hedge_order[i].myTicketFrom==ord_ticket) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::CleanHedgeOrder(CMyTrade *trade,my_order_info &hedge_order[])
  {
   for(int i=0; i<ArraySize(hedge_order); i++)
     {
      int ticket2=(int) hedge_order[i].myTicketFrom;
      if(!IsOrderExit(ticket2))
        {
         if(OrderSelect(hedge_order[i].myTicket))
            if(OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP
               || OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP)
               bool res=trade.OrderDelete(hedge_order[i].myTicket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHedge::IsOrderExit(int ticket2)
  {
   if(OrderSelect(ticket2)) return(true);
   if(PositionSelectByTicket(ticket2)) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CHedge::ProcessHedgeOrder(CMyTrade *trade,
                                string symbol,
                                int HedgeDistance,
                                int NextHedgeDistance,
                                int HedgeTakeDistance,
                                bool UseDigitsPipsAdjusment,
                                string prefix="",
                                string infilter="",
                                bool isECN=true)
  {
   m_IsECNBroker=isECN;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double stoplevel=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL)*pt;
   if(UseDigitsPipsAdjusment)
     {
      if(digits==3 || digits==5) pt=pt*10;
      if(digits==2) pt=pt*100;
     }
   uint magic=(int)trade.GetExpertMagicNumber();
   int order_count=GetHedgeOrders(AllHedgeList,magic,prefix);
   CleanHedgeOrder(trade,AllHedgeList);
//---
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(PositionSelectByTicket(PositionGetTicket(i)))
        {
         if(IsHedgeOrderFound(PositionGetInteger(POSITION_TICKET),AllHedgeList))continue;
         if(PositionGetString(POSITION_COMMENT)!=infilter && infilter!="") continue;
         string comment=prefix+IntegerToString(PositionGetInteger(POSITION_TICKET));
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            double mylots=PositionGetDouble(POSITION_VOLUME);
            double myOpenPending=PositionGetDouble(POSITION_PRICE_OPEN)-HedgeDistance*pt;
            myOpenPending=NormalizePrice(symbol,MathMin(myOpenPending,bid-stoplevel));
            double hedgeTP=NormalizePrice(symbol,myOpenPending-HedgeTakeDistance*pt);
            if(HedgeTakeDistance==0) hedgeTP=0;
            //--
            long ticket=myOrderSend(trade,symbol,ORDER_TYPE_SELL_STOP,mylots,myOpenPending,0,hedgeTP,comment);
            if(ticket>0)
              {
               Print(TimeToString(iTime(symbol,0,0))+" "+comment+" SELL HEDGE at "+DoubleToString(myOpenPending,digits)+
                     " Lots="+DoubleToString(mylots,2));
              }
           }
         //---
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            double mylots=PositionGetDouble(POSITION_VOLUME);
            double myOpenPending=PositionGetDouble(POSITION_PRICE_OPEN)+HedgeDistance*pt;
            myOpenPending=NormalizePrice(symbol,MathMax(myOpenPending,ask+stoplevel));
            double hedgeTP=NormalizePrice(symbol,myOpenPending+HedgeTakeDistance*pt);
            if(HedgeTakeDistance==0) hedgeTP=0;
            //---
            long ticket=myOrderSend(trade,symbol,ORDER_TYPE_BUY_STOP,mylots,myOpenPending,0,hedgeTP,comment);
            if(ticket>0)
              {
               Print(TimeToString(iTime(symbol,0,0))+" "+comment+" BUY HEDGE at "+DoubleToString(myOpenPending,digits)+
                     " Lots="+DoubleToString(mylots,2));
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CHedge::myOrderSend(CMyTrade *trade,string symbol,ENUM_ORDER_TYPE order_type,double volume,
                         double order_price,double stop_price,double take_price,
                         string comment="")
  {
//---
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double stoplevel=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL)*pt;
   double open_price=order_price;
   double SL=stop_price;
   double TP=take_price;
//---
   color Clr=0;
   if(m_IsECNBroker){SL=0;TP=0;}
//--
   if(order_type==ORDER_TYPE_BUY)  open_price=ask;
   if(order_type==ORDER_TYPE_SELL) open_price=bid;
//---
   if(order_type==ORDER_TYPE_BUY || order_type==ORDER_TYPE_BUY_STOP)
     {
      Clr=clrBlue;
      if(TP!=0 && TP-open_price<stoplevel)
         TP=open_price+(stoplevel+pt);
      if(SL!=0 && open_price-SL<stoplevel)
         SL=open_price-(stoplevel+pt);
     }
//---
   if(order_type==ORDER_TYPE_SELL || order_type==ORDER_TYPE_SELL_STOP)
     {
      Clr=clrRed;
      if(TP!=0 && open_price-TP<stoplevel)
         TP=open_price-(stoplevel+pt);
      if(SL!=0 && SL-open_price<stoplevel)
         SL=open_price+(stoplevel+pt);
     }
//---
   long ticket=-1;
   for(int i=0; i<m_MaxTries; i++)
     {
      if(SymbolInfoInteger(symbol,SYMBOL_SPREAD)*pt>m_MaxSpread*pt) continue;
      if(SL<=0) SL=0;
      //---
      if(order_type==ORDER_TYPE_BUY_STOP || order_type==ORDER_TYPE_SELL_STOP)
        {
         trade.OrderOpen(symbol,order_type,volume,0,open_price,SL,TP,0,0,comment);
         if(trade.CheckResultRetcode()==TRADE_RETCODE_PLACED)
           {
            ticket=(long)trade.ResultOrder();
            return(ticket);
           }
        }
      //---
      if(order_type==ORDER_TYPE_BUY || order_type==ORDER_TYPE_SELL)
        {
         trade.PositionOpen(symbol,order_type,volume,open_price,SL,TP,comment);
         if(trade.CheckResultRetcode()==TRADE_RETCODE_PLACED)
           {
            ticket=(long)trade.ResultOrder();
            if(m_IsECNBroker)
              {
               if(PositionSelectByTicket(ticket))
                  if(PositionGetDouble(POSITION_TP)==0 && PositionGetDouble(POSITION_SL)==0)
                    {
                     for(int j=0; j<m_MaxTries; j++)
                       {
                        trade.PositionModify(ticket,SL,TP);
                        if(trade.ResultRetcode()==TRADE_RETCODE_ORDER_CHANGED)
                           return(ticket);
                        Sleep(1000);
                       }
                    }
              }
            else
               return(ticket);
           }
        }
      //---
      Sleep(1000);
     }
   return (ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   CHedge::NormalizePrice(const string symbol,const double price)
  {
   long tmp;
   double tick_size;
   int digits;
   if(!SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE,tick_size))
      return(false);
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,tmp))
      return(false);
   digits=(int)tmp;
   if(tick_size!=0)
      return(NormalizeDouble(MathRound(price/tick_size)*tick_size,digits));
//---
   return(NormalizeDouble(price,digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge:: ProcessLockPosition(CMyTrade *trade,trade_info &info,main_recovery_and_launch_setting &setting)
  {
   long ticket_buy[],ticket_sell[];
   string symbol=info.symbol;
   GetTicketByProfitSort(ticket_buy,ticket_sell,symbol);
   GetLockedOrder(ticket_buy,ticket_sell,info,setting);
//---
   if(info.lock_buy_volume==info.lock_sell_volume) return;
   CleanLockOrderSLTP(trade,setting);
//
   if((info.lock_buy_volume-info.lock_sell_volume)>=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN))
     {
      trade.Sell((info.lock_buy_volume-info.lock_sell_volume),info.symbol,0,0,0,"L");
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
        {
         long ticket=(long)trade.ResultOrder();
         if(PositionSelectByTicket(ticket))
           {
            info.symbol=PositionGetString(POSITION_SYMBOL);
            info.open_high=info.open_low=PositionGetDouble(POSITION_PRICE_OPEN);
           }
        }
      Sleep(2000);
     }
//---
   if((info.lock_sell_volume-info.lock_buy_volume)>=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN))
     {
      trade.Buy((info.lock_sell_volume-info.lock_buy_volume),info.symbol,0,0,0,"L");
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
        {
         long ticket=(long)trade.ResultOrder();
         if(PositionSelectByTicket(ticket))
           {
            info.symbol=PositionGetString(POSITION_SYMBOL);
            info.open_high=info.open_low=PositionGetDouble(POSITION_PRICE_OPEN);

           }
        }
      Sleep(2000);
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::GetTicketByProfitSort(long &list_buy[],long &list_sell[],string symbol)
  {
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   int total=PositionsTotal();
   struct order_price_ticket
     {
      double            profit;
      long              ticket;
     };
//---
   double price_buy[],price_sell[];
   double profit_buy[],profit_sell[];
   order_price_ticket order_buy[],order_sell[];
//---
   ArrayResize(price_buy,total,10);
   ArrayResize(price_sell,total,10);
   ArrayResize(profit_buy,total,10);
   ArrayResize(profit_sell,total,10);
   ArrayResize(order_buy,total,10);
   ArrayResize(order_sell,total,10);
   int count_buy=0,count_sell=0;
   for(int i=0; i<total; i++)
     {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetSymbol(i)==symbol || symbol=="")
        {
         //---
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            price_buy[count_buy]=PositionGetDouble(POSITION_PRICE_OPEN);
            profit_buy[count_buy]=order_buy[count_buy].profit=PositionGetDouble(POSITION_PROFIT);
            order_buy[count_buy].ticket=(long)PositionGetTicket(i);
            count_buy++;
           }
         //---
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
            price_sell[count_sell]=PositionGetDouble(POSITION_PRICE_OPEN);
            profit_sell[count_sell]=order_sell[count_sell].profit=PositionGetDouble(POSITION_PROFIT);
            order_sell[count_sell].ticket=(long)PositionGetTicket(i);
            count_sell++;
           }
        }
     }
//---
   ArrayResize(price_buy,count_buy);
   ArrayResize(price_sell,count_sell);
   ArrayResize(profit_buy,count_buy);
   ArrayResize(profit_sell,count_sell);
   ArrayResize(order_buy,count_buy);
   ArrayResize(order_sell,count_sell);
   ArraySort(profit_buy);
   ArraySort(profit_sell);
//---
   ArrayFree(list_buy);
   for(int i=count_buy-1; i>=0; i--)
      for(int j=0; j<count_buy; j++)
         if(profit_buy[i]==order_buy[j].profit)
            AddLongToArray(order_buy[j].ticket,list_buy);
//---
   if(count_buy>0)
     {
      m_buy_open_low=price_buy[ArrayMinimum(price_buy)];
      m_buy_open_high=price_buy[ArrayMaximum(price_buy)];
      DrawBuyZone1(m_buy_open_low,m_buy_open_high);
    //  HideBuyZone1(false);
     }
   else
     {
      m_buy_open_low=bid;
      m_buy_open_high=ask;
     // HideBuyZone1(true);
     }
//---
   ArrayFree(list_sell);
   for(int i=count_sell-1; i>=0; i--)
      for(int j=0; j<count_sell; j++)
         if(profit_sell[i]==order_sell[j].profit)
            AddLongToArray(order_sell[j].ticket,list_sell);
//---
   if(count_sell>0)
     {
      m_sell_open_low=price_sell[ArrayMinimum(price_sell)];
      m_sell_open_high=price_sell[ArrayMaximum(price_sell)];
      DrawSellZone1(m_sell_open_low,m_sell_open_high);
     // HideSellZone(false);
     }
   else
     {
      m_sell_open_low=bid;
      m_sell_open_high=ask;
      HideSellZone(true);
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::GetLockedOrder(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting)
  {
   info.lock_buy_count=0;
   info.lock_sell_count=0;
   info.lock_buy_volume=0;
   info.lock_sell_volume=0;
   info.lock_buy_profit=0;
   info.lock_sell_profit=0;
   ArrayFree(lock_list);
   int lock_count=0;
   switch(setting.group_of_orders_for)
     {
      case All_orders_of_current_symbol:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               info.lock_buy_count++;
               info.lock_buy_volume+=PositionGetDouble(POSITION_VOLUME);
               info.lock_buy_profit+=PositionGetDouble(POSITION_PROFIT);
               ArrayResize(lock_list,lock_count+1);
               lock_list[lock_count].ticket=ticket_buy[i];
               lock_list[lock_count].volume=PositionGetDouble(POSITION_VOLUME);
               lock_count++;
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            //---
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               info.lock_sell_count++;
               info.lock_sell_volume+=PositionGetDouble(POSITION_VOLUME);
               info.lock_sell_profit+=PositionGetDouble(POSITION_PROFIT);
               ArrayResize(lock_list,lock_count+1);
               lock_list[lock_count].ticket=ticket_sell[i];
               lock_list[lock_count].volume=PositionGetDouble(POSITION_VOLUME);
               lock_count++;
              }
           }
         break;
      case Manual_orders_of_the_current_synbol:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)==0
               ||PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  info.lock_buy_count++;
                  info.lock_buy_volume+=PositionGetDouble(POSITION_VOLUME);
                  info.lock_buy_profit+=PositionGetDouble(POSITION_PROFIT);
                  ArrayResize(lock_list,lock_count+1);
                  lock_list[lock_count].ticket=ticket_buy[i];
                  lock_list[lock_count].volume=PositionGetDouble(POSITION_VOLUME);
                  lock_count++;
                 }
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)==0
               ||PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  info.lock_sell_count++;
                  info.lock_sell_volume+=PositionGetDouble(POSITION_VOLUME);
                  info.lock_sell_profit+=PositionGetDouble(POSITION_PROFIT);
                  ArrayResize(lock_list,lock_count+1);
                  lock_list[lock_count].ticket=ticket_sell[i];
                  lock_list[lock_count].volume=PositionGetDouble(POSITION_VOLUME);
                  lock_count++;
                 }
              }
           }
         break;
      case Orders_of_the_current_symbol_with_same_magicnumber:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  info.lock_buy_count++;
                  info.lock_buy_volume+=PositionGetDouble(POSITION_VOLUME);
                  info.lock_buy_profit+=PositionGetDouble(POSITION_PROFIT);
                  ArrayResize(lock_list,lock_count+1);
                  lock_list[lock_count].ticket=ticket_buy[i];
                  lock_list[lock_count].volume=PositionGetDouble(POSITION_VOLUME);
                  lock_count++;
                 }
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  info.lock_sell_count++;
                  info.lock_sell_volume+=PositionGetDouble(POSITION_VOLUME);
                  info.lock_sell_profit+=PositionGetDouble(POSITION_PROFIT);
                  ArrayResize(lock_list,lock_count+1);
                  lock_list[lock_count].ticket=ticket_sell[i];
                  lock_list[lock_count].volume=PositionGetDouble(POSITION_VOLUME);
                  lock_count++;
                 }
              }
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::GetGroupOrder(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting)
  {
   double used_buy_lots=MathMin(info.restore_volume_set,info.lock_buy_volume);
   double used_sell_lots=MathMin(info.restore_volume_set,info.lock_sell_volume);
   info.group_buy_volume=0;
   info.group_sell_volume=0;
   info.group_buy_profit=0;
   info.group_sell_profit=0;
   ArrayFree(group_list);
   int group_count=0;
   switch(setting.group_of_orders_for)
     {
      case All_orders_of_current_symbol:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            double pos_lots=PositionGetDouble(POSITION_VOLUME);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               double get_lots=MathMin(used_buy_lots,pos_lots);
               if(pos_lots>0 && get_lots>0)
                 {
                  info.group_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                  ArrayResize(group_list,group_count+1);
                  group_list[group_count].ticket=ticket_buy[i];
                  group_list[group_count].volume=get_lots;
                  group_count++;
                 }
               used_buy_lots-=get_lots;
               info.group_buy_volume+=get_lots;
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            double pos_lots=PositionGetDouble(POSITION_VOLUME);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               double get_lots=MathMin(used_sell_lots,pos_lots);
               if(pos_lots>0 && get_lots>0)
                 {
                  info.group_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                  ArrayResize(group_list,group_count+1);
                  group_list[group_count].ticket=ticket_sell[i];
                  group_list[group_count].volume=get_lots;
                  group_count++;
                 }
               used_sell_lots-=get_lots;
               info.group_sell_volume+=get_lots;
              }
           }
         break;
      case Manual_orders_of_the_current_synbol:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)==0
               ||PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  double get_lots=MathMin(used_buy_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.group_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(group_list,group_count+1);
                     group_list[group_count].ticket=ticket_buy[i];
                     group_list[group_count].volume=get_lots;
                     group_count++;
                    }
                  used_buy_lots-=get_lots;
                  info.group_buy_volume+=get_lots;
                 }
              }
           }
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)==0
               ||PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  double get_lots=MathMin(used_sell_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.group_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(group_list,group_count+1);
                     group_list[group_count].ticket=ticket_sell[i];
                     group_list[group_count].volume=get_lots;
                     group_count++;
                    }
                  used_sell_lots-=get_lots;
                  info.group_sell_volume+=get_lots;
                 }
              }
           }
         break;
      case Orders_of_the_current_symbol_with_same_magicnumber:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  double get_lots=MathMin(used_buy_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.group_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(group_list,group_count+1);
                     group_list[group_count].ticket=ticket_buy[i];
                     group_list[group_count].volume=get_lots;
                     group_count++;
                    }
                  used_buy_lots-=get_lots;
                  info.group_buy_volume+=get_lots;
                 }
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  double get_lots=MathMin(used_sell_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.group_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(group_list,group_count+1);
                     group_list[group_count].ticket=ticket_sell[i];
                     group_list[group_count].volume=get_lots;
                     group_count++;
                    }
                  used_sell_lots-=get_lots;
                  info.group_sell_volume+=get_lots;
                 }
              }
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::CleanLockOrderSLTP(CMyTrade *trade,main_recovery_and_launch_setting &setting)
  {
   switch(setting.group_of_orders_for)
     {
       //    All_orders_of_current_symbol,
     // Manual_orders_of_the_current_synbol,
     // Orders_of_the_current_symbol_with_same_magicnumber
      case All_orders_of_current_symbol:
         for(int i=0; i<PositionsTotal(); i++)
           {
            if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetDouble(POSITION_SL)!=0 || PositionGetDouble(POSITION_TP)!=0)
               trade.PositionModify(PositionGetTicket(i),0,0);
           }
         break;
      case Manual_orders_of_the_current_synbol:
         for(int i=0; i<PositionsTotal(); i++)
           {
            if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
            if(PositionGetInteger(POSITION_MAGIC)!=m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)!=0
               ||PositionGetInteger(POSITION_MAGIC)!=m_LockMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetDouble(POSITION_SL)!=0 || PositionGetDouble(POSITION_TP)!=0)
               trade.PositionModify(PositionGetTicket(i),0,0);
           }
         break;
      case Orders_of_the_current_symbol_with_same_magicnumber:
         for(int i=0; i<PositionsTotal(); i++)
           {
            if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
            if(PositionGetInteger(POSITION_MAGIC)!=m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)!=m_LockMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetDouble(POSITION_SL)!=0 || PositionGetDouble(POSITION_TP)!=0)
               trade.PositionModify(PositionGetTicket(i),0,0);
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CHedge::AddRestoringOrder(CMyTrade *trade,trade_info &info,int step)
  {
   if(info.open_high==0 || info.open_low==0) return;
//---
   string symbol=info.symbol;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double stoplevel=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL)*pt;
   if(pt==0) return;
//---
   int loss_market_point=0;
   int gain_market_point=0;
   if(info.type==ORDER_TYPE_BUY)
     {
      loss_market_point=(int)MathFloor((info.open_low-ask)/pt);
      gain_market_point=(int)MathFloor((ask-info.open_high)/pt);
      double lots=info.volume;
      if((loss_market_point>0 && loss_market_point>step)
         || (gain_market_point>0 && gain_market_point>step))
        {
         trade.Buy(lots,symbol,0,0,0,"RS");
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            long ticket=(long)trade.ResultOrder();
            if(PositionSelectByTicket(ticket))
              {
               double open=PositionGetDouble(POSITION_PRICE_OPEN);
               info.open_high=MathMax(open,info.open_high);
               info.open_low=MathMin(open,info.open_low);
               info.volume=PositionGetDouble(POSITION_VOLUME);
              }
           }
        }
     }
   else
     {
      loss_market_point=(int)MathFloor((bid-info.open_high)/pt);
      gain_market_point=(int)MathFloor((info.open_low-bid)/pt);
      double lots=info.volume;
      if((loss_market_point>0 && loss_market_point>step)
         || (gain_market_point>0 && gain_market_point>step))
        {
         trade.Sell(lots,symbol,0,0,0,"RS");
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            long ticket=(long)trade.ResultOrder();
            if(PositionSelectByTicket(ticket))
              {
               double open=PositionGetDouble(POSITION_PRICE_OPEN);
               info.open_high=MathMax(open,info.open_high);
               info.open_low=MathMin(open,info.open_low);
               info.volume=PositionGetDouble(POSITION_VOLUME);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::GetPosibleLock(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting)
  {
   info.posible_lock_buy_volume=0;
   info.posible_lock_sell_volume=0;
   info.posible_lock_buy_profit=0;
   info.posible_lock_sell_profit=0;
   ArrayFree(posible_lock_list);
//---
   if(info.lock_buy_volume==0 || info.lock_sell_volume==0) return;
   if(info.lock_buy_volume!=info.lock_sell_volume) return;
   if(info.lock_buy_volume<2*info.restore_volume_set) return;
//---
   double minimum_lots=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN);
//---
   for(int i=0; i<2000; i++)
     {
      //--- adjust lot sell
      if(info.lock_buy_profit>info.lock_sell_profit)
        {
         //-- try down sell lots
         //   info.posible_lock_buy_profit=info.lock_buy_profit;
         info.posible_lock_buy_volume=info.lock_buy_volume;
         info.posible_lock_sell_volume=info.lock_sell_volume-(i+1)*minimum_lots;
         if(info.posible_lock_sell_volume<=0) break;
         CalculateProfitForLock(ticket_buy,ticket_sell,info,setting);
        }
      //--- adjust lot buy
      if(info.lock_sell_profit>info.lock_buy_profit)
        {
         //-- try down buy lot 
         // info.posible_lock_sell_profit=info.lock_sell_profit;
         info.posible_lock_sell_volume=info.lock_sell_volume;
         info.posible_lock_buy_volume=info.lock_buy_volume-(i+1)*minimum_lots;
         if(info.posible_lock_buy_volume<=0) break;
         CalculateProfitForLock(ticket_buy,ticket_sell,info,setting);
        }
      if((info.posible_lock_sell_profit+info.posible_lock_buy_profit)>0
         && info.posible_lock_buy_volume>info.restore_volume_set
         && info.posible_lock_sell_volume>info.restore_volume_set) return;
     }
   info.posible_lock_buy_volume=0;
   info.posible_lock_sell_volume=0;
   info.posible_lock_buy_profit=0;
   info.posible_lock_sell_profit=0;
   ArrayFree(posible_lock_list);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::GrtPosibleRestore(long &ticket_buy[],long &ticket_sell[],trade_info &info)
  {
//---
   info.posible_restore_buy_volume=0;
   info.posible_restore_sell_volume=0;
   info.posible_restore_buy_profit=0;
   info.posible_restore_sell_profit=0;
   ArrayFree(posible_restore_list);
//---
   if(info.restore_buy_volume>info.restore_sell_volume)
     {
      //---
      double delta_lots=info.restore_buy_volume-info.restore_sell_volume;
      info.posible_restore_buy_volume=delta_lots;
      info.posible_restore_sell_volume=0;
      CalculateProfitForRestore(ticket_buy,ticket_sell,info);
     }
   else
   if(info.restore_sell_volume>info.restore_buy_volume)
     {
      //---
      double delta_lots=info.restore_sell_volume-info.restore_buy_volume;
      info.posible_restore_sell_volume=delta_lots;
      info.posible_restore_buy_volume=0;
      CalculateProfitForRestore(ticket_buy,ticket_sell,info);
     }
//---
   if((info.restore_buy_profit+info.restore_sell_profit)>0)
     {
      info.posible_restore_buy_volume=info.restore_buy_volume;
      info.posible_restore_sell_volume=info.restore_sell_volume;
      CalculateProfitForRestore(ticket_buy,ticket_sell,info);
      //---
     }
//---
   if((info.posible_restore_buy_profit+info.posible_restore_sell_profit)>0) return;
//---
   info.posible_restore_buy_volume=0;
   info.posible_restore_sell_volume=0;
   info.posible_restore_buy_profit=0;
   info.posible_restore_sell_profit=0;
   ArrayFree(posible_restore_list);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::GetRestoreOrder(long &ticket_buy[],long &ticket_sell[],trade_info &info)
  {
   info.restore_buy_volume=0;
   info.restore_sell_volume=0;
   info.restore_buy_profit=0;
   info.restore_sell_profit=0;
   ArrayFree(restore_list);
//---
   int restore_count=0;
   for(int i=0; i<ArraySize(ticket_buy); i++)
     {
      if(!PositionSelectByTicket(ticket_buy[i])) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=m_RecoveryMagicNumber) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         info.restore_buy_volume+=PositionGetDouble(POSITION_VOLUME);
         info.restore_buy_profit+=PositionGetDouble(POSITION_PROFIT);
         ArrayResize(restore_list,restore_count+1);
         restore_list[restore_count].ticket=ticket_buy[i];
         restore_list[restore_count].volume=PositionGetDouble(POSITION_VOLUME);
         restore_count++;
        }
     }
//---
   for(int i=0; i<ArraySize(ticket_sell); i++)
     {
      if(!PositionSelectByTicket(ticket_sell[i])) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=m_RecoveryMagicNumber) continue;
      //---
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         info.restore_sell_volume+=PositionGetDouble(POSITION_VOLUME);
         info.restore_sell_profit+=PositionGetDouble(POSITION_PROFIT);
         ArrayResize(restore_list,restore_count+1);
         restore_list[restore_count].ticket=ticket_sell[i];
         restore_list[restore_count].volume=PositionGetDouble(POSITION_VOLUME);
         restore_count++;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::CloseGroup(trade_info &info,main_recovery_and_launch_setting &setting)
  {
   CMyTrade trade;
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double expert_profit=info.group_buy_profit+info.group_sell_profit+
                        info.restore_buy_profit+info.restore_sell_profit;
//---
   for(int i=0; i<ArraySize(restore_list); i++)
      trade.PositionClosePartial(restore_list[i].ticket,restore_list[i].volume);
   for(int i=0; i<ArraySize(group_list); i++)
      trade.PositionClosePartial(group_list[i].ticket,group_list[i].volume);
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   Print("CloseGroup for target= ",NormalizeDouble(expert_profit,2),
         " add balance profit= ",NormalizeDouble(profit,2));
   DrawProfit(profit);
//---
   info.open_high=SymbolInfoDouble(info.symbol,SYMBOL_ASK);
   info.open_low=SymbolInfoDouble(info.symbol,SYMBOL_BID);
   info.volume=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::CloseAll(trade_info &info,main_recovery_and_launch_setting &setting)
  {
   CMyTrade trade;
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double expert_profit=info.lock_buy_profit+info.lock_sell_profit+
                        info.restore_buy_profit+info.restore_sell_profit;
//---
   for(int i=0; i<ArraySize(restore_list); i++)
      trade.PositionClosePartial(restore_list[i].ticket,restore_list[i].volume);
   for(int i=0; i<ArraySize(lock_list); i++)
      trade.PositionClosePartial(lock_list[i].ticket,lock_list[i].volume);
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   Print("CloseAll for target= ",NormalizeDouble(expert_profit,2),
         " add balance profit= ",NormalizeDouble(profit,2));
   DrawProfit(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::ClosePosibleLock(trade_info &info,main_recovery_and_launch_setting &setting)
  {
   CMyTrade trade;
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double expert_profit=info.posible_lock_buy_profit+info.posible_lock_sell_profit;
//---
   for(int i=0; i<ArraySize(posible_lock_list); i++)
      trade.PositionClosePartial(posible_lock_list[i].ticket,posible_lock_list[i].volume);
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   Print("ClosePosibleLock for target= ",NormalizeDouble(expert_profit,2),
         " add balance profit= ",NormalizeDouble(profit,2));
   DrawProfit(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::ClosePosibleRestore(trade_info &info)
  {
   CMyTrade trade;
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double expert_profit=info.posible_restore_buy_profit+info.posible_restore_sell_profit;
//---
   for(int i=0; i<ArraySize(posible_restore_list); i++)
      trade.PositionClosePartial(posible_restore_list[i].ticket,posible_restore_list[i].volume);
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   Print("ClosePosibleRestore for target= ",NormalizeDouble(expert_profit,2),
         " add balance profit= ",NormalizeDouble(profit,2));
   DrawProfit(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHedge::DrawProfit(double value)
  {
   static int counter=200;
   string curr=AccountInfoString(ACCOUNT_CURRENCY);
   counter++;
   string obj_name="profit_"+string(counter);
   ObjectCreate(0,obj_name,OBJ_TEXT,0,iTime(ChartSymbol(),
                PERIOD_CURRENT,0),SymbolInfoDouble(ChartSymbol(),SYMBOL_ASK));
   ObjectSetString(0,obj_name,OBJPROP_TEXT," "+curr+" "+DoubleToString(value,2));
   ObjectSetInteger(0,obj_name,OBJPROP_COLOR,clrYellow);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::CalculateProfitForLock(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting)
  {
   double used_buy_lots=info.posible_lock_buy_volume;
   double used_sell_lots=info.posible_lock_sell_volume;
//---
   info.posible_lock_buy_profit=0;
   info.posible_lock_sell_profit=0;
   info.posible_lock_buy_volume=0;
   info.posible_lock_sell_volume=0;
   ArrayFree(posible_lock_list);
   int posible_lock_count=0;
   switch(setting.group_of_orders_for)
     {
      case All_orders_of_current_symbol:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            double pos_lots=PositionGetDouble(POSITION_VOLUME);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               double get_lots=MathMin(used_buy_lots,pos_lots);
               if(pos_lots>0 && get_lots>0)
                 {
                  info.posible_lock_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                  ArrayResize(posible_lock_list,posible_lock_count+1);
                  posible_lock_list[posible_lock_count].ticket=ticket_buy[i];
                  posible_lock_list[posible_lock_count].volume=get_lots;
                  posible_lock_count++;
                 }
               used_buy_lots-=get_lots;
               info.posible_lock_buy_volume+=get_lots;
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            double pos_lots=PositionGetDouble(POSITION_VOLUME);
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               double get_lots=MathMin(used_sell_lots,pos_lots);
               if(pos_lots>0 && get_lots>0)
                 {
                  info.posible_lock_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                  ArrayResize(posible_lock_list,posible_lock_count+1);
                  posible_lock_list[posible_lock_count].ticket=ticket_sell[i];
                  posible_lock_list[posible_lock_count].volume=get_lots;
                  posible_lock_count++;
                 }
               used_sell_lots-=get_lots;
               info.posible_lock_sell_volume+=get_lots;
              }
           }
         break;
      case Manual_orders_of_the_current_synbol:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)==0
               ||PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  double get_lots=MathMin(used_buy_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.posible_lock_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(posible_lock_list,posible_lock_count+1);
                     posible_lock_list[posible_lock_count].ticket=ticket_buy[i];
                     posible_lock_list[posible_lock_count].volume=get_lots;
                     posible_lock_count++;
                    }
                  used_buy_lots-=get_lots;
                  info.posible_lock_buy_volume+=get_lots;
                 }
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               ||PositionGetInteger(POSITION_MAGIC)==0
               ||PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  double get_lots=MathMin(used_sell_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.posible_lock_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(posible_lock_list,posible_lock_count+1);
                     posible_lock_list[posible_lock_count].ticket=ticket_sell[i];
                     posible_lock_list[posible_lock_count].volume=get_lots;
                     posible_lock_count++;
                    }
                  used_sell_lots-=get_lots;
                  info.posible_lock_sell_volume+=get_lots;
                 }
              }
           }
         break;
      case Orders_of_the_current_symbol_with_same_magicnumber:
         for(int i=0; i<ArraySize(ticket_buy); i++)
           {
            if(!PositionSelectByTicket(ticket_buy[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
                 {
                  double get_lots=MathMin(used_buy_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.posible_lock_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(posible_lock_list,posible_lock_count+1);
                     posible_lock_list[posible_lock_count].ticket=ticket_buy[i];
                     posible_lock_list[posible_lock_count].volume=get_lots;
                     posible_lock_count++;
                    }
                  used_buy_lots-=get_lots;
                  info.posible_lock_buy_volume+=get_lots;
                 }
              }
           }
         //---
         for(int i=0; i<ArraySize(ticket_sell); i++)
           {
            if(!PositionSelectByTicket(ticket_sell[i])) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_RecoveryMagicNumber) continue;
            if(PositionGetInteger(POSITION_MAGIC)==m_AdditionMagicNumber
               || PositionGetInteger(POSITION_MAGIC)==m_LockMagicNumber)
              {
               double pos_lots=PositionGetDouble(POSITION_VOLUME);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
                 {
                  double get_lots=MathMin(used_sell_lots,pos_lots);
                  if(pos_lots>0 && get_lots>0)
                    {
                     info.posible_lock_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
                     ArrayResize(posible_lock_list,posible_lock_count+1);
                     posible_lock_list[posible_lock_count].ticket=ticket_sell[i];
                     posible_lock_list[posible_lock_count].volume=get_lots;
                     posible_lock_count++;
                    }
                  used_sell_lots-=get_lots;
                  info.posible_lock_sell_volume+=get_lots;
                 }
              }
           }
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::CalculateProfitForRestore(long &ticket_buy[],long &ticket_sell[],trade_info &info)
  {
   double used_buy_lots=info.posible_restore_buy_volume;
   double used_sell_lots=info.posible_restore_sell_volume;
//---
   info.posible_restore_buy_profit=0;
   info.posible_restore_sell_profit=0;
   info.posible_restore_buy_volume=0;
   info.posible_restore_sell_volume=0;
   ArrayFree(posible_restore_list);
   int posible_restore_count=0;
//---
   for(int i=0; i<ArraySize(ticket_buy); i++)
     {
      if(!PositionSelectByTicket(ticket_buy[i])) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=m_RecoveryMagicNumber) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double get_lots=MathMin(used_buy_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.posible_restore_buy_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
            ArrayResize(posible_restore_list,posible_restore_count+1);
            posible_restore_list[posible_restore_count].ticket=ticket_buy[i];
            posible_restore_list[posible_restore_count].volume=get_lots;
            posible_restore_count++;
           }
         used_buy_lots-=get_lots;
         info.posible_restore_buy_volume+=get_lots;
        }
     }
//---
   for(int i=0; i<ArraySize(ticket_sell); i++)
     {
      if(!PositionSelectByTicket(ticket_sell[i])) continue;
      if(PositionGetInteger(POSITION_MAGIC)!=m_RecoveryMagicNumber) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double get_lots=MathMin(used_sell_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.posible_restore_sell_profit+=PositionGetDouble(POSITION_PROFIT)*get_lots/pos_lots;
            ArrayResize(posible_restore_list,posible_restore_count+1);
            posible_restore_list[posible_restore_count].ticket=ticket_sell[i];
            posible_restore_list[posible_restore_count].volume=get_lots;
            posible_restore_count++;
           }
         used_sell_lots-=get_lots;
         info.posible_restore_sell_volume+=get_lots;
        }
     }
  }
//+------------------------------------------------------------------+
void   CHedge::AddLongToArray(long value,long &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return;
   int size=ArraySize(list); ArrayResize(list,size+1); list[size]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::DrawSellZone1(double price_low,double price_high)
  {
   string obj_name_high="sellzone_high";
   string obj_name_low="sellzone_low";
   ObjectCreate(0,obj_name_low,OBJ_HLINE,0,iTime(ChartSymbol(),PERIOD_CURRENT,0),price_low);
   ObjectCreate(0,obj_name_high,OBJ_HLINE,0,iTime(ChartSymbol(),PERIOD_CURRENT,0),price_high);
//---
   ObjectSetDouble(0,obj_name_high,OBJPROP_PRICE,price_high);
   ObjectSetDouble(0,obj_name_low,OBJPROP_PRICE,price_low);
   ObjectSetInteger(0,obj_name_high,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,obj_name_low,OBJPROP_COLOR,clrRed);
   ObjectSetInteger(0,obj_name_high,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,obj_name_low,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,obj_name_high,OBJPROP_WIDTH,3);
   ObjectSetInteger(0,obj_name_low,OBJPROP_WIDTH,3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::DrawBuyZone1(double price_low,double price_high)
  {
   string obj_name_high="buyzone_high";
   string obj_name_low="buyzone_low";
   ObjectCreate(0,obj_name_low,OBJ_HLINE,0,iTime(ChartSymbol(),PERIOD_CURRENT,0),price_low);
   ObjectCreate(0,obj_name_high,OBJ_HLINE,0,iTime(ChartSymbol(),PERIOD_CURRENT,0),price_high);
//---
   ObjectSetDouble(0,obj_name_high,OBJPROP_PRICE,price_high);
   ObjectSetDouble(0,obj_name_low,OBJPROP_PRICE,price_low);
   ObjectSetInteger(0,obj_name_high,OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,obj_name_low,OBJPROP_COLOR,clrGreen);
   ObjectSetInteger(0,obj_name_high,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,obj_name_low,OBJPROP_STYLE,STYLE_DOT);
   ObjectSetInteger(0,obj_name_high,OBJPROP_WIDTH,3);
   ObjectSetInteger(0,obj_name_low,OBJPROP_WIDTH,3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::HideBuyZone(bool value)
  {
   string obj_name_high="buyzone_high";
   string obj_name_low="buyzone_low";
//---
   ObjectSetInteger(0,obj_name_high,OBJPROP_HIDDEN,value);
   ObjectSetInteger(0,obj_name_low,OBJPROP_HIDDEN,value);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CHedge::HideSellZone(bool value)
  {
   string obj_name_high="sellzone_high";
   string obj_name_low="sellzone_low";
//---
   ObjectSetInteger(0,obj_name_high,OBJPROP_HIDDEN,value);
   ObjectSetInteger(0,obj_name_low,OBJPROP_HIDDEN,value);
  }
//+------------------------------------------------------------------+
