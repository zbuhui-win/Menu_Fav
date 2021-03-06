# Menu_Fav.ahk

`Menu_Fav`意为`favorite menu`，即**常用菜单**。目前版本主要功能为：

## 功能介绍

1. 在`Menu_Fav.ini`文件中配置`project`文件夹，定义的名称（`key`）将显示在生成的菜单中，定义的内容（`value`）将为要显示的文件夹；

   ![project示例](https://raw.githubusercontent.com/536/Menu_Fav/master/images/project示例.gif)

2. `Menu_Fav.ini`中的第二项`menu`，与`project`不同的是，不会遍历目录生成子菜单，单击便访问配置的文件夹/文件（默认打开）；

   ![menu示例](https://raw.githubusercontent.com/536/Menu_Fav/master/images/menu示例.gif)

3. ~~`Menu_Fav.ini`中的第三项`shortcut`，此项配置用于快捷发送短语或句子等，无需按照`key=value`的格式配置，每行为一个菜单；~~（用得少，已去除）

   ![shortcut示例](https://raw.githubusercontent.com/536/Menu_Fav/master/images/shortcut示例.gif)

4. ~~`Menu_Fav.ini`中的第三项`icon`， 用于配置主菜单中每项的图标，`key`为菜单名称，`value`为配置的图标文件绝对路径；~~（用得少，已去除）

5. `Menu_Fav.ini`中的第三项`settings`：

   5.1 `hotkey`用于配置显示菜单的快捷键，可为`F1`、`^1`、`#z`等(参考[AutoHotkey][1]的[hotkey][2]语法)；

   ~~5.2 `showMenuerror`用于配置是否忽略菜单中出现的错误，默认不显示即可；~~（用得少，已去除）

   5.3 `Activatewindows`作为显示当前活动窗口列表的白名单，以逗号分隔每一项，将在菜单的最下面显示。

## 使用方法

+ （一般方法）可以在`Menu_Fav.ini`-`settings`-`hotkey`中配置快捷键；
+ （不建议）可以通过重载脚本生成新菜单；
+ （**建议**）通过运行目录下的`Menu_Call_Menu.ahk`和`Menu_Call_Win.ahk`两个脚本发送`WM`消息给`Menu_Fav.ahk`，来显示对应的菜单；

> 可以通过鼠标手势软件（GIF中为WGestures）的特定手势调用`Menu_Call_Menu.ahk`或`Menu_Call_Win.ahk`，或者直接给这两个脚本定义`热键`，分别显示**主菜单**和单独显示**窗口列表菜单**）

+ 按住`ctrl`或者`shift`再点击菜单项有部分额外的功能（打开所在路径、编辑），直接点击`Menu_Fav`菜单下的`Menu_Fav.ahk`可以重载脚本。

## 注意事项

+ 配置项中的`key`不要重复，否则会出现菜单的合并缺失（相当于对同一菜单进行了重新定义）；
+ 任何问题欢迎提[ISSUES][3]

## TODO

1. [Project]中生成的目录，如果存在子文件夹或文件，无法通过点击打开。目前可通过按住ctrl加左键点击文件来打开所在文件夹。
2. 生成菜单的函数执行慢，考虑优化的可能。
3. 优化代码结构。

[1]: https://www.autohotkey.com/ "AutoHotkey"
[2]:https://autohotkey.com/docs/Hotkeys.htm#Symbols "Hotkey Symbols"
[3]: https://github.com/536/Menu_Fav/issues/new "new issues"
