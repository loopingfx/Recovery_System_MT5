//+------------------------------------------------------------------+
//|                                                 SchemeDefine.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#include "RecoveryParameterGroup.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSchemeDefine
  {
private:
   color_scheme      m_default_scheme,m_light_scheme,m_medium_scheme;
public:

                     CSchemeDefine();
   void      color_scheme(scheme_apply value,color_scheme &scheme)
     {
      if(value==Light_Scheme) scheme=m_light_scheme;
      if(value==Medium_Scheme) scheme=m_medium_scheme;
      if(value==Default_Scheme) scheme=m_default_scheme;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSchemeDefine::CSchemeDefine()
  {
   m_default_scheme.caption_clr=clrBlack;
   m_default_scheme.caption_bgclr=clrWheat;
   m_default_scheme.caption_borderclor=clrWhite;
   m_default_scheme.group_clr=clrWhiteSmoke;
   m_default_scheme.group_bgclr=clrWhite;
   m_default_scheme.group_borderclor=clrBrown;
   m_default_scheme.client_clr=clrWhiteSmoke;
   m_default_scheme.client_bgclr=clrWhiteSmoke;
   m_default_scheme.client_borderclor=clrWhiteSmoke;
   m_default_scheme.edit_clr=clrWhite;
   m_default_scheme.edit_bgclr=clrBlack;
   m_default_scheme.edit_borderclor=clrWhite;
   m_default_scheme.label_clr=clrBlack;
   m_default_scheme.label_bgclr=clrWhiteSmoke;
   m_default_scheme.label_borderclor=clrWhiteSmoke;
   m_default_scheme.row_label_clr=clrBrown;
   m_default_scheme.row_label_bgclr=clrWhiteSmoke;
   m_default_scheme.row_label_borderclor=clrWhiteSmoke;
   m_default_scheme.button_clr=clrBlack;
   m_default_scheme.button_bgclr=clrWheat;
   m_default_scheme.button_borderclor=clrWhite;
   m_default_scheme.button_buy_clr=clrBlack;
   m_default_scheme.button_buy_bgclr=clrLightGreen;
   m_default_scheme.button_buy_borderclor=clrWhite;
   m_default_scheme.button_sell_clr=clrBlack;
   m_default_scheme.button_sell_bgclr=clrLightPink;
   m_default_scheme.button_sell_borderclor=clrWhite;
//---
   m_light_scheme=m_default_scheme;
   m_light_scheme.caption_clr=clrBlack;
   m_light_scheme.caption_bgclr=clrPink;
   m_light_scheme.button_clr=clrBlack;
   m_light_scheme.button_bgclr=clrPink;
   m_light_scheme.group_clr=clrWhiteSmoke;
   m_light_scheme.group_bgclr=clrWhite;
   m_light_scheme.group_borderclor=clrPink;
   m_light_scheme.label_clr=clrBlack;
   m_light_scheme.row_label_clr=clrRed;
//---
   m_light_scheme.button_buy_clr=clrWhite;
   m_light_scheme.button_buy_bgclr=clrGreen;
   m_light_scheme.button_buy_borderclor=clrWhite;
   m_light_scheme.button_sell_clr=clrWhite;
   m_light_scheme.button_sell_bgclr=clrRed;
   m_light_scheme.button_sell_borderclor=clrWhite;
//---
   m_medium_scheme=m_light_scheme;
   m_medium_scheme.caption_clr=clrWhite;
   m_medium_scheme.caption_bgclr=clrBlue;
   m_medium_scheme.button_clr=clrWhite;
   m_medium_scheme.button_bgclr=clrBlue;
   m_medium_scheme.group_clr=clrWhiteSmoke;
   m_medium_scheme.group_bgclr=clrWhite;
   m_medium_scheme.group_borderclor=clrBlue;
   m_medium_scheme.label_clr=clrBlue;
   m_medium_scheme.row_label_clr=clrBlue;
//---
  }
//+------------------------------------------------------------------+
