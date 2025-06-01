//+------------------------------------------------------------------+
//|                                          Recovery System MT5.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include <multitake\EnumDefine.mqh>
#include <multitake\MyTrade.mqh>
#include <multitake\TradeUtility.mqh>
#include <multitake\RecoveryPanel.mqh>
#include <multitake\BasicTradeClass.mqh>
#include <multitake\RecoveryParameterGroup.mqh>
#include <multitake\RecoveryTrade.mqh>
#include <multitake\signal\TwoMaSignal.mqh>
#include <multitake\signal\ParabolicSarSignal.mqh>
#include <multitake\signal\AlligatorSignal.mqh>
#include <multitake\signal\HeikenAshiSignal.mqh>

//+------------------------------------------------------------------+
//| Input Parameters for Automatic Entry                             |
//+------------------------------------------------------------------+
enum ENTRY_MODE {
   Manual = 0,       // Manual Entry
   TimeBased = 1,    // Time-Based Entry
   SNRBased = 2      // SNR-Based Entry
};

input ENTRY_MODE EntryMode = Manual;      // Automatic Entry Mode
input int StartHour = 9;                  // Start Hour (0-23) for Time-Based Entry
input int EndHour = 17;                   // End Hour (0-23) for Time-Based Entry
input double SNRLevel = 50.0;             // SNR Threshold in points for XAUUSD
input long RecoverMagicNumberInput = 123454321; // Magic Number for Recovery Orders

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CMyTrade trade_recover_order;
CMyTrade trade_dealbutton_order;
CMyTrade trade_hedge_order;
CTradeUtility utility;
CRecoveryPanel recovery_panel;
CBasicTradeClass basic;
basic_structure data_structure;
CRecoveryTrade lock;
trade_info expert_info;
CTwoMaSignal ind_two_ma;
CParabolicSarSignal ind_sar;
CAlligatorSignal ind_alligator;
CHeikenAshiSignal ind_heiken;

time_trade_setting TimeTradeSetting;
main_recovery_and_launch_setting MainRecoveryAndLaunchSetting;
recovery_order_setting RecoveryOrderSetting;
trailing_and_takeprofit_setting TrailingAndTakeProfitSetting;
notification_setting NotificationSetting;
protection_setting ProtectionSetting;
auto_calculation_setting AutoCalcuationSetting;
graphic_setting GraphicSetting;
indicator_parabolic_sar_setting IndicatorParabolicSarSetting;
indicator_alligator_setting IndicatorAlligatorSetting;
indicator_2ma_setting IndicatorTwoMASetting;
indicator_heiken_ashi_setting IndicatorHeikenAshiSetting;

bool indicatorsAttached = false;

//+------------------------------------------------------------------+
//| Input Parameters (Your Settings)                                 |
//+------------------------------------------------------------------+
sinput string Settings_bworkgroup_1="           MAIN RECOVERY AND LAUNCH SETTINGS";
input launch_mode Work_Mode=Start_at_drawndown_in_money;
input double Drawdown_for_Start=200.0;
input group_for Work_With=All_orders_of_current_symbol;
input start_profit_from OrdersSelector=Start_with_the_farest_order_to_profitability;
input calculation_method RiskManagment=Manual_calculation;
input int RecoverMagicNumber=123454321;
input int HedgeMagicNumber=5667;
input order_open_method TypeOfZones=Sell_zone_is_above_and_buy_zone_is_below;
input int VarSizeOfZone=500;
input bool Locking=true;
input string LockedOrderComment="lock order";

sinput string Settings_bworkgroup_2="           RECOVERY ORDERS SETTINGS";
input bool CanTradeBothSides=false;
input order_type_filter RecTypeOpen=Buy_and_Sell_orders;
input indicator_filter Trend_Filter_Grids=Filtering_via_Two_MAs;
input double MinRecStartLots=0.02;
input double Multiplier=1.0;
input int Start_Step_Grids=1000;
input double Step_Multiplier=1.0;

sinput string Settings_bworkgroup_3="           TRAILING AND TAKEPROFIT SETTINGS";
input double MinPart_For_Close=0.01;
input double TakeProfit_Closure_Money=10;
input double TakeProfit_System_Money=10;

sinput string Settings_bworkgroup_4="           NOTIFICATIONS SETTINGS";
input bool Send_Push_Notifications=false;
input bool Send_Mail=false;
input bool Send_PopUp_Alerts=false;

