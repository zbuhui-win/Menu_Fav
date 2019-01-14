/*
 * @Author  : Jiang Hui (jianghui@zigui.me)
 * @Link    :
 * @Version : 2019-01-13 10:25:04
 */

#NoEnv
#SingleInstance, force
#NoTrayIcon
Process, Priority, , High
SetBatchLines, -1
SetWorkingDir, % A_ScriptDir

SplitPath, A_ScriptFullPath, , OutDir, , OutNameNoExt
ini          := % OutDir "\" OutNameNoExt ".ini"
MainmenuName := "Fav_Folders"
;---------------------------------------------------------------------------------------------------
/*
* Add Section [Project]
*/
IniRead, project, % ini, project
project_Lists := {}
If project
{
    Loop, Parse, % project, `n, `r
    {
        pos := InStr(A_LoopField, "=", , , 1)
        Menu_key   := SubStr(A_LoopField, 1, pos-1)
        Menu_value := SubStr(A_LoopField, pos+1)
        project_Lists[Menu_key] := Menu_value

        If FileExist(Menu_value)
        {
            Folder2Menu(Menu_value,MainmenuName,Menu_key)
            SetIcon(MainmenuName,Menu_key,Menu_value)
        }
    }
    Menu, % MainmenuName, Add
}
;---------------------------------------------------------------------------------------------------
/*
* Add Section [menu]
*/
IniRead, Menu_Items, % ini, Menu_Items
Menu_Lists := {}
If Menu_Items
{
    Loop, parse, % Menu_Items, `n, `r
    {
        pos := InStr(A_LoopField, "=", , , 1)
        Menu_key   := SubStr(A_LoopField, 1, pos-1)
        Menu_value := SubStr(A_LoopField, pos+1)
        Menu_Lists[Menu_key] := Menu_value

        Menu, % MainmenuName, Add, % Menu_key, Menu_Fav
        If Not FileExist(Menu_value)
            Menu, % MainmenuName, Disable, % Menu_key
        Else
            SetIcon("Fav_Folders",Menu_key,Menu_value)
    }
    Menu, % MainmenuName, Add
}
; For key, value in Menu_Lists
;     MsgBox %key% = %value%
;---------------------------------------------------------------------------------------------------
/*
* Add Section [快捷短语]
*/
IniRead, 快捷短语   , % ini, 快捷短语
If 快捷短语
{
    Loop, parse, % 快捷短语, `n, `r
    {
        Menu, 快捷短语, Add, % A_LoopField, Menu_Fav
    }
    Menu, % MainmenuName, Add, 快捷短语, :快捷短语
}
Menu, % MainmenuName, Add
;---------------------------------------------------------------------------------------------------
/*
* Add Section [Settings]
*/
IniRead, EditIcon  , % ini, Settings, EditIcon
IniRead, ConfigIcon, % ini, Settings, ConfigIcon
If Not A_IsCompiled
{
    Menu, % MainmenuName, Add, &Edit, Menu_Fav
    Menu, % MainmenuName, Icon, &Edit, % FileExist(EditIcon)?EditIcon:"", , 16
}
Menu, % MainmenuName, Add, &Config, Menu_Fav
Menu, % MainmenuName, Icon, &Config, % FileExist(ConfigIcon)?ConfigIcon:"", , 16

Menu, % MainmenuName, Show
Return


Menu_Fav:
    If FileExist(Menu_Lists[A_ThisMenuItem])
    {
        If WinActive("ahk_class CabinetWClass")
        {
            WinActivate, ahk_class CabinetWClass
            ControlFocus, ToolbarWindow323
            Sleep, 300
            ControlSetText, Edit1, % Menu_Lists[A_ThisMenuItem]
            Sleep, 300
            ControlSend, Edit1, {Enter}
        }
        Else
            Run % Menu_Lists[A_ThisMenuItem]
    }
    If (A_ThisMenuItem = "&Config")
    {
        If GetKeyState("Ctrl")
            Run % OutDir
        Else
            Run % ini
    }
    If (A_ThisMenuItem = "&Edit")
    {
        If GetKeyState("Ctrl")
            Run % OutDir
        Else
            Run % "Edit " A_ScriptFullPath
    }
    If (A_ThisMenu = "快捷短语") || (A_ThisMenu = "emoji")
    {
        Send % "{Bind}{Text}" A_ThisMenuItem
    }
    Return
