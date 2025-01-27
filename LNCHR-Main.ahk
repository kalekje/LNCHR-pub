#Requires Autohotkey v2.0+
#SingleInstance Force
#WinActivateForce

Suspend 1 ; suspend all hotkeys until loaded

global lngui_props := object() ; stored in an object to allow for easier access in functons (objects are global)
lngui_props.calceqfile := "LNCHR-CalcEqns.txt" ; used in Funcs, list of equations to load up


#Include LNCHR-Commands.ahk
#Include LNCHR-Funcs.ahk
#Include QuickTips.ahk


TraySetIcon("rocketlnchr.ico")

SetCapsLockState("AlwaysOff")

toggleCapsLock(){
    if ! is_lngui_on() {
    SetCapsLockState !GetKeyState('CapsLock', 'T')
}}

; Allow normal CapsLock functionality to be toggled by Alt+CapsLock, or shift, or crl
!CapsLock::
^CapsLock::
+CapsLock::toggleCapsLock()


; Some flags for commands
UsingWorkComputer := A_ComputerName == "computer name if you want" ; Global flag for using main work computer, changes title
; and toggle can be used for enabling specific commands

;#Include ../LNCHR-Private/LNCHR-Load-Private.ahk ; some private functions, I set my computer name here and load custom functions I can't share



; some settings
lngui_props.show_commands_tips := True
lngui_props.query_autocomplete := True


; ______________________________________________________________________________ gui properties  ___________

;  lngui is the launcher gui, pronounced linguini


lngui_props.title := " 🚀 LNCHR" ; restore the title
if UsingWorkComputer
    lngui_props.title  := lngui_props.title " 💼"


lngui_props.memfile := "LNCHR-Memory.ini"
if lngui_props.show_commands_tips
    lngui_props.commands := FileRead("HELP-Commands.txt") ; for tooltip prompt when in main



reset_lngui_props(mainoff := "main") {  ; reset flags and choose what state you want
    lngui_props.state := mainoff ; state of lngui
    lngui_props.qfunc := "" ; the function name to be called when in query mode
    lngui_props.qclose := True ; close after running query flag
    lngui_props.click_exit := False ; click to exit gui (when in main, keep gui open in query)
    lngui_props.calced := False ; has calculator been used before?
    lngui_props.memind := 0 ; memory index, changes with up/down arrow
    lngui_props.memcat := "Calculate" ; memory category, changes with query mode
    lngui_props.memarr := [] ; memory array accessed with arrow keys
    lngui_props.memstr := "" ; memory string (separated by lines) accessed with arrow keys
}
reset_lngui_props("off") ; initialize flags, set state to off

global key_presses := object() ; log number of keypresses, used for multi-tapping of caps lock
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


; ______________________________________________________________________________ make the gui ___________


build_lngui(){
    global lngui

    SetCapsLockState false

    lngui := Gui()
    
    acccolor := "FFB900" ; accentcolor
    backcolor := "1d1f21" ; background color
    common_gui_opts := "xm w400 cc5c8c6 -E0x200"

    lngui.Opt("AlwaysOnTop -SysMenu -caption +Border ")
    lngui.SetFont("s14", "Verdana")
    lngui.Title := lngui_props.title
    lngui.BackColor := backcolor

    lngui._text := lngui.AddText(common_gui_opts " c" acccolor , lngui_props.title)
    lngui._edit := lngui.AddEdit(common_gui_opts " Background" backcolor, "") ; the main input box

    lngui._edit.OnEvent("Change", lngui_edit_chng)
    lngui._butt := lngui.AddButton("xp-0 yp-0 w0 h0 +default")  ; add a hidden button to allow enter to submit contents
    lngui._butt.OnEvent("Click", lngui_query_enter)  ; see function below

    lngui.OnEvent("Escape", close_lngui)

    reset_lngui_props("main")
    lngui_props.click_exit := True

    WinSetTransparent 230, lngui.Hwnd

    lngui.Show("autosize")
}


; ______________________________________________________________________________ interfacing with gui input/edit box ___________


add_lngui_input(s:=""){
    lngui._edit.value := lngui._edit.value . s
}

set_lngui_input(s:=""){
    lngui._edit.value := s
}

get_lngui_input() {
    try {
    return lngui._edit.value
    } catch as e {
    }
}


lngui_edit_chng(GuiCtrlObj, Info) {
    if is_lngui_state("main") {
         lngui_run_commands(get_lngui_input()) ;
         lngui_show_command_tips()
     } else if lngui_props.query_autocomplete {
        lngui_autocomplete()
     }
     return
}


lngui_show_command_tips() { ; show tooltip with commands
if lngui_props.show_commands_tips {
    tip := filter_lines(get_lngui_input(), lngui_props.commands)
    ToolTip(tip, 500, 0)
    SetTimer(() => ToolTip(), -10000)
}}



; ______________________________________________________________________________ open/close gui ___________



close_lngui(*) {
    ToolTip()
    reset_lngui_props("off")
    lngui.Destroy()
}



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


; ______________________________________________________________________________ hotkeys while gui is open ___________


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
            lngui_arr_press(1)
            return
        }

    Down::{
            lngui_arr_press(-1)
            return
        }
#HotIf




; ______________________________________________________________________________ query mode ___________


