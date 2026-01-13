#SingleInstance Force
#NoEnv
SetBatchLines -1

; Global Settings
Global SettingsFile := A_ScriptDir "\LauncherSettings.ini"
Global ShowLabels := true
Global ShowTitleBar := true
Global Apps := []
Global IconSize := 48
Global SlotSize := 80
Global Rows := 4
Global Cols := 4
Global TotalSlots := Rows * Cols

; Load Settings
LoadSettings()

; Hotkeys
F10::ShowLauncher()
!r::ShowSettings()

Return

LoadSettings() {
    Global
    IfExist, %SettingsFile%
    {
        IniRead, ShowLabels, %SettingsFile%, General, ShowLabels, 1
        IniRead, ShowTitleBar, %SettingsFile%, General, ShowTitleBar, 1
        
        Loop, %TotalSlots%
        {
            IniRead, path, %SettingsFile%, Apps, App%A_Index%, %A_Space%
            Apps.Push(path)
        }
    }
    Else
    {
        ; Initialize empty slots
        Loop, %TotalSlots%
            Apps.Push("")
    }
}

SaveSettings() {
    Global
    IniWrite, %ShowLabels%, %SettingsFile%, General, ShowLabels
    IniWrite, %ShowTitleBar%, %SettingsFile%, General, ShowTitleBar
    
    Loop, %TotalSlots%
    {
        path := Apps[A_Index]
        IniWrite, %path%, %SettingsFile%, Apps, App%A_Index%
    }
}

ShowLauncher() {
    Global
    
    If WinExist("AppLauncher")
    {
        Gui Launcher:Destroy
        Return
    }
    
    Gui Launcher:New, +AlwaysOnTop HwndLauncherHwnd, AppLauncher
    If (!ShowTitleBar)
        Gui Launcher:+ToolWindow -Caption
    
    Gui Launcher:Color, 1a1a1a
    Gui Launcher:Font, s9 cWhite, Segoe UI
    
    xPos := 10
    yPos := 10
    
    Loop, %Rows%
    {
        row := A_Index
        Loop, %Cols%
        {
            col := A_Index
            idx := (row - 1) * Cols + col
            
            xPos := 10 + (col - 1) * SlotSize
            yPos := 10 + (row - 1) * (ShowLabels ? SlotSize + 20 : SlotSize)
            
            appPath := Apps[idx]
            
            ; Create icon button with slot number in the label name
            If (appPath != "" && FileExist(appPath))
            {
                SplitPath, appPath, fileName
                ; Use a button label that includes the slot number
                Gui Launcher:Add, Picture, x%xPos% y%yPos% w%IconSize% h%IconSize% BackgroundTrans gSlot%idx% vIcon%idx%, %appPath%
                
                If (ShowLabels)
                {
                    labelY := yPos + IconSize + 2
                    StringLeft, shortName, fileName, 10
                    Gui Launcher:Add, Text, x%xPos% y%labelY% w%IconSize% cWhite Center BackgroundTrans, %shortName%
                }
            }
            Else
            {
                ; Empty slot
                Gui Launcher:Add, Text, x%xPos% y%yPos% w%IconSize% h%IconSize% BackgroundTrans Border gSlot%idx% vIcon%idx% Center 0x200, +
            }
        }
    }
    
    guiWidth := Cols * SlotSize + 2
    guiHeight := Rows * (ShowLabels ? SlotSize + 15 : SlotSize) + 10
    
    ; Adjust for title bar if shown
    If (ShowTitleBar)
        Gui Launcher:Show, w%guiWidth% h%guiHeight%
    Else
    {
        ; For borderless window, calculate exact client area needed
        clientWidth := Cols * SlotSize + 2
        clientHeight := Rows * (ShowLabels ? SlotSize + 15 : SlotSize) + 10
        Gui Launcher:Show, w%clientWidth% h%clientHeight%
    }
    Return
}

; Individual slot handlers - these will be called when each icon is clicked
Slot1:
Slot2:
Slot3:
Slot4:
Slot5:
Slot6:
Slot7:
Slot8:
Slot9:
Slot10:
Slot11:
Slot12:
Slot13:
Slot14:
Slot15:
Slot16:
    Global Apps
    
    ; Extract slot number from the label name
    RegExMatch(A_ThisLabel, "Slot(\d+)", match)
    slotNum := match1
    
    ; Get the app path for this slot
    appPath := Apps[slotNum]
    
    If (appPath = "" || !FileExist(appPath))
    {
        MsgBox, 48, Empty Slot, No application assigned to this slot.`n`nUse Settings (Alt+R) to assign apps.
        Return
    }
    
    ; Check modifiers
    If GetKeyState("LCtrl", "P")
    {
        ; Run as admin
        Run *RunAs "%appPath%"
        Gui Launcher:Destroy
    }
    Else If GetKeyState("RCtrl", "P")
    {
        ; Open file location
        SplitPath, appPath,, folder
        Run %folder%
        Gui Launcher:Destroy
    }
    Else
    {
        ; Normal launch
        Run "%appPath%"
        Gui Launcher:Destroy
    }
