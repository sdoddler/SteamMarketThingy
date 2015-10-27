#include <array.au3>
#include <json.au3>
#include <inet.au3>


Func _FloatValues($webAKey, $steamID, $saveLocation, $iProgress = "")
	$localdebug = 0

	For $i = 0 to 20
	if $iProgress <> "" Then GUICtrlSetData($iProgress,$i*4.5)
	if $localdebug = 0 Then


			$hDownload = InetGet("http://api.steampowered.com/IEconItems_730/GetPlayerItems/v0001/?key="&$webAKey&"&SteamID="&$steamID, $saveLocation & "GetPlayerItems.JSON", -1, $INET_DOWNLOADBACKGROUND)
			Do
				Sleep(20)
			Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
			ConsoleWrite("GetPlayerItems URL = http://api.steampowered.com/IEconItems_730/GetPlayerItems/v0001/?key=" & $webAKey & "&SteamID=" & $steamID & @LF)

			ConsoleWrite("GetPlayerItems - Download Complete" & @LF)
	EndIf

			$file = FileRead($saveLocation & "GetPlayerItems.JSON")
			FileDelete($saveLocation & "GetPlayerItems.JSON")
			Local $Obj = JSON_Decode($file)

			if Json_IsObject($obj) Then
				ExitLoop
			Else
				ConsoleWrite("Failed to Download" &@LF)
			EndIf
	Next
			if Not(Json_IsObject($obj)) Then
				Dim $playerItems[1][1]
				$playerItems[0][0] ="Error"
				Return $playerItems
			EndIf


			$result = Json_ObjGet($obj,"result")
			$status = Json_ObjGet($result,"status")

			ConsoleWrite(@LF&"Status = " & $status & @LF)
			$floatCount = -1
			If $status Then
				$items = Json_ObjGet($result,"items")
				if IsArray($items) Then
					;_ArrayDisplay($items)
					Dim $playerItems[Ubound($items)][2]
					For $k = 0 to Ubound($items)-1
						if $iProgress <> "" Then GUICtrlSetData($iProgress,$k*4.5)
						$itemID = Json_ObjGet($items[$k],"id")
						$attributes = Json_ObjGet($items[$k],"attributes")
							;_ArrayDisplay($attributes)
							For $l = 0 to Ubound($attributes)-1
								if Json_ObjGet($attributes[$l],"defindex") = 8 Then
									$floatValue = Json_ObjGet($attributes[$l],"float_value")
								;;	ConsoleWrite("Has Float value: " & $floatValue)
									$floatCount +=1
									$playerItems[$floatCount][0] = $itemID
									$playerItems[$floatCount][1] = $floatValue


								Endif
							Next
					Next
				EndIf
				if $iProgress <> "" Then GUICtrlSetData($iProgress,0)
			Elseif $status = 8 Then
				ConsoleWrite("Error Downloading Item\Float Values" &@LF)
			EndIf
		if $iProgress <> "" Then GUICtrlSetData($iProgress,0)

		If $floatCount = -1 Then
			Dim $playerItems[1][1]
				$playerItems[0][0] ="Error"
				Return $playerItems
		Else
				;_ArrayDisplay($playerItems)
			ReDim $playerItems[$floatCount+1][2]
		;_ArrayDisplay($playerItems)
			Return $playerItems
		EndIf

EndFunc

;