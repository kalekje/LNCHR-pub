#Requires Autohotkey v2.0+
#SingleInstance Force
#WinActivateForce

Suspend 1 ; suspend all hotkeys until loaded

#Include LNCHR-Commands.ahk
#Include LNCHR-Funcs.ahk

TraySetIcon("rocketlnchr.ico")

SetCapsLockState("AlwaysOff")

toggleCapsLock(){
    SetCapsLockState !GetKeyState('CapsLock', 'T')
}

; Allow normal CapsLock functionality to be toggled by Alt+CapsLock, or shift, or crl
!CapsLock::
^CapsLock::
+CapsLock::toggleCapsLock()



UsingMainWorkComputer := A_ComputerName == "xyz" ; Global flag for using main work computer, changes title
UsingAnyWorkComputer := InStr(A_ComputerName, "xyz") == 1 ; Global flag for using any work computer for select commands


; ______________________________________________________________________________ Globals and Funcs ___________

;  lngui = launcher gui, pronounced linguini

global lngui_props := object()

reset_lngui_props(mainoff := "main") {  ; reset flags and choose what state you want
    lngui_props.state := mainoff
    lngui_props.qfunc := ""
    lngui_props.qclose := True
    lngui_props.click_exit := False
    lngui_props.title := " 🚀 LNCHR"
    lngui_props.calced := False ; has calculator been used before?
    lngui_props.calcmem := 0 ; calculator memory line
    lngui_props.acccolor := "FFB900" ; calculator memory line


    if UsingMainWorkComputer {
        lngui_props.title  := lngui_props.title " 💼"
    }


}
reset_lngui_props("off") ; initialize flags, set state to off

global key_presses := object()
key_presses.caps := 0

is_lngui_state(state) {  ; check state of lngui
    return (lngui_props.state == state)
}

is_lngui_on() { ; check if gui is on
    return ! is_lngui_state("off")
}

set_lngui_state(state) {  ; set state of lngui
   lngui_props.state := state
}


; ______________________________________________________________________________ The GUI ___________


build_lngui(){
    global lngui

    common_options := "xm w400 cc5c8c6 -E0x200"

    lngui := Gui()

;    lngui.AddPicture("x0 y0 w350 h97 0x4000000","bg1.png")  ; background ; messing around with backgrounds here
;    lngui._text := lngui.AddText("x0 y0 w400 cc5c8c6 -E0x200 +BackgroundTrans c" lngui_props.acccolor , lngui_props.title)


    lngui.Opt("AlwaysOnTop -SysMenu -caption +Border ")
    lngui.SetFont("s14", "Verdana")
    lngui.Title := lngui_props.title
    lngui.BackColor := "1d1f21"

    lngui._text := lngui.AddText(common_options " c" lngui_props.acccolor , lngui_props.title)
    lngui._edit := lngui.AddEdit(common_options " Background1d1f21", "") ; the main input box
    lngui._edit.OnEvent("Change", lngui_edit_chng)
    lngui._butt := lngui.AddButton("xp-0 yp-0 w0 h0 +default")  ; add a hidden button to allow enter to submit contents
    lngui._butt.OnEvent("Click", lngui_query_enter)  ; see function below

    lngui.OnEvent("Escape", close_lngui)

    reset_lngui_props("main")
    lngui_props.click_exit := True

    set_lngui_window("main")
}



set_lngui_window(s){ ; I was messing around with rounded corners here, was not satisfied with results
 if s == "main" {
    WinSetTransparent 230, lngui.Hwnd
;    WinSetRegion "0-0 w350 h90 R20-20", lngui.Hwnd  ;  for round corners
 }
 if s == "query" {
;     WinSetRegion "0-0 w350 h87 R20-20", lngui.Hwnd  ;  for round corners
 }
  if s == "calc" {
;        WinSetRegion "0-0 w350 h110 R20-20", lngui.Hwnd  ; for round corners
 }
    lngui.Show("autosize")
}


set_lngui_input(s:=""){
    lngui._edit.Value := s
}

get_lngui_input() {
    return lngui._edit.Value
}


lngui_edit_chng(GuiCtrlObj, Info) {
    if is_lngui_state("main")
        lngui_run_commands(get_lngui_input()) ;
    return
}



close_lngui(*) {
    reset_lngui_props("off")
    lngui.Destroy()
}




