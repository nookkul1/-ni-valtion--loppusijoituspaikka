#SingleInstance Force
#Persistent
#NoEnv
FileEncoding, UTF-8



openedOpenOpen := 0

VarsToSave := []
CmdHis := []
installedArray := []

ScriptName := SubStr(A_ScriptName, 1, -4)
iniFilePath := A_ScriptDir "\" ScriptName ".ini"


if (!FileExist(iniFilePath))
{
    FileAppend, [Settings]`nSaveCmdSetVars=1`nSaveVars=1`n[Vars]`nKeepOnOpen=0`nDrop1_1=Right`nDrop1_2=Left`nDrop1_3=Fullscreen`nDrop1_4=None`nDrop1_5=Top right`nDrop1_6=Top left`nDrop1_7=Bottom right`nDrop1_8=Bottom left, %iniFilePath%
    MsgBox, ERROR: ini file not found, settings and whatnot lost.
}


LoadFromIni:
RegRead, LoadFromIni, HKCU, Software\amonjus, LoadFromIni
if (LoadFromIni = 0)
    Goto, NoLoadFromIni
else if (LoadFromIni = 1)
{
    FileRead, FileContents, %iniFilePath%
    Loop, Parse, FileContents, `n, `r ; Reads settings and other variables
    {
        if (InStr(A_LoopField, "["))
            continue
        Temp3 := InStr(A_LoopField, "=")
        Temp1 := SubStr(A_LoopField, 1, Temp3 - 1)
        Temp2 := A_LoopField
        if (Temp1 = "")
            continue
        %Temp1% := SubStr(Temp2, Temp3 + 1)
    }
}
else
{
    RegWrite, REG_BINARY, HKCU, Software\amonjus, LoadFromIni, 1
    MsgBox, Register LoadFromIni created and set to 1
    Goto, LoadFromIni
}
NoLoadFromIni:


Gui, +Resize
Gui, Font, s24 cC6B652
Gui, Color, 697068
Gui, Add, Text, vText1, Main menu
Gui, Add, Button, gopenOpen, Open
Gui, Add, Button, gopenSettings, Settings
Gui, Add, Button, x800 y30 greload, Reload
Gui, Show, , amonjus
Switch Drop1_1 ; Where to dock on startup
{
Case "Right":
    Send, #{Right}{Esc}
Case "Left":
    Send, #{Left}{Esc}
Case "Fullscreen":
    Send, #{Up}
Case "None":
Case "Top right":
    Send, {LWin Down}{Right}{Up}{Esc}{LWin Up}
Case "Top left":
    Send, {LWin Down}{Left}{Up}{Esc}{LWin Up}
Case "Bottom right":
    Send, {LWin Down}{Right}{Down}{Esc}{LWin Up}
Case "Bottom left":
    Send, {LWin Down}{Left}{Down}{Esc}{LWin Up}
}
return ; End of auto execute section



openOpen:
SoundPlay, C:\Windows\Media\Windows Navigation Start.wav

if (openedOpenOpen = 0)
{
    openedOpenOpen := 1

    Gui, Open:New, +ToolWindow +AlwaysOnTop, Open
    Gui, Open:Font, s12 cC6B652
    Gui, Open:Color, 697068

    regInstalls("ar")
    for index, Temp1 in installedArray
    {
        Temp2 := StrReplace(Temp1, ".", "ᾦ")
        Temp2 := StrReplace(Temp2, A_Space, "ᾢ")
        Gui, Open:Add, Button, ginstalledButton v%Temp2%, %Temp1%
    }
    Gui, Open:Add, Button, y9 gopenFile, Open file
}

WinGetPos, X, Y, W, H, amonjus
X := X + 100
Y := Y + 120
Gui, Open:Show, x%X% y%Y%, Open
return


OpenGuiClose:
Gui, Open:Hide
return


