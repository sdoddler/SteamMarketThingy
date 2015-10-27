#include <JSON.au3>
#include <array.au3>
#include <GraphGDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <WINAPI.Au3>
#include <EditConstants.au3>
#include <GuiToolTip.au3>


;~ $lel = GUICreate("LEL")

;~ $priceHistoryJSON = FileOpenDialog("Choose a PriceHistory.Json", @ScriptDir & "\", "Json Files (*.json)")
;~ ;$test = FileRead("p90dotcom.json")
;~ ;$days = 10000

;~ _PriceGraph($priceHistoryJSON,$lel))

Func _PriceGraph($hFile, $parentGUI)
	GUISetState(@SW_DISABLE, $parentGUI)

	$read = FileRead($hFile)

	$obj = JSON_Decode($read)

	If Not (Json_IsObject($obj)) Then
		GUISetState(@SW_ENABLE, $parentGUI)
		MsgBox(48, "JSON Read Issue", "There was a problem reading the selected JSON file: " & @LF & _
				$hFile & @LF & @LF & _
				"This does not seem to be a normal JSON file")

		Return 1
	EndIf

	$abc = JSON_ObjGet($obj, "prices")


	If Not ($abc <> "") Then
		GUISetState(@SW_ENABLE, $parentGUI)
		MsgBox(48, "JSON Read Issue", "There was a problem reading the selected JSON file: " & @LF & _
				$hFile & @LF & @LF & _
				"This JSON contains no price data")

		Return 1
	EndIf

	;; After Error Checking the JSON - Disable Main GUI


	$ttG = GUICreate("Time to Graph", 200, 80)

	Local $days = IniRead("Settings.ini", "LastSearch", "Days", "30")
	Local $iHours = IniRead("Settings.ini", "LastSearch", "Hours", "24")
	Local $timeFormat = IniRead("Settings.ini", "LastSearch", "TimeFormat", "Days")

	$gRadHours = GUICtrlCreateRadio("Hours", 10, 10)
	$gRadDays = GUICtrlCreateRadio("Days", 80, 10)
	If $timeFormat = "Days" Then
		GUICtrlSetState($gRadDays, $GUI_CHECKED)
	Else
		GUICtrlSetState($gRadHours, $GUI_CHECKED)
	EndIf

	$gHours = GUICtrlCreateInput($iHours, 10, 40, -1, -1, $ES_NUMBER)
	GUICtrlSetLimit(-1, 1000)
	$gDays = GUICtrlCreateInput($days, 80, 40, -1, -1, $ES_NUMBER)
	GUICtrlSetLimit(-1, 9999)

	$gBtn = GUICtrlCreateButton("Save", 150, 40)

	GUISetState()

	While 1

		Switch GUIGetMsg($ttG)
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_ENABLE, $parentGUI)
				GUIDelete($ttG)
				Return 1
			Case $gBtn
				$days = GUICtrlRead($gDays)
				$iHours = GUICtrlRead($gHours)
				ConsoleWrite("SAVE MOTHER FUCKER" & @LF & "Hours = " & $iHours & @LF & "Days = " & $days & @LF & @LF _
						 & "Hours Checked = " & (BitAND(GUICtrlRead($gRadHours), $GUI_CHECKED) = $GUI_CHECKED) & @LF & "Days Checked = " & _
						(BitAND(GUICtrlRead($gRadDays), $GUI_CHECKED) = $GUI_CHECKED))
				If BitAND(GUICtrlRead($gRadHours), $GUI_CHECKED) = $GUI_CHECKED Then
					$timeFormat = "Hours"
					IniWrite("Settings.ini", "LastSearch", $timeFormat, $iHours)
				ElseIf BitAND(GUICtrlRead($gRadDays), $GUI_CHECKED) = $GUI_CHECKED Then
					$timeFormat = "Days"
					IniWrite("Settings.ini", "LastSearch", $timeFormat, $days)
				EndIf
				IniWrite("Settings.ini", "LastSearch", "TimeFormat", $timeFormat)
				;	ConsoleWrite("Time Format = " & $timeFormat & @LF)
				GUISetState(@SW_ENABLE, $parentGUI)
				GUIDelete($ttG)
				ExitLoop
		EndSwitch
	WEnd


	$currency = JSON_ObjGet($obj, "price_prefix")
	;$currency = "$"

	;; WORKING!!
	;ConsoleWrite(Json_Get($abc[0], "[0]") & @LF & Json_Get($abc[0], "[1]") & @LF & Json_Get($abc[0], "[2]") & @LF) ;; WORKING!!
	;; WORKING!!

	Local $priceHistory[0][3], $maxPrice = 0, $priceCount[1][3], $count = -1, $lastDate, $hours = 1, $minPrice = 400, $recordedInHours = False


	Switch $timeFormat
		Case "Days"
			$tFormat = $days
			For $i = 0 To UBound($abc) - 1
				;ConsoleWrite(StringLeft(Json_get($abc[$i],"[0]"),6) &@LF)
				If $lastDate <> StringLeft(Json_get($abc[$i], "[0]"), 6) Then
					;;If New Date Then
					If $hours > 1 Then ; Divide last date by the hours to get average price.
						$priceHistory[$count][1] = $priceHistory[$count][1] / $hours
					EndIf
					$count += 1 ; Increase count to $i
					ReDim $priceHistory[$count + 1][3] ;Redim Array inline with current Data(ready for input)
					$priceHistory[$count][0] = Json_get($abc[$i], "[0]") ; Date (May 02 2014 01: +0)
					$lastDate = StringLeft(Json_get($abc[$i], "[0]"), 6) ; Last Date = May 02
					$priceHistory[$count][1] = Json_get($abc[$i], "[1]") ; Average Price (340.96)
					If $priceHistory[$count][1] > $maxPrice Then ; If Average bigger than Current Max then
						$maxPrice = $priceHistory[$count][1] ; Max Price = Current Average
					EndIf
					If $priceHistory[$count][1] < $minPrice Then ;If Average smaller than current Min then
						$minPrice = $priceHistory[$count][1] ; Min Price = Current Average
					EndIf
					$priceHistory[$count][2] = Json_get($abc[$i], "[2]") ; Volume
					$hours = 1; Set the counter of Hours to 1 (first hour of new date)
				Else; Else if this entry is same as last date Then
					$hours += 1 ; Add hour
					$priceHistory[$count][1] += Json_get($abc[$i], "[1]")


					If Json_get($abc[$i], "[1]") > $maxPrice Then
						$maxPrice = Json_get($abc[$i], "[1]")
					EndIf
					If Json_get($abc[$i], "[1]") < $minPrice Then
						$minPrice = Json_get($abc[$i], "[1]")
					EndIf
					$priceHistory[$count][2] += Json_get($abc[$i], "[2]")
				EndIf
			Next
			If $hours > 1 Then
				$priceHistory[$count][1] = $priceHistory[$count][1] / $hours ; Divide Last Day Average Price (total) by Hours to get the daily average..
			EndIf

		Case "Hours" ;; MORE MATHS REQUIRED HERE TO DETERMINE AVERAGE OVER MISSING HOURS :(
			$tFormat = $iHours
			$count = 0
			For $i = 0 To UBound($abc) - 1
				If $recordedInHours = False And Not (StringLeft(Json_get($abc[$i], "[0]"), 6) = StringLeft(Json_get($abc[$i + 1], "[0]"), 6)) Then
					;ConsoleWrite("Skipping, Day not hour" & @LF)
					ContinueLoop
				ElseIf $recordedInHours = False Then
					$recordedInHours = True
					ReDim $priceHistory[$count + 1][3]
					$priceHistory[$count][0] = Json_get($abc[$i], "[0]") ; Date (May 02 2014 01: +0)
					$lastDate = $priceHistory[$count][0]
					$priceHistory[$count][1] = Json_get($abc[$i], "[1]") ; Average Price (340.96)
					$priceHistory[$count][2] = Json_get($abc[$i], "[2]")
					If $priceHistory[$count][1] > $maxPrice Then ; If Average bigger than Current Max then
						$maxPrice = $priceHistory[$count][1] ; Max Price = Current Average
					EndIf
					If $priceHistory[$count][1] < $minPrice Then ;If Average smaller than current Min then
						$minPrice = $priceHistory[$count][1] ; Min Price = Current Average
					EndIf
					$count += 1
					ContinueLoop
				EndIf


				If $recordedInHours Then

					$tempDate = Json_get($abc[$i], "[0]")
					If StringLeft($tempDate, 6) = StringLeft($lastDate, 6) Then
						;ConsoleWrite("StringLeft($tempdate,6) = StringLeft($lastDate,6)"&@LF)
						$tempHour = StringLeft(StringRight($tempDate, 6), 2)
						$lastHour = StringLeft(StringRight($lastDate, 6), 2)
						;ConsoleWrite(@LF & "Temp Hour = "& $tempHour & @LF & "Last Hour = " & $lastHour &@LF & $lastHour + 1 &@LF)
						If Not ($tempHour = $lastHour + 1) Then
							For $h = $lastHour + 1 To $tempHour - 1
								ConsoleWrite("Hour = " & $h & @LF)

								If $h < 10 Then
									$hour = "0" & $h
								Else
									$hour = $h
								EndIf
								ReDim $priceHistory[$count + 1][3]
								$priceHistory[$count][0] = StringLeft($priceHistory[$count - 1][0], 12) & $hour & ": +0" ; Date (May 02 2014 01: +0)
								$priceHistory[$count][1] = $priceHistory[$count - 1][1] ; Average Price (340.96)
								$priceHistory[$count][2] = 0
								$count += 1
							Next
						EndIf
					EndIf

					ReDim $priceHistory[$count + 1][3]
					$priceHistory[$count][0] = Json_get($abc[$i], "[0]") ; Date (May 02 2014 01: +0)
					$lastDate = $priceHistory[$count][0]
					$priceHistory[$count][1] = Json_get($abc[$i], "[1]") ; Average Price (340.96)
					$priceHistory[$count][2] = Json_get($abc[$i], "[2]") ; Volume
					If $priceHistory[$count][1] > $maxPrice Then ; If Average bigger than Current Max then
						$maxPrice = $priceHistory[$count][1] ; Max Price = Current Average
					EndIf
					If $priceHistory[$count][1] < $minPrice Then ;If Average smaller than current Min then
						$minPrice = $priceHistory[$count][1] ; Min Price = Current Average
					EndIf
					$count += 1
				EndIf
			Next
	EndSwitch

	;	_ArrayDisplay($priceHistory)
	$split = StringSplit($hFile, "\")
	$length = UBound($priceHistory) - 1
	$start = $length - $tFormat
	$plotWidths = $length - $start

	$GUI = GUICreate($split[UBound($split) - 1], 630, 600)

	;GUICtrlCreateLabel("TUNNEL SNAKES RUUUUUULE",200,10,200,-1,$SS_CENTER)
	If $tFormat < $length Then
		GUICtrlCreateLabel("Price History over " & $tFormat & " " & $timeFormat, 200, 580, 200, -1, $SS_CENTER)
	Else
		GUICtrlCreateLabel("Price History over " & $length & " " & $timeFormat, 200, 580, 200, -1, $SS_CENTER)
	EndIf

	$savePicture = GUICtrlCreateButton("Save as Image", 450, 575)
	$saveCSV = GUICtrlCreateButton("Save as CSV", 550, 575)


	;GUISetState(@SW_SHOW,$GUI)
	GUISetState(@SW_DISABLE,$parentGUI)
	GUISetState(@SW_SHOW,$GUI)

	GUICtrlCreateLabel("Price in " & $currency, 5, 280, 85, 200, 0x001)
	_GuiCtrlSetFont(-1, 15, 400, 1, -90)



	;----- Create Graph area -----
	$left = 60
	$Graph = _GraphGDIPlus_Create($GUI, $left, 10, 530, 530, 0xFF000000, 0xFFCFCFCF);0xFF88B3DD)

	If $tFormat < $length Then
		$maxPrice = 0
		$minPrice = 400


		For $a = $start To $length
			If $priceHistory[$a][1] > $maxPrice Then
				$maxPrice = $priceHistory[$a][1]
			EndIf
			If $priceHistory[$a][1] < $minPrice Then
				$minPrice = $priceHistory[$a][1]
			EndIf
		Next
		$varMin = Round($minPrice - ($maxPrice / 10), 1)
		If $varMin < 0 Then $varMin = 0
		$varMax = Round($maxPrice + ($maxPrice / 10), 1)

		;----- Set X axis range from -5 to 5 -----


		If $tFormat < 20 Then
			$xTicks = $tFormat
		Else

			$hcf = 0
			For $i = 8 To 20
				$temp = _EuklidGGT($i, $tFormat)
				If $temp > $hcf Then $hcf = $temp
				ConsoleWrite(@LF _
						 & "$i = " & $i & @LF _
						 & "highest common = " & $hcf & @LF)
			Next
			If $hcf > 6 And $hcf < 20 Then
				$xTicks = $hcf
			Else

				$xTicks = 12

			EndIf
		EndIf

		_GraphGDIPlus_Set_RangeX($Graph, $length - ($tFormat), $length, $xTicks, 1)

		$yTicks = 10

		_GraphGDIPlus_Set_RangeY($Graph, $varMin, $varMax, $yTicks, 1, 2)
	Else
		$varMin = Round($minPrice - ($maxPrice / 10), 1)
		If $varMin < 0 Then $varMin = 0
		$varMax = Round($maxPrice + ($maxPrice / 10), 1)
		$xTicks = 12
		_GraphGDIPlus_Set_RangeX($Graph, 0, $length, $xTicks, 1)

		$yTicks = 10

		_GraphGDIPlus_Set_RangeY($Graph, $varMin, $varMax, $yTicks, 1, 2)

	EndIf

	;----- Set Y axis range from -5 to 5 -----
	If $tFormat > $length Then
		_GraphGDIPlus_Set_GridX($Graph, $length / $xTicks, 0xFF6993BE)
	Else
		_GraphGDIPlus_Set_GridX($Graph, $tFormat / $xTicks, 0xFF6993BE)
	EndIf
	_GraphGDIPlus_Set_GridY($Graph, ($varMax - $varMin) / 10, 0xFF6993BE)


	;----- Draw the graph -----
	$roar = $Graph[13]
	For $s = 1 To $yTicks + 1
		GUICtrlSetPos($roar[$s], $left - 50, -1, 40)
	Next
	;----- Set line color and size -----
	_GraphGDIPlus_Set_PenColor($Graph, 0xFF325D87)
	_GraphGDIPlus_Set_PenSize($Graph, 2)
	$blah = $Graph[11]
	$graphTool = _GUIToolTip_Create(0)
	_GUIToolTip_SetMaxTipWidth($graphTool, 200)



	If $tFormat < $length Then
		$box = (530 / $tFormat) / 2
		If $box < 3 Then $box = 3
		For $s = 1 To $xTicks + 1
;~ 			$fraction = $tFormat / $xTicks
;~ 			If $recordedInHours Then
;~ 				$quickSplit = StringSplit($priceHistory[$start + (($s - 1) * $fraction)][0], " ")
;~ 				ConsoleWrite(_dayStuff($quickSplit[2]) & "-" & StringLeft($quickSplit[4],2) & @LF)
;~ 				GUICtrlSetData($blah[$s],;$quickSplit[1] &@LF &_dayStuff($quickSplit[2]) & "-" &  StringLeft($quickSplit[4],2))
;~ 			Else
;~ 				;GUICtrlSetData($blah[$s], $priceHistory[$start + (($s - 1) * $fraction)][0])
;~ 			EndIf
			GUICtrlSetData($blah[$s], GUICtrlRead($blah[$s]) - $start)

		Next

		;----- draw lines -----
		$First = True
		For $i = $start To $length
			$y = $priceHistory[$i][1]
			If $First = True Then _GraphGDIPlus_Plot_Start($Graph, $i, $y)
			$First = False
			_GraphGDIPlus_Plot_Line($Graph, $i, $y)
			_GraphGDIPlus_Set_PenColor($Graph, 0xFF02FF00)
			_GraphGDIPlus_Set_PenSize($Graph, 4)
			_GraphGDIPlus_Plot_Dot($Graph, $i, $y)
			_GraphGDIPlus_Set_PenSize($Graph, 2)
			_GraphGDIPlus_Set_PenColor($Graph, 0xFF325D87)
			_GraphGDIPlus_Refresh($Graph)
			_GUIToolTip_AddTool($graphTool, $GUI, "Average Price: " & Round($priceHistory[$i][1], 2) & @CRLF _
					 & "Date: " & $priceHistory[$i][0] & @CRLF & _
					"Volume: " & $priceHistory[$i][2] _
					, 0, $left + $Graph[18] - $box, 10 + $Graph[19] - $box, $left + $Graph[18] + $box, 10 + $Graph[19] + $box, $TTF_SUBCLASS)
		Next
	Else
		$box = 3
		;----- Set Date as Footer Ticks
;~ 		For $s = 1 To $xTicks + 1
;~ 			$fraction = (UBound($priceHistory) - 1) / $xTicks
;~ 			if $recordedInHours Then
;~ 				$quickSplit = StringSplit($priceHistory[($s - 1) * $fraction][0]," ")
;~ 			ConsoleWrite(_dayStuff($quickSplit[2]) & "-" & StringLeft($quickSplit[4],2) & @LF)
;~ 				;GUICtrlSetData($blah[$s], $quickSplit[1] &@LF &_dayStuff($quickSplit[2]) & "-" &  StringLeft($quickSplit[4],2))
;~ 			Else
;~ 			;GUICtrlSetData($blah[$s], $priceHistory[($s - 1) * $fraction][0])
;~ 			EndIf

;~ 		Next

		;Create Tooltip Area



		;----- draw lines -----
		$First = True
		For $i = 0 To $length
			$y = $priceHistory[$i][1]
			If $First = True Then _GraphGDIPlus_Plot_Start($Graph, $i, $y)
			$First = False
			_GraphGDIPlus_Plot_Line($Graph, $i, $y)
			_GraphGDIPlus_Set_PenColor($Graph, 0xFF02FF00)
			_GraphGDIPlus_Plot_Dot($Graph, $i, $y)
			_GraphGDIPlus_Set_PenColor($Graph, 0xFF325D87)
			_GraphGDIPlus_Refresh($Graph)
			_GUIToolTip_AddTool($graphTool, $GUI, "Average Price: " & Round($priceHistory[$i][1], 2) & @CRLF _
					 & "Date: " & $priceHistory[$i][0] & @CRLF & _
					"Volume: " & $priceHistory[$i][2] _
					, 0, $left + $Graph[18] - $box, 10 + $Graph[19] - $box, $left + $Graph[18] + $box, 10 + $Graph[19] + $box, $TTF_SUBCLASS)
		Next
	EndIf
	ConsoleWrite("Box: " & $box & @LF)

	ConsoleWrite("WIDTH " & $Graph[4] & @LF)
	ConsoleWrite("X low " & $Graph[6] & @LF)
	ConsoleWrite("X High " & $Graph[7] & @LF)

;~ 	$tempArray = $graph[11]
;~ 	For $i = 1 to Ubound($tempArray)-1
;~ 		GUICtrlSetState($tempArray[$i],$GUI_DISABLE)
;~ 	Next
;~ 	GUICtrlSetState($graph[1],$GUI_DISABLE)
;~ 	GUICtrlSetState($graph[16],$GUI_DISABLE)
;~ 	GUICtrlSetState($graph[20],$GUI_DISABLE)
;~ 	GUICtrlSetState($graph[21],$GUI_DISABLE)
;~ 	GUICtrlSetState($graph[22],$GUI_DISABLE)
;~ 	GUICtrlSetState($graph[23],$GUI_DISABLE)


	;                    [1] graphic control handle
	;                    [2] left
	;                    [3] top
	;                    [4] width
	;                    [5] height
	;                    [6] x low
	;                    [7] x high
	;                    [8] y low
	;                    [9] y high
	;                    [10] x ticks handles
	;                    [11] x labels handles
	;                    [12] y ticks handles
	;                    [13] y labels handles
	;					 [14] Border Color
	;					 [15] Fill Color
	;					 [16] Bitmap Handle
	;					 [17] Backbuffer Handle
	;					 [18] Last used x pos
	;					 [19] Last used y pos
	;					 [20] Pen (main) Handle
	;					 [21] Brush (fill) Handle
	;					 [22] Pen (border) Handle
	;					 [23] Pen (grid) Handle

	While 1
		$msg = GUIGetMsg($GUI)

		Switch $msg
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_ENABLE, $parentGUI)
				_GraphGDIPlus_Delete($GUI, $Graph)
				_FontCleanUp()
				GUIDelete($GUI)
				ExitLoop
			Case $savePicture
				_GraphGDIPlus_SaveImage(FileSaveDialog("Save Graph as an Image", @ScriptDir, "Image Files (*.BMP)"), $GUI) ;; Test Cancel
			Case $saveCSV
				$csvFile = FileSaveDialog("Save Graph Data as CSV",@ScriptDir,"Comma delimited files (*.CSV)")

				if $start < 0 then $start = 0
				$csvTemp = "PriceHistory Data" &@LF & "As given via " &$split[UBound($split)-1] &@LF &@LF & "Date,Average Price, Volume" &@LF
				For $i = $start to $length
					$csvTemp &= $priceHistory[$i][0]&","
					$csvTemp &= $priceHistory[$i][1]&","
					$csvTemp &= $priceHistory[$i][2]&@LF
				Next

				FileWrite($csvFile,$csvTemp)
		EndSwitch
	WEnd


