//+------------------------------------------------------------------+
//|                                                RecoveryPanel.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\Edit.mqh>
#include <Controls\Panel.mqh>
#include <Controls\BmpButton.mqh>
#include <Controls\WndClient.mqh>
#include "RecoveryParameterGroup.mqh"
#include "SchemeDefine.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#resource "\\Include\\Controls\\res\\Restore.bmp"
#resource "\\Include\\Controls\\res\\Turn.bmp"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRecoveryPanel
  {
private:
   int               m_font_size;
   //--- variable for panel
   CButton           m_button[6];
   CLabel            m_rows_lebel[12][4];
   //--- recovery system panel (A)
   CBmpButton        m_button_close_System;
   CDragWnd          m_drag_object_System;
   CPanel            m_client_System[8];
   CEdit             m_caption_System[3];
   CLabel            m_label_System[6];
   //--- possible closure panel (PClosureSystem)
   CDragWnd          m_drag_object_PClosureSystem;
   CBmpButton        m_button_close_PClosureSystem;
   CPanel            m_client_PClosureSystem[6];
   CEdit             m_caption_PClosureSystem[2];
   CLabel            m_label_PClosureSystem[6];
   //--- possible closure panel (PClosureRecovery)
   CDragWnd          m_drag_object_PClosureRecovery;
   CBmpButton        m_button_close_PClosureRecovery;
   CPanel            m_client_PClosureRecovery[6];
   CEdit             m_caption_PClosureRecovery[2];
   CLabel            m_label_PClosureRecovery[6];
   //--- resoring group panel (C)
   CDragWnd          m_drag_object_RecoveryGroup;
   CBmpButton        m_button_close_RecoveryGroup;
   CPanel            m_client_RecoveryGroup[6];
   CEdit             m_caption_RecoveryGroup[2];
   CLabel            m_label_RecoveryGroup[6];
   //--- trade panel
   CPanel            m_client_DealButton[1];
   CEdit             m_edit_DealButton[1];
   CLabel            m_label_DealButton[2];
   //--- create panel (initialize) 
   void              InitilizeSystem(int offset_x,int offset_y);
   void              InitilizePClosureSystem(int offset_x,int offset_y);
   void              InitilizePClosureRecovery(int offset_x,int offset_y);
   void              InitilizeRecoveryGroup(int offset_x,int offset_y);
   void              InitilizeDealButton(int offset_x,int offset_y,bool aligh_right);
   //--- chart variable
   int               chart_height;
   int               chart_width;
   //--- chart change event function
   void              OnChartChangeDealButton();
   //-- mouse drag founction to all panel
   void              OnPanelDragStart_System();
   void              OnPanelDragProcess_System();
   void              OnPanelDragEnd_System();
   //-- mouse location for move
   int               m_System_mouseX;
   int               m_System_mouseY;
   //-- move routine for panel
   void              MovePanel_System(int x,int y);
   void              OnPanelDragStart_PClosureSystem();
   void              OnPanelDragProcess_PClosureSystem();
   void              OnPanelDragEnd_PClosureSystem();
   //-- mouse location for move
   int               m_PClosureSystem_mouseX;
   int               m_PClosureSystem_mouseY;
   //-- move routine for panel
   void              MovePanel_PClosureSystem(int x,int y);
   void              OnPanelDragStart_PClosureRecovery();
   void              OnPanelDragProcess_PClosureRecovery();
   void              OnPanelDragEnd_PClosureRecovery();
   //-- mouse location for move
   int               m_PClosureRecovery_mouseX;
   int               m_PClosureRecovery_mouseY;
   //-- move routine for panel
   void              MovePanel_PClosureRecovery(int x,int y);
   void              OnPanelDragStart_RecoveryGroup();
   void              OnPanelDragProcess_RecoveryGroup();
   void              OnPanelDragEnd_RecoveryGroup();
   //-- mouse location for move
   int               m_RecoveryGroup_mouseX;
   int               m_RecoveryGroup_mouseY;
   //-- move routine for panel
   void              MovePanel_RecoveryGroup(int x,int y);
   //-- hide and show for panel founction (visible)
   bool              m_minimized_System;
   void              ClientAreaVisible_System(bool visible);
   bool              m_minimized_PClosureSystem;
   void              ClientAreaVisible_PClosureSystem(bool visible);
   bool              m_minimized_PClosureRecovery;
   void              ClientAreaVisible_PClosureRecovery(bool visible);
   bool              m_minimized_RecoveryGroup;
   void              ClientAreaVisible_RecoveryGroup(bool visible);
   //---
   int               X(double value) {return(int(MathCeil(value*m_font_size/10)));}
public:
                     CRecoveryPanel():m_minimized_System(false),
                                          m_minimized_PClosureSystem(false),
                                          m_minimized_PClosureRecovery(false),
                                          m_minimized_RecoveryGroup(false),
                                          m_font_size(10)
     {
     }
   //---
   void              Initilize(graphic_setting &setting)
     {
      m_font_size=setting.FontSize;
      //---
      chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
      InitilizeSystem(X(20),X(20));
      InitilizeRecoveryGroup(X(350),X(20));
      InitilizePClosureSystem(X(350),X(240));
      InitilizeDealButton(X(10),X(10),setting.RightDealButtonPanel);
      InitilizePClosureRecovery(X(20),X(270));
      //---
      ClientAreaVisible_System(false);
      ClientAreaVisible_System(setting.ShowSystemPanel);
      ClientAreaVisible_PClosureSystem(false);
      ClientAreaVisible_PClosureSystem(setting.ShowPClosureSystemPanel);
      ClientAreaVisible_PClosureRecovery(false);
      ClientAreaVisible_PClosureRecovery(setting.ShowPClosureRecoveryPanel);
      ClientAreaVisible_RecoveryGroup(false);
      ClientAreaVisible_RecoveryGroup(setting.ShowRecoveryGroupPanel);
      //---
      m_caption_System[0].Visible(setting.ShowSystemPanel);
      m_button_close_System.Visible(setting.ShowSystemPanel);
      m_caption_PClosureSystem[0].Visible(setting.ShowPClosureSystemPanel);
      m_button_close_PClosureSystem.Visible(setting.ShowPClosureSystemPanel);
      m_caption_PClosureRecovery[0].Visible(setting.ShowPClosureRecoveryPanel);
      m_button_close_PClosureRecovery.Visible(setting.ShowPClosureRecoveryPanel);
      m_caption_RecoveryGroup[0].Visible(setting.ShowRecoveryGroupPanel);
      m_button_close_RecoveryGroup.Visible(setting.ShowRecoveryGroupPanel);
      //--- set object to be readonly
      for(int i=0; i<ArraySize(m_caption_System); i++) m_caption_System[i].ReadOnly(true);
      for(int i=0; i<ArraySize(m_caption_PClosureSystem); i++) m_caption_PClosureSystem[i].ReadOnly(true);
      for(int i=0; i<ArraySize(m_caption_PClosureRecovery); i++) m_caption_PClosureRecovery[i].ReadOnly(true);
      for(int i=0; i<ArraySize(m_caption_RecoveryGroup); i++) m_caption_RecoveryGroup[i].ReadOnly(true);
      m_edit_DealButton[0].ReadOnly(true);
      //--- enable to receive begin drag
      m_caption_System[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
      m_caption_PClosureSystem[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
      m_caption_PClosureRecovery[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
      m_caption_RecoveryGroup[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
      //--- set the id to all object
      m_drag_object_System.Id(1101000);
      m_drag_object_PClosureSystem.Id(1102000);
      m_drag_object_PClosureSystem.Id(1103000);
      m_drag_object_RecoveryGroup.Id(1104000);
      //---
      for(int i=0; i<ArraySize(m_client_System); i++) {m_client_System[i].Id(2100+i*10);}
      for(int i=0; i<ArraySize(m_client_PClosureSystem); i++) {m_client_PClosureSystem[i].Id(2200+i*10);}
      for(int i=0; i<ArraySize(m_client_PClosureRecovery); i++) {m_client_PClosureRecovery[i].Id(2300+i*10);}
      for(int i=0; i<ArraySize(m_client_RecoveryGroup); i++) {m_client_RecoveryGroup[i].Id(2400+i*10);}
      for(int i=0; i<ArraySize(m_client_DealButton); i++) {m_client_DealButton[i].Id(2500+i*10);}
      //---
      for(int i=0; i<ArraySize(m_caption_System); i++) {m_caption_System[i].Id(4100+i*10);}
      for(int i=0; i<ArraySize(m_caption_PClosureSystem); i++) {m_caption_PClosureSystem[i].Id(4200+i*10);}
      for(int i=0; i<ArraySize(m_caption_PClosureRecovery); i++) {m_caption_PClosureRecovery[i].Id(4300+i*10);}
      for(int i=0; i<ArraySize(m_caption_RecoveryGroup); i++) {m_caption_RecoveryGroup[i].Id(4400+i*10);}
      for(int i=0; i<ArraySize(m_label_System); i++) {m_label_System[i].Id(3100+i*10);}
      //---
      for(int i=0; i<ArraySize(m_label_PClosureSystem); i++) {m_label_PClosureSystem[i].Id(3200+i*10);}
      for(int i=0; i<ArraySize(m_label_PClosureRecovery); i++) {m_label_PClosureRecovery[i].Id(3300+i*10);}
      for(int i=0; i<ArraySize(m_label_RecoveryGroup); i++) {m_label_RecoveryGroup[i].Id(3400+i*10);}
      for(int i=0; i<10; i++)
                for(int j=0; j<4; j++) {m_rows_lebel[i][j].Id(5000+i*10+j);}
      //--- init the veriable of objects
      SetDrawndown(0.0,0.0);
      SetPoint(0.0);
      for(int i=0; i<12; i++)
         for(int j=0; j<4; j++)
           {
            m_rows_lebel[i][j].Text("");
            m_rows_lebel[i][j].Color(clrWhite);
           }
      CSchemeDefine sd;
      color_scheme current_scheme;
      sd.color_scheme(setting.Color_Scheme,current_scheme);
      for(int i=0; i<ArraySize(m_client_System); i++)
        {
         m_client_System[i].Color(current_scheme.client_clr);
         m_client_System[i].ColorBackground(current_scheme.client_bgclr);
         m_client_System[i].ColorBorder(current_scheme.client_borderclor);
         //
         if(i==1 || i==3)
           {
            m_client_System[i].Color(current_scheme.group_clr);
            m_client_System[i].ColorBackground(current_scheme.group_bgclr);
            m_client_System[i].ColorBorder(current_scheme.group_borderclor);
           }
        }
      for(int i=0; i<ArraySize(m_client_PClosureSystem); i++)
        {
         m_client_PClosureSystem[i].Color(current_scheme.client_clr);
         m_client_PClosureSystem[i].ColorBackground(current_scheme.client_bgclr);
         m_client_PClosureSystem[i].ColorBorder(current_scheme.client_borderclor);
         if(i==1)
           {
            m_client_PClosureSystem[i].Color(current_scheme.group_clr);
            m_client_PClosureSystem[i].ColorBackground(current_scheme.group_bgclr);
            m_client_PClosureSystem[i].ColorBorder(current_scheme.group_borderclor);
           }
        }
      for(int i=0; i<ArraySize(m_client_PClosureRecovery); i++)
        {
         m_client_PClosureRecovery[i].Color(current_scheme.client_clr);
         m_client_PClosureRecovery[i].ColorBackground(current_scheme.client_bgclr);
         m_client_PClosureRecovery[i].ColorBorder(current_scheme.client_borderclor);
         if(i==1)
           {
            m_client_PClosureRecovery[i].Color(current_scheme.group_clr);
            m_client_PClosureRecovery[i].ColorBackground(current_scheme.group_bgclr);
            m_client_PClosureRecovery[i].ColorBorder(current_scheme.group_borderclor);
           }
        }
      for(int i=0; i<ArraySize(m_client_RecoveryGroup); i++)
        {
         m_client_RecoveryGroup[i].Color(current_scheme.client_clr);
         m_client_RecoveryGroup[i].ColorBackground(current_scheme.client_bgclr);
         m_client_RecoveryGroup[i].ColorBorder(current_scheme.client_borderclor);
         if(i==1)
           {
            m_client_RecoveryGroup[i].Color(current_scheme.group_clr);
            m_client_RecoveryGroup[i].ColorBackground(current_scheme.group_bgclr);
            m_client_RecoveryGroup[i].ColorBorder(current_scheme.group_borderclor);
           }
        }
      for(int i=0; i<ArraySize(m_client_DealButton); i++)
        {
         m_client_DealButton[i].Color(current_scheme.client_clr);
         m_client_DealButton[i].ColorBackground(current_scheme.client_bgclr);
         m_client_DealButton[i].ColorBorder(current_scheme.client_borderclor);
        }
      //---
      for(int i=0; i<ArraySize(m_caption_System); i++)
        {
         m_caption_System[i].Color(current_scheme.caption_clr);
         m_caption_System[i].ColorBackground(current_scheme.caption_bgclr);
         m_caption_System[i].ColorBorder(current_scheme.caption_borderclor);
         if(i>0) m_caption_System[i].ColorBorder(current_scheme.client_borderclor);
         if(i>0) m_caption_System[i].ColorBackground(current_scheme.client_bgclr);
         if(i>0) m_caption_System[i].Color(current_scheme.label_clr);
        }
      for(int i=0; i<ArraySize(m_caption_PClosureSystem); i++)
        {
         m_caption_PClosureSystem[i].Color(current_scheme.caption_clr);
         m_caption_PClosureSystem[i].ColorBackground(current_scheme.caption_bgclr);
         m_caption_PClosureSystem[i].ColorBorder(current_scheme.caption_borderclor);
         if(i>0) m_caption_PClosureSystem[i].ColorBorder(current_scheme.client_borderclor);
         if(i>0) m_caption_PClosureSystem[i].ColorBackground(current_scheme.client_bgclr);
         if(i>0) m_caption_PClosureSystem[i].Color(current_scheme.label_clr);
        }
      for(int i=0; i<ArraySize(m_caption_PClosureRecovery); i++)
        {
         m_caption_PClosureRecovery[i].Color(current_scheme.caption_clr);
         m_caption_PClosureRecovery[i].ColorBackground(current_scheme.caption_bgclr);
         m_caption_PClosureRecovery[i].ColorBorder(current_scheme.caption_borderclor);
         if(i>0) m_caption_PClosureRecovery[i].ColorBorder(current_scheme.client_borderclor);
         if(i>0) m_caption_PClosureRecovery[i].ColorBackground(current_scheme.client_bgclr);
         if(i>0) m_caption_PClosureRecovery[i].Color(current_scheme.label_clr);
        }
      for(int i=0; i<ArraySize(m_caption_RecoveryGroup); i++)
        {
         m_caption_RecoveryGroup[i].Color(current_scheme.caption_clr);
         m_caption_RecoveryGroup[i].ColorBackground(current_scheme.caption_bgclr);
         m_caption_RecoveryGroup[i].ColorBorder(current_scheme.caption_borderclor);
         if(i>0) m_caption_RecoveryGroup[i].ColorBorder(current_scheme.client_borderclor);
         if(i>0) m_caption_RecoveryGroup[i].ColorBackground(current_scheme.client_bgclr);
         if(i>0) m_caption_RecoveryGroup[i].Color(current_scheme.label_clr);
        }
      for(int i=0; i<ArraySize(m_label_System); i++)
        {
         m_label_System[i].Color(current_scheme.label_clr);
         m_label_System[i].ColorBackground(current_scheme.label_bgclr);
         m_label_System[i].ColorBorder(current_scheme.label_borderclor);
        }
      //---
      for(int i=0; i<ArraySize(m_label_PClosureSystem); i++)
        {
         m_label_PClosureSystem[i].Color(current_scheme.label_clr);
         m_label_PClosureSystem[i].ColorBackground(current_scheme.label_bgclr);
         m_label_PClosureSystem[i].ColorBorder(current_scheme.label_borderclor);
        }
      for(int i=0; i<ArraySize(m_label_PClosureRecovery); i++)
        {
         m_label_PClosureRecovery[i].Color(current_scheme.label_clr);
         m_label_PClosureRecovery[i].ColorBackground(current_scheme.label_bgclr);
         m_label_PClosureRecovery[i].ColorBorder(current_scheme.label_borderclor);
        }
      for(int i=0; i<ArraySize(m_label_RecoveryGroup); i++)
        {
         m_label_RecoveryGroup[i].Color(current_scheme.label_clr);
         m_label_RecoveryGroup[i].ColorBackground(current_scheme.label_bgclr);
         m_label_RecoveryGroup[i].ColorBorder(current_scheme.label_borderclor);
        }
      for(int i=0; i<ArraySize(m_label_DealButton); i++)
        {
         m_label_DealButton[i].Color(current_scheme.label_clr);
         m_label_DealButton[i].ColorBackground(current_scheme.label_bgclr);
         m_label_DealButton[i].ColorBorder(current_scheme.label_borderclor);
        }
      //--
      m_edit_DealButton[0].Color(current_scheme.edit_clr);
      m_edit_DealButton[0].ColorBackground(current_scheme.edit_bgclr);
      m_edit_DealButton[0].ColorBorder(current_scheme.edit_borderclor);
      //---
      for(int i=0; i<12; i++)
         for(int j=0; j<4; j++)
           {
            m_rows_lebel[i][j].Text("");
            m_rows_lebel[i][j].Color(current_scheme.row_label_clr);
            m_rows_lebel[i][j].ColorBorder(current_scheme.row_label_borderclor);
            m_rows_lebel[i][j].ColorBackground(current_scheme.row_label_bgclr);
           }
      for(int i=0; i<6; i++)
        {
         m_button[i].Color(current_scheme.button_clr);
         m_button[i].ColorBackground(current_scheme.button_bgclr);
         m_button[i].ColorBorder(current_scheme.button_borderclor);
        }
      //---
      m_button[4].Color(current_scheme.button_buy_clr);
      m_button[4].ColorBackground(current_scheme.button_buy_bgclr);
      m_button[4].ColorBorder(current_scheme.button_buy_borderclor);
      m_button[3].Color(current_scheme.button_sell_clr);
      m_button[3].ColorBackground(current_scheme.button_sell_bgclr);
      m_button[3].ColorBorder(current_scheme.button_sell_borderclor);
      //---
      ChartRedraw();
     }
   //--- panel on event routine
   bool              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- set the value of lot
   void              SetLots(double value){m_edit_DealButton[0].Text(DoubleToString(value,2));}
   //--- set the value of spread
   void              SetPoint(int value){m_label_DealButton[0].Text("Spread: "+IntegerToString(value)+" points");}
   //--- set the value of drowbdown
   void              SetDrawndown(double value,double max_value)
     {
      m_label_DealButton[1].Text("Drawndown: "+DoubleToString(value,2)+"% (^"+
                                 DoubleToString(max_value,2)+"%)");
      if(MQLInfoInteger(MQL_VISUAL_MODE)) OnChartChangeDealButton();
     }
   void              SetLabel(int panal,int line,string descrip,string lot,string profit,string curr);
   //--- set the value for label C
   void              SetRestoringGroupProfit(string profit,string curr)
     {
      m_label_RecoveryGroup[3].Text(profit);
      m_label_RecoveryGroup[4].Text(curr);
     }
   //--- set the value label A
   void SetSystemProfit(string lot,string profit,string curr)
     {
      m_label_System[3].Text(lot);
      m_label_System[4].Text(profit);
      m_label_System[5].Text(curr);
     }
   //--- set the value label PClosureSystem
   void SetLockPosibleProfit(string lot,string profit,string curr)
     {
      m_label_PClosureSystem[3].Text(lot);
      m_label_PClosureSystem[4].Text(profit);
      m_label_PClosureSystem[5].Text(curr);
     }
   //--- set the value label PClosureRecovery
   void SetRestorePosibleProfit(string lot,string profit,string curr)
     {
      m_label_PClosureRecovery[3].Text(lot);
      m_label_PClosureRecovery[4].Text(profit);
      m_label_PClosureRecovery[5].Text(curr);
     }
   //--- check state of button
   int               IsButtonPress(int value){return(m_button[value].Pressed());}
   //--- reset state of button
   void              ResetButtonPress(int value){m_button[value].Pressed(false);}
   //---
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryPanel::InitilizeSystem(int offset_x,int offset_y)
  {
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   int butt_width=X(90);
   int butt_height=X(30);
   int indent=X(5);
   int client_gap=X(5);
   int line_height=X(25);
   int content_height1=2*(line_height+X(2))+2*indent;
   int content_height2=2*(line_height+X(2))+2*indent;
   int client_width=X(320);
//---
   int client_x1,client_x2,client_y1,client_y2;
   client_x1=offset_x;
   client_x2=client_x1+client_width;
   client_y2=offset_y;
   client_y1=client_y2-content_height1+content_height2;
//---
   int x1,x2,y1,y2;
//--- first object left
   x1=offset_x;
   y1=offset_y;
   x2=x1+client_width;
   y2=y1+line_height;
   m_caption_System[0].Create(0,"captionA_0",0,x1,y1,x2,y2);
   m_caption_System[0].Text("Recovery System");
   m_caption_System[0].FontSize(X(12));
//--- first object right
   y1=m_caption_System[0].Top();
   y2=m_caption_System[0].Bottom();
   x2=m_caption_System[0].Right();
   x1=x2-line_height;
   m_button_close_System.Create(0,"button_close_A",0,x1,y1,x2,y2);
   m_button_close_System.FontSize(X(12));
   if(!m_minimized_System)
      m_button_close_System.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_System.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//--- object 2
   y1=m_caption_System[0].Bottom();
   y2=y1+line_height;
   x1=m_caption_System[0].Left();
   x2=m_caption_System[0].Right();
//---
   m_client_System[0].Create(0,"clientA_0",0,x1,y1,x2,y2);
   x1=m_client_System[0].Left()+X(150);
   y1=m_client_System[0].Top();
   y2=m_client_System[0].Bottom();
   x2=x1+X(40);
   m_label_System[0].Create(0,"labelA_0",0,x1,y1,x2,y2);
   m_label_System[0].Text("Lots");
   m_label_System[0].FontSize(X(12));
//---
   x1=m_label_System[0].Right()+X(20);
   y1=m_client_System[0].Top();
   y2=m_client_System[0].Bottom();
   x2=x1+X(40);
   m_label_System[1].Create(0,"labelA_1",0,x1,y1,x2,y2);
   m_label_System[1].Text("Profit");
   m_label_System[1].FontSize(X(12));
   x1=m_client_System[1].Left()+X(10);
   y1=m_client_System[1].Top()-X(14);
//---
   x1=m_client_System[0].Left()+X(4);
   x2=m_client_System[0].Right()-X(4);
   y1=m_client_System[0].Bottom();
   y2=y1+content_height1;
   m_client_System[1].Create(0,"clientA_1",0,x1,y1,x2,y2);
//---
   y1=m_client_System[1].Top()-int(line_height/2);
   x1=m_client_System[1].Left()+line_height;
   y2=y1+line_height;
   x2=x1+X(110);
   m_caption_System[1].Create(0,"captionA_1",0,x1,y1,x2,y2);
   m_caption_System[1].Text("Locked Orders");
   m_caption_System[1].FontSize(X(10));
//---
   y1=m_client_System[1].Bottom();
   y2=y1+int(line_height/2);
   x1=m_caption_System[0].Left();
   x2=m_caption_System[0].Right();
   m_client_System[2].Create(0,"clientA_2",0,x1,y1,x2,y2);
//---
   x1=m_client_System[0].Left()+X(4);
   x2=m_client_System[0].Right()-X(4);
   y1=m_client_System[2].Bottom();
   y2=y1+content_height2;
   m_client_System[3].Create(0,"clientA_3",0,x1,y1,x2,y2);
//---
   y1=m_client_System[3].Top()-int(line_height/2);
   x1=m_client_System[3].Left()+line_height;
   y2=y1+line_height;
   x2=x1+X(120);
   m_caption_System[2].Create(0,"captionA_2",0,x1,y1,x2,y2);
   m_caption_System[2].Text("Restoring Orders");
   m_caption_System[2].FontSize(X(10));
//---
   y1=m_client_System[3].Bottom();
   y2=y1+int(line_height/2);
   x1=m_caption_System[0].Left();
   x2=m_caption_System[0].Right();
   m_client_System[4].Create(0,"clientA_4",0,x1,y1,x2,y2);
//---
   x1=m_client_System[4].Left()+X(4);
   y1=m_client_System[4].Bottom();
   x2=x1+butt_width;
   y2=y1+butt_height;
   m_button[0].Create(0,"BUTT_CLOSE_ALL",0,x1,y1,x2,y2);
   m_button[0].Text("Close All");
   m_button[0].FontSize(X(12));
//---
   y1=m_client_System[3].Bottom();
   y2=m_button[0].Bottom();
   x1=m_button[0].Right();
   x2=m_caption_System[0].Right();
   m_client_System[5].Create(0,"clientA_5",0,x1,y1,x2,y2);
//---
   y1=m_client_System[0].Bottom();
   y2=m_client_System[5].Bottom();
   x1=m_client_System[0].Left();
   x2=m_client_System[1].Left();
   m_client_System[6].Create(0,"clientA_6",0,x1,y1,x2,y2);
//---
   y1=m_client_System[0].Bottom();
   y2=m_client_System[4].Top();
   x1=m_client_System[1].Right();
   x2=m_client_System[0].Right();
   m_client_System[7].Create(0,"clientA_7",0,x1,y1,x2,y2);
//--- calculate coordinates
   int x1_=m_caption_System[0].Left()-CONTROLS_DRAG_SPACING;
   int y1_=m_caption_System[0].Top()-CONTROLS_DRAG_SPACING;
   int x2_=m_client_System[5].Right()+CONTROLS_DRAG_SPACING;
   int y2_=m_client_System[5].Bottom()+CONTROLS_DRAG_SPACING+X(4);
//--- create
   m_drag_object_System.Create(0,"A",0,x1_,y1_,x2_,y2_);
   x1=m_button[0].Right()+X(10);
   y2=m_button[0].Bottom();
   y1=y2-line_height;
   x2=x1+X(50);
   m_label_System[2].Create(0,"labelA_2",0,x1,y1,x2,y2);
   m_label_System[2].Text("Sum:");
   m_label_System[2].FontSize(X(12));
   x1=m_label_System[0].Left();
   y2=m_button[0].Bottom();
   y1=y2-line_height;
   x2=x1+X(50);
   m_label_System[3].Create(0,"labelA_3",0,x1,y1,x2,y2);
   m_label_System[3].Text("00.00");
   m_label_System[3].FontSize(X(12));
   x1=m_label_System[1].Left();
   y2=m_button[0].Bottom();
   y1=y2-line_height;
   x2=x1+X(60);
   m_label_System[4].Create(0,"labelA_4",0,x1,y1,x2,y2);
   m_label_System[4].Text("00.00");
   m_label_System[4].FontSize(X(12));
   x1=m_label_System[4].Right()+X(10);
   y2=m_button[0].Bottom();
   y1=y2-line_height;
   x2=x1+X(50);
   m_label_System[5].Create(0,"labelA_5",0,x1,y1,x2,y2);
   m_label_System[5].Text(curr_);
   m_label_System[5].FontSize(X(10));
//---
   int x1_array[4],x2_array[4],y1_array[4],y2_array[4];
   x1_array[0]=m_client_System[1].Left()+int(line_height/2);
   x1_array[1]=m_label_System[0].Left();
   x1_array[2]=m_label_System[1].Left();
   x1_array[3]=m_label_System[5].Left();
   x2_array[0]=x1_array[0]+X(50);
   x2_array[1]=x1_array[1]+X(50);
   x2_array[2]=x1_array[2]+X(100);
   x2_array[3]=x1_array[3]+X(50);
   for(int i=0; i<4; i++)
     {
      y1_array[i]=m_caption_System[1].Top()+line_height;
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[0][i].Create(0,"rows_levelA0_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[0][i].FontSize(X(10));
      y1_array[i]=m_caption_System[1].Top()+X(50);
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[1][i].Create(0,"rows_levelA1_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[1][i].FontSize(X(10));
     }
   for(int i=0; i<4; i++)
     {
      y1_array[i]=m_caption_System[2].Top()+line_height;
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[2][i].Create(0,"rows_levelA2_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[2][i].FontSize(X(10));
      y1_array[i]=m_caption_System[2].Top()+X(50);
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[3][i].Create(0,"rows_levelA3_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[3][i].FontSize(X(10));
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryPanel::InitilizePClosureSystem(int offset_x,int offset_y)
  {
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   int line_height=X(25);
   int butt_width=X(90);
   int butt_height=X(30);
   int indent=X(5);
   int client_gap=X(5);
   int content_height1=2*(line_height+X(2))+2*indent;
   int content_height2=2*(line_height+X(2))+2*indent;
   int client_width=X(320);
//---
   int x1,x2,y1,y2;
   x1=offset_x;
   y1=offset_y;
   x2=x1+client_width;
   y2=y1+line_height;
   m_caption_PClosureSystem[0].Create(0,"captionPClosureSystem_0",0,x1,y1,x2,y2);
   m_caption_PClosureSystem[0].Text("Possible Closures of System Orders");
   m_caption_PClosureSystem[0].FontSize(X(12));
//---
   y1=m_caption_PClosureSystem[0].Top();
   y2=m_caption_PClosureSystem[0].Bottom();
   x1=m_caption_PClosureSystem[0].Right()-line_height;
   x2=m_caption_PClosureSystem[0].Right();
   m_button_close_PClosureSystem.Create(0,"button_close_PClosureSystem",0,x1,y1,x2,y2);
//---
   if(!m_minimized_PClosureSystem)
      m_button_close_PClosureSystem.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_PClosureSystem.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//--- object 2
   y1=m_caption_PClosureSystem[0].Bottom();
   y2=y1+line_height;
   x1=m_caption_PClosureSystem[0].Left();
   x2=m_caption_PClosureSystem[0].Right();
   m_client_PClosureSystem[0].Create(0,"clientPClosureSystem_0",0,x1,y1,x2,y2);
//---
   x1=m_client_PClosureSystem[0].Left()+X(150);
   y1=m_client_PClosureSystem[0].Top();
   y2=m_client_PClosureSystem[0].Bottom();
   x2=x1+X(40);
   m_label_PClosureSystem[0].Create(0,"labelPClosureSystem_0",0,x1,y1,x2,y2);
   m_label_PClosureSystem[0].Text("Lots");
//--
   x1=m_label_PClosureSystem[0].Right()+X(20);
   y1=m_client_PClosureSystem[0].Top();
   y2=m_client_PClosureSystem[0].Bottom();
   x2=x1+X(40);
   m_label_PClosureSystem[1].Create(0,"labelPClosureSystem_1",0,x1,y1,x2,y2);
   m_label_PClosureSystem[1].Text("Profit");
//---
   x1=m_client_PClosureSystem[0].Left()+X(4);
   x2=m_client_PClosureSystem[0].Right()-X(4);
   y1=m_client_PClosureSystem[0].Bottom();
   y2=y1+content_height1;
   m_client_PClosureSystem[1].Create(0,"clientPClosureSystem_1",0,x1,y1,x2,y2);
//---
   y1=m_client_PClosureSystem[1].Top()-int(line_height/2);
   x1=m_client_PClosureSystem[1].Left()+line_height;
   y2=y1+line_height;
   x2=x1+X(100);
   m_caption_PClosureSystem[1].Create(0,"captionPClosureSystem_1",0,x1,y1,x2,y2);
   m_caption_PClosureSystem[1].Text("Possible Close");
   m_caption_PClosureSystem[1].FontSize(X(10));
//---
   y1=m_client_PClosureSystem[1].Bottom();
   y2=y1+int(line_height/2);
   x1=m_caption_PClosureSystem[0].Left();
   x2=m_caption_PClosureSystem[0].Right();
   m_client_PClosureSystem[2].Create(0,"clientPClosureSystem_2",0,x1,y1,x2,y2);
//--
   x1=m_caption_PClosureSystem[0].Left()+X(4);
   y1=m_client_PClosureSystem[2].Bottom();
   x2=x1+butt_width;
   y2=y1+butt_height;
   m_button[1].Create(0,"BUTT_CLOSE_1",0,x1,y1,x2,y2);
   m_button[1].Text("Close");
   m_button[1].FontSize(X(12));
//---
   y1=m_client_PClosureSystem[2].Bottom();
   y2=m_button[1].Bottom();
   x1=m_button[1].Right();
   x2=m_caption_PClosureSystem[0].Right();
   m_client_PClosureSystem[3].Create(0,"clientPClosureSystem_3",0,x1,y1,x2,y2);
//---
   y1=m_client_PClosureSystem[0].Bottom();
   y2=m_button[1].Bottom();
   x1=m_caption_PClosureSystem[0].Left();
   x2=m_caption_PClosureSystem[0].Left()+4;
   m_client_PClosureSystem[4].Create(0,"clientPClosureSystem_4",0,x1,y1,x2,y2);
//---
   y1=m_client_PClosureSystem[0].Bottom();
   y2=m_client_PClosureSystem[2].Top();
   x1=m_caption_PClosureSystem[0].Right()-4;
   x2=m_caption_PClosureSystem[0].Right();
   m_client_PClosureSystem[5].Create(0,"clientPClosureSystem_5",0,x1,y1,x2,y2);
//--- calculate coordinates
   int x1_=m_caption_PClosureSystem[0].Left()-CONTROLS_DRAG_SPACING;
   int y1_=m_caption_PClosureSystem[0].Top()-CONTROLS_DRAG_SPACING;
   int x2_=m_caption_PClosureSystem[0].Right()+CONTROLS_DRAG_SPACING;
   int y2_=m_button[1].Bottom()+CONTROLS_DRAG_SPACING+X(4);
//--- create
   m_drag_object_PClosureSystem.Create(0,"B",0,x1_,y1_,x2_,y2_);
//---
   x1=m_client_PClosureSystem[0].Left()+X(150);
   y1=m_caption_PClosureSystem[0].Bottom();
   y2=y1+line_height;
   x2=x1+X(40);
   m_label_PClosureSystem[0].Create(0,"labelPClosureSystem_0",0,x1,y1,x2,y2);
   m_label_PClosureSystem[0].Text("Lots");
   m_label_PClosureSystem[0].FontSize(X(10));
   x1=m_label_PClosureSystem[0].Right()+X(20);
   y1=m_label_PClosureSystem[0].Top();
   y2=m_label_PClosureSystem[0].Bottom();
   x2=x1+X(40);
   m_label_PClosureSystem[1].Create(0,"labelPClosureSystem_1",0,x1,y1,x2,y2);
   m_label_PClosureSystem[1].Text("Profit");
   m_label_PClosureSystem[1].FontSize(X(10));
//---
   x1=m_button[1].Right()+X(10);
   y2=m_button[1].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureSystem[2].Create(0,"labelPClosureSystem_2",0,x1,y1,x2,y2);
   m_label_PClosureSystem[2].Text("Sum:");
   m_label_PClosureSystem[2].FontSize(X(12));
   x1=m_label_PClosureSystem[0].Left();
   y2=m_button[1].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureSystem[3].Create(0,"labelPClosureSystem_3",0,x1,y1,x2,y2);
   m_label_PClosureSystem[3].Text("00.00");
   m_label_PClosureSystem[3].FontSize(X(12));
   x1=m_label_PClosureSystem[1].Left();
   y2=m_button[1].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureSystem[4].Create(0,"labelPClosureSystem_4",0,x1,y1,x2,y2);
   m_label_PClosureSystem[4].Text("00.00");
   m_label_PClosureSystem[4].FontSize(X(12));
   x1=m_label_PClosureSystem[4].Right()+X(35);
   y2=m_button[1].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureSystem[5].Create(0,"labelPClosureSystem_5",0,x1,y1,x2,y2);
   m_label_PClosureSystem[5].Text(curr_);
   m_label_PClosureSystem[5].FontSize(X(10));
//---
   int x1_array[4],x2_array[4],y1_array[4],y2_array[4];
   x1_array[0]=m_client_PClosureSystem[1].Left()+int(line_height/2);
   x1_array[1]=m_label_PClosureSystem[0].Left();
   x1_array[2]=m_label_PClosureSystem[1].Left();
   x1_array[3]=m_label_PClosureSystem[5].Left();
   x2_array[0]=x1_array[0]+X(50);
   x2_array[1]=x1_array[1]+X(50);
   x2_array[2]=x1_array[2]+X(100);
   x2_array[3]=x1_array[3]+X(50);
   for(int i=0; i<4; i++)
     {
      y1_array[i]=m_caption_PClosureSystem[1].Top()+line_height;
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[4][i].Create(0,"rows_levelPClosureSystem4_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[4][i].FontSize(X(10));
      y1_array[i]=m_caption_PClosureSystem[1].Top()+X(50);
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[5][i].Create(0,"rows_levelPClosureSystem5_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[5][i].FontSize(X(10));
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryPanel::InitilizePClosureRecovery(int offset_x,int offset_y)
  {
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   int line_height=X(25);
   int butt_width=X(90);
   int butt_height=X(30);
   int indent=X(5);
   int client_gap=X(5);
   int content_height1=2*(line_height+X(2))+2*indent;
   int content_height2=2*(line_height+X(2))+2*indent;
   int client_width=X(320);
//---
   int x1,x2,y1,y2;
   x1=offset_x;
   y1=offset_y;
   x2=x1+client_width;
   y2=y1+line_height;
   m_caption_PClosureRecovery[0].Create(0,"captionPClosureRecovery_0",0,x1,y1,x2,y2);
   m_caption_PClosureRecovery[0].Text("Possible Closures of Restoring Orders");
   m_caption_PClosureRecovery[0].FontSize(X(12));
//---
   y1=m_caption_PClosureRecovery[0].Top();
   y2=m_caption_PClosureRecovery[0].Bottom();
   x1=m_caption_PClosureRecovery[0].Right()-line_height;
   x2=m_caption_PClosureRecovery[0].Right();
   m_button_close_PClosureRecovery.Create(0,"button_close_PClosureRecovery",0,x1,y1,x2,y2);
//---
   if(!m_minimized_PClosureRecovery)
      m_button_close_PClosureRecovery.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_PClosureRecovery.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//--- object 2
   y1=m_caption_PClosureRecovery[0].Bottom();
   y2=y1+line_height;
   x1=m_caption_PClosureRecovery[0].Left();
   x2=m_caption_PClosureRecovery[0].Right();
   m_client_PClosureRecovery[0].Create(0,"clientPClosureRecovery_0",0,x1,y1,x2,y2);
//---
   x1=m_client_PClosureRecovery[0].Left()+X(150);
   y1=m_client_PClosureRecovery[0].Top();
   y2=m_client_PClosureRecovery[0].Bottom();
   x2=x1+X(40);
   m_label_PClosureRecovery[0].Create(0,"labelPClosureRecovery_0",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[0].Text("Lots");
   m_label_PClosureRecovery[0].FontSize(X(10));
//--
   x1=m_label_PClosureRecovery[0].Right()+X(20);
   y1=m_client_PClosureRecovery[0].Top();
   y2=m_client_PClosureRecovery[0].Bottom();
   x2=x1+X(40);
   m_label_PClosureRecovery[1].Create(0,"labelPClosureRecovery_1",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[1].Text("Profit");
   m_label_PClosureRecovery[1].FontSize(X(10));
//---
   x1=m_client_PClosureRecovery[0].Left()+X(4);
   x2=m_client_PClosureRecovery[0].Right()-X(4);
   y1=m_client_PClosureRecovery[0].Bottom();
   y2=y1+content_height1;
   m_client_PClosureRecovery[1].Create(0,"clientPClosureRecovery_1",0,x1,y1,x2,y2);
//---
   y1=m_client_PClosureRecovery[1].Top()-int(line_height/2);
   x1=m_client_PClosureRecovery[1].Left()+line_height;
   y2=y1+line_height;
   x2=x1+X(100);
   m_caption_PClosureRecovery[1].Create(0,"captionPClosureRecovery_1",0,x1,y1,x2,y2);
   m_caption_PClosureRecovery[1].Text("Possible Close");
   m_caption_PClosureRecovery[1].FontSize(X(10));
//---
   y1=m_client_PClosureRecovery[1].Bottom();
   y2=y1+int(line_height/2);
   x1=m_caption_PClosureRecovery[0].Left();
   x2=m_caption_PClosureRecovery[0].Right();
   m_client_PClosureRecovery[2].Create(0,"clientPClosureRecovery_2",0,x1,y1,x2,y2);
//--
   x1=m_caption_PClosureRecovery[0].Left()+X(4);
   y1=m_client_PClosureRecovery[2].Bottom();
   x2=x1+butt_width;
   y2=y1+butt_height;
   m_button[5].Create(0,"BUTT_CLOSE_2",0,x1,y1,x2,y2);
   m_button[5].Text("Close");
   m_button[5].FontSize(X(12));
//---
   y1=m_client_PClosureRecovery[2].Bottom();
   y2=m_button[5].Bottom();
   x1=m_button[5].Right();
   x2=m_caption_PClosureRecovery[0].Right();
   m_client_PClosureRecovery[3].Create(0,"clientPClosureRecovery_3",0,x1,y1,x2,y2);
//---
   y1=m_client_PClosureRecovery[0].Bottom();
   y2=m_button[5].Bottom();
   x1=m_caption_PClosureRecovery[0].Left();
   x2=m_caption_PClosureRecovery[0].Left()+X(4);
   m_client_PClosureRecovery[4].Create(0,"clientPClosureRecovery_4",0,x1,y1,x2,y2);
//---
   y1=m_client_PClosureRecovery[0].Bottom();
   y2=m_client_PClosureRecovery[2].Top();
   x1=m_caption_PClosureRecovery[0].Right()-X(4);
   x2=m_caption_PClosureRecovery[0].Right();
   m_client_PClosureRecovery[5].Create(0,"clientPClosureRecovery_5",0,x1,y1,x2,y2);
//--- calculate coordinates
   int x1_=m_caption_PClosureRecovery[0].Left()-CONTROLS_DRAG_SPACING;
   int y1_=m_caption_PClosureRecovery[0].Top()-CONTROLS_DRAG_SPACING;
   int x2_=m_caption_PClosureRecovery[0].Right()+CONTROLS_DRAG_SPACING;
   int y2_=m_button[5].Bottom()+CONTROLS_DRAG_SPACING+X(4);
//--- create
   m_drag_object_PClosureRecovery.Create(0,"PClosureRecovery",0,x1_,y1_,x2_,y2_);
//---
   x1=m_client_PClosureRecovery[0].Left()+X(150);
   y1=m_caption_PClosureRecovery[0].Bottom();
   y2=y1+line_height;
   x2=x1+X(40);
   m_label_PClosureRecovery[0].Create(0,"labelPClosureRecovery_0",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[0].Text("Lots");
   m_label_PClosureRecovery[0].FontSize(X(10));
   x1=m_label_PClosureRecovery[0].Right()+X(20);
   y1=m_label_PClosureRecovery[0].Top();
   y2=m_label_PClosureRecovery[0].Bottom();
   x2=x1+X(40);
   m_label_PClosureRecovery[1].Create(0,"labelPClosureRecovery_1",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[1].Text("Profit");
   m_label_PClosureRecovery[1].FontSize(X(10));
//---
   x1=m_button[5].Right()+10;
   y2=m_button[5].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureRecovery[2].Create(0,"labelPClosureRecovery_2",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[2].Text("Sum:");
   m_label_PClosureRecovery[2].FontSize(X(12));
   x1=m_label_PClosureRecovery[0].Left();
   y2=m_button[5].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureRecovery[3].Create(0,"labelPClosureRecovery_3",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[3].Text("00.00");
   m_label_PClosureRecovery[3].FontSize(X(12));
   x1=m_label_PClosureRecovery[1].Left();
   y2=m_button[5].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureRecovery[4].Create(0,"labelPClosureRecovery_4",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[4].Text("00.00");
   m_label_PClosureRecovery[4].FontSize(X(12));
   x1=m_label_PClosureRecovery[4].Right()+X(35);
   y2=m_button[5].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_PClosureRecovery[5].Create(0,"labelPClosureRecovery_5",0,x1,y1,x2,y2);
   m_label_PClosureRecovery[5].Text(curr_);
   m_label_PClosureRecovery[5].FontSize(X(10));
//---
   int x1_array[4],x2_array[4],y1_array[4],y2_array[4];
   x1_array[0]=m_client_PClosureRecovery[1].Left()+int(line_height/2);
   x1_array[1]=m_label_PClosureRecovery[0].Left();
   x1_array[2]=m_label_PClosureRecovery[1].Left();
   x1_array[3]=m_label_PClosureRecovery[5].Left();
   x2_array[0]=x1_array[0]+X(50);
   x2_array[1]=x1_array[1]+X(50);
   x2_array[2]=x1_array[2]+X(100);
   x2_array[3]=x1_array[3]+X(50);
   for(int i=0; i<4; i++)
     {
      y1_array[i]=m_caption_PClosureRecovery[1].Top()+line_height;
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[10][i].Create(0,"rows_levelPClosureRecovery4_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[10][i].FontSize(X(10));
      y1_array[i]=m_caption_PClosureRecovery[1].Top()+X(50);
      y2_array[i]=y1_array[i]+line_height;
      m_rows_lebel[11][i].Create(0,"rows_levelPClosureRecovery5_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[11][i].FontSize(X(10));
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryPanel::InitilizeRecoveryGroup(int offset_x,int offset_y)
  {
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   string curr_=AccountInfoString(ACCOUNT_CURRENCY);
   int line_height=X(25);
   int butt_width=X(140);
   int butt_height=X(30);
   int indent=X(5);
   int client_gap=X(5);
   int content_height1=4*(line_height+X(2))+2*indent;
   int content_height2=2*(line_height+X(2))+2*indent;
   int client_width=X(320);
//---
   int client_x1,client_x2,client_y1,client_y2;
   client_x1=offset_x;
   client_x2=client_x1+client_width;
   client_y2=offset_y;
   client_y1=client_y2-content_height1+content_height2;
//---
   int x1,x2,y1,y2;
   x1=offset_x;
   y1=offset_y;
   x2=x1+client_width;
   y2=y1+line_height;
   m_caption_RecoveryGroup[0].Create(0,"captionC_0",0,x1,y1,x2,y2);
   m_caption_RecoveryGroup[0].Text("Restoring Group of Orders");
   m_caption_RecoveryGroup[0].FontSize(X(12));
//---
   y1=m_caption_RecoveryGroup[0].Top();
   y2=m_caption_RecoveryGroup[0].Bottom();
   x1=m_caption_RecoveryGroup[0].Right()-line_height;
   x2=m_caption_RecoveryGroup[0].Right();
   m_button_close_RecoveryGroup.Create(0,"button_close_C",0,x1,y1,x2,y2);
   m_button_close_RecoveryGroup.FontSize(X(12));
//---
   if(!m_minimized_RecoveryGroup)
      m_button_close_RecoveryGroup.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_RecoveryGroup.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//--- object 2
   y1=m_caption_RecoveryGroup[0].Bottom();
   y2=y1+line_height;
   x1=m_caption_RecoveryGroup[0].Left();
   x2=m_caption_RecoveryGroup[0].Right();
   m_client_RecoveryGroup[0].Create(0,"clientC_0",0,x1,y1,x2,y2);
//---
   x1=m_client_RecoveryGroup[0].Left()+X(150);
   y1=m_client_RecoveryGroup[0].Top();
   y2=m_client_RecoveryGroup[0].Bottom();
   x2=x1+X(40);
   m_label_RecoveryGroup[0].Create(0,"labelC_0",0,x1,y1,x2,y2);
   m_label_RecoveryGroup[0].Text("Lots");
   m_label_RecoveryGroup[0].FontSize(X(10));
//--
   x1=m_label_RecoveryGroup[0].Right()+X(20);
   y1=m_client_RecoveryGroup[0].Top();
   y2=m_client_RecoveryGroup[0].Bottom();
   x2=x1+X(40);
   m_label_RecoveryGroup[1].Create(0,"labelC_1",0,x1,y1,x2,y2);
   m_label_RecoveryGroup[1].Text("Profit");
   m_label_RecoveryGroup[1].FontSize(X(10));
//---
   x1=m_client_RecoveryGroup[0].Left()+X(4);
   x2=m_client_RecoveryGroup[0].Right()-X(4);
   y1=m_client_RecoveryGroup[0].Bottom();
   y2=y1+content_height1;
   m_client_RecoveryGroup[1].Create(0,"clientC_1",0,x1,y1,x2,y2);
//---
   y1=m_client_RecoveryGroup[1].Top()-int(line_height/2);
   x1=m_client_RecoveryGroup[1].Left()+line_height;
   y2=y1+line_height;
   x2=x1+X(120);
   m_caption_RecoveryGroup[1].Create(0,"captionC_1",0,x1,y1,x2,y2);
   m_caption_RecoveryGroup[1].Text("Restoring Orders");
   m_caption_RecoveryGroup[1].FontSize(X(10));
//---
   y1=m_client_RecoveryGroup[1].Bottom();
   y2=y1+int(line_height/2);
   x1=m_caption_RecoveryGroup[0].Left();
   x2=m_caption_RecoveryGroup[0].Right();
   m_client_RecoveryGroup[2].Create(0,"clientC_2",0,x1,y1,x2,y2);
//--
   x1=m_caption_RecoveryGroup[0].Left()+X(4);
   y1=m_client_RecoveryGroup[2].Bottom();
   x2=x1+butt_width;
   y2=y1+butt_height;
   m_button[2].Create(0,"BUTT_CLOSE_GROUP",0,x1,y1,x2,y2);
   m_button[2].Text("Close Group");
   m_button[2].FontSize(X(12));
//---
   y1=m_client_RecoveryGroup[2].Bottom();
   y2=m_button[2].Bottom();
   x1=m_button[2].Right();
   x2=m_caption_RecoveryGroup[0].Right();
   m_client_RecoveryGroup[3].Create(0,"clientC_3",0,x1,y1,x2,y2);
//---
   y1=m_client_RecoveryGroup[0].Bottom();
   y2=m_button[2].Bottom();
   x1=m_caption_RecoveryGroup[0].Left();
   x2=m_caption_RecoveryGroup[0].Left()+X(4);
   m_client_RecoveryGroup[4].Create(0,"clientC_4",0,x1,y1,x2,y2);
//---
   y1=m_client_RecoveryGroup[0].Bottom();
   y2=m_client_RecoveryGroup[2].Top();
   x1=m_caption_RecoveryGroup[0].Right()-X(4);
   x2=m_caption_RecoveryGroup[0].Right();
   m_client_RecoveryGroup[5].Create(0,"clientC_5",0,x1,y1,x2,y2);
//--- calculate coordinates
   int x1_=m_caption_RecoveryGroup[0].Left()-CONTROLS_DRAG_SPACING;
   int y1_=m_caption_RecoveryGroup[0].Top()-CONTROLS_DRAG_SPACING;
   int x2_=m_caption_RecoveryGroup[0].Right()+CONTROLS_DRAG_SPACING;
   int y2_=m_button[2].Bottom()+CONTROLS_DRAG_SPACING+4;
//--- create
   m_drag_object_RecoveryGroup.Create(0,"B",0,x1_,y1_,x2_,y2_);
//---
   x1=m_button[2].Right()+X(10);
   y2=m_button[2].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_RecoveryGroup[2].Create(0,"labelC_2",0,x1,y1,x2,y2);
   m_label_RecoveryGroup[2].Text("Sum:");
   m_label_RecoveryGroup[2].FontSize(X(12));
   x1=m_label_RecoveryGroup[1].Left();
   y2=m_button[2].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_RecoveryGroup[3].Create(0,"labelC_3",0,x1,y1,x2,y2);
   m_label_RecoveryGroup[3].Text("00.00");
   m_label_RecoveryGroup[3].FontSize(X(12));
   x1=m_label_RecoveryGroup[3].Right()+X(35);
   y2=m_button[2].Bottom();
   y1=y2-line_height;
   x2=x1+X(40);
   m_label_RecoveryGroup[4].Create(0,"labelC_4",0,x1,y1,x2,y2);
   m_label_RecoveryGroup[4].Text(curr_);
   m_label_RecoveryGroup[4].FontSize(X(10));
//---
   int x1_array[4],x2_array[4],y1_array[4],y2_array[4];
   x1_array[0]=m_client_RecoveryGroup[1].Left()+10;
   x1_array[1]=m_label_RecoveryGroup[0].Left();
   x1_array[2]=m_label_RecoveryGroup[1].Left();
   x1_array[3]=m_label_RecoveryGroup[4].Left();
   x2_array[0]=x1_array[0]+X(50);
   x2_array[1]=x1_array[1]+X(50);
   x2_array[2]=x1_array[2]+X(100);
   x2_array[3]=x1_array[3]+X(50);
   for(int i=0; i<4; i++)
     {
      y1_array[i]=m_caption_RecoveryGroup[1].Top()+X(25);
      y2_array[i]=y1_array[i]+X(25);
      m_rows_lebel[6][i].Create(0,"rows_levelC6_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[6][i].FontSize(X(10));
      y1_array[i]=m_caption_RecoveryGroup[1].Top()+X(50);
      y2_array[i]=y1_array[i]+X(25);
      m_rows_lebel[7][i].Create(0,"rows_levelC7_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[7][i].FontSize(X(10));
      y1_array[i]=m_caption_RecoveryGroup[1].Top()+X(75);
      y2_array[i]=y1_array[i]+X(25);
      m_rows_lebel[8][i].Create(0,"rows_levelC8_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[8][i].FontSize(X(10));
      y1_array[i]=m_caption_RecoveryGroup[1].Top()+X(100);
      y2_array[i]=y1_array[i]+X(25);
      m_rows_lebel[9][i].Create(0,"rows_levelC9_"+string(i),0,x1_array[i],y1_array[i],x2_array[i],y2_array[i]);
      m_rows_lebel[9][i].FontSize(X(10));
     }
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CRecoveryPanel::InitilizeDealButton(int offset_x,int offset_y,bool align_right)
  {
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   int butt_width=X(90);
   int butt_height=X(30);
   int client_x1,client_x2,client_y1,client_y2;
   if(!align_right)
     {
      client_x1=offset_x;
      client_x2=client_x1+3*butt_width;
      client_y2=chart_height-2*offset_y-butt_height;
      client_y1=client_y2-2*butt_height;
      m_client_DealButton[0].Create(0,"clientDealButton_0",0,client_x1,client_y1,client_x2,client_y2);
     }
   else
     {
      client_x2=chart_width-offset_x;
      client_x1=client_x2-3*butt_width;
      client_y2=chart_height-2*offset_y-butt_height;
      client_y1=client_y2-2*butt_height;
      m_client_DealButton[0].Create(0,"clientDealButton_0",0,client_x1,client_y1,client_x2,client_y2);
     }
//---
   int x1,x2,y1,y2;
//-- object
   x2=m_client_DealButton[0].Right()-X(5);
   y1=m_client_DealButton[0].Bottom()+X(5);
   x1=x2-butt_width;
   y2=y1+butt_height;
   m_button[3].Create(0,"BUTT_SELL",0,x1,y1,x2,y2);
   m_button[3].Text("Open Sell");
   m_button[3].FontSize(X(12));
//---object
   x1=m_client_DealButton[0].Left()+X(5);
   y1=m_client_DealButton[0].Bottom()+X(5);
   x2=x1+butt_width;
   y2=y1+butt_height;
   m_button[4].Create(0,"BUTT_BUY",0,x1,y1,x2,y2);
   m_button[4].Text("Open Buy");
   m_button[4].FontSize(X(12));
//---
   x1=m_button[4].Right()+X(5);
   x2=m_button[3].Left()-X(5);
   y2=m_button[3].Bottom();
   y1=y2-butt_height;
   m_edit_DealButton[0].Create(0,"TEXT_LOTS",0,x1,y1,x2,y2);
   m_edit_DealButton[0].TextAlign(ALIGN_CENTER);
   m_edit_DealButton[0].FontSize(X(12));
   x1=m_client_DealButton[0].Left()+int(butt_width*3/4);
   x2=x1+2*butt_width;
   y1=m_client_DealButton[0].Top()+X(5);
   y2=y1+X(25);
   m_label_DealButton[0].Create(0,"TEXT_SPREAD",0,x1,y1,x2,y2);
   m_label_DealButton[0].Text("");
   m_label_DealButton[0].FontSize(X(12));
   x2=m_client_DealButton[0].Right();
   x1=m_client_DealButton[0].Left()+X(25);
   y1=m_label_DealButton[0].Bottom();
   y2=y1+X(25);
   m_label_DealButton[1].Create(0,"TEXT_DRAWDOWN",0,x1,y1,x2,y2);
   m_label_DealButton[1].Text("");
   m_label_DealButton[1].FontSize(X(12));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CRecoveryPanel::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(id==CHARTEVENT_CHART_CHANGE) OnChartChangeDealButton();
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam==m_button_close_System.Name()) m_minimized_System=!m_minimized_System;
      if(sparam==m_button_close_PClosureSystem.Name()) m_minimized_PClosureSystem=!m_minimized_PClosureSystem;
      if(sparam==m_button_close_PClosureRecovery.Name()) m_minimized_PClosureRecovery=!m_minimized_PClosureRecovery;
      if(sparam==m_button_close_RecoveryGroup.Name()) m_minimized_RecoveryGroup=!m_minimized_RecoveryGroup;
     }
//---
   m_caption_System[0].OnEvent(id,lparam,dparam,sparam);
   m_caption_PClosureSystem[0].OnEvent(id,lparam,dparam,sparam);
   m_caption_PClosureRecovery[0].OnEvent(id,lparam,dparam,sparam);
   m_caption_RecoveryGroup[0].OnEvent(id,lparam,dparam,sparam);
   m_drag_object_System.OnEvent(id,lparam,dparam,sparam);
   m_drag_object_PClosureSystem.OnEvent(id,lparam,dparam,sparam);
   m_drag_object_PClosureRecovery.OnEvent(id,lparam,dparam,sparam);
   m_drag_object_RecoveryGroup.OnEvent(id,lparam,dparam,sparam);
//---
   ON_EVENT(ON_DRAG_START,m_caption_System[0],OnPanelDragStart_System)
   ON_EVENT(ON_DRAG_START,m_caption_PClosureSystem[0],OnPanelDragStart_PClosureSystem)
   ON_EVENT(ON_DRAG_START,m_caption_PClosureRecovery[0],OnPanelDragStart_PClosureRecovery)
   ON_EVENT(ON_DRAG_START,m_caption_RecoveryGroup[0],OnPanelDragStart_RecoveryGroup)
   ON_EVENT_PTR(ON_DRAG_PROCESS,GetPointer(m_drag_object_System),OnPanelDragProcess_System)
   ON_EVENT_PTR(ON_DRAG_PROCESS,GetPointer(m_drag_object_PClosureSystem),OnPanelDragProcess_PClosureSystem)
   ON_EVENT_PTR(ON_DRAG_PROCESS,GetPointer(m_drag_object_PClosureRecovery),OnPanelDragProcess_PClosureRecovery)
   ON_EVENT_PTR(ON_DRAG_PROCESS,GetPointer(m_drag_object_RecoveryGroup),OnPanelDragProcess_RecoveryGroup)
   ON_EVENT_PTR(ON_DRAG_END,GetPointer(m_drag_object_System),OnPanelDragEnd_System)
   ON_EVENT_PTR(ON_DRAG_END,GetPointer(m_drag_object_PClosureSystem),OnPanelDragEnd_PClosureSystem)
   ON_EVENT_PTR(ON_DRAG_END,GetPointer(m_drag_object_PClosureRecovery),OnPanelDragEnd_PClosureRecovery)
   ON_EVENT_PTR(ON_DRAG_END,GetPointer(m_drag_object_RecoveryGroup),OnPanelDragEnd_RecoveryGroup)
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnChartChangeDealButton()
  {
   int new_chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   int new_chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   if(chart_height!=new_chart_height || chart_width!=new_chart_width)
     {
      int dy=new_chart_height-chart_height;
      int dx=0;//new_chart_width-chart_width;
      chart_width=new_chart_width;
      chart_height=new_chart_height;
      //---
      for(int i=0; i<ArraySize(m_client_DealButton); i++) m_client_DealButton[i].Shift(dx,dy);
      for(int i=0; i<ArraySize(m_edit_DealButton); i++) m_edit_DealButton[i].Shift(dx,dy);
      for(int i=0; i<ArraySize(m_label_DealButton); i++) m_label_DealButton[i].Shift(dx,dy);
      m_button[3].Shift(dx,dy);
      m_button[4].Shift(dx,dy);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragStart_System()
  {
//-- disable to accept drage begin    
   m_caption_System[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
//-- turn on drag object     
   m_drag_object_System.PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//--- constraints
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   m_drag_object_System.Limits(-CONTROLS_DRAG_SPACING,-CONTROLS_DRAG_SPACING,
                               chart_width+CONTROLS_DRAG_SPACING,
                               chart_height+CONTROLS_DRAG_SPACING);
//--- set mouse params
   m_drag_object_System.MouseX(m_caption_System[0].MouseX());
   m_drag_object_System.MouseY(m_caption_System[0].MouseY());
   m_drag_object_System.MouseFlags(m_caption_System[0].MouseFlags());
   m_System_mouseX=m_drag_object_System.Left();
   m_System_mouseY=m_drag_object_System.Top();
   MovePanel_System(m_System_mouseX,m_System_mouseY);
//--- succeed
   ClientAreaVisible_System(false);
   if(!m_minimized_System)
      ClientAreaVisible_System(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragStart_PClosureSystem()
  {
//-- disable to accept drage begin    
   m_caption_System[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
//-- turn on drag object     
   m_drag_object_PClosureSystem.PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//--- constraints
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   m_drag_object_PClosureSystem.Limits(-CONTROLS_DRAG_SPACING,-CONTROLS_DRAG_SPACING,
                                       chart_width+CONTROLS_DRAG_SPACING,
                                       chart_height+CONTROLS_DRAG_SPACING);
//--- set mouse params
   m_drag_object_PClosureSystem.MouseX(m_caption_PClosureSystem[0].MouseX());
   m_drag_object_PClosureSystem.MouseY(m_caption_PClosureSystem[0].MouseY());
   m_drag_object_PClosureSystem.MouseFlags(m_caption_PClosureSystem[0].MouseFlags());
   m_PClosureSystem_mouseX=m_drag_object_PClosureSystem.Left();
   m_PClosureSystem_mouseY=m_drag_object_PClosureSystem.Top();
   MovePanel_PClosureSystem(m_PClosureSystem_mouseX,m_PClosureSystem_mouseY);
//--- succeed
   ClientAreaVisible_PClosureSystem(false);
   if(!m_minimized_PClosureSystem)
      ClientAreaVisible_PClosureSystem(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragStart_PClosureRecovery()
  {
//-- disable to accept drage begin    
   m_caption_System[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
//-- turn on drag object     
   m_drag_object_PClosureRecovery.PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//--- constraints
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   m_drag_object_PClosureRecovery.Limits(-CONTROLS_DRAG_SPACING,-CONTROLS_DRAG_SPACING,
                                         chart_width+CONTROLS_DRAG_SPACING,
                                         chart_height+CONTROLS_DRAG_SPACING);
//--- set mouse params
   m_drag_object_PClosureRecovery.MouseX(m_caption_PClosureRecovery[0].MouseX());
   m_drag_object_PClosureRecovery.MouseY(m_caption_PClosureRecovery[0].MouseY());
   m_drag_object_PClosureRecovery.MouseFlags(m_caption_PClosureRecovery[0].MouseFlags());
   m_PClosureRecovery_mouseX=m_drag_object_PClosureRecovery.Left();
   m_PClosureRecovery_mouseY=m_drag_object_PClosureRecovery.Top();
   MovePanel_PClosureRecovery(m_PClosureRecovery_mouseX,m_PClosureRecovery_mouseY);
//--- succeed
   ClientAreaVisible_PClosureRecovery(false);
   if(!m_minimized_PClosureRecovery)
      ClientAreaVisible_PClosureRecovery(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragStart_RecoveryGroup()
  {
//-- disable to accept drage begin  
   m_caption_System[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
//-- turn on drag object   
   m_drag_object_RecoveryGroup.PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//--- constraints
   chart_height=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   chart_width=(int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   m_drag_object_RecoveryGroup.Limits(-CONTROLS_DRAG_SPACING,-CONTROLS_DRAG_SPACING,
                                      chart_width+CONTROLS_DRAG_SPACING,
                                      chart_height+CONTROLS_DRAG_SPACING);
//--- set mouse params
   m_drag_object_RecoveryGroup.MouseX(m_caption_RecoveryGroup[0].MouseX());
   m_drag_object_RecoveryGroup.MouseY(m_caption_RecoveryGroup[0].MouseY());
   m_drag_object_RecoveryGroup.MouseFlags(m_caption_RecoveryGroup[0].MouseFlags());
   m_RecoveryGroup_mouseX=m_drag_object_RecoveryGroup.Left();
   m_RecoveryGroup_mouseY=m_drag_object_RecoveryGroup.Top();
   MovePanel_RecoveryGroup(m_RecoveryGroup_mouseX,m_RecoveryGroup_mouseY);
//--- succeed
   ClientAreaVisible_RecoveryGroup(false);
   if(!m_minimized_RecoveryGroup)
      ClientAreaVisible_RecoveryGroup(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragEnd_System()
  {
//-- enable to accept drage begin
   m_caption_System[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//-- turn off drag object
   m_drag_object_System.PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_System[0].MouseFlags(m_drag_object_System.MouseFlags());
//--- set up additional areas
   ClientAreaVisible_System(false);
   if(!m_minimized_System)
      ClientAreaVisible_System(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragEnd_PClosureSystem()
  {
//-- enable to accept drage begin
   m_caption_System[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//-- turn off drag object
   m_drag_object_PClosureSystem.PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].MouseFlags(m_drag_object_PClosureSystem.MouseFlags());
//--- set up additional areas
   ClientAreaVisible_PClosureSystem(false);
   if(!m_minimized_PClosureSystem)
      ClientAreaVisible_PClosureSystem(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragEnd_PClosureRecovery()
  {
//-- enable to accept drage begin
   m_caption_System[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//-- turn off drag object
   m_drag_object_PClosureRecovery.PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].MouseFlags(m_drag_object_PClosureRecovery.MouseFlags());
//--- set up additional areas
   ClientAreaVisible_PClosureRecovery(false);
   if(!m_minimized_PClosureRecovery)
      ClientAreaVisible_PClosureRecovery(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragEnd_RecoveryGroup()
  {
//-- enable to accept drage begin
   m_caption_System[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureSystem[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_PClosureRecovery[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].PropFlagsSet(WND_PROP_FLAG_CAN_DRAG);
//-- turn off drag object   
   m_drag_object_RecoveryGroup.PropFlagsReset(WND_PROP_FLAG_CAN_DRAG);
   m_caption_RecoveryGroup[0].MouseFlags(m_drag_object_RecoveryGroup.MouseFlags());
//--- set up additional areas
   ClientAreaVisible_RecoveryGroup(false);
   if(!m_minimized_RecoveryGroup)
      ClientAreaVisible_RecoveryGroup(true);
//--- succeed
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragProcess_System()
  {
//--- calculate coordinates
   int x=m_drag_object_System.Left();
   int y=m_drag_object_System.Top();
//--- move dialog
   MovePanel_System(x,y);
//--- succeed
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragProcess_PClosureSystem()
  {
//--- calculate coordinates
   int x=m_drag_object_PClosureSystem.Left();
   int y=m_drag_object_PClosureSystem.Top();
//--- move dialog
   MovePanel_PClosureSystem(x,y);
//--- succeed
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragProcess_PClosureRecovery()
  {
//--- calculate coordinates
   int x=m_drag_object_PClosureRecovery.Left();
   int y=m_drag_object_PClosureRecovery.Top();
//--- move dialog
   MovePanel_PClosureRecovery(x,y);
//--- succeed
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::OnPanelDragProcess_RecoveryGroup()
  {
//--- calculate coordinates
   int x=m_drag_object_RecoveryGroup.Left();
   int y=m_drag_object_RecoveryGroup.Top();
//--- move dialog
   MovePanel_RecoveryGroup(x,y);
//--- succeed
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void    CRecoveryPanel::MovePanel_System(int x,int y)
  {
   for(int i=0; i<ArraySize(m_caption_System); i++)
     {
      int x2=m_caption_System[i].Left()+x-m_System_mouseX;
      int y2=m_caption_System[i].Top()+y-m_System_mouseY;
      m_caption_System[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_client_System); i++)
     {
      int x2=m_client_System[i].Left()+x-m_System_mouseX;
      int y2=m_client_System[i].Top()+y-m_System_mouseY;
      m_client_System[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_label_System); i++)
     {
      int x2= m_label_System[i].Left()+x-m_System_mouseX;
      int y2= m_label_System[i].Top()+y-m_System_mouseY;
      m_label_System[i].Move(x2,y2);
     }
   for(int i=0; i<1; i++)
     {
      int x2= m_button[i].Left()+x-m_System_mouseX;
      int y2= m_button[i].Top()+y-m_System_mouseY;
      m_button[i].Move(x2,y2);
     }
   for(int i=0; i<4; i++)
      for(int j=0; j<4; j++)
        {
         int x2= m_rows_lebel[i][j].Left()+x-m_System_mouseX;
         int y2= m_rows_lebel[i][j].Top()+y-m_System_mouseY;
         m_rows_lebel[i][j].Move(x2,y2);
        }
//---
   int x2=m_button_close_System.Left()+x-m_System_mouseX;
   int y2=m_button_close_System.Top()+y-m_System_mouseY;
   m_button_close_System.Move(x2,y2);
//---
   m_System_mouseX=x;
   m_System_mouseY=y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void    CRecoveryPanel::MovePanel_PClosureSystem(int x,int y)
  {
   for(int i=0; i<ArraySize(m_caption_PClosureSystem); i++)
     {
      int x2=m_caption_PClosureSystem[i].Left()+x-m_PClosureSystem_mouseX;
      int y2=m_caption_PClosureSystem[i].Top()+y-m_PClosureSystem_mouseY;
      m_caption_PClosureSystem[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_client_PClosureSystem); i++)
     {
      int x2=m_client_PClosureSystem[i].Left()+x-m_PClosureSystem_mouseX;
      int y2=m_client_PClosureSystem[i].Top()+y-m_PClosureSystem_mouseY;
      m_client_PClosureSystem[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_label_PClosureSystem); i++)
     {
      int x2= m_label_PClosureSystem[i].Left()+x-m_PClosureSystem_mouseX;
      int y2= m_label_PClosureSystem[i].Top()+y-m_PClosureSystem_mouseY;
      m_label_PClosureSystem[i].Move(x2,y2);
     }
   for(int i=1; i<2; i++)
     {
      int x2= m_button[i].Left()+x-m_PClosureSystem_mouseX;
      int y2= m_button[i].Top()+y-m_PClosureSystem_mouseY;
      m_button[i].Move(x2,y2);
     }
   for(int i=4; i<6; i++)
      for(int j=0; j<4; j++)
        {
         int x2= m_rows_lebel[i][j].Left()+x-m_PClosureSystem_mouseX;
         int y2= m_rows_lebel[i][j].Top()+y-m_PClosureSystem_mouseY;
         m_rows_lebel[i][j].Move(x2,y2);
        }
   int x2=m_button_close_PClosureSystem.Left()+x-m_PClosureSystem_mouseX;
   int y2=m_button_close_PClosureSystem.Top()+y-m_PClosureSystem_mouseY;
   m_button_close_PClosureSystem.Move(x2,y2);
//---
   m_PClosureSystem_mouseX=x;
   m_PClosureSystem_mouseY=y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void    CRecoveryPanel::MovePanel_PClosureRecovery(int x,int y)
  {
   for(int i=0; i<ArraySize(m_caption_PClosureRecovery); i++)
     {
      int x2=m_caption_PClosureRecovery[i].Left()+x-m_PClosureRecovery_mouseX;
      int y2=m_caption_PClosureRecovery[i].Top()+y-m_PClosureRecovery_mouseY;
      m_caption_PClosureRecovery[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_client_PClosureRecovery); i++)
     {
      int x2=m_client_PClosureRecovery[i].Left()+x-m_PClosureRecovery_mouseX;
      int y2=m_client_PClosureRecovery[i].Top()+y-m_PClosureRecovery_mouseY;
      m_client_PClosureRecovery[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_label_PClosureRecovery); i++)
     {
      int x2= m_label_PClosureRecovery[i].Left()+x-m_PClosureRecovery_mouseX;
      int y2= m_label_PClosureRecovery[i].Top()+y-m_PClosureRecovery_mouseY;
      m_label_PClosureRecovery[i].Move(x2,y2);
     }
   for(int i=5; i<6; i++)
     {
      int x2= m_button[i].Left()+x-m_PClosureRecovery_mouseX;
      int y2= m_button[i].Top()+y-m_PClosureRecovery_mouseY;
      m_button[i].Move(x2,y2);
     }
   for(int i=10; i<12; i++)
      for(int j=0; j<4; j++)
        {
         int x2= m_rows_lebel[i][j].Left()+x-m_PClosureRecovery_mouseX;
         int y2= m_rows_lebel[i][j].Top()+y-m_PClosureRecovery_mouseY;
         m_rows_lebel[i][j].Move(x2,y2);
        }
   int x2=m_button_close_PClosureRecovery.Left()+x-m_PClosureRecovery_mouseX;
   int y2=m_button_close_PClosureRecovery.Top()+y-m_PClosureRecovery_mouseY;
   m_button_close_PClosureRecovery.Move(x2,y2);
//---
   m_PClosureRecovery_mouseX=x;
   m_PClosureRecovery_mouseY=y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void    CRecoveryPanel::MovePanel_RecoveryGroup(int x,int y)
  {
   for(int i=0; i<ArraySize(m_caption_RecoveryGroup); i++)
     {
      int x2=m_caption_RecoveryGroup[i].Left()+x-m_RecoveryGroup_mouseX;
      int y2=m_caption_RecoveryGroup[i].Top()+y-m_RecoveryGroup_mouseY;
      m_caption_RecoveryGroup[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_client_RecoveryGroup); i++)
     {
      int x2=m_client_RecoveryGroup[i].Left()+x-m_RecoveryGroup_mouseX;
      int y2=m_client_RecoveryGroup[i].Top()+y-m_RecoveryGroup_mouseY;
      m_client_RecoveryGroup[i].Move(x2,y2);
     }
   for(int i=0; i<ArraySize(m_label_RecoveryGroup); i++)
     {
      int x2= m_label_RecoveryGroup[i].Left()+x-m_RecoveryGroup_mouseX;
      int y2= m_label_RecoveryGroup[i].Top()+y-m_RecoveryGroup_mouseY;
      m_label_RecoveryGroup[i].Move(x2,y2);
     }
   for(int i=2; i<3; i++)
     {
      int x2= m_button[i].Left()+x-m_RecoveryGroup_mouseX;
      int y2= m_button[i].Top()+y-m_RecoveryGroup_mouseY;
      m_button[i].Move(x2,y2);
     }
   for(int i=6; i<10; i++)
      for(int j=0; j<4; j++)
        {
         int x2= m_rows_lebel[i][j].Left()+x-m_RecoveryGroup_mouseX;
         int y2= m_rows_lebel[i][j].Top()+y-m_RecoveryGroup_mouseY;
         m_rows_lebel[i][j].Move(x2,y2);
        }
   int x2=m_button_close_RecoveryGroup.Left()+x-m_RecoveryGroup_mouseX;
   int y2=m_button_close_RecoveryGroup.Top()+y-m_RecoveryGroup_mouseY;
   m_button_close_RecoveryGroup.Move(x2,y2);
//---
   m_RecoveryGroup_mouseX=x;
   m_RecoveryGroup_mouseY=y;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CRecoveryPanel::ClientAreaVisible_System(bool visible)
  {
   for(int i=0; i<ArraySize(m_client_System); i++)
      m_client_System[i].Visible(visible);
   for(int i=0; i<ArraySize(m_caption_System); i++)
      m_caption_System[i].Visible(visible);
//---
   for(int i=0; i<ArraySize(m_label_System); i++)
      m_label_System[i].Visible(visible);
   for(int i=0; i<1; i++)
      m_button[i].Visible(visible);
   for(int i=0; i<4; i++)
      for(int j=0; j<4; j++)
         m_rows_lebel[i][j].Visible(visible);
//---
   m_button_close_System.Visible(false);
   m_caption_System[0].Visible(false);
   m_caption_System[0].Visible(true);
   m_button_close_System.Visible(true);
//---
   if(visible)
      m_button_close_System.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_System.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CRecoveryPanel::ClientAreaVisible_PClosureSystem(bool visible)
  {
   for(int i=0; i<ArraySize(m_client_PClosureSystem); i++)
      m_client_PClosureSystem[i].Visible(visible);
   for(int i=0; i<ArraySize(m_caption_PClosureSystem); i++)
      m_caption_PClosureSystem[i].Visible(visible);
//---
   for(int i=0; i<ArraySize(m_label_PClosureSystem); i++)
      m_label_PClosureSystem[i].Visible(visible);
   for(int i=1; i<2; i++)
      m_button[i].Visible(visible);
   for(int i=4; i<6; i++)
      for(int j=0; j<4; j++)
         m_rows_lebel[i][j].Visible(visible);
//---
   m_button_close_PClosureSystem.Visible(false);
   m_caption_PClosureSystem[0].Visible(false);
   m_caption_PClosureSystem[0].Visible(true);
   m_button_close_PClosureSystem.Visible(true);
//---
   if(visible)
      m_button_close_PClosureSystem.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_PClosureSystem.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+ 
void  CRecoveryPanel::ClientAreaVisible_PClosureRecovery(bool visible)
  {
   for(int i=0; i<ArraySize(m_client_PClosureRecovery); i++)
      m_client_PClosureRecovery[i].Visible(visible);
   for(int i=0; i<ArraySize(m_caption_PClosureRecovery); i++)
      m_caption_PClosureRecovery[i].Visible(visible);
//---
   for(int i=0; i<ArraySize(m_label_PClosureRecovery); i++)
      m_label_PClosureRecovery[i].Visible(visible);
   for(int i=5; i<6; i++)
      m_button[i].Visible(visible);
   for(int i=10; i<12; i++)
      for(int j=0; j<4; j++)
         m_rows_lebel[i][j].Visible(visible);
//---
   m_button_close_PClosureRecovery.Visible(false);
   m_caption_PClosureRecovery[0].Visible(false);
   m_caption_PClosureRecovery[0].Visible(true);
   m_button_close_PClosureRecovery.Visible(true);
//---
   if(visible)
      m_button_close_PClosureRecovery.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_PClosureRecovery.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  CRecoveryPanel::ClientAreaVisible_RecoveryGroup(bool visible)
  {
   for(int i=0; i<ArraySize(m_client_RecoveryGroup); i++)
      m_client_RecoveryGroup[i].Visible(visible);
   for(int i=0; i<ArraySize(m_caption_RecoveryGroup); i++)
      m_caption_RecoveryGroup[i].Visible(visible);
//---
   for(int i=0; i<ArraySize(m_label_RecoveryGroup); i++)
      m_label_RecoveryGroup[i].Visible(visible);
   for(int i=2; i<3; i++)
      m_button[i].Visible(visible);
   for(int i=6; i<10; i++)
      for(int j=0; j<4; j++)
         m_rows_lebel[i][j].Visible(visible);
//---
   m_button_close_RecoveryGroup.Visible(false);
   m_caption_RecoveryGroup[0].Visible(false);
   m_caption_RecoveryGroup[0].Visible(true);
   m_button_close_RecoveryGroup.Visible(true);
//---
   if(visible)
      m_button_close_RecoveryGroup.BmpNames("::Include\\Controls\\res\\Turn.bmp");
   else
      m_button_close_RecoveryGroup.BmpNames("::Include\\Controls\\res\\Restore.bmp");
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void   CRecoveryPanel::SetLabel(int panal,int line,string descrip,string lot,string profit,string curr)
  {
   int i=-1;
   if(panal==0 && line<=4) i=line-1;
   if(panal==1 && line<=2) i=line+4-1;
   if(panal==2 && line<=4) i=line+6-1;
   if(panal==3 && line<=2) i=line+10-1;
   if(i>=0 && i<12)
     {
      m_rows_lebel[i][0].Text(descrip);
      m_rows_lebel[i][1].Text(lot);
      m_rows_lebel[i][2].Text(profit);
      m_rows_lebel[i][3].Text(curr);
     }
  }
//+------------------------------------------------------------------+