sinput string Settings_bworkgroup_5="           PROTECTION SETTINGS";
bool Close_Another_Charts=true;
bool One_order_per_bar=true;
input bool Delete_SL_TP=true;
bool Close_Profit_At_Start=true;
bool Delete_Pendings_At_Start=true;
bool TrueECN_Type_of_account=false;
input int Slippage=30;
input int Spread_Limit=75;
input double Maximum_Order_Size=2.0;
input int Maximum_Orders_In_Work=100;
input string RecoveryComment="recover order";
input bool Use_Addictional_Magic=true;
input int Addictional_Magic=567;

sinput string Settings_bworkgroup_6="           AUTOCALCULATIONS SETTINGS";
input double MaxRecStartLots=10.0;
input double MaxPartForClose=0.1;
input int Maximum_Step_between_Ord=5000;
input int Minimum_Step_between_Ord=500;
input double MultiplierFactorToClosureLots=4.0;
input double MinClosureStartLots=0.01;
input double MaxClosureStartLots=10.0;
selection_method Closures_Type=Close_more_loss;
input double QOpen_Lots=0.01;
order_group Orders_Type_DealButtons=Locked_group_of_orders;
input int DealButtonMagicNumber=455;

sinput string Settings_bworkgroup_8="           GRAPHICS SETTINGS";
input scheme_apply Color_Scheme=Default_Scheme;
input int FontSize=8;
input bool ShowPanels=true;
input bool RightDealButtonPanel=false;

sinput string SAR_Settings="           INDICATORS - PARABOLIC SAR SETTINGS";
input ENUM_TIMEFRAMES SAR_Timeframe=PERIOD_CURRENT;
input double step_SAR=0.02;
input double maximum_SAR=0.2;

sinput string Alligator_Settings="           INDICATORS - ALLIGATOR SETTINGS";
input ENUM_TIMEFRAMES Alligator_Timeframe=PERIOD_CURRENT;
input int jaw_period=13;
input int jaw_shift=8;
input int teeth_period=8;
input int teeth_shift=5;
input int lips_period=5;
input int lips_shift=3;
input ENUM_MA_METHOD ma_method_Alligator=MODE_EMA;
input ENUM_APPLIED_PRICE applied_price_Alligator=PRICE_MEDIAN;

sinput string TwoMA_Settings="           INDICATORS - 2MA SETTINGS";
input ENUM_TIMEFRAMES MAS_Timeframe=PERIOD_M5;
input int period_MA1=1;
input ENUM_MA_METHOD ma_method_MA1=MODE_EMA;
input ENUM_APPLIED_PRICE applied_price_MA1=PRICE_CLOSE;
input int period_MA2=12;
input ENUM_MA_METHOD ma_method_MA2=MODE_EMA;
input ENUM_APPLIED_PRICE applied_price_MA2=PRICE_CLOSE;

sinput string HAshi_Settings="           INDICATORS - HEIKEN ASHI SETTINGS";
input ENUM_TIMEFRAMES HARSI_Timeframe=PERIOD_CURRENT;

