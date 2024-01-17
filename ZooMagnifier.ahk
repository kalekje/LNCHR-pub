; the specific (absolute) x, y to be magnified,
start_x:= 2800, start_y:= 500
; the display of the magnified image x, y, w, h
xx:=300, yy:= 50, ww:=400, hh:=400

;ScreenMagnifier from holomind 
;https://autohotkey.com/board/topic/10660-screenmagnifier/
OnExit handle_exit

  Gui,  +AlwaysOnTop  +Owner +Resize +ToolWindow ; window for the dock
  Gui, Show, NoActivate w%ww% h%hh% x%xx% y%yy% , PrintScreen
  Gui, Add, DDL, vzoom   , 0.5|1|2||4|8|16 
  Gui, add, button, x120 y6 h24 w40 gset_sub, Set
  Gui, Add, Checkbox, y12 x180 vantialize, Antialize ?
  Gui, Add, Slider, vdelay x240 y0  Range0-200
  Gui, Add, Text, x340 y12 w80  vdelay2
  

  WinGet PrintScreenID, id  ,PrintScreen  ; 
  WinSet, Transparent , 254, PrintScreen

  ;retrieve the unique ID number (HWND/handle) of that window
  WinGet, PrintSourceID, id 

  hotkey , #x           , toggle_follow
  hotkey , +$LButton    , click_through

  toolbar_def:=35
  toolbar := toolbar_def
  follow :=0

  hdd_frame := DllCall( "GetDC", UInt, PrintSourceID )
  hdc_frame := DllCall( "GetDC", UInt, PrintScreenID )

  hdc_buffer := DllCall("gdi32.dll\CreateCompatibleDC", UInt,  hdc_frame)  ; buffer
  hbm_buffer := DllCall("gdi32.dll\CreateCompatibleBitmap", UInt,hdc_frame, Int,A_ScreenWidth, Int,A_ScreenHeight)
  
  Gosub, Repaint
return 


set_sub:
	; todo if mouse in GUI window, set area to upper right corner of gui. Otherwise, set it to where mouse is pointed to.
    WinGetPos, x, y, w, h
	MouseGetPos, x, y, www, hhh
    ;msgbox, The gui has been autosized to`nx%x%`ty%y%`nw%w%`th%h%
    start_x:= x
    start_y:= y
    ;xx:= start_x
    ;yy:= start_y
    ww:= w
    hh:= h
	Gosub, Repaint
return



toggle_follow: 
    follow := 1 - follow
  
    if follow = 1 
    {
        WinSet Region, 0-0  W%ww% H%wh% E  , PrintScreen
        toolbar := -32 ; height of window title
        GuiControl, Hide, zoom
    }
    else
    {
        WinSet Region,, PrintScreen
        toolbar :=toolbar_def
        GuiControl, Show, zoom
    }
Return

click_through:
    if follow = 1
    {
      Gui, Hide
      Send, {Click}
      SetTimer, Repaint , Off
      Sleep, 100
      Gui, Show
      SetTimer, Repaint, %delay%
    }
Return

Repaint: 

   CoordMode, Mouse, Screen                
   ;MouseGetPos, start_x, start_y             ;  position of mouse
   Gui, Submit, NoHide                       ; needed to read the dropdown and slidervalue
   GuiControl,, delay2 , delay %delay% ms
   WinGetPos, wx, wy, ww, wh , PrintScreen

   wh2 := wh - toolbar

    DllCall( "gdi32.dll\SetStretchBltMode", "uint", hdc_frame, "int", 4 * antialize )  ; Halftone better quality with stretch
   
    DllCall("gdi32.dll\StretchBlt", UInt,hdc_frame, Int,0, Int,toolbar, Int,ww, Int,wh - toolbar
          , UInt,hdd_frame, Int
          , start_x-(ww / 2 / zoom)
          , Int,start_y -( wh2 / 2/zoom), Int,ww / zoom, Int,wh2 / zoom ,UInt,0xCC0020) ; SRCCOPY

   if follow = 1
     WinMove, PrintScreen, ,start_x -ww/2 , start_y-wh/2 
   
  SetTimer, Repaint , %delay% 
Return

GuiClose:
handle_exit:
   DllCall("gdi32.dll\DeleteObject", UInt,hbm_buffer)
   DllCall("gdi32.dll\DeleteDC", UInt,hdc_frame )
   DllCall("gdi32.dll\DeleteDC", UInt,hdd_frame )
   DllCall("gdi32.dll\DeleteDC", UInt,hdc_buffer)
ExitApp