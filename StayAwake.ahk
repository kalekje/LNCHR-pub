#Requires Autohotkey v2.0+
#SingleInstance

TraySetIcon "W.ico"

Persistent()

SetTimer(MoveIt, 100000)

MoveIt(){
	MouseMove(1, 1, 1, "R")
	Sleep(400)
	MouseMove(-1, -1, 1, "R")
}

; https://www.autohotkey.com/boards/viewtopic.php?t=82697