//+------------------------------------------------------------------+
//|                                                  PatialClose.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <multitake\MyTrade.mqh>
#include "RecoveryParameterGroup.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPatialClose
  {
   struct partial_close_format
     {
      double            profit_require;
      double            part_lots;
      double            minimum_part_lots;
      double            maximum_part_lots;
    //  start_profit_from start_option;
     };
   struct profit_ticket
     {
      double            price;
      long              ticket;
     };
private:
   double            SellZoneStartPrice;
   double            BuyZoneStartPrice;
   //---
   void              AddLongToArray(long value,long &list[]);
   void              AddDoubleToArray(double value,double &list[]);
   void              SetPriceTicketValue(profit_ticket &value,profit_ticket &list[]);
   bool              IsLongInArray(long value,long &list[]);
   bool              IsDoubleInArray(double value,double &list[]);
   bool              IsProfitTicketInArray(profit_ticket &value,profit_ticket &list[]);
   //---
   void              SortOrderByFar(long &ticket[]);
   void              SortOrderByNear(long &ticket[]);
   void              SortOrderByProfit(long &ticket[],bool no_loss);
   void              SortOrderByLoss(long &ticket[]);
   void              SelectTicketByMagicNumber(long &selected_ticket[],int magic);
   void              SetZonePrice_buyHIGH_sellLOW(long &ticket[]);
   void              SetZonePrice_buyLOW_sellHIGH(long &ticket[]);
   //---
   double CPatialClose::NormalizeLot(const string symbol_name,double order_lots);
   
public:
   bool              ClosePartByProfitToBalance(trade_info &info,long &ticket[],double new_balance);
   bool              ClosePartByProfitForLots(trade_info &info,long &ticket[],double buy_lots,double sell_lots);
   bool              ClosePartByNearForLots(trade_info &info,long &ticket[],double buy_lots,double sell_lots);
   bool              ClosePartByFarForLots(trade_info &info,long &ticket[],double buy_lots,double sell_lots);
                     CPatialClose();
                    ~CPatialClose();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPatialClose::CPatialClose()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPatialClose::~CPatialClose()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPatialClose::ClosePartByProfitToBalance(trade_info &info,long &ticket[],double new_balance)
  {
   CMyTrade trade;
   double part_lots=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN);
   SortOrderByProfit(ticket,true);
   for(int i=0; i<ArraySize(ticket); i++)
     {
      for(int j=0; j<1000;j++)
        {
         if(AccountInfoDouble(ACCOUNT_BALANCE)>new_balance) break;
         if(!PositionSelectByTicket(ticket[i])) continue;
         trade.PositionClosePartial(ticket[i],part_lots);
        }
     }
   return(AccountInfoDouble(ACCOUNT_BALANCE)>new_balance);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CPatialClose::ClosePartByProfitForLots(trade_info &info,long &ticket[],double buy_lots,double sell_lots)
  {
   CMyTrade trade;
   double want_buy_lots=buy_lots;
   double want_sell_lots=sell_lots;
   SortOrderByNear(ticket);
   for(int i=0; i<ArraySize(ticket); i++)
     {
      if(!PositionSelectByTicket(ticket[i])) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(want_buy_lots==0) continue;
         double used_lots=NormalizeLot(info.symbol,MathMin(want_buy_lots,PositionGetDouble(POSITION_VOLUME)));
         trade.PositionClosePartial(ticket[i],used_lots);
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            want_buy_lots-=used_lots;
           }
        }
      else
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(want_sell_lots==0) continue;
         double used_lots=NormalizeLot(info.symbol,MathMin(want_sell_lots,PositionGetDouble(POSITION_VOLUME)));
         trade.PositionClosePartial(ticket[i],used_lots);
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            want_sell_lots-=used_lots;
           }
        }
     }
   return(want_buy_lots==0 && want_sell_lots==0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   CPatialClose::ClosePartByNearForLots(trade_info &info,long &ticket[],double buy_lots,double sell_lots)
  {
   CMyTrade trade;
   double want_buy_lots=buy_lots;
   double want_sell_lots=sell_lots;
   SortOrderByProfit(ticket,false);
   for(int i=0; i<ArraySize(ticket); i++)
     {
      if(!PositionSelectByTicket(ticket[i])) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(want_buy_lots==0) continue;
         double used_lots=NormalizeLot(info.symbol,MathMin(want_buy_lots,PositionGetDouble(POSITION_VOLUME)));
         trade.PositionClosePartial(ticket[i],used_lots);
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            want_buy_lots-=used_lots;
           }
        }
      else
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(want_sell_lots==0) continue;
         double used_lots=NormalizeLot(info.symbol,MathMin(want_sell_lots,PositionGetDouble(POSITION_VOLUME)));
         trade.PositionClosePartial(ticket[i],used_lots);
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            want_sell_lots-=used_lots;
           }
        }
     }
   return(want_buy_lots==0 && want_sell_lots==0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   CPatialClose::ClosePartByFarForLots(trade_info &info,long &ticket[],double buy_lots,double sell_lots)
  {
   CMyTrade trade;
   double want_buy_lots=buy_lots;
   double want_sell_lots=sell_lots;
   SortOrderByFar(ticket);
   for(int i=0; i<ArraySize(ticket); i++)
     {
      if(!PositionSelectByTicket(ticket[i])) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(want_buy_lots==0) continue;
         double used_lots=NormalizeLot(info.symbol,MathMin(want_buy_lots,PositionGetDouble(POSITION_VOLUME)));
         trade.PositionClosePartial(ticket[i],used_lots);
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            want_buy_lots-=used_lots;
           }
        }
      else
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(want_sell_lots==0) continue;
         double used_lots=NormalizeLot(info.symbol,MathMin(want_sell_lots,PositionGetDouble(POSITION_VOLUME)));
         trade.PositionClosePartial(ticket[i],used_lots);
         if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
           {
            want_sell_lots-=used_lots;
           }
        }
     }
   return(want_buy_lots==0 && want_sell_lots==0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CPatialClose::AddLongToArray(long value,long &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return;
   int size=ArraySize(list); ArrayResize(list,size+1); list[size]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::AddDoubleToArray(double value,double &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return;
   int size=ArraySize(list); ArrayResize(list,size+1); list[size]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SetPriceTicketValue(profit_ticket &value,profit_ticket &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value.ticket==list[i].ticket) return;
   int size=ArraySize(list);
   ArrayResize(list,size+1);
   list[size].ticket=value.ticket;
   list[size].price=value.price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CPatialClose::IsLongInArray(long value,long &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool   CPatialClose::IsDoubleInArray(double value,double &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CPatialClose::IsProfitTicketInArray(profit_ticket &value,profit_ticket &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value.ticket==list[i].ticket) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SortOrderByFar(long &ticket[])
  {
   SetZonePrice_buyHIGH_sellLOW(ticket);
   long selected_ticket[],sorted_ticket[];
   ArrayCopy(selected_ticket,ticket);
   double distance[];
   profit_ticket result[];
   for(int i=0; i<ArraySize(selected_ticket); i++)
     {
      if(!PositionSelectByTicket(selected_ticket[i])) continue;
      double value=PositionGetDouble(POSITION_PROFIT);
      profit_ticket temp;
      temp.price=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      temp.ticket=selected_ticket[i];
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         temp.price=MathAbs(open-BuyZoneStartPrice);
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         temp.price=MathAbs(open-SellZoneStartPrice);
        }
      SetPriceTicketValue(temp,result);
      AddDoubleToArray(temp.price,distance);

     }
   ArraySort(distance);
   for(int i=0; i<ArraySize(distance); i++)
      for(int j=0; j<ArraySize(result); j++)
         if(distance[i]==result[j].price) AddLongToArray(result[j].ticket,sorted_ticket);
   ArrayCopy(ticket,sorted_ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SortOrderByNear(long &ticket[])
  {
   SetZonePrice_buyHIGH_sellLOW(ticket);
   long selected_ticket[],sorted_ticket[];
   ArrayCopy(selected_ticket,ticket);
   double distance[];
   profit_ticket result[];
   for(int i=0; i<ArraySize(selected_ticket); i++)
     {
      if(!PositionSelectByTicket(selected_ticket[i])) continue;
      double value=PositionGetDouble(POSITION_PROFIT);
      profit_ticket temp;
      temp.price=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      temp.ticket=selected_ticket[i];
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         temp.price=MathAbs(open-BuyZoneStartPrice);
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         temp.price=MathAbs(open-SellZoneStartPrice);
        }
      SetPriceTicketValue(temp,result);
      AddDoubleToArray(temp.price,distance);
     }
   ArraySort(distance);
   for(int i=0; i<ArraySize(distance); i++)
      for(int j=0; j<ArraySize(result); j++)
         if(distance[i]==result[j].price) AddLongToArray(result[j].ticket,sorted_ticket);
   ArrayCopy(ticket,sorted_ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SortOrderByProfit(long &ticket[],bool no_loss)
  {
   long selected_ticket[],sorted_ticket[];
   ArrayCopy(selected_ticket,ticket);
   double profit[];
   profit_ticket result[];
   for(int i=0; i<ArraySize(selected_ticket); i++)
     {
      if(!PositionSelectByTicket(selected_ticket[i])) continue;
      double value=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      if(no_loss && value<0) continue;
      profit_ticket temp;
      temp.price=value;
      temp.ticket=selected_ticket[i];
      SetPriceTicketValue(temp,result);
      AddDoubleToArray(temp.price,profit);
     }
   ArraySort(profit);
   for(int i=ArraySize(profit)-1; i>=0; i--)
      for(int j=0; j<ArraySize(result); j++)
         if(profit[i]==result[j].price) AddLongToArray(result[j].ticket,sorted_ticket);
   ArrayCopy(ticket,sorted_ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SortOrderByLoss(long &ticket[])
  {
   long selected_ticket[],sorted_ticket[];
   ArrayCopy(selected_ticket,ticket);
   double profit[];
   profit_ticket result[];
   for(int i=0; i<ArraySize(selected_ticket); i++)
     {
      if(!PositionSelectByTicket(selected_ticket[i])) continue;
      double value=PositionGetDouble(POSITION_PROFIT);
      profit_ticket temp;
      temp.price=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP);
      temp.ticket=selected_ticket[i];
      SetPriceTicketValue(temp,result);
      AddDoubleToArray(temp.price,profit);
     }
   ArraySort(profit);
   for(int i=ArraySize(profit)-1; i>=0; i--)
      for(int j=0; j<ArraySize(result); j++)
         if(profit[i]==result[j].price) AddLongToArray(result[j].ticket,sorted_ticket);
   ArrayCopy(ticket,sorted_ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SelectTicketByMagicNumber(long &selected_ticket[],int magic)
  {
   for(int i=0; i<PositionsTotal(); i++)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetInteger(POSITION_MAGIC)==magic)
         AddLongToArray(ticket,selected_ticket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SetZonePrice_buyHIGH_sellLOW(long &ticket[])
  {
   for(int i=0; i<ArraySize(ticket); i++)
     {
      if(!PositionSelectByTicket(ticket[i])) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         if(BuyZoneStartPrice==0) SellZoneStartPrice=open;
         if(BuyZoneStartPrice>0) BuyZoneStartPrice=MathMax(BuyZoneStartPrice,open);
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         if(SellZoneStartPrice==0) SellZoneStartPrice=open;
         if(SellZoneStartPrice>0) SellZoneStartPrice=MathMin(SellZoneStartPrice,open);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPatialClose::SetZonePrice_buyLOW_sellHIGH(long &ticket[])
  {
   for(int i=0; i<ArraySize(ticket); i++)
     {
      if(!PositionSelectByTicket(ticket[i])) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         if(BuyZoneStartPrice==0) SellZoneStartPrice=open;
         if(BuyZoneStartPrice>0) BuyZoneStartPrice=MathMin(BuyZoneStartPrice,open);
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double open=PositionGetDouble(POSITION_PRICE_OPEN);
         if(SellZoneStartPrice==0) SellZoneStartPrice=open;
         if(SellZoneStartPrice>0) SellZoneStartPrice=MathMax(SellZoneStartPrice,open);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPatialClose::NormalizeLot(const string symbol_name,double order_lots)
  {
   double ml=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
   double ln=NormalizeDouble(order_lots,int(ceil(fabs(log(ml)/log(10)))));
   return(ln<ml ? ml : ln>mx ? mx : ln);
  }
//+------------------------------------------------------------------+