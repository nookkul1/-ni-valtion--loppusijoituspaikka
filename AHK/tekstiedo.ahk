#SingleInstance Force
FileEncoding, UTF-8

RegRead, selectedFile, HKCU, Software\tekstiedo, selectedFile

Dock := "fullscreen"
X := 0
Y := 0
W := A_ScreenWidth - X
H := 1080
W2 := W - 20
H2 := H - 100

Gui, +Resize
Gui, Add, Button, gopen, Open
Gui, Add, Button, y6 greload, Reload
Gui, Font, s24 cC6B652
Gui, Color, 676866, 697068
FileRead, FileContents, %selectedFile%
Gui, Add, Edit, x10 w%W2% h%H2% vMyEdit, %FileContents%
Gui, Show, x%X% y%Y% w%W% h%H%, tekstiedo - %selectedFile%
if (Dock = "fullscreen")
    Send, #{up}
return

open:
FileSelectFile, selectedFile
RegWrite, REG_SZ, HKCU, Software\tekstiedo, selectedFile, %selectedFile%
Gui, Destroy
reload

reload:
reload

#IfWinActive tekstiedo

^s::
Gui, Submit, NoHide
FileDelete, %selectedFile%
FileAppend,  %MyEdit%, %selectedFile%
;msgbox, Deleted %selectedFile% and replaced it with `n`n%MyEdit%
return

^Backspace::
Send, ^+{Left}{backspace}
return

GuiClose:
exitapp