installedButton:
GuiControlGet, Temp1, FocusV
Temp1 := StrReplace(Temp1, "ᾦ", ".")
Temp1 := StrReplace(Temp1, "ᾢ", A_Space)
run(Temp1)
return


openFile:
FileSelectFile, openedFile
run(openedFile)
return



openSettings:
SoundPlay, C:\Windows\Media\Windows Navigation Start.wav
Gui, Settings:New, +ToolWindow +AlwaysOnTop, Settings
Gui, Settings:Font, s16 cC6B652
Gui, Settings:Color, 697068

WinGetPos, X, Y, W, H
Gui, Settings:Add, Tab3, , Startup|Open
Gui, Font, s12
Gui, Add, DropDownList, x30 y60 AltSubmit vDrop1, %Drop1_1%||%Drop1_2%|%Drop1_3%|%Drop1_4%|%Drop1_5%|%Drop1_6%|%Drop1_7%|%Drop1_8%
Gui, Add, Text, x220 y60 vSettText2, Window docking on startup

Gui, Tab, 2
Gui, Add, CheckBox, Checked%KeepOnOpen% vKeepOnOpen, Keep this app open when opening another in the 'Open' menu?

Gui, Tab
Gui, Settings:Add, Button, gSettSubmit, Apply
GuiControlGet, Apply, Pos,
CancelX := ApplyX + 80
Gui, Settings:Add, Button, x%CancelX% y%ApplyY% gCancel, Cancel
X := X + 100
Y := Y + 200
Gui, Show, x%X% y%Y%, Settings
return


SettSubmit:
SoundPlay, C:\Windows\Media\Windows Navigation Start.wav
Gui, Submit, NoHide
if (Drop1 > 1)
{
    Swap(Drop1_1, Drop1_%Drop1%)
    PushIfNotIn("VarsToSave", "Drop1_1")
    PushIfNotIn("VarsToSave", "Drop1_"Drop1)
}
PushIfNotIn("VarsToSave", "KeepOnOpen")
return


Cancel:
Gui, Destroy
return



#IfWinActive amonjus
§::
Gui, CmdLine:New, +ToolWindow +AlwaysOnTop
WinGetPos, X, Y, W, H, amonjus
W := W -220
Gui, CmdLine:Add, Edit, w%W% vCmdLineCont
;Gui, CmdLine:Add, Text, w%W% h1 vCmdHisText
X := X + 100
Y := Y + H - 380
W := W + 20
Gui, CmdLine:Show, x%X% y%Y% w%W%, Command line
;WinGetPos, X, Y, W, H, Command line
return


#IfWinActive Command line
Enter::
;for index, Temp1 in CmdHis
;    Temp2 .= "`n" Temp1
;GuiControl, CmdLine:Text, CmdHisText, %Temp2%
;WinGetPos, X, Y, W, H
;W := W - 6
;if (H > 280)
;    Gui, CmdLine:Show, x%X% y%Y% w%W% h280, Command line
;else
;    Gui, CmdLine:Show, x%X% y%Y% w%W% h%H%, Command line
Temp1 := ""
Temp2 := ""
Temp3 := ""
Temp4 := ""
Temp5 := ""
Gui, CmdLine:Submit, NoHide
CmdHis.push("> " CmdLineCont)
CmdHisPos := "0"
Goto, CmdLineExe
return
Esc::Gui, CmdLine:Destroy
Up::
CmdHisPos := CmdHis.MaxIndex()
return
#IfWinActive


CmdLineExe:
Loop, Parse, CmdLineCont, `,, %A_Space%
        Temp%A_Index% := A_LoopField
;Msgbox, % "Tampuriinit`n" Temp1 "`n" Temp2 "`n" Temp3 "`n" Temp4 "`n" Temp5
if (InStr(SubStr(CmdLineCont, 1, 3), "set"))
    Set(Temp2, Temp3) ; Set, Variable, Value    Sets Variable to Value
else if (InStr(SubStr(CmdLineCont, 1, 4), "swap"))
    SwapCmd(Temp2, Temp3) ; Swap, Variable, Variable    Swaps the contents of Variable and Variable
