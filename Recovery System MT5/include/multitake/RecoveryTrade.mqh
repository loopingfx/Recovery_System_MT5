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
#include "RectangleObject.mqh"
#include "PatialClose.mqh"
#include "StdNotification.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRecoveryTrade : public CObject
  {
private:
   //---
   order_process_info workclosuregroup_list[],closuregroup_list[],restore_list[],posible_workclosuregroup_list[],posible_restore_list[];
   long              workgroup_ticket_buy[],workgroup_ticket_sell[];
   long              restore_ticket_buy[],restore_ticket_sell[];
   //---
   void              AddLongToArray(long value,long &list[]);
   bool              IsLongInArray(long &value,long &list[]);
   void              AddDoubleToArray(double value,double &list[]);
   void              AddCloseInfoToArray(order_process_info &value,order_process_info &list[]);
   bool              IsCloseInfoInArray(order_process_info &value,order_process_info &list[]);
   double            NormalizePrice(const string symbol,const double price);
   double            NormalizeLot(const string symbol_name,double order_lots);
   //---                        
   void              ResetWorkGroupSLTP();
   void              SortTicketByProfit(order_process_info &process_set[],
                                        long &list_buy[],
                                        long &list_sell[],
                                        trade_info &info);
   void              SortTicketByDistanceFromFar(order_process_info &process_set[],
                                                 long &list_buy[],long &list_sell[],
                                                 trade_info &info);
   void              SortTicketByDistanceFromNear(order_process_info &process_set[],
                                                  long &list_buy[],long &list_sell[],
                                                  trade_info &info);
   void              SelectOrderByWorkGroup(trade_info &info,long &list_buy[],long &list_sell[],
                                            main_recovery_and_launch_setting &setting,
                                            protection_setting &protec_setting,
                                            auto_calculation_setting &calc_setting);
   void              SelectOrderByRestoring(trade_info &info,long &list_buy[],long &list_sell[],
                                            main_recovery_and_launch_setting &setting);
   void              MakeOrderProcessInfo_WorkGroup(long &ticket_buy[],long &ticket_sell[],trade_info &info,
                                                    main_recovery_and_launch_setting &setting,
                                                    trailing_and_takeprofit_setting &profit_setting);
   void              MakeOrderProcessInfo_Restore(long &ticket_buy[],long &ticket_sell[],trade_info &info);
   void              SelectForClosureGroupPanel(long &ticket_buy[],long &ticket_sell[],trade_info &info,
                                                main_recovery_and_launch_setting &setting,
                                                trailing_and_takeprofit_setting &profit_setting);
   //---
   void              SelectForPosibleWorkGroupPanel(long &ticket_buy[],long &ticket_sell[],trade_info &info,
                                                    main_recovery_and_launch_setting &setting);
   void              CalculateProfitForWorkGroup(long &ticket_buy[],long &ticket_sell[],trade_info &info,
                                                 main_recovery_and_launch_setting &setting);
   void              SelectForPosibleRestorePanel(long &ticket_buy[],long &ticket_sell[],trade_info &info);
   void              CalculateProfitForRestore(long &ticket_buy[],long &ticket_sell[],trade_info &info);
   void              DrawProfit(double value);
   void              SetBuySellZoneFromPriceInClosureWorkGroup(trade_info  &info,double &buy_price[],double &sell_price[],
                                                               main_recovery_and_launch_setting &setting,
                                                               trailing_and_takeprofit_setting &profit_setting);
   void              DrawBuyZone(trade_info &info);
   void              DrawSellZone(trade_info &info);
   bool              CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type);
