#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 100
#InstallKeybdHook
#InstallMouseHook
#Include lib.ahk



SendMode Event
SetWorkingDir %A_ScriptDir%
SetKeyDelay 0
SetMouseDelay 0

if !ProcessExist("GenshinImpact.exe")
{
    ; Run the game only if it's not already running
    Run, C:\Program Files\Genshin Impact\Genshin Impact game\GenshinImpact.exe ; Change this if you have a different directory
    Sleep, 3000
}

; Rerun script with administrator rights if required.
if (!A_IsAdmin) {
    try {
        Run *RunAs "%A_ScriptFullPath%"
    } catch e {
        MsgBox, Failed to run script with administrator rights
        ExitApp
    }
}

; =======================================
; Global variables
; =======================================

ContextualBindingsEnabled := false

; =======================================
; Script initialization
; =======================================
SetTimer, SuspendOnGameInactive, -1
SetTimer, ExitOnGameClose, 5000
SetTimer, ConfigureContextualBindings, 250



; =======================================
; Technical stuff
; =======================================

; Pause script
Pause::
    Suspend
    ; Pause ; script won't be unpaused
return

; Reload script
Numpad0::
    Reload
return

SuspendOnGameInactive() {
    global GameProcessName

    Suspend ; run suspended
    loop {
        WinWaitActive, %GameProcessName%
        Suspend, Off

        WinWaitNotActive, %GameProcessName%
        Suspend, On
    }
}

ExitOnGameClose() {
    global GameProcessName

    ; WinWaitActive is blocked forever when WinWaitClose is waiting (looks like a bug), it can't be used here
    if (!WinExist(GameProcessName)) {
        ExitApp
    }
}



; =======================================
; Enable/disable contextual bindings
; =======================================

ConfigureContextualBindings() {
    global ContextualBindingsEnabled

    PixelGetColor, Color, 808, 1010, "RGB" ; left pixel of the hp bar
    HpBarFound := (Color = "0x96D722") || (Color = "0xFF5A5A") || (Color = "0xFFCC32") ; green or red or orange

    PixelGetColor, ThirdActionItemColor, 1626, 1029, "RGB"
    FishingActive := ThirdActionItemColor = "0xFFE92C" ; is 3rd action icon bound to LMB

    if (!ContextualBindingsEnabled && HpBarFound && !FishingActive) {
        ; enable bindings
        Hotkey, ~$*f, Loot, On
        ContextualBindingsEnabled := true
    } else if (ContextualBindingsEnabled && (!HpBarFound || FishingActive)) {
        ; disable bindings
        Hotkey, ~$*f, Loot, Off
        ContextualBindingsEnabled := false
    }
}

; =======================================
; Hold F to loot
; =======================================

Loot() {
    while(GetKeyState("f", "P")) {
        Send, {f}
        Sleep, 20
        Send, {WheelDown}
        Sleep, 20
    }
}

; =======================================
; Expeditions
; =======================================

; Recieve all the rewards
Numpad1::
    MouseClick Left, 169, 1020
    Sleep 900
    MouseClick Left, 1150, 1008
    Sleep 20
    Send, {Esc}
return

; =======================================
; Artifact animation cancel
; =======================================

Numpad5::
    if(!HpBarFound){
        MouseGetPos, X, Y
        MouseClick, left, 1780, 760
        Sleep, 200
        MouseClick, left, 1780, 1015
        Sleep, 200
        MouseClick, left, 150, 150
        Sleep, 150
        MouseClick, left, 180, 230
        Sleep, 150
        MouseMove, X, Y
    }
return


; =======================================
; Change account
; =======================================

=::
    Send, {Esc}
    Sleep 500
    MouseMove, 45, 1025
    Sleep, 200
    Click, left
    Sleep, 500
    MouseMove, 1200, 760
    Sleep, 100
    Click, left
    Sleep, 4500 ; login screen
    MouseMove, 1825, 980 ; logout button
    Sleep, 100
    Click, left
    Sleep, 550
    MouseMove, 1090, 590 ; ok button
    Sleep, 100
    Click, left
return



; =======================================
; Select maximum stacks and craft ores
; =======================================

Numpad9::
    MouseClick, left, 1178, 600 ; max stacks
    Sleep, 50
    ClickOnBottomRightButton()
return

; =======================================
; Purchase max
; =======================================

Numpad8::
    ClickOnBottomRightButton()
    ; Sleep 400
    ; MouseClick, left, 1178, 600 ; max stacks
    Sleep 200
    MouseClick, left, 1170, 790
    Sleep 300
    Click
return

; =======================================
; Receive all BP exp and rewards
; =======================================

