//+------------------------------------------------------------------+
//|                                                   EnumDefine.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   //---
   enum launch_mode
     {
      Instant_start,
      Start_at_drawndown_in_percent,
      Start_at_drawndown_in_money
     };
   //---
   enum group_for
     {
      All_orders_of_current_symbol,
      Manual_orders_of_the_current_synbol1,
      Orders_of_the_current_symbol_with_same_dealbutton_magic
     };
   //---
   enum start_profit_from
     {
      Start_with_the_nearest_order_to_profitability,
      Start_with_the_farest_order_to_profitability,
      Start_with_the_most_profit_order_to_profitability
     };
   //---
   enum order_open_method
     {
      Sell_zone_is_above_and_buy_zone_is_below,
      Buy_zone_is_above_and_sell_zone_is_below,
      No_separation
     };
   //---
   enum calculation_method
     {
      Manual_calculation,
      Middle_risk,
      MidleHigh_risk
     };
   //---
   enum order_type_filter
     {
      Buy_and_Sell_orders,
      Buy_orders,
      Sell_orders
     };
   //---
   enum indicator_filter
     {
      Filtering_via_Alligator,
      Filtering_via_Two_MAs,
      Filtering_via_PalabolicSAR,
      Filtering_via_Heiken_Ashi,
      Without_filtering
     };
        //---
   enum time_mode
     {
      time_local,
      time_current
     };
   //---
   //---
   enum scheme_apply
     {
      Medium_Scheme,
      Light_Scheme,
      Default_Scheme
     };
   //---
   enum order_group
     {
      Locked_group_of_orders,
      Restorative_group_of_orders
     };
   //---
   enum selection_method
     {
      Close_more_lots,
      Close_more_loss
     };
   //---
   struct order_process_info
     {
      long              ticket;
      double            volume;
      double            profit;
      double            distance;
      double            price;
     };
   //---
   struct trade_info
     {
      string            symbol;
      bool              type_buy;
      bool              type_sell;
      //---
      double            recovery_step_distance_for_buy;
      double            recovery_step_distance_for_sell;
      //--- market condition relate to zone condition A create buy above sell below
      int               for_buy_above_distance_of_ask_over_buyzone_high;
      int               for_sell_below_distance_of_bid_under_sellzone_low;
      //--- market condition relate to zone condition B create sell above buy below
      int               for_sell_above_distance_of_bid_over_sellzone_high;
      int               for_buy_below_distance_of_ask_under_buyzone_low;
      //---
      double            recovery_volume_for_sell1;
      double            recovery_volume_for_buy1;
      //---
      int               two_ma_signal;
      int               alligator_signal;
      int               heiken_ashi_signal;
      int               parabolic_sar_signal;
      double            restore_volume_set1;
      //---
      double            buyzone_high;
      double            buyzone_low;
      double            sellzone_high;
      double            sellzone_low;
      //---
      int               workgroup_buy_count;
      int               workgroup_sell_count;
      double            workgroup_buy_volume1;
      double            workgroup_sell_volume1;
      double            workgroup_buy_profit;
      double            workgroup_sell_profit;
      //---
      double            restore_buy_volume;
      double            restore_sell_volume;
      double            restore_buy_profit;
      double            restore_sell_profit;
      //---
      double            group_buy_volume;
      double            group_sell_volume;
      double            group_buy_profit;
      double            group_sell_profit;
      //---
      double            posible_workgroup_buy_volume;
      double            posible_workgroup_sell_volume;
      double            posible_workgroup_buy_profit;
      double            posible_workgroup_sell_profit;
      //---
      double            posible_restore_buy_volume;
      double            posible_restore_sell_volume;
      double            posible_restore_buy_profit;
      double            posible_restore_sell_profit;
      //---
      double            system_profit;
      double            current_group_profit;
      double            posible_workgroup_closure_profit;
      double            posible_restoring_closure_profit;
     };
   //---
   struct basic_structure
     {
      string            symbol;
      string            text;
      double            open_lots_of_dealbutton_panel;
      //---
      int               points;
      double            drawndown_money;
      double            drawndown_percent;
      double            drawndown_percent_max;
      //---
      bool              recovery_turn_on;
      bool              recovery_on_service;
     };
   struct color_scheme
     {
      color             caption_clr;
      color             caption_bgclr;
      color             caption_borderclor;
      color             group_clr;
      color             group_bgclr;
      color             group_borderclor;
      color             client_clr;
      color             client_bgclr;
      color             client_borderclor;
      color             edit_clr;
      color             edit_bgclr;
      color             edit_borderclor;
      color             label_clr;
      color             label_bgclr;
      color             label_borderclor;
      color             row_label_clr;
      color             row_label_bgclr;
      color             row_label_borderclor;
      color             button_clr;
      color             button_bgclr;
      color             button_borderclor;
      color             button_buy_clr;
      color             button_buy_bgclr;
      color             button_buy_borderclor;
      color             button_sell_clr;
      color             button_sell_bgclr;
      color             button_sell_borderclor;
     };
class CEnumDefine
  {
private:     
public:
  };
//+------------------------------------------------------------------+
