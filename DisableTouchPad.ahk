; v1.0 2010-02-23 Original Release
; v1.1 2010-02-25 Added user configuration section
;                 Added option to block mouse clicks
;                 Added option to omit blocking for shift, ctrl, alt, win keys
; Added support for latest AHK version by setting DllCall parameters to appropriate Ptr instead of Uint
; plus fixed timer to run once and using global variable.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance force; Performs in single instance mode.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
ICON_FILE_NAME := ".\res\disabletouchpad.ico"

Menu, Tray, Icon, %ICON_FILE_NAME%,

;user configuration
DisableTime := -500 ;in milliseconds
BlockMouseMove := False
BlockLeftClick := True
BlockMiddleClick := True
BlockRightClick := True
AllowShift := True
AllowCtrl := True
AllowAlt := True
AllowWin :=True
TimePassed := 0
;keyboard hook code credit: http://www.autohotkey.com/forum/post-127490.html#127490
#Persistent
OnExit, Unhook

;initialize
hCallback := RegisterCallback("Keyboard", "Fast")
;ToolTip, %hCallback%
hHookKeybd := SetWindowsHookEx(13, hCallback)
;ToolTip, %hHookKeybd%
Hotkey, LButton, DoNothing, Off
Hotkey, MButton, DoNothing, Off
Hotkey, RButton, DoNothing, Off
Return

DisableTrackpad:
   TimePassed := A_TickCount
   ShiftActive := AllowShift && GetKeyState("Shift")
   CtrlActive := AllowCtrl && GetKeyState("Ctrl")
   AltActive := AllowAlt && GetKeyState("Alt")
   LWinActive := AllowWin && GetKeyState("LWin")
   RWinActive := AllowWin && GetKeyState("RWin")
   if (!ShiftActive && !CtrlActive && !AltActive && !LWinActive && !RWinActive)
   {
      if (BlockMouseMove){
         ;ToolTip, Disabling mousemove
         BlockInput, MouseMove   
      }
      if (BlockLeftClick){
         Hotkey, LButton, DoNothing, On
      }
      if (BlockMiddleClick){
         Hotkey, MButton, DoNothing, On
      }
      if (BlockLeftClick){
         Hotkey, RButton, DoNothing, On
      }
   }
   Return

ReenableTrackpad:
   ;SetTimer, ReenableTrackpad, Off
   TimePassed := A_TickCount - TimePassed
   ;ToolTip, Reenabling mousemove after %TimePassed%
   if (BlockMouseMove)
      BlockInput, MouseMoveOff
   if (BlockLeftClick)
      Hotkey, LButton, Off
   if (BlockMiddleClick)
      Hotkey, MButton, Off
   if (BlockLeftClick)
      Hotkey, RButton, Off
   Return

DoNothing:
   Return

Unhook:
   UnhookWindowsHookEx(hHookKeybd)
   ExitApp

Keyboard(nCode, wParam, lParam){
   Critical
   global DisableTime
   If ( !nCode ){
      Gosub, DisableTrackpad
      SetTimer, ReenableTrackpad, %DisableTime%
   }
   Return CallNextHookEx(nCode, wParam, lParam)
}

SetWindowsHookEx(idHook, pfn){
   ;DllCall("GetModuleHandle", "Ptr", 0)
   Return DllCall("SetWindowsHookEx", "int", idHook, "Ptr", pfn, "Ptr", 0, "Ptr", 0)
}

UnhookWindowsHookEx(hHook){
   Return DllCall("UnhookWindowsHookEx", "Ptr", hHook)
}

CallNextHookEx(nCode, wParam, lParam, hHook = 0){
   Return DllCall("CallNextHookEx", "Ptr", hHook, "int", nCode, "Ptr", wParam, "Ptr", lParam)
}