EndFunc   ;==>_PriceGraph

Global $ahFontEx[1] = [0]


Func _GuiCtrlSetFont($controlID, $size, $weight = 400, $attribute = 0, $rotation = 0, $fontname = "", $quality = 2)
	Local $fdwItalic = BitAND($attribute, 1)
	Local $fdwUnderline = BitAND($attribute, 2)
	Local $fdwStrikeOut = BitAND($attribute, 4)

	ReDim $ahFontEx[UBound($ahFontEx) + 1]
	$ahFontEx[0] += 1

	$ahFontEx[$ahFontEx[0]] = _WinAPI_CreateFont($size, 0, $rotation * 10, $rotation, $weight, _
			$fdwItalic, $fdwUnderline, $fdwStrikeOut, -1, 0, 0, $quality, 0, $fontname)

	GUICtrlSendMsg($controlID, 48, $ahFontEx[$ahFontEx[0]], 1)
EndFunc   ;==>_GuiCtrlSetFont

Func _FontCleanUp()
	For $i = 1 To $ahFontEx[0]
		_WinAPI_DeleteObject($ahFontEx[$i])
	Next
EndFunc   ;==>_FontCleanUp

Func _DayStuff($string)
	$right = StringRight($string, 1)
	Switch $right
		Case 1
			$modifier = "st"
		Case 2
			$modifier = "nd"
		Case 3
			$modifier = "rd"
		Case Else
			$modifier = "th"
	EndSwitch

	Return $string & $modifier
EndFunc   ;==>_DayStuff

Func _EuklidGGT($zahl1, $zahl2) ;; Thanks to ProgAndy
	While $zahl2 <> 0
		$temp = Mod($zahl1, $zahl2)
		$zahl1 = $zahl2
		$zahl2 = $temp
	WEnd
	Return $zahl1
EndFunc   ;==>_EuklidGGT
