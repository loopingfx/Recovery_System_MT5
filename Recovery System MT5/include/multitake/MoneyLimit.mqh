//+------------------------------------------------------------------+
//|                                                   MoneyLimit.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMoneyLimit
  {
   bool CMoneyLimit::CheckMoneyForTrade(string symb,double lots,ENUM_ORDER_TYPE type)
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
      if(!OrderCalcMargin(type,symb,lots,price,margin))
        {
         //--- something went wrong, report and return false
         Print("Error in ",__FUNCTION__," code=",GetLastError());
         return(false);
        }
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
  };
//+------------------------------------------------------------------+
