#AutoIt3Wrapper_AU3Check_Parameters=-d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6
#include-once

; TrIDlib AutoIt Demo[Modified]

; #INDEX# =======================================================================================================================
; Title .........: 7Zip
; AutoIt Version : 3.3.8.1
; Language ......: English
; Description ...: Functions that assist with TrIDLib DLL.
; Author(s) .....: Gajjar Tejas
; Notes .........: The original code came from this subject : http://mark0.net/download/tridlib-samples.zip
;				  - 12 June 2013 :
;						* Intial
;						* Added _TrIDLib_GetInfo, _TrIDLib_GetVersion, _TrIDLib_GetFileTypeDef,_TrIDLib_Startup, _TrIDLib_Shutdown,_TrIDLib_GetRealExtension
;						* 32bit dll Version(v1.0.2.0).
;						* Auto Open Dll, Manually Close
;				  - Note
;						* Using _TrIDLib_Startup() and _TrIDLib_Shutdown() is recommanded for multiples Files.
;						* The last x32 DLL file can be found here : http://mark0.net/code-tridlib-e.html
; 						* The last Definition file can be found here : http://mark0.net/soft-trid-e.html
; ===============================================================================================================================

; #CURRENT# =====================================================================================================================
;_TrIDLib_Startup
;_TrIDLib_Shutdown
;_TrIDLib_GetInfo			Auto Open dll***
;_TrIDLib_GetVersion		Auto Open dll
;_TrIDLib_GetFileTypeDef	Auto Open dll

;***Using _TrIDLib_Startup() and _TrIDLib_Startup() is recommanded for multiples Files to avoid
;	repetitive dll open that can increase operation time.
;***If _TrIDLib_Startup is not specified then dll will open and close automatically for _TrIDLib_GetInfo()
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
; Definations & dll File
Global $sTridDefDir
Global $sTridDllFile = $sTridDefDir & "\TrIDLib.dll"
Global $sTridDefFile = $sTridDefDir & "\triddefs.trd"

; Others
Global $iTridIsDllOpen = 0 ;Default Dll is not opened.
Global $hTridDll = 0 ;Handle to Dll
Global $iTridAutoLoad = 1 ;Default auto load Dll

; Constants FOR TrID_GetInfo
Const $TRID_GET_RES_NUM = 1 ;Get the number of results available
Const $TRID_GET_RES_FILETYPE = 2 ;Filetype descriptions
Const $TRID_GET_RES_FILEEXT = 3 ;Filetype extension
Const $TRID_GET_RES_POINTS = 4 ;Matching points

Const $TRID_GET_VER = 1001 ;TrIDLib version (major * 100 + minor)
Const $TRID_GET_DEFSNUM = 1004 ;Number of filetypes definitions loaded
; ===============================================================================================================================

; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib_CheckFiles
; Description ...: Check File
; Syntax ........: _TrIDLib_CheckFiles()
; Parameters ....:
; Return values .: Success - Returns 1
; 				   Failure - Returns 0 and and sets @error to non zero
;							|1 = TrIDLib.dll File Not Found.(FileExist)
;							|2 = Triddefs.trd File Not Found(FileExist)
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _TrIDLib_CheckFiles()
	If Not FileExists($sTridDllFile) Then
		Return SetError(1, 0, 0)
	ElseIf Not FileExists($sTridDefFile) Then
		Return SetError(2, 0, 0)
	Else
		Return SetError(0, 0, 1)
	EndIf
EndFunc   ;==>_TrIDLib_CheckFiles



; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib_initWithDir
; Description ...: Manually Load TrIDLib.dll
; Syntax ........: _TrIDLib_initWithDir()
; Parameters ....:
; Return values .: Success - Returns 1
; 				   Failure - Returns 0 and and sets @error to non zero
;							|1 = TrIDLib.dll File Not Found.(FileExist)
;							|2 = Triddefs.trd File Not Found(FileExist)
;							|3 = While Opening TrIDLib.dll(DllOpen)
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _TrIDLib_InitWithDir($sDir = $sTridDefDir)

	$sTridDefDir = $sDir
	_TrIDLib_CheckFiles()
	If @error Then Return SetError(@error, 0, 0)

	$hTridDll = DllOpen($sTridDllFile)
	If $hTridDll = -1 Then Return SetError(3, 0, 0)
	$iTridIsDllOpen = 1
	$iTridAutoLoad = 0
	Return SetError(0, 0, 1)
