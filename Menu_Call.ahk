/*
 * @Author  : Jiang Hui (jianghui@zigui.me)
 * @Link    :
 * @Version : 2019-01-19 17:25:51
 */

#NoEnv
#SingleInstance, force
#NoTrayIcon
SetWorkingDir, %A_ScriptDir%

SetTitleMatchMode 2
DetectHiddenWindows On
if WinExist("Menu_Fav.ahk ahk_class AutoHotkey")
{
    PostMessage, 0x5555, 11, 22
}
Else
    Run % "Menu_Fav.ahk"
Return