NumpadDot::
    ;global RedNotificationColor

    ;PixelGetColor, Color, 1515, 23, "RGB" ; top right BP notification icon
    ;if (Color != RedNotificationColor) {
    ;    MsgBox, "No BP exp or reward"
    ;    return
    ;}

    Send, {f4}
    WaitFullScreenMenu()

    ReceiveBpExp()
    ReceiveBpRewards()

    Send, {Esc}
return

ReceiveBpExp() {
    global RedNotificationColor

    ; Check for available BP experience and receive if any
    PixelGetColor, Color, 993, 20, "RGB"
    if (Color != RedNotificationColor) {
        return ; no exp
    }

    MouseClick, left, 993, 20 ; to exp tab
    Sleep, 100

    ClickOnBottomRightButton() ; "Claim all"
    Sleep, 200

    if (!IsFullScreenMenuOpen()) {
        ; level up, need to close popup
        Send, {Esc}
        WaitFullScreenMenu()
    }
}

ReceiveBpRewards() {
    global RedNotificationColor

    ; Check for available BP experience and receive if any
    PixelGetColor, Color, 899, 20, "RGB"
    if (Color != RedNotificationColor) {
        return ; no rewards
    }

    MouseClick, left, 899, 20 ; to rewards tab
    Sleep, 100

    ClickOnBottomRightButton() ; "Claim all"
    Sleep, 200
    Send, {Esc} ; close popup with received rewards
    WaitFullScreenMenu()
}

; =======================================
; Teleport in sereneti teapot
; =======================================

[::
    if (!IsFullScreenMenuOpen()) {
        Send M
        Sleep 500
    }
    ClickOnBottomRightButton()
    Sleep 500
    MouseClick, Left, 1400, 690 ; Serenitea pot
    Sleep 600
    PixelSearch, FoundX, FoundY, 0, 0, 1299, 1080, 0xFDCA00, 10, "Fast RGB"
    if (ErrorLevel = 0)
    {
        Sleep 10
        MouseClick, Left, FoundX, FoundY
        Sleep 500
        PixelSearch, FoundX, FoundY, 1298, 460, 1299, 1080, 0xFFFFFF, 10, "Fast RGB"
        if (ErrorLevel = 0)
        {
            MouseClick, Left, FoundX, FoundY
            Sleep 200
            ClickOnBottomRightButton()
            Sleep 10
            MoveCursorToCenter()
        } else {
            MoveCursorToCenter()
        }
    } else {
        MoveCursorToCenter()
    }
        
    
return

; =======================================
; Teleport in one click
; =======================================

~MButton::
    if (!IsFullScreenMenuOpen()) {
        return ; not in the world map menu
    }

    MapClick()
    try {
        ; wait for a little white arrow or teleport button
        WaitPixelsRegions([ { X1: 1255, Y1: 484, X2: 1258, Y2: 1080, Color: "0xECE5D8" }, { X1: 1478, Y1: 1012, X2: 1478, Y2: 1013, Color: "0xFFCC33" } ])
    } catch e {
        return
    }

    PixelGetColor, TpColor, 1478, 1012, "RGB"
    if (TpColor = "0xFFCC33") {
        ; selected point has only 1 selectable option and it's available for teleport
        ClickOnBottomRightButton()
        Sleep, 50
        MoveCursorToCenter()
    } else {
        ; selected point has multiple selectable options or selected point is not available for teleport
        TeleportablePointColors := [ "0x2D91D9" ; Teleport waypoint
            , "0x99ECF5"                        ; Statue of The Seven
            , "0x05EDF6"                        ; Domain
            , "0x00FFFF"                        ; One-time dungeon
            , "0X0CF3F5"                        ; Temp waypoint
            , "0xFFCC00" ]                      ; Serenitea teapot teleport

        for Index, TeleportablePointColor in TeleportablePointColors {
            Teleported := FindIconAndTeleport(TeleportablePointColor)
            if (Teleported) {
                MoveCursorToCenter()
                break
            }
        }
    }
return

FindIconAndTeleport(IconPixelColor) {
    PixelSearch, FoundX, FoundY, 1298, 460, 1299, 1080, IconPixelColor, 0, "Fast RGB"
    if (ErrorLevel) {
        ; icon wasn't found
        return false
    }

    MouseClick, left, FoundX, FoundY
    WaitPixelColor("0xFFCB33", 1480, 1011, 500) ; "Teleport" button

    ClickOnBottomRightButton()
    Sleep, 50
    return true
}

ProcessExist(name) {
    Process, Exist, %name%
    return ErrorLevel
}