EndFunc   ;==>_TrIDLib_InitWithDir



; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib
; Description ...: Identify file types from their binary signatures.
; Syntax ........: _TrIDLib($sFile)
; Parameters ....: $sFile               - A full path of file.
; Return values .: Success - Returns the array (n x 4) with results
;							n = Total No of possible file type found(UBound(array, 1))
;							array[0][0] = File Type 1st instant
;							array[0][1] = Extension "
;							array[0][2] = Points 	"
;							array[0][3] = % Point 	"
;							...
;							array[n-1][0] = File Type	(n-1)th instant
;							array[n-1][1] = Extension	"
;							array[n-1][2] = Points		"
;							array[n-1][3] = % Point		"
; 				  Failure - Returns 0 and and sets @error to non zero
;							|1 = TrIDLib.dll File Not Found.(FileExist)
;							|2 = Triddefs.trd File Not Found(FileExist)
;							|3 = While Opening TrIDLib.dll(DllOpen)
;							|4 = While Loading triddefs.trd(DllCall)
;							|5 = While Submitting File(DllCall)
;							|6 = While Analysing File(DllCall)
;							|7 = Unable to detect file type(DllCall)
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _TrIDLib_GetInfo($sFile)

	If $iTridAutoLoad Then
		_TrIDLib_InitWithDir()
		If @error Then Return SetError(@error, 0, 0)
		$iTridAutoLoad = 1
	Else
		;Check if Manually Load Using _TrIDLib_Startup and previously dll open or not
		If Not $iTridIsDllOpen Then
			_TrIDLib_InitWithDir()
			If @error Then Return SetError(@error, 0, 0)
		EndIf
	EndIf

	; load the definitions
	Local $Ret = DllCall($hTridDll, "int", "TrID_LoadDefsPack", "str", $sTridDefDir)
	If @error Then Return SetError(4, 0, 0)

	; submit the file
	$Ret = DllCall($hTridDll, "int", "TrID_SubmitFileA", "str", $sFile)
	If @error Then Return SetError(5, 0, 0)

	; perform the analysis
	$Ret = DllCall($hTridDll, "int", "TrID_Analyze")
	If @error Then Return SetError(6, 0, 0)

	Local $Buf
	$Ret = DllCall($hTridDll, "int", "TrID_GetInfo", "int", $TRID_GET_RES_NUM, "int", 0, "str", $Buf)

	Local $iTotalSumPoints = 0
	Local $RetCom
	If $Ret[0] > 0 Then
		Local $aTridLibInfoInform2D[$Ret[0]][4]

		For $ResId = 0 To $Ret[0] - 1

			;Get File Type
			$RetCom = DllCall($hTridDll, "int", "TrID_GetInfo", "int", $TRID_GET_RES_FILETYPE, "int", $ResId + 1, "str", $Buf)
			$aTridLibInfoInform2D[$ResId][0] = $RetCom[3] ;First Element

			;Get Extension
			$RetCom = DllCall($hTridDll, "int", "TrID_GetInfo", "int", $TRID_GET_RES_FILEEXT, "int", $ResId + 1, "str", $Buf)
			$aTridLibInfoInform2D[$ResId][1] = $RetCom[3] ;Second Element

			;Get Points
			$RetCom = DllCall($hTridDll, "int", "TrID_GetInfo", "int", $TRID_GET_RES_POINTS, "int", $ResId + 1, "str", $Buf)
			$aTridLibInfoInform2D[$ResId][2] = $RetCom[0]
			$iTotalSumPoints += Number($aTridLibInfoInform2D[$ResId][2]) ;Third Element

		Next

		;Get Points in Percentage
		If $iTotalSumPoints > 0 Then
			For $ResId = 0 To $Ret[0] - 1
				$aTridLibInfoInform2D[$ResId][3] = Round($aTridLibInfoInform2D[$ResId][2] * 100 / $iTotalSumPoints, 2) ;Fourth Element
			Next
		EndIf

	Else
		Return SetError(7, 0, 0)
	EndIf
	If $iTridAutoLoad Then _TrIDLib_Shutdown()
	Return $aTridLibInfoInform2D
EndFunc   ;==>_TrIDLib_GetInfo

; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib_GetRealExtension
; Description ...:
; Syntax ........: _TrIDLib_GetRealExtension($sFile)
; Parameters ....: $sFile               - A full path of file.
; Return values .: Success - Returns the Original File Extension
; 				  Failure - Returns Empty String('') and and sets @error to non zero
;							|1 = TrIDLib.dll File Not Found.(FileExist)
;							|2 = Triddefs.trd File Not Found(FileExist)
;							|3 = While Opening TrIDLib.dll(DllOpen)
;							|4 = While Loading triddefs.trd(DllCall)
;							|5 = While Submitting File(DllCall)
;							|6 = While Analysing File(DllCall)
;							|7 = Unable to detect file type(DllCall)
;							|8 = File was Identified But Extension Not Found in the Database(null('') extension return by dll)
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _TrIDLib_GetRealExtension($sFile)
	Local $at = _TrIDLib_GetInfo($sFile)
	Local $iErr = @error
	Local $sExt = $at[0][1]

	If Not $iErr Then
		If $sExt <> "" Then
			$sExt = "." & $sExt
		Else
			Return SetError(8, 0, '');null extension return by dll
		EndIf
	Else
		Return SetError($iErr, 0, '')
	EndIf
	Return $sExt
EndFunc   ;==>_TrIDLib_GetRealExtension

; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib_GetVersion
; Description ...: Get the TrIDLib.dll version
; Syntax ........: _TrIDLib_GetVersion()
; Parameters ....:
; Return values .: Success - Returns Numrical - Version
; 				  Failure - Returns 0 and and sets @error to non zero
;							|1 = TrIDLib.dll File Not Found.(FileExist)
;							|2 = Triddefs.trd File Not Found(FileExist)
;							|3 = While Opening TrIDLib.dll(DllOpen)
;							|4 = While Loading triddefs.trd(DllCall)
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: Yes
; ===============================================================================================================================
Func _TrIDLib_GetVersion()

	;Check if is dll open or not
	If Not $iTridIsDllOpen Then
		_TrIDLib_InitWithDir()
		If @error Then Return SetError(@error, 0, 0)
	EndIf

	;Get TrIDLib version
	Local $Buf
	Local $RetCom = DllCall($hTridDll, "int", "TrID_GetInfo", "int", $TRID_GET_VER, "int", 0, "str", $Buf)

	Return Round($RetCom[0] / 100, 2)
EndFunc   ;==>_TrIDLib_GetVersion

; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib_GetFileTypeDef
; Description ...: Get the total no of Definitions triddefs.trd
; Syntax ........: _TrIDLib_GetFileTypeDef()
; Parameters ....:
; Return values .: Success - Returns Numrical - Version
; 				  Failure - Returns 0 and and sets @error to non zero
;							|1 = TrIDLib.dll File Not Found.(FileExist)
;							|2 = Triddefs.trd File Not Found(FileExist)
;							|3 = While Opening TrIDLib.dll(DllOpen)
;							|4 = While Loading triddefs.trd(DllCall)
; Author ........: Your Name
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _TrIDLib_GetFileTypeDef()

	;Check if is dll open or not
	If Not $iTridIsDllOpen Then
		_TrIDLib_InitWithDir()
		If @error Then Return SetError(@error, 0, 0)
	EndIf

	; load the definitions
	DllCall($hTridDll, "int", "TrID_LoadDefsPack", "str", $sTridDefDir)
	If @error Then Return SetError(4, 0, 0)

	;Get Number of filetypes definitions loaded
	Local $Buf
	Local $RetCom = DllCall($hTridDll, "int", "TrID_GetInfo", "int", $TRID_GET_DEFSNUM, "int", 0, "str", $Buf)

	Return $RetCom[0]
EndFunc   ;==>_TrIDLib_GetFileTypeDef



; #FUNCTION# ====================================================================================================================
; Name ..........: _TrIDLib_Shutdown
; Description ...:Manually Unload TrIDLib.dll
; Syntax ........: _TrIDLib_Shutdown()
; Parameters ....:
; Return values .: None
; Author ........: Gajjar Tejas
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _TrIDLib_Shutdown()
	DllClose($hTridDll)
	$iTridAutoLoad = 1;Default auto load
	$iTridIsDllOpen = 0
EndFunc   ;==>_TrIDLib_Shutdown
