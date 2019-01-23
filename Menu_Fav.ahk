/**
 * @Author  : Jiang Hui (jianghui@zigui.me)
 * @Link    :
 * @Version : 2019-01-13 10:25:04
 */

/**
 * warning!
 * The names of menus and menu items can be up to 260 characters long.
 * This Script didn't consider about it so far.
 * may fix it by using menu id and store the path in global array/list.
*/
#NoEnv
#NoTrayIcon
#SingleInstance, force
Process, Priority, , High
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir
Menu, Tray, NoStandard
Menu, Tray, Tip, Have Fun!

SplitPath, A_ScriptFullPath, , OutDir, , OutNameNoExt
ini := % OutDir "\" OutNameNoExt ".ini"
FileInstall, Menu_Fav.ini, Menu_Fav.ini
;---------------------------------------------------------------------------------------------------
Global list_setting     := {}
Global list_icon        := {}
Global list_menu        := {}
Global list_project     := {}
Global arr_shortcut     := []
Global Activatewindows
Activatewindows=C:\Windows\explorer.exe
,C:\Windows\SysWOW64\hh.exe
,C:\Program Files\Typora\Typora.exe
,C:\Program Files\Microsoft VS Code\Code.exe
,C:\Program Files\Mozilla Firefox\firefox.exe
,C:\Program Files (x86)\Tencent\TIM\Bin\TIM.exe
,C:\Program Files (x86)\Google\Chrome\Application\chrome.exe
,C:\Windows\System32\notepad.exe

for index, section in ini(ini)
{
    If (section = "setting")
        for key, value in ini_section(ini,section)
            list_setting[key] := value
    If (section = "icon"   )
        for key, value in ini_section(ini,section)
            list_icon[key]    := value
    If (section = "menu"   )
        for key, value in ini_section(ini,section)
            list_menu[key]    := value
    If (section = "project")
        for key, value in ini_section(ini,section)
            list_project[key] := value
    If (section = "shortcut")
    {
        IniRead, shortcut, % ini, % section
        Loop, Parse, % shortcut, `n, `t
            arr_shortcut.push(A_LoopField)
        }
}
;---------------------------------------------------------------------------------------------------
If list_setting.Activatewindows
    Activatewindows := list_setting.Activatewindows
;---------------------------------------------------------------------------------------------------
Global mainmenu_main := A_Now
Menu, Tray, UseErrorLevel
If !list_setting.showMenuerror
    Menu, % mainmenu_main, UseErrorLevel
;---------------------------------------------------------------------------------------------------
/**
 * Add Section [Project]
 */
