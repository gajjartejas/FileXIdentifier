#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Resources\icon.ico
#AutoIt3Wrapper_Outfile=FileXIdentifier.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", Dialog, 1000,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", Icon, 99,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", Icon, 162,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", Icon, 164,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", Icon, 169,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", Menu, 166,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", VersionInfo, 1,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -delete "%out%", "%out%", 24, 1,
#AutoIt3Wrapper_Run_After=Utilities\ResHacker.exe -add "%out%", "%out%", Resources\FileXIdentifier.res,,,
#AutoIt3Wrapper_Run_After=del "FileXIdentifier.exe_Obfuscated.au3"
#AutoIt3Wrapper_Run_After=del Utilities\ResHacker.ini
#AutoIt3Wrapper_Run_After=del Utilities\ResHacker.log
#AutoIt3Wrapper_Run_After=Utilities\upx.exe --best --all-methods --overlay=copy "%out%"
#AutoIt3Wrapper_Run_After=del "FileXIdentifier_stripped.au3"
#AutoIt3Wrapper_Run_After=del Utilities\ResHacker.log
#AutoIt3Wrapper_Run_Tidy=y
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/so
#AutoIt3Wrapper_Versioning=v
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#Region
#Region ;************ Includes ************
#include "Includes\TrIDLib\_TrIDLib.au3"
#include "Includes\DragDropEvent.au3"
#include "Includes\_Resources.au3"
#include <WinAPIEx.au3>
#include <GuiImageList.au3>
#include <GuiButton.au3>
#include <GUIConstantsEx.au3>
#include <GUIListView.au3>
#include <GuiStatusBar.au3>
#EndRegion ;************ Includes ************
#EndRegion

;I am using /lib Folder For dll and defination remove /lib if dll and defination are in script dir
$sTridDefDir = @TempDir ; @ScriptDir || @TempDir

$sTridDllFile = $sTridDefDir & "\TrIDLib.dll"
$sTridDefFile = $sTridDefDir & "\triddefs.trd"

Global $sFile
Global $MainWin, $idInputFile, $idButtonBrowse, $idButtonRefresh, $idButtonAbout, $idListView, $hListView, $StatusBar1, $nMsg

Global Const $s_Current_Version = "1.0.0.0"
Global Const $s_ProgramName = "FileXIdentifier"
Global $s_Win_Title = $s_ProgramName & $s_Current_Version
Global Const $i_xWidth = 421
Global Const $i_yHight = 211
Global Const $i_xWinPos = (@DesktopWidth - $i_xWidth) / 2
Global Const $i_yWinPos = (@DesktopHeight - $i_yHight) / 2

Global Const $s_Build_Date = FileGetVersion(@ScriptFullPath, "Compile date")


_SetupTrIDLib()
_LoadGui()
_RegisterDragDropEvent()
_Startup()
_Main()

Func _RegisterDragDropEvent()
	DragDropEvent_Startup()
	DragDropEvent_Register($MainWin)
	GUIRegisterMsg($WM_DRAGENTER, "OnDragDrop")
	GUIRegisterMsg($WM_DRAGOVER, "OnDragDrop")
	GUIRegisterMsg($WM_DRAGLEAVE, "OnDragDrop")
	GUIRegisterMsg($WM_DROP, "OnDragDrop")
EndFunc   ;==>_RegisterDragDropEvent

Func _SetupTrIDLib()
	If (Not FileExists($sTridDllFile)) Then
		_ResourceGetAsBytes("tridlib.dll")
		_ResourceSaveToFile(@TempDir & "\tridlib.dll", "tridlib.dll", 10, 0, 8, -1)
	EndIf

	If (Not FileExists($sTridDefFile)) Then
		_ResourceGetAsBytes("triddefs.trd")
		_ResourceSaveToFile(@TempDir & "\triddefs.trd", "triddefs.trd", 10, 0, 8, -1)
	EndIf
	_TrIDLib_InitWithDir($sTridDefDir)
