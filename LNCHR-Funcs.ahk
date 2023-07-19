#Requires AutoHotkey v2.0+
#Include QuickTips.ahk

; ______________________________________________________________________________ TryRun ___________


TryRun(s) {
    try {
            run s
            }
    catch {
        QuickTrayTip("failed to run:`n" s, tit:="LNCHR")
        }
}


UrlEncode(str, sExcepts := "-_.", enc := "UTF-8")
{
	hex := "00", func := "msvcrt\swprintf"
	buff := Buffer(StrPut(str, enc)), StrPut(str, buff, enc)   ;转码
	encoded := ""
	Loop {
		if (!b := NumGet(buff, A_Index - 1, "UChar"))
			break
		ch := Chr(b)
		; "is alnum" is not used because it is locale dependent.
		if (b >= 0x41 && b <= 0x5A ; A-Z
			|| b >= 0x61 && b <= 0x7A ; a-z
			|| b >= 0x30 && b <= 0x39 ; 0-9
			|| InStr(sExcepts, Chr(b), true))
			encoded .= Chr(b)
		else {
			DllCall(func, "Str", hex, "Str", "%%%02X", "UChar", b, "Cdecl")
			encoded .= hex
		}
	}
	return encoded
}


; Decode precent encoding
UrlDecode(Url, Enc := "UTF-8")
{
	Pos := 1
	Loop {
		Pos := RegExMatch(Url, "i)(?:%[\da-f]{2})+", &code, Pos++)
		If (Pos = 0)
			Break
		code := code[0]
		var := Buffer(StrLen(code) // 3, 0)
		code := SubStr(code, 2)
		loop Parse code, "`%"
			NumPut("UChar", Integer("0x" . A_LoopField), var, A_Index - 1)
		Url := StrReplace(Url, "`%" code, StrGet(var, Enc))
	}
	Return Url
}


run_ReplaceText(replacement, runString){
    if InStr(runString, "http")  ; if url, do a clean replacement
    {
        replacement := UrlEncode(replacement)
    }
    ; assume proper formatting for command line stuff
    runString := StrReplace(runstring, "REPLACEME", replacement)
    tryrun(runString)
}


make_run_ReplaceTexts_func(args*) { ; create a 1 arg function from a list of args given as templates, used to pass to run_Replace_Text
func(rep) {
   for index, arg in args
     run_ReplaceText(rep, arg)
   }
return func
}






; ______________________________________________________________________________ Outlook ___________

GetOutlookCom(){
try
    outlookApp := ComObjActive("Outlook.Application")
catch
    outlookApp := ComObject("Outlook.Application")
return outlookApp
}


OutlookSearch(searchstr)
{
    searchstr := StrReplace(searchstr, "!", " hasattachments:yes")
    olApp := GetOutlookCom()
    static olSearchScopeAllFolders := 2
    olApp.ActiveExplorer.Search(searchstr, olSearchScopeAllFolders) ; Activate the Outlook window
    WinActivate("ahk_class rctrl_renwnd32") ; Send Tab to hide the "suggested searches" drop down
    ControlSend "{Tab}", "RICHEDIT60W1", "ahk_class rctrl_renwnd32"
    return
}






; ______________________________________________________________________________ math JS "Calculate" ___________
#Include JS.ahk


JS := JsRT.Edge() ; instantiate JS obj
JS.Eval(FileRead("mathjs.js"))  ; add math js

JS.Eval("const parser = math.parser()") ; create a parser object in JS

Loop Read, 'LNCHR-CalcEqns.txt' { ; load equations
    JS.Eval("parser.evaluate('" A_LoopReadLine "')")
}


MakeMathExpr(expr) => "math.format(parser.evaluate('" expr "'), {precision: 5}).toString()"
TryEvalMathExpr(expr) => JS.Eval("try { " . MakeMathExpr(expr) . "; } catch(e) { 'undefined'; }" )


js_math_exp_helper(exp)
{
	exp := StrReplace(exp, "**", "^") ; python syntax, ** = ^2
	some_number := "(\d|\d\)[)]?)" ; regex to capture a number (followed by an optional ))
	exp := RegExReplace(exp, some_number . "j", "$1i") ; replace j with 1i, because I'm an EE (:
	exp := RegExReplace(exp, some_number . "sq", "$1^2") ; shortcut for number squard eg: 3sq or (1+2)sq
	exp := RegExReplace(exp, some_number . "cu", "$1^3") ; shortcut for number cubed
	exp := RegExReplace(exp, some_number . "roo", "$1^0.5") ; shortcut for square root (3+6)roo = 3
	return exp
}


run_calc_shortcut_then_return(s){
        tryrun(s)
        set_lngui_input()
        Sleep(200)
        WinActivate(lngui.Hwnd)
        return
}


lngui_calctext := Map() ; dummy declaration

Calculate(expr)
{
;
    exprOG := expr
    expr := js_math_exp_helper(expr)  ;

    if expr == '?' { ; load equations list
        run_calc_shortcut_then_return('LNCHR-CalcEqns.txt')
        return
   } else if expr == "mem" {
        run_calc_shortcut_then_return("LNCHR-CalcMemory.txt")
        return
    }


    result := TryEvalMathExpr(expr)

     if result != "undefined" {
          if InStr(expr, '=') {
            FileAppend expr "`n", "LNCHR-CalcEqns.txt" ; store equation in memory
          } else {
            A_Clipboard := result
            FileAppend exprOG "`n", "LNCHR-CalcMemory.txt" ; store expression in memory
          }
     } else {
        result := "..."
     }

    set_calc_text(result)

}




