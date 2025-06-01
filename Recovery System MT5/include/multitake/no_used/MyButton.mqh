//+------------------------------------------------------------------+
//|                                                     MyButton.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyButton
  {
private:
   string            m_name;
   int               m_top;
   int               m_right;
   int               m_left;
   int               m_bottom;
   //---
   bool              ButtonCreate(const long              chart_ID=0,               // chart's ID 
                                  const string            name="Button",            // button name 
                                  const int               sub_window=0,             // subwindow index 
                                  const int               x=0,                      // X coordinate 
                                  const int               y=0,                      // Y coordinate 
                                  const int               width=50,                 // button width 
                                  const int               height=18,                // button height 
                                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                                  const string            text="Button",            // text 
                                  const string            font="Arial",             // font 
                                  const int               font_size=10,             // font size 
                                  const color             clr=clrBlack,             // text color 
                                  const color             back_clr=C'236,233,216',  // background color 
                                  const color             border_clr=clrNONE,       // border color 
                                  const bool              state=false,              // pressed/released 
                                  const bool              back=false,               // in the background 
                                  const bool              selection=false,          // highlight to move 
                                  const bool              hidden=true,              // hidden in the object list 
                                  const long              z_order=1);                // priority for mouse click 
   //---
   bool              ButtonMove(const long   chart_ID=0,// chart's ID 
                                const string name="Button", // button name 
                                const int    x=0,           // X coordinate 
                                const int    y=0);           // Y coordinate    
   bool              ButtonChangeSize(const long   chart_ID=0,// chart's ID 
                                      const string name="Button", // button name 
                                      const int    width=50,      // button width 
                                      const int    height=18);     // button height 
   bool              ButtonChangeCorner(const long             chart_ID=0,// chart's ID 
                                        const string           name="Button",// button name 
                                        const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER); // chart corner for anchoring                    
   bool              ButtonDelete(const long   chart_ID=0,// chart's ID 
                                  const string name="Button"); // button name 
   bool              ButtonTextChange(const long   chart_ID=0,// chart's ID 
                                      const string name="Button",// button name 
                                      const string text="Text");   // text
   //---                                
public:
   bool              Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   string            Name(){return(m_name);}
   void              ColorBorder(color value){ObjectSetInteger(ChartID(),m_name,OBJPROP_BORDER_COLOR,value);}
   void              ColorBackground(color value){ObjectSetInteger(ChartID(),m_name,OBJPROP_BGCOLOR,value);}
   void              Color(color value){ObjectSetInteger(ChartID(),m_name,OBJPROP_COLOR,value);}
   void              Text(string value){ObjectSetString(ChartID(),m_name,OBJPROP_TEXT,value);}
   int               Top(){return(m_top);}
   int               Left(){return(m_left);}
   int               Bottom(){return(m_bottom);}
   int               Right(){return(m_right);}
   void              Move(int x,int y){ButtonMove(ChartID(),m_name,x,y);}
   void              Shift(int dx,int dy){}
   void              Visible(bool value)
     {
      ObjectSetInteger(ChartID(),m_name,OBJPROP_HIDDEN,value);
      ObjectSetInteger(ChartID(),m_name,OBJPROP_BACK,false);
     }
   //---
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CMyButton::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   m_name=name;
//---
   int x_size=(int)MathAbs(x1-x2);
   int y_size=(int)MathAbs(y1-y2);
   ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER;
   string text="";
   string font="";
   int font_size=10;
   color Clr=clrRed;
   color BgClr=clrGreen;
   color BorderClr=clrRed;
   bool state=false;
   bool selection=false;
   bool back=false;
   bool hidden=false;
   bool zOrder=false;
   return(ButtonCreate(0,name,0,x1,y1,x_size,y_size,corner,text,font,font_size,
          Clr,BgClr,BorderClr,state,back,selection,hidden,zOrder));
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the button                                                | 
//+------------------------------------------------------------------+ 
bool CMyButton::ButtonCreate(const long              chart_ID=0,// chart's ID 
                             const string            name="Button",            // button name 
                             const int               sub_window=0,             // subwindow index 
                             const int               x=0,                      // X coordinate 
                             const int               y=0,                      // Y coordinate 
                             const int               width=50,                 // button width 
                             const int               height=18,                // button height 
                             const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                             const string            text="Button",            // text 
                             const string            font="Arial",             // font 
                             const int               font_size=10,             // font size 
                             const color             clr=clrBlack,             // text color 
                             const color             back_clr=C'236,233,216',  // background color 
                             const color             border_clr=clrNONE,       // border color 
                             const bool              state=false,              // pressed/released 
                             const bool              back=false,               // in the background 
                             const bool              selection=false,          // highlight to move 
                             const bool              hidden=true,              // hidden in the object list 
                             const long              z_order=1)                // priority for mouse click 
  {
//--- reset the error value 
   ResetLastError();
//--- create the button 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,
            ": failed to create the button! Error code = ",GetLastError());
      return(false);
     }
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
//--- enable (true) or disable (false) the mode of moving the button by mouse 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the button                                                  | 
//+------------------------------------------------------------------+ 
bool CMyButton::ButtonMove(const long   chart_ID=0,// chart's ID 
                           const string name="Button", // button name 
                           const int    x=0,           // X coordinate 
                           const int    y=0)           // Y coordinate 
  {
//--- reset the error value 
   ResetLastError();
//--- move the button 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x))
     {
      Print(__FUNCTION__,
            ": failed to move X coordinate of the button! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y))
     {
      Print(__FUNCTION__,
            ": failed to move Y coordinate of the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Change button size                                               | 
//+------------------------------------------------------------------+ 
bool CMyButton::ButtonChangeSize(const long   chart_ID=0,// chart's ID 
                                 const string name="Button", // button name 
                                 const int    width=50,      // button width 
                                 const int    height=18)     // button height 
  {
//--- reset the error value 
   ResetLastError();
//--- change the button size 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width))
     {
      Print(__FUNCTION__,
            ": failed to change the button width! Error code = ",GetLastError());
      return(false);
     }
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height))
     {
      Print(__FUNCTION__,
            ": failed to change the button height! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Change corner of the chart for binding the button                | 
//+------------------------------------------------------------------+ 
bool CMyButton::ButtonChangeCorner(const long             chart_ID=0,// chart's ID 
                                   const string           name="Button",            // button name 
                                   const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) // chart corner for anchoring 
  {
//--- reset the error value 
   ResetLastError();
//--- change anchor corner 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner))
     {
      Print(__FUNCTION__,
            ": failed to change the anchor corner! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Change button text                                               | 
//+------------------------------------------------------------------+ 
bool CMyButton::ButtonTextChange(const long   chart_ID=0,// chart's ID 
                                 const string name="Button", // button name 
                                 const string text="Text")   // text 
  {
//--- reset the error value 
   ResetLastError();
//--- change object text 
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the button                                                | 
//+------------------------------------------------------------------+ 
bool CMyButton::ButtonDelete(const long   chart_ID=0,// chart's ID 
                             const string name="Button") // button name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the button 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the button! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Script program start function                                    | 
//+------------------------------------------------------------------+ 