public:
   void              CalculateBuySellZone(trade_info  &info,
                                          main_recovery_and_launch_setting &setting,
                                          trailing_and_takeprofit_setting &profit_setting);
   void              SelectOrders(trade_info &info,main_recovery_and_launch_setting &setting,
                                  auto_calculation_setting &auto_setting,
                                  trailing_and_takeprofit_setting &profit_setting,
                                  protection_setting &protec_setting)
     {
      //---
      SelectOrderByWorkGroup(info,workgroup_ticket_buy,workgroup_ticket_sell,
                             setting,protec_setting,auto_setting);
      SelectOrderByRestoring(info,restore_ticket_buy,restore_ticket_sell,
                             setting);
     }
   void              ProcessTradeInfo(trade_info &info,main_recovery_and_launch_setting &setting,
                                      auto_calculation_setting &auto_setting,
                                      trailing_and_takeprofit_setting &profit_setting,
                                      protection_setting &protec_setting)
     {
      string symbol=info.symbol;
      long ticket_buy[],ticket_sell[];
      if(setting.OrdersSelector==Start_with_the_most_profit_order_to_profitability)
         SortTicketByProfit(workclosuregroup_list,ticket_buy,ticket_sell,info);
      if(setting.OrdersSelector==Start_with_the_farest_order_to_profitability)
         SortTicketByDistanceFromFar(workclosuregroup_list,ticket_buy,ticket_sell,info);
      if(setting.OrdersSelector==Start_with_the_nearest_order_to_profitability)
         SortTicketByDistanceFromNear(workclosuregroup_list,ticket_buy,ticket_sell,info);
      double to_closure_lots1=info.restore_volume_set1;
      if(auto_setting.MultiplierFactorToClosureLots>0)
        {
         to_closure_lots1=MathMax(auto_setting.MinClosureStartLots,to_closure_lots1);
         to_closure_lots1=MathMin(auto_setting.MaxClosureStartLots,to_closure_lots1);
        }
      info.restore_volume_set1=NormalizeLot(info.symbol,to_closure_lots1);
      //---
      SelectForClosureGroupPanel(workgroup_ticket_buy,workgroup_ticket_sell,info,setting,profit_setting);
      SelectForPosibleWorkGroupPanel(workgroup_ticket_buy,workgroup_ticket_sell,info,setting);
      //---
      if(setting.OrdersSelector==Start_with_the_most_profit_order_to_profitability)
         SortTicketByProfit(restore_list,ticket_buy,ticket_sell,info);
      if(setting.OrdersSelector==Start_with_the_farest_order_to_profitability)
         SortTicketByDistanceFromFar(restore_list,ticket_buy,ticket_sell,info);
      if(setting.OrdersSelector==Start_with_the_nearest_order_to_profitability)
         SortTicketByDistanceFromNear(restore_list,ticket_buy,ticket_sell,info);
      SelectForPosibleRestorePanel(restore_ticket_buy,restore_ticket_sell,info);
     }
   //---
   void              CloseClosureGroup(trade_info &info,main_recovery_and_launch_setting &setting,
                                       auto_calculation_setting &calcuate_setting,
                                       time_trade_setting &time_set,
                                       notification_setting &notify_setting);
   void              CloseAllSystem(trade_info &info,main_recovery_and_launch_setting &setting,
                                    auto_calculation_setting &calcuate_setting,
                                    trailing_and_takeprofit_setting &profit_setting,
                                     time_trade_setting &time_set,
                                    notification_setting &notify_setting);
   void              ClosePosibleWorkGroup(trade_info &info,main_recovery_and_launch_setting &setting,
                                           auto_calculation_setting &calcuate_setting,
                                             time_trade_setting &time_set,
                                           notification_setting &notify_setting);
   void              ClosePosibleRestore(trade_info &info,
                                         auto_calculation_setting &calcuate_setting,
                                           time_trade_setting &time_set,
                                         notification_setting &notify_setting);
   //---
   void              AddRestoringOrder(CMyTrade *trade,trade_info &info,
                                       main_recovery_and_launch_setting &setting,
                                       recovery_order_setting &order_setting,
                                       auto_calculation_setting &calculate_setting,
                                       protection_setting &protect_setting,
                                         time_trade_setting &time_set,
                                       notification_setting &notify_setting);
   void              ProcessLockPosition(CMyTrade *trade,trade_info &info,
                                         main_recovery_and_launch_setting &setting,
                                         protection_setting &protect_setting,
                                         auto_calculation_setting &auto_setting,
                                         trailing_and_takeprofit_setting &profit_setting,
                                           time_trade_setting &time_set,
                                         notification_setting &notify_setting);
   //---
                     CRecoveryTrade()
     {
      //---
     };
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double   CRecoveryTrade::NormalizePrice(const string symbol,const double price)
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
//| Return the normalized lot                                        |
//+------------------------------------------------------------------+
double     CRecoveryTrade::NormalizeLot(const string symbol_name,double order_lots)
  {
   double ml=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MIN);
   double mx=SymbolInfoDouble(symbol_name,SYMBOL_VOLUME_MAX);
   double ln=NormalizeDouble(order_lots,int(ceil(fabs(log(ml)/log(10)))));
   return(ln<ml ? ml : ln>mx ? mx : ln);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade:: ProcessLockPosition(CMyTrade *trade,trade_info &info,
                                          main_recovery_and_launch_setting &setting,
                                          protection_setting &protect_setting,
                                          auto_calculation_setting &auto_setting,
                                          trailing_and_takeprofit_setting &profit_setting,
                                            time_trade_setting &time_set,
                                          notification_setting &notify_setting)
  {
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   double bid=SymbolInfoDouble(info.symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(info.symbol,SYMBOL_ASK);
   long ticket_buy[],ticket_sell[];
   if(info.workgroup_buy_volume1==info.workgroup_sell_volume1) return;
   if(protect_setting.Delete_SL_TP)
      ResetWorkGroupSLTP();
//---
   if((info.workgroup_buy_volume1-info.workgroup_sell_volume1)>=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN))
     {
      string text=protect_setting.LockedOrderComment;
      if(!CheckMoneyForTrade(info.symbol,
         (info.workgroup_buy_volume1-info.workgroup_sell_volume1),
         ORDER_TYPE_SELL)) return;
      trade.Sell((info.workgroup_buy_volume1-info.workgroup_sell_volume1),info.symbol,0,0,0,text);
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
        {
         long ticket=(long)trade.ResultOrder();
         string messege=StringFormat("Locking Order SELL added price=%s volume=%s for %s.",
                                     (string)trade.ResultPrice(),(string)trade.ResultVolume(),info.symbol);
         CStdNotification note;
         note.SendNotify(messege,notify_setting,time_set);
        }
     }
//---
   if((info.workgroup_sell_volume1-info.workgroup_buy_volume1)>=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN))
     {
      string text=protect_setting.LockedOrderComment;
      if(!CheckMoneyForTrade(info.symbol,
         (info.workgroup_sell_volume1-info.workgroup_buy_volume1),
         ORDER_TYPE_BUY)) return;
      trade.Buy((info.workgroup_sell_volume1-info.workgroup_buy_volume1),info.symbol,0,0,0,text);
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
        {
         long ticket=(long)trade.ResultOrder();
         string messege=StringFormat("Locking Order BUY added price=%s volume=%s for %s.",
                                     (string)trade.ResultPrice(),(string)trade.ResultVolume(),info.symbol);
         CStdNotification note;
         note.SendNotify(messege,notify_setting,time_set);
        }
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SortTicketByProfit(order_process_info &process_set[],
                                        long &list_buy[],
                                        long &list_sell[],
                                        trade_info &info)
  {
   double profit_buy[],profit_sell[];
   int total=ArraySize(process_set);
   for(int i=0; i<total; i++)
     {
      if(!PositionSelectByTicket(process_set[i].ticket)) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         AddDoubleToArray(process_set[i].profit,profit_buy);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         AddDoubleToArray(process_set[i].profit,profit_sell);
     }
//---
   ArraySort(profit_buy);
   ArraySort(profit_sell);
//---
   ArrayFree(list_buy);
   for(int i=0; i<ArraySize(profit_buy); i++)
      for(int j=0; j<total; j++)
         if(profit_buy[i]==process_set[j].profit)
            AddLongToArray(process_set[j].ticket,list_buy);
//---
   ArrayFree(list_sell);
   for(int i=0; i<ArraySize(profit_sell); i++)
      for(int j=0; j<total; j++)
         if(profit_sell[i]==process_set[j].profit)
            AddLongToArray(process_set[j].ticket,list_sell);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SortTicketByDistanceFromFar(order_process_info &process_set[],
                                                 long &list_buy[],long &list_sell[],
                                                 trade_info &info)
  {
   double distance_buy[],distance_sell[];
   int total=ArraySize(process_set);
   for(int i=0; i<total; i++)
     {
      if(!PositionSelectByTicket(process_set[i].ticket)) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         AddDoubleToArray(process_set[i].distance,distance_buy);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         AddDoubleToArray(process_set[i].distance,distance_sell);
     }
//---
   ArraySort(distance_buy);
   ArraySort(distance_sell);
   int count_buy=ArraySize(distance_buy);
   int count_sell=ArraySize(distance_sell);
//---
   ArrayFree(list_buy);
   for(int i=count_buy-1; i>=0; i--)
      for(int j=0; j<total; j++)
         if(distance_buy[i]==process_set[j].distance)
            AddLongToArray(process_set[j].ticket,list_buy);
//---
   ArrayFree(list_sell);
   for(int i=count_sell-1; i>=0; i--)
      for(int j=0; j<total; j++)
         if(distance_sell[i]==process_set[j].distance)
            AddLongToArray(process_set[j].ticket,list_sell);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SortTicketByDistanceFromNear(order_process_info &process_set[],
                                                  long &list_buy[],long &list_sell[],
                                                  trade_info &info)
  {
   double distance_buy[],distance_sell[];
   int total=ArraySize(process_set);
   for(int i=0; i<total; i++)
     {
      if(!PositionSelectByTicket(process_set[i].ticket)) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
         AddDoubleToArray(process_set[i].distance,distance_buy);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
         AddDoubleToArray(process_set[i].distance,distance_sell);
     }
//---
   ArraySort(distance_buy);
   ArraySort(distance_sell);
//---
   ArrayFree(list_buy);
   for(int i=0; i<ArraySize(distance_buy); i++)

      for(int j=0; j<total; j++)
         if(distance_buy[i]==process_set[j].distance)
            AddLongToArray(process_set[j].ticket,list_buy);
//---
   ArrayFree(list_sell);
   for(int i=0; i<ArraySize(distance_sell); i++)
      for(int j=0; j<total; j++)
         if(distance_sell[i]==process_set[j].distance)
            AddLongToArray(process_set[j].ticket,list_sell);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::MakeOrderProcessInfo_WorkGroup(long &ticket_buy[],long &ticket_sell[],trade_info &info,
                                                      main_recovery_and_launch_setting &setting,
                                                      trailing_and_takeprofit_setting &profit_setting)
  {
   double bid=SymbolInfoDouble(info.symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(info.symbol,SYMBOL_ASK);
   double pt=SymbolInfoDouble(info.symbol,SYMBOL_POINT);
//---
   ArrayFree(workclosuregroup_list);
   for(int i=0; i<ArraySize(ticket_buy); i++)
     {
      if(!PositionSelectByTicket(ticket_buy[i])) continue;
      double distance_for_buy=MathAbs((PositionGetDouble(POSITION_PRICE_OPEN)-bid)/pt);
      order_process_info temp;
      temp.ticket=ticket_buy[i];
      temp.volume=PositionGetDouble(POSITION_VOLUME);
      if(IsCloseInfoInArray(temp,workclosuregroup_list)) continue;
      temp.price=PositionGetDouble(POSITION_PRICE_OPEN);
      temp.distance=distance_for_buy;
      temp.profit=(PositionGetDouble(POSITION_PROFIT)+
                   PositionGetDouble(POSITION_SWAP));
      AddCloseInfoToArray(temp,workclosuregroup_list);
     }
//---
   for(int i=0; i<ArraySize(ticket_sell); i++)
     {
      if(!PositionSelectByTicket(ticket_sell[i])) continue;
      double distance_for_sell=MathAbs((PositionGetDouble(POSITION_PRICE_OPEN)-ask)/pt);
      order_process_info temp;
      temp.ticket=ticket_sell[i];
      temp.volume=PositionGetDouble(POSITION_VOLUME);
      if(IsCloseInfoInArray(temp,workclosuregroup_list)) continue;
      temp.price=PositionGetDouble(POSITION_PRICE_OPEN);
      temp.distance=distance_for_sell;
      temp.profit=(PositionGetDouble(POSITION_PROFIT)+
                   PositionGetDouble(POSITION_SWAP));
      AddCloseInfoToArray(temp,workclosuregroup_list);
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::SelectForClosureGroupPanel(long &ticket_buy[],long &ticket_sell[],trade_info &info,
                                                  main_recovery_and_launch_setting &setting,
                                                  trailing_and_takeprofit_setting &profit_setting)
  {
   double used_buy_lots=MathMin(info.restore_volume_set1,info.workgroup_buy_volume1);
   double used_sell_lots=MathMin(info.restore_volume_set1,info.workgroup_sell_volume1);

   double price_sell[],price_buy[];
   ArrayFree(closuregroup_list);
   int group_count=0;
//---
   info.group_buy_volume=0;
   info.group_buy_profit=0;
   for(int i=0; i<ArraySize(ticket_buy); i++)
     {
      if(!PositionSelectByTicket(ticket_buy[i])) continue;
      if(PositionGetString(POSITION_SYMBOL)!=info.symbol) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      //  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double get_lots=MathMin(used_buy_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.group_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                    PositionGetDouble(POSITION_SWAP))*get_lots/pos_lots;
            ArrayResize(closuregroup_list,group_count+1);
            closuregroup_list[group_count].ticket=ticket_buy[i];
            closuregroup_list[group_count].volume=get_lots;
            group_count++;
            AddDoubleToArray(PositionGetDouble(POSITION_PRICE_OPEN),price_buy);
           }
         used_buy_lots-=get_lots;
         info.group_buy_volume+=get_lots;
        }
     }
//---
   info.group_sell_volume=0;
   info.group_sell_profit=0;
   for(int i=0; i<ArraySize(ticket_sell); i++)
     {
      if(!PositionSelectByTicket(ticket_sell[i])) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      //  if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double get_lots=MathMin(used_sell_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.group_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                     PositionGetDouble(POSITION_SWAP))*get_lots/pos_lots;
            ArrayResize(closuregroup_list,group_count+1);
            closuregroup_list[group_count].ticket=ticket_sell[i];
            closuregroup_list[group_count].volume=get_lots;
            group_count++;
            AddDoubleToArray(PositionGetDouble(POSITION_PRICE_OPEN),price_sell);
           }
         used_sell_lots-=get_lots;
         info.group_sell_volume+=get_lots;
        }
     }
//---
   SetBuySellZoneFromPriceInClosureWorkGroup(info,price_buy,price_sell,
                                             setting,
                                             profit_setting);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::ResetWorkGroupSLTP()
  {
   CMyTrade trade;
   for(int i=0; i<ArraySize(workgroup_ticket_buy); i++)
     {
      if(!PositionSelectByTicket(workgroup_ticket_buy[i])) continue;
      if(PositionGetDouble(POSITION_SL)!=0 || PositionGetDouble(POSITION_TP)!=0)
         trade.PositionModify(PositionGetTicket(i),0,0);
     }

   for(int i=0; i<ArraySize(workgroup_ticket_sell); i++)
     {
      if(!PositionSelectByTicket(workgroup_ticket_sell[i])) continue;
      if(PositionGetDouble(POSITION_SL)!=0 || PositionGetDouble(POSITION_TP)!=0)
         trade.PositionModify(PositionGetTicket(i),0,0);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CRecoveryTrade::AddRestoringOrder(CMyTrade *trade,trade_info &info,
                                        main_recovery_and_launch_setting &setting,
                                        recovery_order_setting &order_setting,
                                        auto_calculation_setting &calculate_setting,
                                        protection_setting &protect_setting,
                                          time_trade_setting &time_set,
                                        notification_setting &notify_setting)
  {
//---
   string VPS="";
   if(TerminalInfoInteger(TERMINAL_VPS)) VPS="[VPS]";
   double start_lots_buy=order_setting.MinRecStartLots;
   double start_lots_sell=order_setting.MinRecStartLots;
   if(calculate_setting.MultiplierFactorToClosureLots>0)
     {
      info.restore_volume_set1=calculate_setting.MultiplierFactorToClosureLots*order_setting.MinRecStartLots;
      info.restore_volume_set1=NormalizeLot(info.symbol,info.restore_volume_set1);
      //---
      start_lots_buy=MathMax(start_lots_buy,order_setting.MinRecStartLots);
      start_lots_sell=MathMax(start_lots_sell,order_setting.MinRecStartLots);
      start_lots_buy=NormalizeLot(info.symbol,MathMin(calculate_setting.MaxRecStartLots,start_lots_buy));
      start_lots_sell=NormalizeLot(info.symbol,MathMin(calculate_setting.MaxRecStartLots,start_lots_sell));
     }
   string symbol=info.symbol;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
   long spread=SymbolInfoInteger(symbol,SYMBOL_SPREAD);
   double bid=SymbolInfoDouble(symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(symbol,SYMBOL_ASK);
   double pt=SymbolInfoDouble(symbol,SYMBOL_POINT);
   double stoplevel=SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL)*pt;
   if(pt==0) return;
//---
   info.for_buy_below_distance_of_ask_under_buyzone_low=(int)MathFloor((info.buyzone_low-ask)/pt); //buy_below
   info.for_buy_above_distance_of_ask_over_buyzone_high=(int)MathFloor((ask-info.buyzone_high)/pt);//buy_above
   if(info.buyzone_low==0) info.for_buy_below_distance_of_ask_under_buyzone_low=0;
   if(info.buyzone_high==0) info.for_buy_above_distance_of_ask_over_buyzone_high=0;
//---
   info.for_sell_below_distance_of_bid_under_sellzone_low=(int)MathFloor((info.sellzone_low-bid)/pt);//sell  below
   info.for_sell_above_distance_of_bid_over_sellzone_high=(int)MathFloor((bid-info.sellzone_high)/pt); // sell above
   if(info.sellzone_low==0) info.for_sell_below_distance_of_bid_under_sellzone_low=0;
   if(info.sellzone_high==0) info.for_sell_above_distance_of_bid_over_sellzone_high=0;
//---
   if(info.recovery_step_distance_for_buy==0)
      info.recovery_step_distance_for_buy=order_setting.Start_Step_Grids;
   if(info.recovery_volume_for_buy1==0)
      info.recovery_volume_for_buy1=NormalizeLot(info.symbol,start_lots_buy);
   if(info.recovery_step_distance_for_sell==0)
      info.recovery_step_distance_for_sell=order_setting.Start_Step_Grids;
   if(info.recovery_volume_for_sell1==0)
      info.recovery_volume_for_sell1=NormalizeLot(info.symbol,start_lots_sell);
//---
   switch(setting.TypeOfZones)
     {
      case Sell_zone_is_above_and_buy_zone_is_below:
         info.type_buy=(info.for_buy_below_distance_of_ask_under_buyzone_low>info.recovery_step_distance_for_buy);
         info.type_sell=(info.for_sell_above_distance_of_bid_over_sellzone_high>info.recovery_step_distance_for_sell);
         break;
      case Buy_zone_is_above_and_sell_zone_is_below:
         info.type_buy=(info.for_buy_above_distance_of_ask_over_buyzone_high>info.recovery_step_distance_for_buy);
         info.type_sell=(info.for_sell_below_distance_of_bid_under_sellzone_low>info.recovery_step_distance_for_sell);
         break;
      case No_separation:
         info.type_buy=(info.for_buy_below_distance_of_ask_under_buyzone_low>info.recovery_step_distance_for_buy
                        || info.for_buy_above_distance_of_ask_over_buyzone_high>info.recovery_step_distance_for_buy);
      info.type_sell=(info.for_sell_above_distance_of_bid_over_sellzone_high>info.recovery_step_distance_for_sell
                      || info.for_sell_below_distance_of_bid_under_sellzone_low>info.recovery_step_distance_for_sell);
      break;
     };
//---
   switch(order_setting.RecTypeOpen)
     {
      case Buy_and_Sell_orders:
         if(!order_setting.CanTradeBothSides
            && order_setting.Trend_Filter_Grids==Without_filtering)
           {
            info.type_buy=false;
            info.type_sell=false;
           }
      break;
      case Sell_orders:
         info.type_buy=false;
         break;
      case Buy_orders:
         info.type_sell=false;
         break;
     };
//---
   switch(order_setting.Trend_Filter_Grids)
     {
      case Filtering_via_Alligator:
         info.type_sell&=info.alligator_signal<0;
         info.type_buy&=info.alligator_signal>0;
         break;
      case Filtering_via_PalabolicSAR:
         info.type_sell&=info.parabolic_sar_signal<0;
         info.type_buy&=info.parabolic_sar_signal>0;
         break;
      case Filtering_via_Heiken_Ashi:
         info.type_sell&=info.heiken_ashi_signal<0;
         info.type_buy&=info.heiken_ashi_signal>0;
         break;
      case Filtering_via_Two_MAs:
         info.type_sell&=info.two_ma_signal<0;
         info.type_buy&=info.two_ma_signal>0;
         break;
      case Without_filtering:
         break;
     };
//---
   if(info.type_buy && spread<protect_setting.Spread_Limit)
     {
      double lots=info.recovery_volume_for_buy1;
      //--protection lot and total order
      if(lots>=protect_setting.Maximum_Order_Size) return;
      if(PositionsTotal()+OrdersTotal()>=protect_setting.Maximum_Orders_In_Work) return;
      string text=protect_setting.RecoveryComment;
      if(!CheckMoneyForTrade(info.symbol,lots,ORDER_TYPE_BUY)) return;
      trade.Buy(lots,symbol,0,0,0,text);
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
        {
         long ticket=(long)trade.ResultOrder();
         if(PositionSelectByTicket(ticket))
           {
            double open=PositionGetDouble(POSITION_PRICE_OPEN);
            info.recovery_volume_for_buy1=NormalizeLot(info.symbol,PositionGetDouble(POSITION_VOLUME)*
                                                       order_setting.Multiplier);
            info.recovery_volume_for_buy1=NormalizeLot(info.symbol,MathMin(info.recovery_volume_for_buy1,
                                                       protect_setting.Maximum_Order_Size));
            info.recovery_step_distance_for_buy*=order_setting.Step_Multiplier;
            if(info.recovery_step_distance_for_buy>calculate_setting.Maximum_Step_between_Ord)
               info.recovery_step_distance_for_buy=calculate_setting.Maximum_Step_between_Ord;
            if(info.recovery_step_distance_for_buy<calculate_setting.Minimum_Step_between_Ord)
               info.recovery_step_distance_for_buy=calculate_setting.Minimum_Step_between_Ord;
           }
         string messege=StringFormat("Restoring Order BUY added price=%s volume=%s for %s.",
                                     (string)trade.ResultPrice(),(string)trade.ResultVolume(),info.symbol);
         CStdNotification note;
         note.SendNotify(messege,notify_setting,time_set);
        }
     }
//---
   if(info.type_sell && spread<protect_setting.Spread_Limit)
     {
      double lots=info.recovery_volume_for_sell1;
      //--protection lot an total order
      if(lots>=protect_setting.Maximum_Order_Size) return;
      if(PositionsTotal()+OrdersTotal()>=protect_setting.Maximum_Orders_In_Work) return;
      string text=protect_setting.RecoveryComment;
      if(!CheckMoneyForTrade(info.symbol,lots,ORDER_TYPE_SELL)) return;
      trade.Sell(lots,symbol,0,0,0,text);
      if(trade.ResultRetcode()==TRADE_RETCODE_DONE)
        {
         long ticket=(long)trade.ResultOrder();
         if(PositionSelectByTicket(ticket))
           {
            double open=PositionGetDouble(POSITION_PRICE_OPEN);
            info.recovery_volume_for_sell1=NormalizeLot(info.symbol,PositionGetDouble(POSITION_VOLUME)*
                                                        order_setting.Multiplier);
            info.recovery_volume_for_sell1=NormalizeLot(info.symbol,MathMin(info.recovery_volume_for_sell1,
                                                        protect_setting.Maximum_Order_Size));
            info.recovery_step_distance_for_sell*=order_setting.Step_Multiplier;
            if(info.recovery_step_distance_for_sell>calculate_setting.Maximum_Step_between_Ord)
               info.recovery_step_distance_for_sell=calculate_setting.Maximum_Step_between_Ord;
            if(info.recovery_step_distance_for_sell<order_setting.Start_Step_Grids)
               info.recovery_step_distance_for_sell=order_setting.Start_Step_Grids;
           }
         string messege=StringFormat("Restoring Order SELL added price=%s volume=%s for %s.",
                                     (string)trade.ResultPrice(),(string)trade.ResultVolume(),info.symbol);
         CStdNotification note;
         note.SendNotify(messege,notify_setting,time_set);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SelectForPosibleWorkGroupPanel(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting)
  {
   info.posible_workgroup_buy_volume=0;
   info.posible_workgroup_sell_volume=0;
   info.posible_workgroup_buy_profit=0;
   info.posible_workgroup_sell_profit=0;
   ArrayFree(posible_workclosuregroup_list);
//---
   if(info.workgroup_buy_volume1==0 || info.workgroup_sell_volume1==0) return;
   if(info.workgroup_buy_volume1!=info.workgroup_sell_volume1) return;
   if(info.workgroup_buy_volume1<2*info.restore_volume_set1) return;
//---
   double minimum_lots=SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN);
//---
   for(int i=0; i<2000; i++)
     {
      //--- adjust lot sell
      if(info.workgroup_buy_profit>info.workgroup_sell_profit)
        {
         //-- try down sell lots
         //   info.posible_workgroup_buy_profit=info.workgroup_buy_profit;
         info.posible_workgroup_buy_volume=info.workgroup_buy_volume1;
         info.posible_workgroup_sell_volume=info.workgroup_sell_volume1-(i+1)*minimum_lots;
         if(info.posible_workgroup_sell_volume<=0) break;
         CalculateProfitForWorkGroup(ticket_buy,ticket_sell,info,setting);
        }
      //--- adjust lot buy
      if(info.workgroup_sell_profit>info.workgroup_buy_profit)
        {
         //-- try down buy lot 
         // info.posible_workgroup_sell_profit=info.workgroup_sell_profit;
         info.posible_workgroup_sell_volume=info.workgroup_sell_volume1;
         info.posible_workgroup_buy_volume=info.workgroup_buy_volume1-(i+1)*minimum_lots;
         if(info.posible_workgroup_buy_volume<=0) break;
         CalculateProfitForWorkGroup(ticket_buy,ticket_sell,info,setting);
        }
      if((info.posible_workgroup_sell_profit+info.posible_workgroup_buy_profit)>0
         && info.posible_workgroup_buy_volume>info.restore_volume_set1
         && info.posible_workgroup_sell_volume>info.restore_volume_set1) return;
     }
   info.posible_workgroup_buy_volume=0;
   info.posible_workgroup_sell_volume=0;
   info.posible_workgroup_buy_profit=0;
   info.posible_workgroup_sell_profit=0;
   ArrayFree(posible_workclosuregroup_list);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SelectForPosibleRestorePanel(long &ticket_buy[],long &ticket_sell[],trade_info &info)
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
void CRecoveryTrade::MakeOrderProcessInfo_Restore(long &ticket_buy[],long &ticket_sell[],trade_info &info)
  {
   double bid=SymbolInfoDouble(info.symbol,SYMBOL_BID);
   double ask=SymbolInfoDouble(info.symbol,SYMBOL_ASK);
   double pt=SymbolInfoDouble(info.symbol,SYMBOL_POINT);
//---
   ArrayFree(restore_list);
   for(int i=0; i<ArraySize(ticket_buy); i++)
     {
      if(!PositionSelectByTicket(ticket_buy[i])) continue;
      double distance_for_buy=MathAbs((PositionGetDouble(POSITION_PRICE_OPEN)-bid)/pt);
      order_process_info temp;
      temp.ticket=ticket_buy[i];
      temp.volume=PositionGetDouble(POSITION_VOLUME);
      if(IsCloseInfoInArray(temp,restore_list)) continue;
      //---
      temp.distance=distance_for_buy;
      temp.profit=(PositionGetDouble(POSITION_PROFIT)+
                   PositionGetDouble(POSITION_SWAP));
      AddCloseInfoToArray(temp,restore_list);
     }
//---
   for(int i=0; i<ArraySize(ticket_sell); i++)
     {
      if(!PositionSelectByTicket(ticket_sell[i])) continue;
      double distance_for_sell=MathAbs((PositionGetDouble(POSITION_PRICE_OPEN)-ask)/pt);
      order_process_info temp;
      temp.ticket=ticket_sell[i];
      temp.volume=PositionGetDouble(POSITION_VOLUME);
      if(IsCloseInfoInArray(temp,restore_list)) continue;
      //---
      temp.distance=distance_for_sell;
      temp.profit=(PositionGetDouble(POSITION_PROFIT)+
                   PositionGetDouble(POSITION_SWAP));
      AddCloseInfoToArray(temp,restore_list);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::CloseClosureGroup(trade_info &info,main_recovery_and_launch_setting &setting,
                                       auto_calculation_setting &calcuate_setting,
                                       time_trade_setting &time_set,
                                       notification_setting &notify_setting)
  {
   long ticket_buy[],ticket_sell[];
   ArrayCopy(ticket_buy,restore_ticket_buy);
   ArrayCopy(ticket_sell,restore_ticket_sell);
   MakeOrderProcessInfo_Restore(ticket_buy,ticket_sell,info);
   CMyTrade trade;
   calcuate_setting.MaxPartForClose=MathMax(calcuate_setting.MaxPartForClose,
                                            SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN));
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double target_balance=balance+info.group_sell_profit+info.group_buy_profit;
//---
   double system_profit=info.group_buy_profit+info.group_sell_profit+
                        info.restore_buy_profit+info.restore_sell_profit;
//---
   for(int i=0; i<ArraySize(restore_list); i++)
     {
      if(restore_list[i].volume<=calcuate_setting.MaxPartForClose)
         trade.PositionClosePartial(restore_list[i].ticket,restore_list[i].volume);
      else
        {
         double used_lots=restore_list[i].volume;
         for(int j=0; j<1000; j++)
           {
            double get_lots=NormalizeLot(info.symbol,MathMin(used_lots,calcuate_setting.MaxPartForClose));
            trade.PositionClosePartial(restore_list[i].ticket,
                                       get_lots);
            used_lots-=get_lots;
            if(used_lots<=0) break;
           }
        }
     }
//--
   for(int i=0; i<ArraySize(closuregroup_list); i++)
     {
      if(closuregroup_list[i].volume<=calcuate_setting.MaxPartForClose)
         trade.PositionClosePartial(closuregroup_list[i].ticket,closuregroup_list[i].volume);
      else
        {
         double used_lots=closuregroup_list[i].volume;
         for(int j=0; j<1000; j++)
           {
            double get_lots=NormalizeLot(info.symbol,MathMin(used_lots,calcuate_setting.MaxPartForClose));
            trade.PositionClosePartial(closuregroup_list[i].ticket,
                                       get_lots);
            used_lots-=get_lots;
            if(used_lots<=0) break;
           }
        }
     }
//---
   if(AccountInfoDouble(ACCOUNT_BALANCE)<target_balance
      && info.group_sell_profit+info.group_buy_profit>0)
     {
      CPatialClose close_more;
      long target[];
      for(int i=0; i<ArraySize(workgroup_ticket_buy); i++)
         AddLongToArray(workgroup_ticket_buy[i],target);
      for(int i=0; i<ArraySize(workgroup_ticket_sell); i++)
         AddLongToArray(workgroup_ticket_sell[i],target);
      close_more.ClosePartByProfitToBalance(info,target,target_balance);
     }
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   string messege=StringFormat("[%s]CloseClosureGroup for target= %.2f",info.symbol,system_profit);
   messege+=StringFormat(" add balance profit= %.2f.",profit);
   messege+=StringFormat("New balance=%s %.2f",AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
   messege+=".";
   CStdNotification note;
   note.SendNotify(messege,notify_setting,time_set);
   DrawProfit(profit);
//---
   info.buyzone_high=0;
   info.buyzone_low=0;
   info.sellzone_high=0;
   info.sellzone_low=0;
   Sleep(1000);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::CloseAllSystem(trade_info &info,main_recovery_and_launch_setting &setting,
                                    auto_calculation_setting &calcuate_setting,
                                    trailing_and_takeprofit_setting &profit_setting,
                                     time_trade_setting &time_set,
                                    notification_setting &notify_setting)
  {
   long ticket_buy[],ticket_sell[];
   ArrayCopy(ticket_buy,restore_ticket_buy);
   ArrayCopy(ticket_sell,restore_ticket_sell);
   MakeOrderProcessInfo_Restore(ticket_buy,ticket_sell,info);
   ArrayCopy(ticket_buy,workgroup_ticket_buy);
   ArrayCopy(ticket_sell,workgroup_ticket_sell);
   MakeOrderProcessInfo_WorkGroup(ticket_buy,ticket_sell,info,setting,profit_setting);
   CMyTrade trade;
   calcuate_setting.MaxPartForClose=MathMax(calcuate_setting.MaxPartForClose,
                                            SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN));
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double system_profit=info.workgroup_buy_profit+info.workgroup_sell_profit+
                        info.restore_buy_profit+info.restore_sell_profit;
//---
   for(int i=0; i<ArraySize(restore_list); i++)
     {
      if(restore_list[i].volume<=calcuate_setting.MaxPartForClose)
         trade.PositionClosePartial(restore_list[i].ticket,restore_list[i].volume);
      else
        {
         double used_lots=restore_list[i].volume;
         for(int j=0; j<1000; j++)
           {
            double get_lots=NormalizeLot(info.symbol,MathMin(used_lots,calcuate_setting.MaxPartForClose));
            trade.PositionClosePartial(restore_list[i].ticket,
                                       get_lots);
            used_lots-=get_lots;
            if(used_lots<=0) break;
           }
        }
     }
//---
   for(int i=0; i<ArraySize(workclosuregroup_list); i++)
     {
      if(workclosuregroup_list[i].volume<=calcuate_setting.MaxPartForClose)
         trade.PositionClosePartial(workclosuregroup_list[i].ticket,workclosuregroup_list[i].volume);
      else
        {
         double used_lots=workclosuregroup_list[i].volume;
         for(int j=0; j<1000; j++)
           {
            double get_lots=NormalizeLot(info.symbol,MathMin(used_lots,calcuate_setting.MaxPartForClose));
            trade.PositionClosePartial(workclosuregroup_list[i].ticket,
                                       get_lots);
            used_lots-=get_lots;
            if(used_lots<=0) break;
           }
        }
     }
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   string messege=StringFormat("[%s]CloseAllSystem for target= %.2f",info.symbol,system_profit);
   messege+=StringFormat(" add balance profit= %.2f.",profit);
   messege+=StringFormat("New balance=%s %.2f",AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
   messege+=".";
   CStdNotification note;
   note.SendNotify(messege,notify_setting,time_set);
   DrawProfit(profit);
//---
//  info.workgroup_buy_profit=0;
// info.workgroup_sell_profit=0;
// info.restore_buy_profit=0;
// info.restore_sell_profit=0;
//---
   info.buyzone_high=0;
   info.buyzone_low=0;
   info.sellzone_high=0;
   info.sellzone_low=0;
   Sleep(1000);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::ClosePosibleWorkGroup(trade_info &info,main_recovery_and_launch_setting &setting,
                                           auto_calculation_setting &calcuate_setting,
                                             time_trade_setting &time_set,
                                           notification_setting &notify_setting)
  {
   CMyTrade trade;
   calcuate_setting.MaxPartForClose=MathMax(calcuate_setting.MaxPartForClose,
                                            SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN));
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double target_balance=balance+info.posible_workgroup_buy_profit+info.posible_workgroup_sell_profit;
   double system_profit=info.posible_workgroup_buy_profit+info.posible_workgroup_sell_profit;
//---
   for(int i=0; i<ArraySize(posible_workclosuregroup_list); i++)
     {
      if(posible_workclosuregroup_list[i].volume<=calcuate_setting.MaxPartForClose)
         trade.PositionClosePartial(posible_workclosuregroup_list[i].ticket,posible_workclosuregroup_list[i].volume);
      else
        {
         double used_lots=posible_workclosuregroup_list[i].volume;
         for(int j=0; j<1000; j++)
           {
            double get_lots=NormalizeLot(info.symbol,MathMin(used_lots,calcuate_setting.MaxPartForClose));
            trade.PositionClosePartial(posible_workclosuregroup_list[i].ticket,
                                       get_lots);
            used_lots-=get_lots;
            if(used_lots<=0) break;
           }
        }
     }
//---
   if(AccountInfoDouble(ACCOUNT_BALANCE)<target_balance
      && info.posible_workgroup_sell_profit+info.posible_workgroup_sell_profit>0)
     {
      CPatialClose close_more;
      long target[];
      for(int i=0; i<ArraySize(workgroup_ticket_buy); i++)
         AddLongToArray(workgroup_ticket_buy[i],target);
      for(int i=0; i<ArraySize(workgroup_ticket_sell); i++)
         AddLongToArray(workgroup_ticket_sell[i],target);
      close_more.ClosePartByProfitToBalance(info,target,target_balance);
     }
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   string messege=StringFormat("[%s]CloseAllSystem for target= %.2f",info.symbol,system_profit);
   messege+=StringFormat(" add balance profit= %.2f.",profit);
   messege+=StringFormat("New balance=%s %.2f",AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
   messege+=".";
   CStdNotification note;
   note.SendNotify(messege,notify_setting,time_set);
   DrawProfit(profit);
//---
   info.buyzone_high=0;
   info.buyzone_low=0;
   info.sellzone_high=0;
   info.sellzone_low=0;
   Sleep(1000);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::ClosePosibleRestore(trade_info &info,
                                         auto_calculation_setting &calcuate_setting,
                                         time_trade_setting &time_set,
                                         notification_setting &notify_setting)
  {
   CMyTrade trade;
   calcuate_setting.MaxPartForClose=MathMax(calcuate_setting.MaxPartForClose,
                                            SymbolInfoDouble(info.symbol,SYMBOL_VOLUME_MIN));
   double balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double target_balance=balance+info.posible_restore_buy_profit+info.posible_restore_sell_profit;
   double system_profit=info.posible_restore_buy_profit+info.posible_restore_sell_profit;
//---
   for(int i=0; i<ArraySize(posible_restore_list); i++)
     {
      if(posible_restore_list[i].volume<=calcuate_setting.MaxPartForClose)
         trade.PositionClosePartial(posible_restore_list[i].ticket,posible_restore_list[i].volume);
      else
        {
         double used_lots=posible_restore_list[i].volume;
         for(int j=0; j<1000; j++)
           {
            double get_lots=NormalizeLot(info.symbol,MathMin(used_lots,calcuate_setting.MaxPartForClose));
            trade.PositionClosePartial(posible_restore_list[i].ticket,
                                       get_lots);
            used_lots-=get_lots;
            if(used_lots<=0) break;
           }
        }
     }
//---
   if(AccountInfoDouble(ACCOUNT_BALANCE)<target_balance
      && info.posible_restore_buy_profit+info.posible_restore_sell_profit>0)
     {
      CPatialClose close_more;
      long target[];
      for(int i=0; i<ArraySize(restore_ticket_sell); i++)
         AddLongToArray(restore_ticket_sell[i],target);
      for(int i=0; i<ArraySize(restore_ticket_buy); i++)
         AddLongToArray(restore_ticket_buy[i],target);
      close_more.ClosePartByProfitToBalance(info,target,target_balance);
     }
//---
   double profit=AccountInfoDouble(ACCOUNT_BALANCE)-balance;
   string messege=StringFormat("[%s]CloseAllSystem for target= %.2f",info.symbol,system_profit);
   messege+=StringFormat(" add balance profit= %.2f.",profit);
   messege+=StringFormat("New balance=%s %.2f",AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
   messege+=".";
   CStdNotification note;
   note.SendNotify(messege,notify_setting,time_set);
   DrawProfit(profit);
//---
   info.buyzone_high=0;
   info.buyzone_low=0;
   info.sellzone_high=0;
   info.sellzone_low=0;
   Sleep(1000);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::DrawProfit(double value)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::CalculateProfitForWorkGroup(long &ticket_buy[],long &ticket_sell[],trade_info &info,main_recovery_and_launch_setting &setting)
  {
   double used_buy_lots=info.posible_workgroup_buy_volume;
   double used_sell_lots=info.posible_workgroup_sell_volume;
//---
   info.posible_workgroup_buy_profit=0;
   info.posible_workgroup_sell_profit=0;
   info.posible_workgroup_buy_volume=0;
   info.posible_workgroup_sell_volume=0;
   ArrayFree(posible_workclosuregroup_list);
   int posible_workgroup_count=0;
   for(int i=0; i<ArraySize(ticket_buy); i++)
     {
      if(!PositionSelectByTicket(ticket_buy[i])) continue;
      if(PositionGetString(POSITION_SYMBOL)!=info.symbol) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double get_lots=MathMin(used_buy_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.posible_workgroup_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                                PositionGetDouble(POSITION_SWAP))*get_lots/pos_lots;
            ArrayResize(posible_workclosuregroup_list,posible_workgroup_count+1);
            posible_workclosuregroup_list[posible_workgroup_count].ticket=ticket_buy[i];
            posible_workclosuregroup_list[posible_workgroup_count].volume=get_lots;
            posible_workgroup_count++;
           }
         used_buy_lots-=get_lots;
         info.posible_workgroup_buy_volume+=get_lots;
        }
     }
//---
   for(int i=0; i<ArraySize(ticket_sell); i++)
     {
      if(!PositionSelectByTicket(ticket_sell[i])) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double get_lots=MathMin(used_sell_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.posible_workgroup_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                                 PositionGetDouble(POSITION_SWAP))*get_lots/pos_lots;
            ArrayResize(posible_workclosuregroup_list,posible_workgroup_count+1);
            posible_workclosuregroup_list[posible_workgroup_count].ticket=ticket_sell[i];
            posible_workclosuregroup_list[posible_workgroup_count].volume=get_lots;
            posible_workgroup_count++;
           }
         used_sell_lots-=get_lots;
         info.posible_workgroup_sell_volume+=get_lots;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::CalculateProfitForRestore(long &ticket_buy[],long &ticket_sell[],trade_info &info)
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
      if(PositionGetString(POSITION_SYMBOL)!=info.symbol) continue;
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         double get_lots=MathMin(used_buy_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.posible_restore_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                              PositionGetDouble(POSITION_SWAP))*get_lots/pos_lots;
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
      double pos_lots=PositionGetDouble(POSITION_VOLUME);
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         double get_lots=MathMin(used_sell_lots,pos_lots);
         if(pos_lots>0 && get_lots>0)
           {
            info.posible_restore_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                               PositionGetDouble(POSITION_SWAP))*get_lots/pos_lots;
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
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::AddLongToArray(long value,long &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return;
   int size=ArraySize(list); ArrayResize(list,size+1); list[size]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool  CRecoveryTrade::IsLongInArray(long &value,long &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::AddDoubleToArray(double value,double &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value==list[i]) return;
   int size=ArraySize(list); ArrayResize(list,size+1); list[size]=value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::AddCloseInfoToArray(order_process_info &value,order_process_info &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value.ticket==list[i].ticket) return;
   int size=ArraySize(list); ArrayResize(list,size+1);
   list[size].ticket=value.ticket;
   list[size].volume=value.volume;
   list[size].distance=value.distance;
   list[size].profit=value.profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CRecoveryTrade::IsCloseInfoInArray(order_process_info &value,order_process_info &list[])
  {
   for(int i=0; i<ArraySize(list); i++)
      if(value.ticket==list[i].ticket) return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::DrawSellZone(trade_info &info)
  {
   CRectangleObject rc;
   if(info.sellzone_high==0 || info.sellzone_low==0)
     {
      if(ObjectFind(0,"sellzone")==0) rc.RectangleDelete(0,"sellzone");
     }
   else
     {
      if(ObjectFind(0,"sellzone")!=0)
         rc.RectangleCreate(0,"sellzone",0,
                            iTime(ChartSymbol(),0,3),info.sellzone_high,
                            iTime(ChartSymbol(),0,1),info.sellzone_low,clrLightPink,0,2);
      else
        {
         rc.RectanglePointChange(0,"sellzone",0,iTime(ChartSymbol(),0,3),info.sellzone_high);
         rc.RectanglePointChange(0,"sellzone",1,iTime(ChartSymbol(),0,1),info.sellzone_low);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryTrade::DrawBuyZone(trade_info &info)
  {
   CRectangleObject rc;
   if(info.buyzone_high==0 || info.buyzone_low==0)
     {
      if(ObjectFind(0,"buyzone")==0) rc.RectangleDelete(0,"buyzone");
     }
   else
     {
      if(ObjectFind(0,"buyzone")!=0)
         rc.RectangleCreate(0,"buyzone",0,iTime(ChartSymbol(),0,0)+PeriodSeconds(PERIOD_CURRENT),info.buyzone_high,
                            iTime(ChartSymbol(),0,0)+3*PeriodSeconds(PERIOD_CURRENT),info.buyzone_low,clrLightGreen,0,2);
      else
        {
         rc.RectanglePointChange(0,"buyzone",0,iTime(ChartSymbol(),0,0)+PeriodSeconds(PERIOD_CURRENT),info.buyzone_high);
         rc.RectanglePointChange(0,"buyzone",1,iTime(ChartSymbol(),0,0)+3*PeriodSeconds(PERIOD_CURRENT),info.buyzone_low);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::CalculateBuySellZone(trade_info  &info,
                                          main_recovery_and_launch_setting &setting,
                                          trailing_and_takeprofit_setting &profit_setting)
  {
   if(info.group_buy_volume+info.group_sell_volume<profit_setting.MinPart_For_Close) return;
   if(info.restore_buy_volume+info.restore_sell_volume==0)

     {
      if(setting.VarSizeOfZone>0)
        {
         double bid=SymbolInfoDouble(info.symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(info.symbol,SYMBOL_ASK);
         double pt=SymbolInfoDouble(info.symbol,SYMBOL_POINT);
         if(info.buyzone_high==0) info.buyzone_high=ask;
         if(info.sellzone_low==0) info.sellzone_low=bid;
         if(info.buyzone_low==0) info.buyzone_low=info.buyzone_high-setting.VarSizeOfZone*pt;
         if(info.sellzone_high==0) info.sellzone_high=info.sellzone_low+setting.VarSizeOfZone*pt;
        }
      else
        {
         //-- do by other routine in [SelectForClosureGroupPanel]
        }
     }
   else
     {
      for(int i=0; i<PositionsTotal(); i++)
        {
         long ticket=(long)PositionGetTicket(i);
         if(!PositionSelectByTicket(ticket)) continue;
         if(PositionGetInteger(POSITION_MAGIC)==setting.RecoverMagicNumber
            && PositionGetString(POSITION_SYMBOL)==info.symbol)
           {
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
              {
               if(info.buyzone_high==0) info.buyzone_high=PositionGetDouble(POSITION_PRICE_OPEN);
               if(info.buyzone_low==0) info.buyzone_low=PositionGetDouble(POSITION_PRICE_OPEN);
               info.buyzone_high=MathMax(PositionGetDouble(POSITION_PRICE_OPEN),info.buyzone_high);
               info.buyzone_low=MathMin(PositionGetDouble(POSITION_PRICE_OPEN),info.buyzone_low);
              }
            if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
              {
               if(info.sellzone_high==0) info.sellzone_high=PositionGetDouble(POSITION_PRICE_OPEN);
               if(info.sellzone_low==0) info.sellzone_low=PositionGetDouble(POSITION_PRICE_OPEN);
               info.sellzone_high=MathMax(PositionGetDouble(POSITION_PRICE_OPEN),info.sellzone_high);
               info.sellzone_low=MathMin(PositionGetDouble(POSITION_PRICE_OPEN),info.sellzone_low);
              }
           }
        }
     }
//---
   DrawBuyZone(info);
   DrawSellZone(info);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SetBuySellZoneFromPriceInClosureWorkGroup(trade_info  &info,double &buy_price[],double &sell_price[],
                                                               main_recovery_and_launch_setting &setting,
                                                               trailing_and_takeprofit_setting &profit_setting)
  {
   if(info.group_buy_volume+info.group_sell_volume<profit_setting.MinPart_For_Close) return;
   if(setting.VarSizeOfZone>0) return;
   if(info.restore_buy_volume+info.restore_sell_volume==0)
     {
      //---
      if(ArraySize(buy_price)>0)
        {
         if(info.buyzone_high==0) info.buyzone_high=buy_price[ArrayMaximum(buy_price)];
         if(info.buyzone_low==0) info.buyzone_low=buy_price[ArrayMinimum(buy_price)];
        }
      if(ArraySize(sell_price)>0)
        {
         if(info.sellzone_high==0) info.sellzone_high=sell_price[ArrayMaximum(sell_price)];
         if(info.sellzone_low==0) info.sellzone_low=sell_price[ArrayMinimum(sell_price)];
        }
      //---
      if(info.sellzone_high==0) info.sellzone_high=info.buyzone_high;
      if(info.sellzone_low==0) info.sellzone_low=info.buyzone_low;
      if(info.buyzone_high==0) info.buyzone_high=info.buyzone_high;
      if(info.buyzone_low==0) info.buyzone_low=info.buyzone_low;
      //---
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SelectOrderByWorkGroup(trade_info &info,long &list_buy[],long &list_sell[],
                                            main_recovery_and_launch_setting &setting,
                                            protection_setting &protec_setting,
                                            auto_calculation_setting &calc_setting)
  {
//---
   info.workgroup_buy_count=0;
   info.workgroup_buy_volume1=0;
   info.workgroup_buy_profit=0;
//---
   info.workgroup_sell_count=0;
   info.workgroup_sell_volume1=0;
   info.workgroup_sell_profit=0;
//---
   long for_buy[],for_sell[];
   for(int i=0;i<PositionsTotal(); i++)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      long magic=PositionGetInteger(POSITION_MAGIC);
      if(PositionGetString(POSITION_SYMBOL)!=info.symbol) continue;
      if(magic==setting.RecoverMagicNumber) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         switch((int)setting.Work_With)
           {
            case(int)All_orders_of_current_symbol:
               if(IsLongInArray(ticket,for_buy)) break;

               info.workgroup_buy_count++;
               info.workgroup_buy_volume1+=PositionGetDouble(POSITION_VOLUME);
               info.workgroup_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                           PositionGetDouble(POSITION_SWAP));
               AddLongToArray(ticket,for_buy);
               break;
            case(int)Manual_orders_of_the_current_synbol1:
               if(IsLongInArray(ticket,for_buy)) break;
               if(magic==0
                  || magic==setting.HedgeMagicNumber
                  || magic==calc_setting.DealButtonMagicNumber)
                 {
                  info.workgroup_buy_count++;
                  info.workgroup_buy_volume1+=PositionGetDouble(POSITION_VOLUME);
                  info.workgroup_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                              PositionGetDouble(POSITION_SWAP));
                  AddLongToArray(ticket,for_buy);
                 }
               else
                  if(protec_setting.Use_Addictional_MagicNumber
                     && magic==protec_setting.AdditionalMagicNumber)
                    {
                     info.workgroup_buy_count++;
                     info.workgroup_buy_volume1+=PositionGetDouble(POSITION_VOLUME);
                     info.workgroup_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                                 PositionGetDouble(POSITION_SWAP));
                     AddLongToArray(ticket,for_buy);
                    }
               break;
            case(int)Orders_of_the_current_symbol_with_same_dealbutton_magic:
               if(IsLongInArray(ticket,for_buy)) break;
               if(magic==setting.HedgeMagicNumber
                  || magic==calc_setting.DealButtonMagicNumber)
                 {
                  info.workgroup_buy_count++;
                  info.workgroup_buy_volume1+=PositionGetDouble(POSITION_VOLUME);
                  info.workgroup_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                              PositionGetDouble(POSITION_SWAP));
                  AddLongToArray(ticket,for_buy);
                 }
               else
                  if(protec_setting.Use_Addictional_MagicNumber
                     && magic==protec_setting.AdditionalMagicNumber)
                    {
                     info.workgroup_buy_count++;
                     info.workgroup_buy_volume1+=PositionGetDouble(POSITION_VOLUME);
                     info.workgroup_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                                 PositionGetDouble(POSITION_SWAP));
                     AddLongToArray(ticket,for_buy);
                    }
               break;
           }
        }
      //---
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {

         switch((int)setting.Work_With)
           {
            case(int)All_orders_of_current_symbol:
               if(IsLongInArray(ticket,for_sell)) break;
               info.workgroup_sell_count++;
               info.workgroup_sell_volume1+=PositionGetDouble(POSITION_VOLUME);
               info.workgroup_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                            PositionGetDouble(POSITION_SWAP));
               AddLongToArray(ticket,for_sell);
               break;
            case(int)Manual_orders_of_the_current_synbol1:
               if(IsLongInArray(ticket,for_sell)) break;
               if(magic==0
                  || magic==setting.HedgeMagicNumber
                  || magic==calc_setting.DealButtonMagicNumber)
                 {
                  info.workgroup_sell_count++;
                  info.workgroup_sell_volume1+=PositionGetDouble(POSITION_VOLUME);
                  info.workgroup_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                               PositionGetDouble(POSITION_SWAP));
                  AddLongToArray(ticket,for_sell);
                 }
               else
                  if(protec_setting.Use_Addictional_MagicNumber
                     && magic==protec_setting.AdditionalMagicNumber)
                    {
                     info.workgroup_sell_count++;
                     info.workgroup_sell_volume1+=PositionGetDouble(POSITION_VOLUME);
                     info.workgroup_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                                  PositionGetDouble(POSITION_SWAP));
                     AddLongToArray(ticket,for_sell);
                    }
               break;
            case(int)Orders_of_the_current_symbol_with_same_dealbutton_magic:
               if(IsLongInArray(ticket,for_sell)) break;
               if(magic==setting.HedgeMagicNumber
                  || magic==calc_setting.DealButtonMagicNumber)
                 {
                  info.workgroup_sell_count++;
                  info.workgroup_sell_volume1+=PositionGetDouble(POSITION_VOLUME);
                  info.workgroup_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                               PositionGetDouble(POSITION_SWAP));
                  AddLongToArray(ticket,for_sell);
                 }
               else
                  if(protec_setting.Use_Addictional_MagicNumber
                     && magic==protec_setting.AdditionalMagicNumber)
                    {
                     info.workgroup_sell_count++;
                     info.workgroup_sell_volume1+=PositionGetDouble(POSITION_VOLUME);
                     info.workgroup_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                                  PositionGetDouble(POSITION_SWAP));
                     AddLongToArray(ticket,for_sell);
                    }
               break;
           }
        }
     }
//---
   ArrayCopy(list_buy,for_buy);
   ArrayCopy(list_sell,for_sell);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryTrade::SelectOrderByRestoring(trade_info &info,long &list_buy[],long &list_sell[],
                                            main_recovery_and_launch_setting &setting)
  {
//---
   info.restore_buy_volume=0;
   info.restore_sell_volume=0;
   info.restore_buy_profit=0;
   info.restore_sell_profit=0;
//---
   long for_buy[],for_sell[];
   for(int i=0;i<PositionsTotal(); i++)
     {
      long ticket=(long)PositionGetTicket(i);
      if(!PositionSelectByTicket(ticket)) continue;
      if(PositionGetString(POSITION_SYMBOL)!=info.symbol) continue;
      long magic=PositionGetInteger(POSITION_MAGIC);
      if(magic!=setting.RecoverMagicNumber) continue;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         if(IsLongInArray(ticket,for_buy)) continue;
         AddLongToArray(ticket,for_buy);
         info.restore_buy_volume+=PositionGetDouble(POSITION_VOLUME);
         info.restore_buy_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                   PositionGetDouble(POSITION_SWAP));
        }
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(IsLongInArray(ticket,for_sell)) continue;
         AddLongToArray(ticket,for_sell);
         info.restore_sell_volume+=PositionGetDouble(POSITION_VOLUME);
         info.restore_sell_profit+=(PositionGetDouble(POSITION_PROFIT)+
                                    PositionGetDouble(POSITION_SWAP));
        }
     }
//---
   ArrayCopy(list_buy,for_buy);
   ArrayCopy(list_sell,for_sell);
  }
//+------------------------------------------------------------------+
bool   CRecoveryTrade::CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
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
