

QuickTrayTip(msg:="", tit:="", t:=5) {
    TrayTip(msg, tit)
    SetTimer(() => TrayTip(), -t*1000)
}



QuickToolTip(msg:="", t:=2) {
    ToolTip(msg)
    SetTimer(() => ToolTip(), -t*1000)
}