EndFunc   ;==>_SetupTrIDLib



Func _LoadGui()

	$MainWin = GUICreate($s_Win_Title, $i_xWidth, $i_yHight, $i_xWinPos, $i_yWinPos)

	$idInputFile = GUICtrlCreateInput("[Drag and Drop any File]", 10, 25, 295, 21)

	$idButtonBrowse = GUICtrlCreateButton("", 310, 25, 30, 22)
	_AET_ButtonSetIcon(-1, 1, 16, 16, 4)
	GUICtrlSetTip(-1, "Browse...")

	$idButtonRefresh = GUICtrlCreateButton("", 345, 25, 30, 22)
	_AET_ButtonSetIcon(-1, 2, 16, 16, 4)
	GUICtrlSetTip(-1, "Re Analyse File")

	$idButtonAbout = GUICtrlCreateButton("", 380, 25, 30, 22)
	_AET_ButtonSetIcon(-1, 3, 16, 16, 4)

	$idListView = GUICtrlCreateListView("No|File Type|Extension|Points|% Points", 10, 64, 400, 108)
	GUICtrlSetFont(-1, 8.5, 400, 0, 'Tahoma')
	$hListView = GUICtrlGetHandle($idListView)
	_GUICtrlListView_SetExtendedListViewStyle($idListView, BitOR($LVS_EX_DOUBLEBUFFER, $LVS_EX_FULLROWSELECT, $LVS_EX_INFOTIP, $LVS_EX_GRIDLINES, $LVS_EX_HEADERDRAGDROP))
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 30)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 188)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 2, 60)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 3, 50)
	GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 4, 60)
	_GUICtrlListView_SetColumn($hListView, 0, "No.", -1, 1)
	_GUICtrlListView_SetColumn($hListView, 3, "Points", -1, 1)
	_GUICtrlListView_SetColumn($hListView, 4, "% Points", -1, 1)
	_GUICtrlListView_JustifyColumn(GUICtrlGetHandle($idListView), 3, 1)
	_GUICtrlListView_JustifyColumn(GUICtrlGetHandle($idListView), 4, 1)
	If $__WINVER >= 0x0600 Then
		_WinAPI_SetWindowTheme($hListView, 'Explorer') ;Require Windows Vista or later.
	EndIf


	$StatusBar1 = _GUICtrlStatusBar_Create($MainWin, -1, "", $SBARS_TOOLTIPS)
	Local $StatusBar1_PartsWidth[3] = [260, 360, -1]
	_GUICtrlStatusBar_SetParts($StatusBar1, $StatusBar1_PartsWidth)
	_GUICtrlStatusBar_SetText($StatusBar1, "File: Not Loaded", 0)
	_GUICtrlStatusBar_SetText($StatusBar1, "No of Def: " & _TrIDLib_GetFileTypeDef(), 1)
	_GUICtrlStatusBar_SetText($StatusBar1, "v" & _TrIDLib_GetVersion(), 2)
	GUISetState(@SW_SHOW)
EndFunc   ;==>_LoadGui

Func _Main()
	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				_TrIDLib_Shutdown()
				Exit

			Case $idButtonAbout
				_SwAboutDiloag()

			Case $idButtonBrowse
				$sFile = FileOpenDialog("Open any file", "", "All Files(*.*)", 3, "*.*", $MainWin)
				If @error Then
				Else
					GUICtrlSetData($idInputFile, $sFile)
					_SetData()
				EndIf

			Case $idButtonRefresh
				$sFile = GUICtrlRead($idInputFile)
				If FileExists($sFile) Then _SetData()

		EndSwitch
	WEnd
EndFunc   ;==>_Main