; ______________________________________________________________________________ Open/Closing GUI ___________

lngui_activable(){ ; conditions to be met to allow hotkey
    try {
        return !InStr(WinGetTitle("A"), "Remote Desktop")
    }
    return True
}

; Opening and Closing GUI with Caps Lock button
; Single press toggles gui on/off (or closes app that requires double press)
; Double press within 500 ms -> send win+alt+space to open power launcher
; Disable if Remote Desktop is active (to allow other instance of this app take over)
#HotIf lngui_activable()  ;; do not push capslock stuff to remote desktop
CapsLock::
    {
        if is_lngui_state("query") {
            if !WinActive(lngui.Hwnd) { ; return focus to lnchr
                WinActivate(lngui.Hwnd)
                return
            }
                close_lngui() ; return to main
                build_lngui()
                return
            }
        key_presses.caps := key_presses.caps + 1
        if key_presses.caps == 1 {
                SetTimer(caps_presses_timer, -500) ; set timer on first press
            }

        if WinActive("PowerToys.PowerLauncher") {
                Send "{Esc}"
                return
            }
        if is_lngui_state("off"){
                build_lngui()
                return
            }
        if  is_lngui_on(){
                close_lngui() ; don't return here as a second key press might have been used
            }
        if (key_presses.caps > 1){ ; do this when double press
                Send "#!{Space}" ; win+alt+space, opens MS Power Toys Run
                close_lngui()
                return
            }
        return
    }
#HotIf

caps_presses_timer() { ; reset cap timer to 0
    key_presses.caps := 0
}


#HotIf lngui_props.click_exit  ; exit gui by clicking outside of it
    LButton::
    RButton::
        {
            MouseGetPos , , &id, &control
            if (control = ""){
                close_lngui()
                }
            return
        }
#HotIf


; ______________________________________________________________________________ HotKeys in GUI ___________


#HotIf is_lngui_on()  ; hotkeys for when gui is on
    Tab::{
            tryrun("C:\Program Files\Everything\Everything.exe")
            close_lngui()
            return
        }

    LWin::{
                tryrun("ipython")
                close_lngui()
                return
        }

    Up::{
            lngui_arr_press(-1)
            return
        }

    Down::{
            lngui_arr_press(1)
            return
        }
#HotIf



; ______________________________________________________________________________ Query Mode Stuff ___________



lngui_enable_query(query_title, qfunc) {
    lngui_props.click_exit := False
    set_lngui_state("query")
    lngui._text.Value := lngui_props.title "  🠖  " query_title
    set_lngui_input()
    set_lngui_window("query")
    lngui_props.qfunc := [qfunc] ; for some reason, this must be stored in an array, maybe to make new obj?
}


reset_lngui_query(){
    lngui_props.qfunc := ""
}



lngui_query_enter(*) { ; gui_call_sub_funcs
    if is_lngui_state("query")
        lngui_props.qfunc[1](get_lngui_input())
    if lngui_props.qclose ; by default, close after query
        close_lngui()
}



; ______________________________________________________________________________ Calc Mode Stuff ___________


lngui_enable_calc(){
   lngui_props.qclose := False ; don't close gui after submission
    if ! lngui_props.calced {
        lngui_enable_query("Calculate", Calculate)
        lngui_calctext := lngui.AddText("yp+30 xm w220 cc5c8c6 -E0x200 vCalcText ", " ")
        set_lngui_window("calc")
   }
   lngui_props.calced := True
}



GetCalcMem(TheFileName, Offset) {
    _text := FileRead(TheFileName)
    _arr := StrSplit(_text , "`n")
    if Offset < 1 {
        Offset := 1
    }
    if Offset > _arr.Length {
        Offset := _arr.Length
    }
    lngui_props.calcmem := Offset
    return _arr[-Offset]
}



lngui_arr_press(ud) {
    lngui_enable_calc()
    lngui_props.calcmem += ud
    lngui._edit.Value := ""
    set_lngui_input()
    set_lngui_input(GetCalcMem("LNCHR-CalcMemory.txt", lngui_props.calcmem))
    SendMessage(0xB1, 69, 69,, lngui._edit.Hwnd) ; EM_SETSEL ; set cursor to end
    lngui.Show("autosize")

}


set_calc_text(result) {
    lngui["CalcText"].Value := " = " result
    lngui.Show("autosize")
}





Suspend 0 ; re-enable hot keys