Return

ShowSettings() {
    Global
    
    If WinExist("LauncherSettings")
    {
        Gui Settings:Destroy
        Return
    }
    
    Gui Settings:New, +AlwaysOnTop HwndSettingsHwnd, LauncherSettings
    Gui Settings:Color, 1a1a1a
    Gui Settings:Font, s10 cWhite, Segoe UI
    
    ; Register custom message handler for edit control colors
    OnMessage(0x0133, "WM_CTLCOLOREDIT")
    
    Gui Settings:Add, Text, x20 y20 cWhite, Application Paths (Top-Left to Bottom-Right):
    
    yPos := 50
    Loop, %TotalSlots%
    {
        slotNum := A_Index
        currentPath := Apps[slotNum]
        
        Gui Settings:Add, Text, x20 y%yPos% w60 cWhite, Slot %slotNum%:
        Gui Settings:Add, Edit, x90 y%yPos% w450 h25 vAppPath%slotNum% Background2d2d2d cWhite HwndHEdit%slotNum%, %currentPath%
		
		; Apply dark theme
		hEdit := HEdit%slotNum%
		DllCall("UxTheme\SetWindowTheme", "Ptr", hEdit, "Str", "DarkMode_Explorer", "Ptr", 0)
		
        Gui Settings:Add, Button, x550 y%yPos% w80 h25 vBrowse%slotNum% gBrowseFile HwndHBtn%slotNum%, Browse
		
		hBtn := HBtn%slotNum%
		DllCall("UxTheme\SetWindowTheme", "Ptr", hBtn, "Str", "DarkMode_Explorer", "Ptr", 0)
        
        yPos += 35
    }
    
    yPos += 10
    Gui Settings:Add, Checkbox, x20 y%yPos% vShowLabelsCheck cWhite, Show Labels Under Icons
    If (ShowLabels)
        GuiControl Settings:, ShowLabelsCheck, 1
    
    yPos += 30
    Gui Settings:Add, Checkbox, x20 y%yPos% vShowTitleBarCheck cWhite, Show Title Bar
    If (ShowTitleBar)
        GuiControl Settings:, ShowTitleBarCheck, 1
    
    yPos += 40
    Gui Settings:Add, Button, x20 y%yPos% w100 gSaveSettingsBtn HwndHBtnSave, Save
    Gui Settings:Add, Button, x130 y%yPos% w100 gCancelSettings HwndHBtnCancel, Cancel
	
	DllCall("UxTheme\SetWindowTheme", "Ptr", hBtnSave, "Str", "DarkMode_Explorer", "Ptr", 0)
    DllCall("UxTheme\SetWindowTheme", "Ptr", hBtnCancel, "Str", "DarkMode_Explorer", "Ptr", 0)
    
    guiHeight := yPos + 40
    Gui Settings:Show, w650 h%guiHeight% Center
}

BrowseFile:
    Global TotalSlots
    
    ; Get the focused control name
    GuiControlGet, ctrl, Settings:FocusV
    
    ; Extract slot number from button name
    slotNum := 0
    Loop, %TotalSlots%
    {
        If (ctrl = "Browse" . A_Index)
        {
            slotNum := A_Index
            Break
        }
    }
    
    If (slotNum = 0)
        Return
    
    FileSelectFile, selected, 3,, Select Application, Programs (*.exe)
    If (selected != "")
        GuiControl Settings:, AppPath%slotNum%, %selected%
Return

SaveSettingsBtn:
    Global Apps, ShowLabels, ShowTitleBar, TotalSlots
    
    Gui Settings:Submit, NoHide
    
    Loop, %TotalSlots%
    {
        GuiControlGet, path, Settings:, AppPath%A_Index%
        Apps[A_Index] := path
    }
    
    GuiControlGet, ShowLabels, Settings:, ShowLabelsCheck
    GuiControlGet, ShowTitleBar, Settings:, ShowTitleBarCheck
    
    SaveSettings()
    Gui Settings:Destroy
    
    If WinExist("AppLauncher")
        Gui Launcher:Destroy
    
    MsgBox, 64, Success, Settings saved! Press F10 to see changes.
Return

CancelSettings:
    OnMessage(0x0133, "")  ; Unregister message handler
    Gui Settings:Destroy
Return

SettingsGuiClose:
    OnMessage(0x0133, "")  ; Unregister message handler
    Gui Settings:Destroy
Return

WM_CTLCOLOREDIT(wParam, lParam) {
    ; Set text color to white
    DllCall("SetTextColor", "Ptr", wParam, "UInt", 0xFFFFFF)
    ; Set background color to dark gray (2d2d2d)
    DllCall("SetBkColor", "Ptr", wParam, "UInt", 0x2d2d2d)
    ; Return brush for background
    Return DllCall("CreateSolidBrush", "UInt", 0x2d2d2d, "Ptr")
}

LauncherGuiClose:
    Gui Launcher:Destroy
Return

ReloadScript:
    Reload
Return

ExitScript:
    ExitApp
Return