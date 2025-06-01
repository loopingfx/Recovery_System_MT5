//+------------------------------------------------------------------+
//|                                           BasicTradeFunction.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include "TradeUtility.mqh"
#include "MyTrade.mqh"
#include "RecoveryParameterGroup.mqh"
#include "StdNotification.mqh"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
class CBasicTradeClass :public CObject
  {
private:
   CTradeUtility     m_util;
   //---
   bool              CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type);
public:
   //---
   void              OpenBuy(CMyTrade *trade,
                               basic_structure &structures,
                               time_trade_setting &time_setting,
                               notification_setting &setting);
   void              OpenSell(CMyTrade *trade,
                               basic_structure &structures,
                               time_trade_setting &time_setting,
                               notification_setting &setting);
   void              OpenSellStop(CMyTrade *trade,
                                  basic_structure &structures,
                                  notification_setting &setting);
   void              OpenSellLimit(CMyTrade *trade,
                                   basic_structure &structures,
                                   notification_setting &setting);
   void              OpenBuyStop(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting);
   void              OpenBuyLimit(CMyTrade *trade,
                                  basic_structure &structures,
                                  notification_setting &setting);
   //---
   void              OpenGridsBuyStop(CMyTrade *trade,
                                      basic_structure &structures,
                                      notification_setting &setting);
   void              OpenGridsSellStop(CMyTrade *trade,
                                       basic_structure &structures,
                                       notification_setting &setting);
   //---
   void              CloseBuy(CMyTrade *trade,
                              basic_structure &structures,
                              notification_setting &setting);
   void              CloseSell(CMyTrade *trade,
                               basic_structure &structures,
                               notification_setting &setting);
   void              DeleteBuy(CMyTrade *trade,
                               basic_structure &structures,
                               notification_setting &setting);
   void              DeleteSell(CMyTrade *trade,
                                basic_structure &structures,
                                notification_setting &setting);
   //---
   void              CloseAll(CMyTrade *trade,
                              basic_structure &structures,
                              notification_setting &setting);
   void              CloseAllSell(CMyTrade *trade,
                                  basic_structure &structures,
                                  notification_setting &setting);
   void              CloseAllBuy(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting);
   void              DeleteAll(CMyTrade *trade,
                               basic_structure &structures,
                               notification_setting &setting);
   void              CloseProfit(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting);
   void              CloseLoss(CMyTrade *trade,
                               basic_structure &structures,
                               notification_setting &setting);
   //---
   void              DeleteAllSell(CMyTrade *trade,
                                   basic_structure &structures,
                                   notification_setting &setting);
   void              DeleteAllBuy(CMyTrade *trade,
                                  basic_structure &structures,
                                  notification_setting &setting);
   //---
   double            Drawndown1(string symbol,int magic);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::OpenBuy(CMyTrade *trade,
                               basic_structure &structures,
                               time_trade_setting &time_setting,
                               notification_setting &setting)
  {
   double volume=structures.open_lots_of_dealbutton_panel;
   double price=0;
   double sl=0,tp=0;
   string comment=structures.text;
   if(!CheckMoneyForTrade(structures.symbol,volume,ORDER_TYPE_BUY)) return;
   trade.Buy(volume,structures.symbol,price,sl,tp,comment);
// if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
     {
      string messege=StringFormat("Deal BUY price=%s volume=%s for %s.",
                                  (string)trade.ResultPrice(),(string)trade.ResultVolume(),structures.symbol);
      CStdNotification note;
      note.SendNotify(messege,setting,time_setting);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::OpenSell(CMyTrade *trade,
                               basic_structure &structures,
                               time_trade_setting &time_setting,
                               notification_setting &setting)
  {
   double volume=structures.open_lots_of_dealbutton_panel;
   double price=0;
   double sl=0,tp=0;
   string comment=structures.text;
   if(!CheckMoneyForTrade(structures.symbol,volume,ORDER_TYPE_SELL)) return;
   trade.Sell(volume,structures.symbol,price,sl,tp,comment);
   if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
     {
      string messege=StringFormat("Deal SELL price=%s volume=%s for %s.",
                                  (string)trade.ResultPrice(),(string)trade.ResultVolume(),structures.symbol);
      CStdNotification note;
      note.SendNotify(messege,setting,time_setting);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::OpenBuyStop(CMyTrade *trade,
                                    basic_structure &structures,
                                    notification_setting &setting)
  {
   double volume=0;
   double price=0;
   double sl=0,tp=0;
   string comment=structures.text;
   trade.BuyStop(volume,price,structures.symbol,sl,tp,0,0,comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void  CBasicTradeClass::OpenBuyLimit(CMyTrade *trade,
                                     basic_structure &structures,
                                     notification_setting &setting)
  {
   double volume=0;
   double price=0;
   double sl=0,tp=0;
   string comment=structures.text;
   trade.BuyLimit(volume,price,structures.symbol,sl,tp,0,0,comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::OpenSellStop(CMyTrade *trade,
                                     basic_structure &structures,
                                     notification_setting &setting)
  {
   double volume=0;
   double price=0;
   double sl=0,tp=0;
   string comment=structures.text;
   trade.SellStop(volume,price,structures.symbol,sl,tp,0,0,comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::OpenSellLimit(CMyTrade *trade,
                                      basic_structure &structures,
                                      notification_setting &setting)
  {
   double volume=0;
   double price=0;
   double sl=0,tp=0;
   string comment=structures.text;
   trade.SellLimit(volume,price,structures.symbol,sl,tp,0,0,comment);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseBuy(CMyTrade *trade,
                                basic_structure &structures,
                                notification_setting &setting)
  {
   int magic=0;
   double profit=0;
   long ticket=0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0)
         && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(profit==0)
           {
            profit=PositionGetDouble(POSITION_PROFIT);
            ticket=(long)PositionGetTicket(i);
           }
         else
           {
            if(PositionGetDouble(POSITION_PROFIT)>profit)
              {
               profit=PositionGetDouble(POSITION_PROFIT);
               ticket=(long)PositionGetTicket(i);
              }
           }
        }
     }
//---
   if(PositionSelectByTicket(ticket))
      trade.PositionClose(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseSell(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting)
  {
   int magic=0;
   double profit=0;
   long ticket=0;
   for(int i=0; i<PositionsTotal(); i++)
     {
      if(!PositionSelectByTicket(PositionGetTicket(i))) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0)
         && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(profit==0)
           {
            profit=PositionGetDouble(POSITION_PROFIT);
            ticket=(long)PositionGetTicket(i);
           }
         else
           {
            if(PositionGetDouble(POSITION_PROFIT)>profit)
              {
               profit=PositionGetDouble(POSITION_PROFIT);
               ticket=(long)PositionGetTicket(i);
              }
           }
        }
     }
//---
   if(PositionSelectByTicket(ticket))
      trade.PositionClose(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::DeleteBuy(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting)
  {
   int magic=0;
   long msc=0;
   long ticket=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(OrderGetTicket(i)))
        {
         if((OrderGetString(ORDER_SYMBOL)==structures.symbol || structures.symbol=="")
            && (OrderGetInteger(ORDER_MAGIC)==magic || magic==0)
            && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP)
           {
            if(msc==0)
              {
               msc=OrderGetInteger(ORDER_TIME_SETUP_MSC);
               ticket=(long)OrderGetTicket(i);
              }
            else
            if(msc<OrderGetInteger(ORDER_TIME_SETUP_MSC))
              {
               msc=OrderGetInteger(ORDER_TIME_SETUP_MSC);
               ticket=(long)OrderGetTicket(i);
              }
           }
        }
     }
//---
   if(OrderSelect(ticket))
      trade.OrderDelete(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::DeleteSell(CMyTrade *trade,
                                  basic_structure &structures,
                                  notification_setting &setting)
  {
   int magic=0;
   long msc=0;
   long ticket=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(OrderGetTicket(i)))
        {
         if((OrderGetString(ORDER_SYMBOL)==structures.symbol || structures.symbol=="")
            && (OrderGetInteger(ORDER_MAGIC)==magic || magic==0)
            && OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP)
           {
            if(msc==0)
              {
               msc=OrderGetInteger(ORDER_TIME_SETUP_MSC);
               ticket=(long)OrderGetTicket(i);
              }
            else
            if(msc<OrderGetInteger(ORDER_TIME_SETUP_MSC))
              {
               msc=OrderGetInteger(ORDER_TIME_SETUP_MSC);
               ticket=(long)OrderGetTicket(i);
              }
           }
        }
     }
//---
   if(OrderSelect(ticket))
      trade.OrderDelete(ticket);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseAll(CMyTrade *trade,
                                basic_structure &structures,
                                notification_setting &setting)
  {
   int magic=0;
   CloseProfit(GetPointer(trade),structures,setting);
//---
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0))
        {
         trade.PositionClose(ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::DeleteAll(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting)
  {
   int magic=0;
   int res=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      long ticket=(long)OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if((OrderGetString(ORDER_SYMBOL)==structures.symbol || structures.symbol=="")
            && (OrderGetInteger(ORDER_MAGIC)==magic || magic==0))
           {
            trade.OrderDelete(ticket);
           }
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseProfit(CMyTrade *trade,
                                   basic_structure &structures,
                                   notification_setting &setting)
  {
   int magic=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0))
        {
         if(PositionGetDouble(POSITION_PROFIT)>0)
            trade.PositionClose(ticket);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseAllBuy(CMyTrade *trade,
                                   basic_structure &structures,
                                   notification_setting &setting)
  {
   int magic=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
            trade.PositionClose(ticket);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseAllSell(CMyTrade *trade,
                                    basic_structure &structures,
                                    notification_setting &setting)
  {
   int magic=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
            trade.PositionClose(ticket);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBasicTradeClass::CloseLoss(CMyTrade *trade,
                                 basic_structure &structures,
                                 notification_setting &setting)
  {
   int magic=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetSymbol(i)==structures.symbol
         && (PositionGetInteger(POSITION_MAGIC)==magic || magic==0))
        {
         if(PositionGetDouble(POSITION_PROFIT)<=0)
            trade.PositionClose(ticket);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::OpenGridsBuyStop(CMyTrade *trade,
                                         basic_structure &structures,
                                         notification_setting &setting)
  {
   double volume[];
   double price[];
   double sl[],tp[];
   string comment[];
   for(int i=0; i<ArraySize(price); i++)
      trade.BuyStop(volume[i],price[i],structures.symbol,sl[i],tp[i],0,0,comment[i]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::OpenGridsSellStop(CMyTrade *trade,
                                          basic_structure &structures,
                                          notification_setting &setting)
  {
   double volume[];
   double price[];
   double sl[],tp[];
   string comment[];
   for(int i=0; i<ArraySize(price); i++)
      trade.SellStop(volume[i],price[i],structures.symbol,sl[i],tp[i],0,0,comment[i]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::DeleteAllSell(CMyTrade *trade,
                                      basic_structure &structures,
                                      notification_setting &setting)
  {
   int magic=0;
   int res=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      long ticket=(long)OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if((OrderGetString(ORDER_SYMBOL)==structures.symbol || structures.symbol=="")
            &&(OrderGetInteger(ORDER_MAGIC)==magic || magic==0)
            && (OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_STOP || OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_SELL_LIMIT))
           {
            trade.OrderDelete(ticket);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CBasicTradeClass::DeleteAllBuy(CMyTrade *trade,
                                     basic_structure &structures,
                                     notification_setting &setting)
  {
   int magic=0;
   int res=0;
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      long ticket=(long)OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if((OrderGetString(ORDER_SYMBOL)==structures.symbol || structures.symbol=="")
            &&(OrderGetInteger(ORDER_MAGIC)==magic || magic==0)
            && (OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_STOP || OrderGetInteger(ORDER_TYPE)==ORDER_TYPE_BUY_LIMIT))
           {
            trade.OrderDelete(ticket);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool   CBasicTradeClass::CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
  {
//--- Getting the opening price
   MqlTick mqltick;
   SymbolInfoTick(symb,mqltick);
   double price=mqltick.ask;
   if(type==ORDER_TYPE_SELL)
      price=mqltick.bid;
//--- values of the required and free margin
   double margin,free_margin=AccountInfoDouble(ACCOUNT_MARGIN_FREE);
//--- call of the checking function
   if(!OrderCalcMargin(type,symb,lots,price,margin)) return(false);
//--- if there are insufficient funds to perform the operation
   if(margin>free_margin)
     {
      //--- report the error and return false
      Print("Not enough money for ",EnumToString(type)," ",lots," ",symb," Error code=",GetLastError());
      return(false);
     }
//--- checking successful
   return(true);
  }
//+------------------------------------------------------------------+