Func _SetData()
	Local $at, $iErr
	_GuiBusy()

	;Force tip to be shown when text is more than fits in the box
	_GUICtrlStatusBar_SetTipText($StatusBar1, 0, $sFile)
	_GUICtrlStatusBar_SetText($StatusBar1, "File: Analysing...", 0)

	$at = _TrIDLib_GetInfo($sFile)
	$iErr = @error

	If Not $iErr Then
		_GUICtrlListView_DeleteAllItems($idListView)
		For $j = 0 To UBound($at, 1) - 1
			GUICtrlCreateListViewItem($j & "|" & $at[$j][0] & "|" & $at[$j][1] & "|" & $at[$j][2] & "|" & $at[$j][3], $idListView)
		Next
		_GUICtrlStatusBar_SetText($StatusBar1, "File: " & StringRight($sFile, StringLen($sFile) - StringInStr($sFile, "\", 0, -1)), 0)
	Else
		Switch $iErr
			Case 1
				MsgBox(0, "Error", "TrIDLib.dll File Not Found in Script Directory.", 0, $MainWin)
			Case 2
				MsgBox(0, "Error", "triddefs.trd File Not Found in Script Directory.", 0, $MainWin)
			Case 3
				MsgBox(0, "Error", "Error occurs during opening TrIDLib.dll", 0, $MainWin)
			Case 4
				MsgBox(0, "Error", "Error occurs during Loading triddefs.trd.", 0, $MainWin)
			Case 5
				MsgBox(0, "Error", "Error occurs during Submitting File: " & $sFile, 0, $MainWin)
			Case 6
				MsgBox(0, "Error", "Error occurs during Analysing File: " & $sFile, 0, $MainWin)
			Case 7
				MsgBox(0, "Info", "Unable to detect file type", 0, $MainWin)
		EndSwitch
		_GUICtrlListView_DeleteAllItems($idListView)
		_GUICtrlStatusBar_SetText($StatusBar1, "File: Not Loaded", 0)
	EndIf
	_GuiDefault()
EndFunc   ;==>_SetData

Func _GuiBusy()
	GUICtrlSetCursor($idInputFile, 15)
	GUICtrlSetCursor($idButtonBrowse, 15)
	GUICtrlSetCursor($idButtonRefresh, 15)
	GUICtrlSetCursor($idListView, 15)
	GUICtrlSetCursor($StatusBar1, 15)
	GUISetCursor(15)
EndFunc   ;==>_GuiBusy

Func _GuiDefault()
	GUICtrlSetCursor($idInputFile, -1)
	GUICtrlSetCursor($idButtonBrowse, -1)
	GUICtrlSetCursor($idButtonRefresh, -1)
	GUICtrlSetCursor($idListView, -1)
	GUICtrlSetCursor($StatusBar1, -1)
	GUISetCursor(2)
EndFunc   ;==>_GuiDefault

;Other Udf================================
Func OnDragDrop($hWnd, $Msg, $wParam, $lParam)
	#forceref $hWnd, $Msg, $wParam, $lParam
	Static $DropAccept

	Switch $Msg
		Case $WM_DRAGENTER, $WM_DROP
			Select
				Case DragDropEvent_IsFile($wParam)
					If $Msg = $WM_DROP Then
						$sFile = DragDropEvent_GetFile($wParam)
						If FileExists($sFile) And StringInStr(FileGetAttrib($sFile), "D") = 0 Then
							GUICtrlSetData($idInputFile, $sFile)
							_SetData()
						EndIf
					EndIf
					$DropAccept = $DROPEFFECT_COPY

				Case Else
					$DropAccept = $DROPEFFECT_NONE

			EndSelect
			Return $DropAccept

		Case $WM_DRAGOVER
			DragDropEvent_GetX($wParam)
			DragDropEvent_GetY($wParam)
			Return $DropAccept

		Case $WM_DRAGLEAVE

	EndSwitch
EndFunc   ;==>OnDragDrop

Func _SwAboutDiloag()
	GUISetState(@SW_DISABLE, $MainWin)

	Local $size = WinGetPos($s_Win_Title)
	Local $Child_About = GUICreate("About", 298, 230, $size[0] + $i_xWidth / 2 - 297 / 2, $size[1] + $i_yHight / 2 - 310 / 2, BitXOR($GUI_SS_DEFAULT_GUI, $WS_MINIMIZEBOX), BitOR($WS_EX_TOOLWINDOW, $WS_EX_WINDOWEDGE), $MainWin)
	GUISetBkColor(0xFFFFFF)
	Local $idPic1 = GUICtrlCreatePic("", 0, 0, 281, 41, 67108864)
	_ResourceSetImageToCtrl($idPic1, "NAVBAR")
	GUICtrlCreateGroup("", 3, 3, 285, 192)
	GUICtrlCreateLabel("About " & $s_Win_Title, 77, 29, 205, 17)
	GUICtrlCreateLabel("Copyright (c) 2016 Gajjar Tejas", 77, 57, 205, 17)
	GUICtrlCreateIcon(@ScriptFullPath, -1, 10, 30, 42, 42)
	GUICtrlCreateLabel("Email:", 10, 90, 65, 17)
	GUICtrlCreateLabel("Website:", 10, 110, 65, 17)
	Local $Child_Label_Email_ = GUICtrlCreateLabel("gajjartejas26@gmail.com", 77, 90, 205, 17)
	GUICtrlSetFont(-1, 8, 400, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetCursor(-1, 0)
	Local $Child_Label_Website_ = GUICtrlCreateLabel("http://www.tejasgajjar.in", 77, 110, 205, 17)
	GUICtrlSetFont(-1, 8, 400, 4, "MS Sans Serif")
	GUICtrlSetColor(-1, 0x0000FF)
	GUICtrlSetCursor(-1, 0)
	GUICtrlCreateLabel("FileXIdentifier Stand For File eXtension Identifier" & @CRLF & "FileXIdentifier Is Free(GNU GPL v3) Software", 10, 160, 260, 34)
	GUICtrlCreateLabel("Build Date: ", 10, 130, 65, 17)
	GUICtrlCreateLabel($s_Build_Date, 77, 130, 205, 17)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	Local $Contribute = GUICtrlCreateButton("&Project Homepage", 3, 197, 150, 25)
	Local $Child_Ok = GUICtrlCreateButton("&OK", 198, 197, 90, 25)
	GUISetState(@SW_SHOW, $Child_About)
	Local $Msg
	While 1
		$Msg = GUIGetMsg()
		If $Msg = $Child_Ok Or $Msg = $GUI_EVENT_CLOSE Then ExitLoop
		If $Msg = $Contribute Then ShellExecute("http://www.tejasgajjar.in/p/filexidentifierfile-extension-identifier.html")
		If $Msg = $Child_Label_Email_ Then ShellExecute("mailto:gajjartejas26@gmail.com")
		If $Msg = $Child_Label_Website_ Then ShellExecute("http://www.tejasgajjar.in")
	WEnd

	GUISetState(@SW_ENABLE, $MainWin)
	GUIDelete($Child_About)
EndFunc   ;==>_SwAboutDiloag

;Set Icon From @ScriptFullPath resources.
Func _AET_ButtonSetIcon($hWnd, $iIndex, $iWidth, $iHeight, $iAlign)
	Local $hImageList = _GUIImageList_Create($iWidth, $iHeight, 5, 3)
	_GUIImageList_AddIcon($hImageList, @ScriptFullPath, $iIndex, True)
	_GUICtrlButton_SetImageList($hWnd, $hImageList, $iAlign)
EndFunc   ;==>_AET_ButtonSetIcon

Func _Startup()

	Switch $CmdLine[0]
		Case 0

		Case 1
			$sFile = $CmdLine[1]
			GUICtrlSetData($idInputFile, $sFile)
			_SetData()
	EndSwitch

EndFunc   ;==>_Startup