//+------------------------------------------------------------------+
//| Expert Initialization Function                                   |
//+------------------------------------------------------------------+
int OnInit() {
   if(!MQLInfoInteger(MQL_VISUAL_MODE))
      ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,true);
   else
      ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,false);

   // Initialize settings
   MainRecoveryAndLaunchSetting.Work_Mode=Work_Mode;
   MainRecoveryAndLaunchSetting.Drawdown_for_Start=Drawdown_for_Start;
   MainRecoveryAndLaunchSetting.Work_With=Work_With;
   MainRecoveryAndLaunchSetting.OrdersSelector=OrdersSelector;
   MainRecoveryAndLaunchSetting.RecoverMagicNumber=RecoverMagicNumber;
   MainRecoveryAndLaunchSetting.HedgeMagicNumber=HedgeMagicNumber;
   MainRecoveryAndLaunchSetting.TypeOfZones=TypeOfZones;
   MainRecoveryAndLaunchSetting.VarSizeOfZone=VarSizeOfZone;
   MainRecoveryAndLaunchSetting.Locking=Locking;

   RecoveryOrderSetting.CanTradeBothSides=CanTradeBothSides;
   RecoveryOrderSetting.MinRecStartLots=MinRecStartLots;
   RecoveryOrderSetting.RecTypeOpen=RecTypeOpen;
   RecoveryOrderSetting.Trend_Filter_Grids=Trend_Filter_Grids;
   RecoveryOrderSetting.Multiplier=Multiplier;
   RecoveryOrderSetting.Start_Step_Grids=Start_Step_Grids;
   RecoveryOrderSetting.Step_Multiplier=Step_Multiplier;

   TrailingAndTakeProfitSetting.MinPart_For_Close=MinPart_For_Close;
   TrailingAndTakeProfitSetting.TakeProfit_System_Money=TakeProfit_System_Money;
   TrailingAndTakeProfitSetting.TakeProfit_Closure_Money=TakeProfit_Closure_Money;

   NotificationSetting.Send_Push_Notifications=Send_Push_Notifications;
   NotificationSetting.Send_Mail=Send_Mail;
   NotificationSetting.Send_PopUp_Alerts=Send_PopUp_Alerts;
   NotificationSetting.Mail_Subject="Notify from Recovery System MT5";

   ProtectionSetting.Delete_SL_TP=Delete_SL_TP;
   ProtectionSetting.Slippage=Slippage;
   ProtectionSetting.Spread_Limit=Spread_Limit;
   ProtectionSetting.Maximum_Order_Size=Maximum_Order_Size;
   ProtectionSetting.Maximum_Orders_In_Work=Maximum_Orders_In_Work;
   ProtectionSetting.AdditionalMagicNumber=Addictional_Magic;
   ProtectionSetting.RecoveryComment=RecoveryComment;
   ProtectionSetting.LockedOrderComment=LockedOrderComment;

   AutoCalcuationSetting.MultiplierFactorToClosureLots=MultiplierFactorToClosureLots;
   AutoCalcuationSetting.MinClosureStartLots=MinClosureStartLots;
   AutoCalcuationSetting.MaxClosureStartLots=MaxClosureStartLots;
   AutoCalcuationSetting.MaxRecStartLots=MaxRecStartLots;
   AutoCalcuationSetting.MaxPartForClose=MaxPartForClose;
   AutoCalcuationSetting.Maximum_Step_between_Ord=Maximum_Step_between_Ord;
   AutoCalcuationSetting.Minimum_Step_between_Ord=Minimum_Step_between_Ord;
   AutoCalcuationSetting.QOpen_Lots=QOpen_Lots;
   AutoCalcuationSetting.DealButtonMagicNumber=DealButtonMagicNumber;

   GraphicSetting.Color_Scheme=Color_Scheme;
   GraphicSetting.ShowPanels=ShowPanels;
   GraphicSetting.FontSize=FontSize;
   GraphicSetting.RightDealButtonPanel=RightDealButtonPanel;
   if(GraphicSetting.ShowPanels) {
      GraphicSetting.ShowSystemPanel=true;
      GraphicSetting.ShowRecoveryGroupPanel=true;
      GraphicSetting.ShowPClosureSystemPanel=false;
      GraphicSetting.ShowPClosureRecoveryPanel=true;

      if(MQLInfoInteger(MQL_TESTER)) {
         GraphicSetting.ShowPClosureSystemPanel=true;
         GraphicSetting.ShowPClosureRecoveryPanel=false;
      }
   } else {
      GraphicSetting.ShowSystemPanel=false;
      GraphicSetting.ShowRecoveryGroupPanel=false;
      GraphicSetting.ShowPClosureSystemPanel=false;
      GraphicSetting.ShowPClosureRecoveryPanel=false;
   }

   IndicatorParabolicSarSetting.reverse_signal=false;
   IndicatorParabolicSarSetting.SAR_Timeframe=SAR_Timeframe;
   IndicatorParabolicSarSetting.step_SAR=step_SAR;
   IndicatorParabolicSarSetting.maximum_SAR=maximum_SAR;

   IndicatorAlligatorSetting.reverse_signal=false;
   IndicatorAlligatorSetting.Alligator_Timeframe=Alligator_Timeframe;
   IndicatorAlligatorSetting.jaw_period=jaw_period;
   IndicatorAlligatorSetting.jaw_shift=jaw_shift;
   IndicatorAlligatorSetting.teeth_period=teeth_period;
   IndicatorAlligatorSetting.teeth_shift=teeth_shift;
   IndicatorAlligatorSetting.lips_period=lips_period;
   IndicatorAlligatorSetting.lips_shift=lips_shift;
   IndicatorAlligatorSetting.ma_method_Alligator=ma_method_Alligator;
   IndicatorAlligatorSetting.applied_price_Alligator=applied_price_Alligator;

   IndicatorTwoMASetting.reverse_signal=false;
   IndicatorTwoMASetting.MAS_Timeframe=MAS_Timeframe;
   IndicatorTwoMASetting.period_MA1=period_MA1;
   IndicatorTwoMASetting.ma_method_MA1=ma_method_MA1;
   IndicatorTwoMASetting.applied_price_MA1=applied_price_MA1;
   IndicatorTwoMASetting.period_MA2=period_MA2;
   IndicatorTwoMASetting.ma_method_MA2=ma_method_MA2;
   IndicatorTwoMASetting.applied_price_MA2=applied_price_MA2;

   IndicatorHeikenAshiSetting.reverse_signal=false;
   IndicatorHeikenAshiSetting.HARSI_Timeframe=HARSI_Timeframe;

   data_structure.recovery_turn_on=false;
   data_structure.recovery_on_service=false;
   data_structure.open_lots_of_dealbutton_panel=AutoCalcuationSetting.QOpen_Lots;

   EventSetTimer(60);
   expert_info.symbol=ChartSymbol();
   data_structure.symbol=expert_info.symbol;
   recovery_panel.Initilize(GraphicSetting);

   trade_dealbutton_order.SetExpertMagicNumber(AutoCalcuationSetting.DealButtonMagicNumber);
   trade_hedge_order.SetExpertMagicNumber(MainRecoveryAndLaunchSetting.HedgeMagicNumber);
   trade_recover_order.SetExpertMagicNumber(MainRecoveryAndLaunchSetting.RecoverMagicNumber);
   trade_recover_order.SetDeviationInPoints(ProtectionSetting.Slippage);

   if(MQLInfoInteger(MQL_TESTER)) {
      data_structure.text="testing order";
      basic.OpenSell(GetPointer(trade_dealbutton_order),data_structure,TimeTradeSetting,NotificationSetting);
      data_structure.text="deal_button";
      lock.SelectOrders(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TrailingAndTakeProfitSetting,ProtectionSetting);
   }

   expert_info.buyzone_high=0;
   expert_info.buyzone_low=0;
   expert_info.sellzone_high=0;
   expert_info.sellzone_low=0;
   expert_info.recovery_volume_for_buy1=0;
   expert_info.recovery_volume_for_sell1=0;

   lock.SelectOrders(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TrailingAndTakeProfitSetting,ProtectionSetting);
   lock.ProcessTradeInfo(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TrailingAndTakeProfitSetting,ProtectionSetting);

   // Attach indicators only once during initialization
   if (!indicatorsAttached) {
      ind_two_ma.Initialize(expert_info,IndicatorTwoMASetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_sar.Initialize(expert_info,IndicatorParabolicSarSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_heiken.Initialize(expert_info,IndicatorHeikenAshiSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_alligator.Initialize(expert_info,IndicatorAlligatorSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_two_ma.AttachToChart(expert_info,IndicatorTwoMASetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_sar.AttachToChart(expert_info,IndicatorParabolicSarSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_heiken.AttachToChart(expert_info,IndicatorHeikenAshiSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_alligator.AttachToChart(expert_info,IndicatorAlligatorSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      indicatorsAttached = true;
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert Deinitialization Function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   EventKillTimer();
   // Clean up GUI elements (removed DeInit call due to undeclared identifier)
   // Assuming CRecoveryPanel handles cleanup in its destructor
   // Release indicators
   ind_two_ma.Release(expert_info,IndicatorTwoMASetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
   ind_sar.Release(expert_info,IndicatorParabolicSarSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
   ind_heiken.Release(expert_info,IndicatorHeikenAshiSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
   ind_alligator.Release(expert_info,IndicatorAlligatorSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
}

//+------------------------------------------------------------------+
//| Expert Tick Function                                             |
//+------------------------------------------------------------------+
void OnTick() {
   // Automatic entry logic
   if (EntryMode == TimeBased) {
      MqlDateTime time;
      TimeCurrent(time);
      if (time.hour >= StartHour && time.hour < EndHour && !data_structure.recovery_on_service) {
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         basic.OpenBuy(GetPointer(trade_dealbutton_order), data_structure, TimeTradeSetting, NotificationSetting);
         Print("Time-Based Entry Triggered at ", TimeToString(TimeCurrent()));
      }
   } else if (EntryMode == SNRBased) {
      double snr = CalculateSNR();
      if (snr > SNRLevel && !data_structure.recovery_on_service) {
         double price = SymbolInfoDouble(_Symbol, SYMBOL_BID);
         basic.OpenBuy(GetPointer(trade_dealbutton_order), data_structure, TimeTradeSetting, NotificationSetting);
         Print("SNR-Based Entry Triggered with SNR = ", snr);
      }
   }

   // Manage recovery orders to prevent abandonment
   ManageRecoveryOrders();

   // Existing OnTick logic
   if(data_structure.recovery_on_service) {
      ind_two_ma.Refresh(expert_info,IndicatorTwoMASetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_sar.Refresh(expert_info,IndicatorParabolicSarSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_heiken.Refresh(expert_info,IndicatorHeikenAshiSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
      ind_alligator.Refresh(expert_info,IndicatorAlligatorSetting,RecoveryOrderSetting,TimeTradeSetting,NotificationSetting);
   }

   LaunchControl(expert_info,MainRecoveryAndLaunchSetting,data_structure,NotificationSetting);

   if(data_structure.recovery_turn_on) {
      data_structure.recovery_turn_on=false;
      data_structure.recovery_on_service=true;
   }

   if(data_structure.recovery_on_service) {
      if(MainRecoveryAndLaunchSetting.Locking)
         lock.ProcessLockPosition(GetPointer(trade_hedge_order),expert_info,
                                  MainRecoveryAndLaunchSetting,
                                  ProtectionSetting,
                                  AutoCalcuationSetting,
                                  TrailingAndTakeProfitSetting,
                                  TimeTradeSetting,
                                  NotificationSetting);
      lock.AddRestoringOrder(GetPointer(trade_recover_order),expert_info,
                             MainRecoveryAndLaunchSetting,
                             RecoveryOrderSetting,
                             AutoCalcuationSetting,
                             ProtectionSetting,
                             TimeTradeSetting,
                             NotificationSetting);
      if(expert_info.current_group_profit>TrailingAndTakeProfitSetting.TakeProfit_Closure_Money
         && TrailingAndTakeProfitSetting.TakeProfit_Closure_Money>0) {
         lock.CloseClosureGroup(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TimeTradeSetting,NotificationSetting);
         expert_info.recovery_step_distance_for_buy=RecoveryOrderSetting.Start_Step_Grids;
         expert_info.recovery_step_distance_for_sell=RecoveryOrderSetting.Start_Step_Grids;
         expert_info.recovery_volume_for_buy1=0;
         expert_info.recovery_volume_for_sell1=0;
      }
      if(expert_info.system_profit>TrailingAndTakeProfitSetting.TakeProfit_System_Money
         && TrailingAndTakeProfitSetting.TakeProfit_System_Money>0) {
         lock.CloseAllSystem(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,
                             TrailingAndTakeProfitSetting,TimeTradeSetting,NotificationSetting);
         expert_info.recovery_step_distance_for_buy=RecoveryOrderSetting.Start_Step_Grids;
         expert_info.recovery_step_distance_for_sell=RecoveryOrderSetting.Start_Step_Grids;
         expert_info.recovery_volume_for_buy1=0;
         expert_info.recovery_volume_for_sell1=0;
      }
      lock.CalculateBuySellZone(expert_info,MainRecoveryAndLaunchSetting,TrailingAndTakeProfitSetting);
   }

   if(MQLInfoInteger(MQL_VISUAL_MODE)) CheckButton(expert_info);
   Drawndown();
   ProcessDataForPanel();
}

//+------------------------------------------------------------------+
//| Calculate SNR for XAUUSD                                         |
//+------------------------------------------------------------------+
double CalculateSNR() {
   double high = iHigh(_Symbol, PERIOD_D1, 0);  // Daily high
   double low = iLow(_Symbol, PERIOD_D1, 0);    // Daily low
   double close = iClose(_Symbol, PERIOD_M5, 0); // Current M5 close
   double range = high - low;
   if (range == 0) return 0.0;
   double snr = MathAbs(close - low) / range * 100.0;
   return snr;
}

//+------------------------------------------------------------------+
//| Manage Recovery Orders with Timeout                              |
//+------------------------------------------------------------------+
void ManageRecoveryOrders() {
   for (int i = PositionsTotal() - 1; i >= 0; i--) {
      if (PositionSelectByTicket(PositionGetTicket(i))) {
         if (PositionGetInteger(POSITION_MAGIC) == RecoverMagicNumber) {
            datetime openTime = (datetime)PositionGetInteger(POSITION_TIME);
            if (TimeCurrent() - openTime > 3600) { // 1-hour timeout
               trade_recover_order.PositionClose(PositionGetTicket(i));
               Print("Recovery Order Closed due to Timeout: Ticket #", PositionGetTicket(i));
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Existing Functions (Unchanged)                                   |
//+------------------------------------------------------------------+
void OnTimer() {}

void OnTrade() {
   lock.SelectOrders(expert_info,MainRecoveryAndLaunchSetting,
                     AutoCalcuationSetting,
                     TrailingAndTakeProfitSetting,
                     ProtectionSetting);
   lock.ProcessTradeInfo(expert_info,MainRecoveryAndLaunchSetting,
                         AutoCalcuationSetting,
                         TrailingAndTakeProfitSetting,
                         ProtectionSetting);
}

void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result) {}

double OnTester() {
   return 0.0;
}

void OnTesterInit() {}
void OnTesterPass() {}
void OnTesterDeinit() {}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   recovery_panel.OnEvent(id,lparam,dparam,sparam);
   OnButtonsClick(id,lparam,dparam,sparam);
   ChartRedraw();
}

void OnBookEvent(const string &symbol) {}

void LaunchControl(trade_info &info,main_recovery_and_launch_setting &setting,basic_structure &structure,
                   notification_setting &notify_setting) {
   string messege="";
   if(structure.recovery_on_service
      && info.workgroup_buy_volume1+info.workgroup_sell_volume1==0) {
      messege="End of Recovery Processing";
      switch(setting.Work_Mode) {
         case Instant_start:
            structure.recovery_on_service=false;
            messege+=StringFormat(" in Instant Start Mode resulting the balance=%s %.2f.",
                                  AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
            break;
         case Start_at_drawndown_in_percent:
            structure.recovery_on_service=false;
            messege+=StringFormat(" in DrawnDown Percent Mode result the balance=%s %.2f.",
                                  AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
            break;
         case Start_at_drawndown_in_money:
            structure.recovery_on_service=false;
            messege+=StringFormat(" in DrawnDown Money Mode resulting the balance=%s %.2f.",
                                  AccountInfoString(ACCOUNT_CURRENCY),AccountInfoDouble(ACCOUNT_BALANCE));
            break;
      }
      if(!structure.recovery_on_service && !structure.recovery_turn_on) {
         if(notify_setting.Send_Mail) SendMail(notify_setting.Mail_Subject,messege);
         if(notify_setting.Send_Push_Notifications) SendNotification(messege);
         if(notify_setting.Send_PopUp_Alerts) Alert(messege);
         Print(messege);
      }
   }
   if(!structure.recovery_turn_on
      && !structure.recovery_on_service
      && info.workgroup_buy_volume1+info.workgroup_sell_volume1>0) {
      messege="Start Recovery Processing";
      switch(setting.Work_Mode) {
         case Instant_start:
            structure.recovery_turn_on=true;
            messege+=" with Instant Start Mode.";
            break;
         case Start_at_drawndown_in_percent:
            if(structure.drawndown_percent>setting.Drawdown_for_Start) {
               structure.recovery_turn_on=true;
               messege+=StringFormat(" with DrawnDown Percent=%.2f hit target value=%.2f.",
                                     structure.drawndown_percent,setting.Drawdown_for_Start);
            }
            break;
         case Start_at_drawndown_in_money:
            if(structure.drawndown_money>setting.Drawdown_for_Start) {
               structure.recovery_turn_on=true;
               messege+=StringFormat(" with DrawnDown Money=%.2f hit target value=%.2f.",
                                     structure.drawndown_money,setting.Drawdown_for_Start);
            }
            break;
      }
      if(structure.recovery_turn_on && !structure.recovery_on_service) {
         if(notify_setting.Send_Mail) SendMail(notify_setting.Mail_Subject,messege);
         if(notify_setting.Send_Push_Notifications) SendNotification(messege);
         if(notify_setting.Send_PopUp_Alerts) Alert(messege);
         Print(messege);
      }
   }
}

void OnButtonsClick(const int id,const long &lparam,const double &dparam,const string &sparam) {
   if(id==CHARTEVENT_OBJECT_CLICK) {
      if(sparam=="BUTT_BUY")  basic.OpenBuy(GetPointer(trade_dealbutton_order),data_structure,TimeTradeSetting,NotificationSetting);
      if(sparam=="BUTT_SELL") basic.OpenSell(GetPointer(trade_dealbutton_order),data_structure,TimeTradeSetting,NotificationSetting);
      if(sparam=="BUTT_CLOSE_GROUP") lock.CloseClosureGroup(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TimeTradeSetting,NotificationSetting);
      if(sparam=="BUTT_CLOSE_ALL") lock.CloseAllSystem(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TrailingAndTakeProfitSetting,TimeTradeSetting,NotificationSetting);
      if(sparam=="BUTT_CLOSE_1") lock.ClosePosibleWorkGroup(expert_info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,TimeTradeSetting,NotificationSetting);
      if(sparam=="BUTT_CLOSE_2") lock.ClosePosibleRestore(expert_info,AutoCalcuationSetting,TimeTradeSetting,NotificationSetting);
   }
}

void CheckButton(trade_info &info) {
   if(recovery_panel.IsButtonPress(0)) {
      Sleep(1000);
      recovery_panel.ResetButtonPress(0);
      lock.CloseAllSystem(info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,
                          TrailingAndTakeProfitSetting,TimeTradeSetting,NotificationSetting);
   }
   if(recovery_panel.IsButtonPress(1)) {
      Sleep(1000);
      recovery_panel.ResetButtonPress(1);
      lock.ClosePosibleWorkGroup(info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,
                                 TimeTradeSetting,NotificationSetting);
   }
   if(recovery_panel.IsButtonPress(2)) {
      Sleep(1000);
      recovery_panel.ResetButtonPress(2);
      lock.CloseClosureGroup(info,MainRecoveryAndLaunchSetting,AutoCalcuationSetting,
                             TimeTradeSetting,NotificationSetting);
   }
   if(recovery_panel.IsButtonPress(3)) {
      Sleep(1000);
      recovery_panel.ResetButtonPress(3);
      basic.OpenSell(GetPointer(trade_dealbutton_order),data_structure,TimeTradeSetting,NotificationSetting);
   }
   if(recovery_panel.IsButtonPress(4)) {
      Sleep(1000);
      recovery_panel.ResetButtonPress(4);
      basic.OpenBuy(GetPointer(trade_dealbutton_order),data_structure,TimeTradeSetting,NotificationSetting);
   }
   if(recovery_panel.IsButtonPress(5)) {
      Sleep(1000);
      recovery_panel.ResetButtonPress(5);
      lock.ClosePosibleRestore(info,AutoCalcuationSetting,TimeTradeSetting,NotificationSetting);
   }
}

void ProcessDataForPanel() {
   lock.SelectOrders(expert_info,MainRecoveryAndLaunchSetting,
                     AutoCalcuationSetting,
                     TrailingAndTakeProfitSetting,
                     ProtectionSetting);
   lock.ProcessTradeInfo(expert_info,MainRecoveryAndLaunchSetting,
                         AutoCalcuationSetting,
                         TrailingAndTakeProfitSetting,
                         ProtectionSetting);
   SetGroupPanel(expert_info);
   SetSystemPanel(expert_info);
   SetPosibleClosurePanel(expert_info);
   if(data_structure.drawndown_percent_max>0)
      data_structure.drawndown_percent_max=MathMax(data_structure.drawndown_percent_max,
                                                   data_structure.drawndown_percent);
   else data_structure.drawndown_percent_max=data_structure.drawndown_percent;
   recovery_panel.SetLots(data_structure.open_lots_of_dealbutton_panel);
   data_structure.points=(int)SymbolInfoInteger(data_structure.symbol,SYMBOL_SPREAD);
   recovery_panel.SetPoint(data_structure.points);
   recovery_panel.SetDrawndown(data_structure.drawndown_percent,
                               data_structure.drawndown_percent_max);
}

void SetPosibleClosurePanel(trade_info &info) {
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   recovery_panel.SetLabel(1,1,
                           "Locked orders buy",
                           DoubleToString(info.posible_workgroup_buy_volume,2),
                           DoubleToString(info.posible_workgroup_buy_profit,2),
                           curr_);
   recovery_panel.SetLabel(1,2,
                           "Locked orders sell",
                           DoubleToString(info.posible_workgroup_sell_volume,2),
                           DoubleToString(info.posible_workgroup_sell_profit,2),
                           curr_);
   info.posible_workgroup_closure_profit=info.posible_workgroup_sell_profit+
                                         info.posible_workgroup_buy_profit;
   recovery_panel.SetLockPosibleProfit(DoubleToString(info.posible_workgroup_sell_volume+
                                       info.posible_workgroup_buy_volume,2),
                                       DoubleToString(info.posible_workgroup_closure_profit,2),
                                       curr_);
   recovery_panel.SetLabel(3,1,
                           "Restore orders buy",
                           DoubleToString(info.posible_restore_buy_volume,2),
                           DoubleToString(info.posible_restore_buy_profit,2),
                           curr_);
   recovery_panel.SetLabel(3,2,
                           "Restore orders sell",
                           DoubleToString(info.posible_restore_sell_volume,2),
                           DoubleToString(info.posible_restore_sell_profit,2),
                           curr_);
   info.posible_restoring_closure_profit=info.posible_restore_sell_profit+
                                         info.posible_restore_buy_profit;
   recovery_panel.SetRestorePosibleProfit(DoubleToString(info.posible_restore_sell_volume+
                                          info.posible_restore_buy_volume,2),
                                          DoubleToString(info.posible_restoring_closure_profit,2),
                                          curr_);
}

void SetGroupPanel(trade_info &info) {
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   recovery_panel.SetLabel(2,1,
                           "Orders buy",
                           DoubleToString(info.group_buy_volume,2),
                           DoubleToString(info.group_buy_profit,2),
                           curr_);
   recovery_panel.SetLabel(2,2,
                           "Orders sell",
                           DoubleToString(info.group_sell_volume,2),
                           DoubleToString(info.group_sell_profit,2),
                           curr_);
   recovery_panel.SetLabel(2,3,
                           "Restore orders buy",
                           DoubleToString(info.restore_buy_volume,2),
                           DoubleToString(info.restore_buy_profit,2),
                           curr_);
   recovery_panel.SetLabel(2,4,
                           "Restore orders sell",
                           DoubleToString(info.restore_sell_volume,2),
                           DoubleToString(info.restore_sell_profit,2),
                           curr_);
   info.current_group_profit=info.group_buy_profit+
                             info.group_sell_profit+
                             info.restore_buy_profit+
                             info.restore_sell_profit;
   recovery_panel.SetRestoringGroupProfit(DoubleToString(info.current_group_profit,2),
                                          curr_);
}

void SetSystemPanel(trade_info &info) {
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   recovery_panel.SetLabel(0,1,
                           string(info.workgroup_buy_count)+" orders buy",
                           DoubleToString(info.workgroup_buy_volume1,2),
                           DoubleToString(info.workgroup_buy_profit,2),
                           curr_);
   recovery_panel.SetLabel(0,2,
                           string(info.workgroup_sell_count)+" orders sell",
                           DoubleToString(info.workgroup_sell_volume1,2),
                           DoubleToString(info.workgroup_sell_profit,2),
                           curr_);
   recovery_panel.SetLabel(0,3,
                           "Restore orders buy",
                           DoubleToString(info.restore_buy_volume,2),
                           DoubleToString(info.restore_buy_profit,2),
                           curr_);
   recovery_panel.SetLabel(0,4,
                           "Restore orders sell",
                           DoubleToString(info.restore_sell_volume,2),
                           DoubleToString(info.restore_sell_profit,2),
                           curr_);
   info.system_profit=info.workgroup_buy_profit+
                      info.workgroup_sell_profit+
                      info.restore_buy_profit+
                      info.restore_sell_profit;
   recovery_panel.SetSystemProfit(DoubleToString(info.workgroup_buy_volume1+
                                  info.workgroup_sell_volume1+
                                  info.restore_buy_volume+
                                  info.restore_sell_volume,2),
                                  DoubleToString(info.system_profit,2),
                                  curr_);
}

void Drawndown() {
   double profit=expert_info.workgroup_buy_profit+
                 expert_info.workgroup_sell_profit+
                 expert_info.restore_buy_profit+
                 expert_info.restore_sell_profit;
   double keep_balance=AccountInfoDouble(ACCOUNT_BALANCE);
   double curr_equity=keep_balance+profit;
   static double keep_equity=curr_equity;
   keep_equity=MathMax(keep_equity,keep_balance);
   keep_equity=MathMax(keep_equity,curr_equity);
   if(keep_equity>curr_equity)
      data_structure.drawndown_money=keep_equity-curr_equity;
   else data_structure.drawndown_money=0;
   data_structure.drawndown_percent=data_structure.drawndown_money/keep_equity*100;
}