else if (InStr(SubStr(CmdLineCont, 1, 4), "push"))
    Push(Temp2, Temp3) ; Push, Array, Value    Pushes Value to Array
else if (InStr(SubStr(CmdLineCont, 1, 10), "removeitem"))
    RemoveItem(Temp2, Temp3, Temp4) ; RemoveItem, Array, Value, Number    Removes the nth item that matches Value in Array. If omitted Number defaults to 1
else if (InStr(SubStr(CmdLineCont, 1, 4), "peek"))
    Peek(Temp2) ; Peek, Array/Variable    Creates a window with the contents of Array/Variable
else if (InStr(SubStr(CmdLineCont, 1, 4), "pushifnotin"))
    PushIfNotIn(Temp2, Temp3) ; PushIfNotIn, Array, Value    Pushes Value to Array if Value is not already in Array
else if (InStr(SubStr(CmdLineCont, 1, 5), "clear"))
    clear(Temp2) ; Clear, Array    Removes all items from Array
else if (InStr(SubStr(CmdLineCont, 1, 4), "quit"))
    Quit(Temp2) ; Quit, Options    Closes the program
else
{
    %Temp1%(Temp2)
}
return



; Command functions


Set(VarA, VarB)
{
    Global
    %VarA% := VarB
    if (SaveCmdSetVars = 1)
        PushIfNotIn("VarsToSave", VarA)
    MsgBox, Set var %VarA% to %VarB%.
    return
}


SwapCmd(VarA, VarB)
{
    Global
    Temp1 := %VarA%
    %VarA% := %VarB%
    %VarB% := Temp1
    MsgBox, % "Swapped the values of " VarA " and " VarB ".`n(" VarA ": " %VarB% ", " VarB ": " %VarA% " > " VarA ": " %VarA% ", " VarB ": " %VarB% "."
    return
}


Push(VarA, VarB)
{
    Global
    %VarA%.Push(VarB)
    MsgBox, Pushed %VarB% to array %VarA%
    return
}


RemoveItem(VarA, VarB, VarC:=1)
{
    Global
    Temp4 := VarC
    if (Temp4 = "")
        Temp4 := 1
    For index, Temp1 in %VarA%
    {
        if (Temp1 = VarB)
        {
            if (Temp4 = 1)
            {
                %VarA%.RemoveAt(index)
                msgbox, Removed item %VarB% from array %VarA% at position %index%.
                return
            }
            else
            {
                Temp4--
                continue
            }
        }
    }
    MsgBox, Item %VarB% not found in %VarA%.
    return
}


Peek(VarA)
{
    Global
    Temp2 := VarA ":`n"
    Temp2 .= %VarA%
    For index, Temp1 in %VarA%
        Temp2 .= index ": " Temp1 "`n"
    Random, Rand
    Gui, Peek%Rand%:New, +ToolWindow +AlwaysOnTop
    Gui, Peek%Rand%:Add, Text, , %Temp2%
    GUi, Peek%Rand%:Show, NoActivate, Peek
    return
}



; End of command functions



Swap(ByRef VarA, ByRef VarB)
{
    Temp1 := VarA
    VarA := VarB
    VarB := Temp1
    return
}


PushIfNotIn(VarA, VarB)
{
    Global
    For index, Temp1 in %VarA%
    {
        if (Temp1 = VarB)
        {
;            MsgBox, % VarB " already in " VarA " at position " index
            return
        }
    }
    %VarA%.Push(VarB)
    return
}


Clear(VarA)
{
    if (IsObject(%VarA%))
        %VarA% := []
    else
        %VarA% := ""
    MsgBox, %VarA% cleared
    return
}


Quit(VarA:="")
{
    Global
    if (VarA = "")
        exitapp
    if (InStr(VarA, "smoking"))
        msgbox, hehehehaaa
    exitapp
}