If list_project
{
    for key, value in list_project
    {
        If FileExist(value) && (key != OutNameNoExt)
        {
            Folder2Menu(value,mainmenu_main,key)
            If FileExist(list_icon[key])
                Menu, % mainmenu_main, Icon, % key, % list_icon[key]
            Else If FileExist(value . "\" . FileName(value) . ".ico")
                Menu, % mainmenu_main, Icon, % key, % value . "\" . FileName(value) . ".ico"
            Else
                Menu, % mainmenu_main, Icon, % key, imageres.dll,4
        }
    }
    Menu, % mainmenu_main, Add
}
;---------------------------------------------------------------------------------------------------
/**
 * Add Section [menu]
 */
If list_menu
{
    for key, value in list_menu
    {
        If FileExist(value) && (key != OutNameNoExt)
        {
            Menu, % mainmenu_main, Add, % key, Label_Menu_Fav

            SetIconItself(mainmenu_main,key,value)
            If FileExist(list_icon[key])
                Menu, % mainmenu_main, Icon, % key, % list_icon[key]
        }
    }
    Menu, % mainmenu_main, Add
}
;---------------------------------------------------------------------------------------------------
/**
 * Add Section [shortcut]
 */
If arr_shortcut.Length()
{
    for index, value in arr_shortcut
    {
        If (value != OutNameNoExt)
        {
            Menu, shortcut, Add, % value, Label_Menu_Fav
            ; SetIconRandom()
        }
    }
    Menu, % mainmenu_main, Add, Shortcut, :shortcut
    Menu, % mainmenu_main, Icon, Shortcut, % list_icon.shortcut
    Menu, % mainmenu_main, Add
}
;---------------------------------------------------------------------------------------------------
/**
 * Add Section [Setting]
 */
If Not A_IsCompiled
{
    Folder2Menu(A_ScriptDir,mainmenu_main,OutNameNoExt)

    Menu, % A_ScriptDir, Add
    Menu, % A_ScriptDir, Add, Exit
    Menu, % A_ScriptDir, Icon, Exit, % list_icon.exit
}
;---------------------------------------------------------------------------------------------------
/**
 * Set Script icon
 */
; If FileExist(list_icon[OutNameNoExt])
; {
;     Menu, % mainmenu_main, Icon, % OutNameNoExt, % list_icon[OutNameNoExt]
;     Menu, Tray, Icon, % list_icon[OutNameNoExt], , 1
; }
; Else If FileExist(A_ScriptDir . "\" . OutNameNoExt . ".ico")
; {
;     Menu, % mainmenu_main, Icon, % OutNameNoExt, % A_ScriptDir . "\" . OutNameNoExt . ".ico"
;     Menu, Tray, Icon, % A_ScriptDir . "\" . OutNameNoExt . ".ico", , 1
; }
SetIconItself(mainmenu_main,"Menu_Fav",A_ScriptDir)
Gosub, label_ShowMenu
;---------------------------------------------------------------------------------------------------
/**
 * Set Hotkey
 */
If list_setting.hotkey
{
    Hotkey, % list_setting.hotkey, label_ShowMenu
}
; Else
;     Hotkey, F1, label_ShowMenu
;---------------------------------------------------------------------------------------------------
OnMessage(0x5555, "MsgMonitor")
OnMessage(0x5556, "MsgMonitor")
Return

MsgMonitor(wParam, lParam, msg) {
    ; get message from Menu_Call_Menu.ahk
    If (msg = 0x5555 && wParam = 11 && lParam = 22)
        Gosub, label_ShowMenu
    ; get message from Menu_Call_Win.ahk
    Else If (msg = 0x5556 && wParam = 11 && lParam = 22)
    {
        Gosub, label_CreateMenu_Win
        Menu, Windows, Show
    }


}
;---------------------------------------------------------------------------------------------------
/**
 * Functions
 */
Folder2Menu(folder,mainmenu_main,mainmenu_sub) {
    If CheckPath(folder).length()
    {
        for index, obj in Array_Reverse(CheckPath(folder))
        {
            If (IsFolderOrFile(obj) = "file")
            {
                menu_main := Dir(obj)
                menu_sub  := FileName(obj)
                label     := "label_Folder2Menu"
                Menu, % menu_main, Add, % menu_sub, % label
                SetIconItself(menu_main,menu_sub,obj)
            }
            Else
            {
                menu_main := Dir(obj)
                menu_sub  := FileName(obj)
                label     := "label_Folder2Menu"
                If (DllCall("GetMenuItemCount", "ptr", MenuGetHandle(obj))>0)
                    label := ":" . obj
                Menu, % menu_main, Add, % menu_sub, % label
                SetIconItself(menu_main,menu_sub,obj)
            }
        }
        Menu, % mainmenu_main, Add, % mainmenu_sub, % ":" . folder
    }
}
;---------------------------------------------------------------------------------------------------
FileName(path) {
    If (IsFolderOrFile(path) = "drive")
        Return path
    SplitPath, path, OutFileName
    Return OutFileName
}
Dir(path) {
    If (IsFolderOrFile(path) = "drive")
        Return path
    SplitPath, path, , OutDir
    Return OutDir
}
;---------------------------------------------------------------------------------------------------
CheckPath(folder) {
    path := []
    Loop, Files, %folder%\*, RDF
    {
        ; Skip any file that is either H (Hidden), R (Read-only), or S (System).
        If A_LoopFileAttrib contains H,R,S
            Continue
        If (A_LoopFileFullPath ~= "\.git\\*")
            Continue
        If (A_LoopFileFullPath ~= "node_modules\\*")
            Continue
        path.push(A_LoopFileFullPath)
    }
    Return path
}
;---------------------------------------------------------------------------------------------------
SetIconItself(menuName,submenuName,menuItemPath) {
    If (menuItemPath = A_Desktop)
    {
        Menu, % menuName, Icon, % submenuName, imageres.dll,106
    }
    Else If (menuItemPath = "c:\")
        Menu, % menuName, Icon, % submenuName, imageres.dll,32
    Else If (menuItemPath ~= "i)\.ico$")
        Menu, % menuName, Icon, % submenuName, % menuItemPath
    Else If (menuItemPath ~= "i)\.png$")
        Menu, % menuName, Icon, % submenuName, % menuItemPath
    Else If (menuItemPath ~= "i)\.jpg$")
        Menu, % menuName, Icon, % submenuName, % menuItemPath
    Else If (IsFolderOrFile(menuItemPath) = "folder")
    {
        ico := menuItemPath "\" FileName(menuItemPath) ".ico"
        exe := menuItemPath "\" FileName(menuItemPath) ".exe"
        If FileExist(ico)
            Menu, % menuName, Icon, % submenuName, % ico
        Else If FileExist(exe)
            Menu, % menuName, Icon, % submenuName, % exe
        Else
            Menu, % menuName, Icon, % submenuName, imageres.dll,4
    }
    Else If (IsFolderOrFile(menuItemPath) = "drive")
    {
        Menu, % menuName, Icon, % submenuName, imageres.dll,31
    }
    Else
    {
        VarSetCapacity(fileinfo, fisize := A_PtrSize + 688)
        if DllCall("shell32\SHGetFileInfoW", "Wstr", menuItemPath, "UInt", 0, "Ptr", &fileinfo, "UInt", fisize, "UInt", 0x100)
        {
            hicon := NumGet(fileinfo, 0, "Ptr")
            Menu, % menuName, Icon, % submenuName, HICON:%hicon%
        }
    }
}
;---------------------------------------------------------------------------------------------------
IsFolderOrFile(path) {
    If FileExist(path)
    {
        If path ~= "i)^[a-z]:\\$"
            Return "drive"
        Else If RegExMatch(path, "\\$")
            Return "folder"
        Else If FileExist(path . "\")
            Return "folder"
        Else
            Return "file"
    }
}
;---------------------------------------------------------------------------------------------------
ini(ini) {
    IniRead, ini, % ini
    array := []
    Loop, Parse, % ini, `n, `r
    {
        array.Insert(A_LoopField)
    }
    Return array
}
ini_section(ini,section) {
    IniRead, section, % ini, % section
    list := {}
    If section
    {
        Loop, Parse, % section, `n, `r
        {
            pos := InStr(A_LoopField, "=")
            If pos
            {
                key       := SubStr(A_LoopField, 1, pos-1)
                value     := SubStr(A_LoopField, pos+1)
                list[key] := value
            }
        }
        Return list
    }
}
;---------------------------------------------------------------------------------------------------
Array_Reverse(arr) {
    Reverse := []
    Loop % len:=arr.maxindex()
    {
        Reverse[len-A_Index+1] := arr[A_Index]
    }
    Return Reverse
}
;---------------------------------------------------------------------------------------------------
label_ShowMenu:
    Gosub, label_CreateMenu_Win
    Menu, % mainmenu_main, Add, Windows, :Windows
    Menu, % mainmenu_main, Show
    Return
label_CreateMenu_Win:
    Menu, Windows, Add
    Menu, Windows, DeleteAll
    for key,value in getActivatedWindows()
    {
        if value in % Activatewindows
        {
            menu, Windows, Add, % key, Label_Activatewindows
            SetIconItself("Windows",key,value)
        }
    }
    Return
Label_Activatewindows:
    RegExMatch(A_ThisMenuItem, "0x[a-fA-F0-9]+", ahk_id)
    WinActivate, % "ahk_id " ahk_id
    Return
Exit:
    ExitApp
    Return
label_Folder2Menu:
    If GetKeyState("ctrl")
    {
        Run % A_ThisMenu
    }
    /**
    * #TODO#
    *
    */
    Else If GetKeyState("shift")
    {
        If A_ThisMenuItem ~= ".ahk"
            Run % "Edit " A_ThisMenu "\" A_ThisMenuItem
    }
    Else
        Run % A_ThisMenu "\" A_ThisMenuItem
    Return
Label_Menu_Fav:
    If GetKeyState("ctrl")
    {
        If (A_ThisMenu = mainmenu_main) && FileExist(list_menu[A_ThisMenuItem])
            Run % Dir(list_menu[A_ThisMenuItem])
        Else If (A_ThisMenu = "shortcut")
            Run % ini
    }
    /**
    * #TODO#
    *
    */
    Else If GetKeyState("shift")
    {
        If A_ThisMenuItem ~= ".ahk"
            Run % "Edit " A_ThisMenu "\" A_ThisMenuItem
    }
    Else
    {
        If (A_ThisMenu = mainmenu_main) && FileExist(list_menu[A_ThisMenuItem])
        {
            If list_menu[A_ThisMenuItem] ~= ".ahk"
                Run % list_menu[A_ThisMenuItem]
            Else
                Run % list_menu[A_ThisMenuItem]
        }
        Else If (A_ThisMenu = "shortcut")
            Send % "{Blind}{Text} " A_ThisMenuItem
    }
    Return
;---------------------------------------------------------------------------------------------------
getActivatedWindows() {
    list_ActivatedWindows:={}
    WinGet, id, List,,, Program Manager
    Loop % id
    {
        this_id := id%A_Index%
        WinGetTitle, this_title, % "ahk_id " this_id
        WinGet, ProcessPath, ProcessPath, % "ahk_id " this_id
        If this_title
            list_ActivatedWindows[Rpad(this_id,9) A_Tab this_title] := ProcessPath
    }
    Return list_ActivatedWindows
}
Rpad(str,num,span:=" ") {
    if (num > StrLen(str))
    {
        Loop, % num
            str := str . span
        return % SubStr(str, 1, num)
    }
}
Lpad(str,num,span:=" ") {
    if (num > StrLen(str))
    {
        Loop, % num-StrLen(str)
            str := span . str
        return % SubStr(str, 1-num)
    }
}