;---------------------------------------------------------------------------------------------------
/*
*
*/
Folder2Menu(path,MainmenuName,MainMenuItem:="") {
    global project_Lists
    for i, obj in GetDir(path)
    {
        menuItemPath     := obj.arr_path
        menuName         := obj.arr_menu
        submenuName      := obj.arr_item
        Label_or_Submenu := "Menuhandler"
        Menu % menuName, Add, % submenuName, % Label_or_Submenu
        ; Msgbox % "1Menu " menuName ", Add, " submenuName ", " Label_or_Submenu

        project_Lists[menuName] := path
        ; msgbox % "1project_Lists[" submenuName "]:=" path
        SetIcon(menuName,submenuName,menuItemPath)

        If InStr(obj.arr_menu, "\")
        {
            If (DllCall("GetMenuItemCount", "ptr", MenuGetHandle(obj.arr_menu)) = 1)
            {
                menuItemPath     := Path_FolderName(obj.arr_path)
                menuName         := SubStr(obj.arr_menu,1,InStr(obj.arr_menu, "\",,-1)-1)
                submenuName      := Substr(obj.arr_menu,Instr(obj.arr_menu,"\",,-1)+1)
                Label_or_Submenu := ":" obj.arr_menu
                Menu, % menuName, Add, % submenuName, % Label_or_Submenu
                ; Msgbox % "2Menu, " menuName ", Add, " submenuName ", " Label_or_Submenu

                project_Lists[menuName] := path
                ; msgbox % "2project_Lists[" submenuName "]:=" path
                SetIcon(menuName,submenuName,menuItemPath)
            }
        }
    }

    If Not MainMenuItem
        MainMenuItem := Path_FileName(path)
    Menu, % MainmenuName, Add, % MainMenuItem, % ":" Path_FileName(path)

    ; Menu, % Path_FileName(path), Show,0 ,0
    Return

    Menuhandler:
        path := Path_FolderName(project_Lists[A_ThisMenu]) "\" A_ThisMenu "\" A_ThisMenuItem
        If GetKeyState("Ctrl")
            Run % Path_FolderName(path)
        Else
        {
            ; MsgBox % "project_Lists[A_ThisMenuItem]:" project_Lists[A_ThisMenuItem] "`nA_ThisMenu: " A_ThisMenu "`nA_ThisMenuItem:" A_ThisMenuItem "`n`npath:" path
            Run % path
        }
        Return
}
;---------------------------------------------------------------------------------------------------
Path_FileName(path) {
    Return Trim(SubStr(path, InStr(path, "\", , -1)),"\")  ;文件名称
}
Path_FolderName(path) {
    Return Trim(SubStr(path, 1, InStr(path, "\", , -1)),"\") ;文件路径
}
Getfilename(path) {
    SplitPath, path, , , , OutNameNoExt
    Return OutNameNoExt
}
GetDir(path) {
    arr:=[]
    Loop, Files, %path%\*, RDF
    {
        If A_LoopFileAttrib contains H,R,S ;忽略隐藏、只读、系统属性的文件
            Continue
        If (A_LoopFileFullPath ~= ".*\.git\\*")
            Continue
        arr.push({  arr_index:A_Index
                    ,arr_path:A_LoopFileFullPath
                    ,arr_menu:Path_FolderName(StrReplace(A_LoopFileFullPath, Path_FolderName(path)))
                    ,arr_item:Path_FileName(A_LoopFileFullPath)})
    }
    Return arr
}
;---------------------------------------------------------------------------------------------------
SetIcon(menuName,submenuName,menuItemPath) {
    VarSetCapacity(fileinfo, fisize := A_PtrSize + 688)
    if DllCall("shell32\SHGetFileInfoW", "Wstr", menuItemPath, "UInt", 0, "Ptr", &fileinfo, "UInt", fisize, "UInt", 0x100)
    {
        hicon := NumGet(fileinfo, 0, "Ptr")
        Menu, %menuName%, Icon, %submenuName%, HICON:%hicon%
    }
}
;---------------------------------------------------------------------------------------------------
; StrIsFolderOrFile(path) {
;     If FileExist(path)
;     {
;         If RegExMatch(path, "\\\\$")
;             Return "folder"
;         Else If FileExist(path . "\")
;             Return "folder"
;         Else
;             Return "file"
;     }
; }
;---------------------------------------------------------------------------------------------------
