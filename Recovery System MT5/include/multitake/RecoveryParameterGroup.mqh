//+------------------------------------------------------------------+
//|                                       RecoveryParameterGroup.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "EnumDefine.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   struct main_recovery_and_launch_setting
     {
      launch_mode       Work_Mode;//Type of the launch
      double            Drawdown_for_Start;//Drawdown in percentage or in money to run
      group_for         Work_With;//Group of orders for recovery
      start_profit_from OrdersSelector;//Order selection procedure
     // calculation_method RiskManagment;//???
      int               RecoverMagicNumber;
      int               HedgeMagicNumber;
      order_open_method TypeOfZones;//Type of location for recovery zone
      int               VarSizeOfZone;//Size of recovery zome in Point(0-AutoSize)
      bool              Locking;//Allow auto locking
     };
   //---
   struct recovery_order_setting
     {
      bool              CanTradeBothSides;
      order_type_filter RecTypeOpen;
      indicator_filter  Trend_Filter_Grids;
      double            MinRecStartLots;
      double            Multiplier;
      int               Start_Step_Grids;
      double            Step_Multiplier;
     };
   //---
   struct trailing_and_takeprofit_setting
     {
      double            MinPart_For_Close;
      double            TakeProfit_System_Money;
      double            TakeProfit_Closure_Money;
      double            TakeProfit_Possible_System_Money;
      double            TakeProfit_Possible_Recovery_Money;
  //    bool              OverLap_LH;
    //  int               Overlap_after;
     };
   //---
   struct notification_setting
     {
      bool              Send_Push_Notifications;
      bool              Send_Mail;
      bool              Send_PopUp_Alerts;
      string            Mail_Subject;
     };
      //---
   struct time_trade_setting
     {
      time_mode         mode;
      bool              enable[];
      bool              state[];
      string            start_input[];
      string            stop_input[];
     };  
   //---
   struct protection_setting
     {
  //    bool              Close_Another_Charts;
   //   bool              One_order_per_bar;
      bool              Delete_SL_TP;
   //   bool              Close_Profit_At_Start;
  //    bool              Delete_Pendings_At_Start;
   //   bool              TrueECN_Type_of_account;
      int               Slippage;
      int               Spread_Limit;
      double            Maximum_Order_Size;
      int               Maximum_Orders_In_Work;
      string            RecoveryComment;
      bool              Use_Addictional_MagicNumber;
      int               AdditionalMagicNumber;
      //--
      string            LockedOrderComment;
     };
   //---
   struct auto_calculation_setting
     {
      double            MaxRecStartLots;//
      double            MaxPartForClose;//
      int               Maximum_Step_between_Ord;//Maximal step between orders
      int               Minimum_Step_between_Ord;
  //    selection_method  Closures_Type;//Type of selection method for orders
      double            QOpen_Lots;//Opened lot size of DealButton panel
    //  order_group       Orders_Type_DealButtons;//Group of opened orders
      //---
      int               DealButtonMagicNumber;
      double            MultiplierFactorToClosureLots;
      //---
      double            MinClosureStartLots;//Miimal size of lock order to closure
      double            MaxClosureStartLots;//Maximal size of lock order to closure
     };
   //---
   struct graphic_setting
     {
      scheme_apply      Color_Scheme;
      int               FontSize;
      bool              ShowPanels;
      bool              ShowSystemPanel;
      bool              ShowPClosureSystemPanel;
      bool              ShowPClosureRecoveryPanel;
      bool              ShowRecoveryGroupPanel;
      bool              RightDealButtonPanel;
      //---
     };
   //---
   struct indicator_parabolic_sar_setting
     {
      ENUM_TIMEFRAMES   SAR_Timeframe;
      double            step_SAR;
      double            maximum_SAR;
      //---
      bool              reverse_signal;//signal type to apply
     };
   //---
   struct indicator_alligator_setting
     {
      ENUM_TIMEFRAMES   Alligator_Timeframe;
      int               jaw_period;
      int               jaw_shift;
      int               teeth_period;
      int               teeth_shift;
      int               lips_period;
      int               lips_shift;
      ENUM_MA_METHOD    ma_method_Alligator;
      ENUM_APPLIED_PRICE applied_price_Alligator;
      //---
      bool              reverse_signal;//signal type to apply   
     };
   //---
   struct indicator_2ma_setting
     {
      ENUM_TIMEFRAMES   MAS_Timeframe;
      int               period_MA1;
      ENUM_MA_METHOD    ma_method_MA1;
      ENUM_APPLIED_PRICE applied_price_MA1;
      int               period_MA2;
      ENUM_MA_METHOD    ma_method_MA2;
      ENUM_APPLIED_PRICE applied_price_MA2;
      //
      bool              reverse_signal;//signal type to apply
     };
   //---
   struct indicator_heiken_ashi_setting
     {
      ENUM_TIMEFRAMES   HARSI_Timeframe;
      //
      bool              reverse_signal;//signal type to apply
     };
   //---
class CRecoveryParameterGroup
  {
private:   
public:
  };
//+------------------------------------------------------------------+