lngui_enable_query(query_title, qfunc) {
    ToolTip()
    lngui_props.click_exit := False
    set_lngui_state("query")
    lngui._text.Value := lngui_props.title "  🠖  " query_title
    set_lngui_input()
    lngui_props.qfunc := [qfunc] ; for some reason, this must be stored in an array, maybe to make new obj?
    lngui_props.memcat := query_title
    lngui_props.memarr := []
    lngui_props.memstr := ""
    lngui_reload_qmem()
}


lngui_reload_qmem() {
    if InStr(IniRead(lngui_props.memfile),  lngui_props.memcat) {
        lngui_props.memstr := IniRead(lngui_props.memfile, lngui_props.memcat) "`n"
        lngui_props.memarr := StrSplit(lngui_props.memstr, "`n")
    } else {
        lngui_props.memarr := []
        lngui_props.memstr := ""
    }
}



lngui_update_qmem() {
    mem := get_lngui_input() . "`n" . StrReplace(lngui_props.memstr, get_lngui_input() . "`n", "") ; remove existing entries from memory and add current entry
    IniDelete(lngui_props.memfile, lngui_props.memcat) ; delete section to re-add it with
    IniWrite(mem, lngui_props.memfile, lngui_props.memcat)
}


lngui_query_enter(*) { ; gui_call_sub_funcs
    if is_lngui_state("query") {
        if get_lngui_input() == "clrmem" { ; type clear to delete memory
            IniDelete(lngui_props.memfile, lngui_props.memcat)
        } else {
            lngui_props.qfunc[1](get_lngui_input())
            if lngui_props.memcat != "Calculate" { ; note different function updates calculator memory only if expression is valid
                lngui_update_qmem()
            }
        }
    }
    if lngui_props.qclose ; by default, close after query
        close_lngui()
}



lngui_enable_calc(){
   lngui_props.qclose := False ; don't close gui after submission
    if ! lngui_props.calced {
        lngui_enable_query("Calculate", Calculate)
        lngui_calctext := lngui.AddText("yp+30 xm w220 cc5c8c6 -E0x200 vCalcText ", " ")
   }
   lngui_props.calced := True
   lngui_props.memcat := "Calculate"
   lngui.Show("autosize")
}


set_calc_text(result) {
    lngui["CalcText"].Value := " = " result
}



lngui_arr_press(ud) {
    if is_lngui_state("main") {
        input := get_lngui_input()
        if input {
            lngui_run_commands(input " ") ; try to activate query by adding space, eg. o ↓ goes through outlook history
        }
        if not is_lngui_state("query") {
            lngui_enable_calc() ; if was not put into query, assume calc enables
        }
    } else {
    lngui_props.memind -= ud
    set_lngui_input(lngui_get_query_mem(lngui_props.memcat, lngui_props.memind))
    move_caret(0,-1)
    }
}


lngui_get_query_mem(cat, ind) { ; retrieve memory based on index
    if lngui_props.memarr.Length == 0 {
        return ""
    }
    if ind < 1 {
        ind := 1
        lngui_reload_qmem()
    }
    if ind > lngui_props.memarr.Length {
        ind := lngui_props.memarr.Length
    }
    lngui_props.memind := ind
    return lngui_props.memarr[ind]
}



lngui_autocomplete() {
  if ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
      return ; dont autocomplete on delete or backspace
  input := get_lngui_input()  ; stash current input
  res := filter_lines(input, lngui_props.memstr, True, lngui_props.memcat != "Calculate") ; get autocomplete result, do case insensitive unless calculator
  if res == "" or input == res or StrLen(input) > StrLen(res)
    return ; don't autocomplete if exact match or no match
  currCaret := SendMessage(0xB0,0,0,lngui._edit.hwnd) & 0xFFFF ; stash caret pos
  set_lngui_input(res) ; set to the suggest word
  move_caret(currCaret,-1) ; highlight from what was originally entered to end
}


; ______________________________________________________________________________ utils  ___________


move_caret(s:=-1, e:=s) { ; move caret from start to end, -1 means end of input
        if s < 0 {
            s := StrLen(lngui._edit.value) + 1 - s
        }
        if e < 0 {
            e := StrLen(lngui._edit.value) + 1 - e
        }
        SendMessage(0xB1, s, e,, lngui._edit.Hwnd)
}




RegExReplaceInsensitive() {
; todo make a function for case insensitive regex relacement, but return the correct case
; this would be useful for allowing proper recall of case for query memory but be case-insensitive for matching
}

;replace_text_file(file, find, replace) {
;    text := FileRead(file)
;    text := StrReplace(text, find, replace)
;    FileDelete(file)
;    FileAppend(text, file)
;}


filter_lines(q, s, one:=False, insens:=False) {  ; used to filter lines from a string "s", each line starting with "q"
    if insens {
        q := StrLower(q)
        s := StrLower(s)
    }
    ; one returns a single match, insens does a case insensitive match
    if q == "" or InStr(q, "\") ; \ causes error with Regex, so skip
        return ""
     prepend := ""
     loop Parse q { ; iterate through characters
         s := RegExReplace(s, "m)^" prepend "[^" A_LoopField "].*\R", "") ; remove lines where character doesn't match
         prepend := prepend "." ; adjusts position for the next character
     }
     if s == ""
        return s
     if one
        s := StrSplit(s,["`r","`n"])[1]
     return s
}


Suspend 0 ; re-enable hot keys