SaveVars()
{
    Global
    if (SaveVars = 1)
    {
        For index, Temp1 in VarsToSave
        {
            Temp2 := %Temp1%
            iniWrite, %Temp2%, %iniFilePath%, Vars, %Temp1%
        }
        VarsToSave := []
    }
    return
}


getPath(VarA)
{
    Global
    if FileExist(A_WorkingDir "\" VarA)
        gotPath := A_WorkingDir "\" VarA
    else if FileExist(A_Desktop "\" VarA)
        gotPath := A_Desktop "\" VarA
    else if FileExist("C:\Users\" A_UserName "\Downloads\" VarA)
        gotPath := "C:\Users\" A_UserName "\Downloads\" VarA
     else if FileExist("C:\Users\" A_UserName "\Music\" VarA)
        gotPath := "C:\Users\" A_UserName "\Music\" VarA
    else if FileExist("C:\Users\" A_UserName "\Documents\" VarA)
        gotPath := "C:\Users\" A_UserName "\Documents\" VarA
    else
    {
        gotPath := "ERROR"
        MsgBox, ERROR: fwile not found.
    }
    return
}


regInstalls(VarA:="")
{
    Global
    Temp1 := SubStr(VarA, 1 ,2)
    Temp2 := SubStr(VarA, 3) . ","
    RegRead, installedScripts, HKCU, Software\amonjus, installedScripts

    if (VarA = "")
        return
    else if (Temp1 = "un")
        installedScripts := StrReplace(installedScripts, Temp2)
    else if (Temp1 = "in")
        installedScripts .= Temp2
    else if (Temp1 = "ar")
    {
        Loop, Parse, installedScripts, `,
        {
            if (A_LoopField = "")
                continue
            installedArray.Push(A_LoopField)
        }
    return
    }
    RegWrite, REG_SZ, HKCU, Software\amonjus, installedScripts, %installedScripts%
}


run(VarA)
{
    Global
    run, %VarA%, , UseErrorLevel
    if ErrorLevel
        getPath(VarA)
    else if (KeepOnOpen = 0)
        exitapp
    run, %gotPath%, , UseErrorLevel
    if ErrorLevel
        if FileExist(gotPath)
            MsgBox, ERROR: unable to open file. %ErrorLevel%
        else
            MsgBox, ERROR: file not found.
    else if (KeepOnOpen = 0)
        exitapp
}


;ö::
msgbox, megis bokus
return

å::
;MsgBox, iniFilePath: %iniFilePath%`n`n`nText1: %Text1%`nText2: %Text2%`nDrop1: %Drop1%`n`n`nDrop1_1: %Drop1_1%`nDrop1_2: %Drop1_2%`nDrop1_3: %Drop1_3%`nDrop1_4: %Drop1_4%`nDrop1_5: %Drop1_5%`nDrop1_6: %Drop1_6%`nDrop1_7: %Drop1_7%`nDrop1_8: %Drop1_8%
;MsgBox, Text2: %Text2%`nDrop1: %Drop1%`n`n`nDrop1_1: %Drop1_1%`nDrop1_2: %Drop1_2%`nDrop1_3: %Drop1_3%`nDrop1_4: %Drop1_4%`nDrop1_5: %Drop1_5%`nDrop1_6: %Drop1_6%`nDrop1_7: %Drop1_7%`nDrop1_8: %Drop1_8%
MsgBox, CmdHisText: %CmdHisText%`nCmdLineCont: %CmdLineCont%`nSaveCmdSetVars: %SaveCmdSetVars%`nSaveVars: %SaveVars%`n
;MsgBox, Temp1: %Temp1%`nTemp2: %Temp2%`nTemp3: %Temp3%`nTemp4: %Temp4%`nTemp5: %Temp5%
;for index, value in VarsToSave
;    MsgBox, % "Index: " index " - Value: " value
return

~^s::
SaveVars()
reload
return
reload:
SaveVars()
reload



GuiClose:
SaveVars()
exitapp