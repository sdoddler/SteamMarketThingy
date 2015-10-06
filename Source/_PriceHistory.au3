#include <JSON.au3>
#include <array.au3>
#include <GraphGDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <WINAPI.Au3>



;$test = FileRead("p90dotcom.json")
;$days = 10000

;_PriceGraph($test, 10)

Func _PriceGraph($hFile, $days, $parentGUI)
$read = FileRead($hFile)

$obj = JSON_Decode($read)

If NOT(Json_IsObject($Obj)) Then
	MsgBox(48,"JSON Read Issue","There was a problem reading the selected JSON file: " &@LF & _
	$hFile & @LF &@LF& _
	"This does not seem to be a normal JSON file")
	Return 1
EndIf

$abc = JSON_ObjGet($obj, "prices")


If NOT($abc <> "") Then
	MsgBox(48,"JSON Read Issue","There was a problem reading the selected JSON file: " &@LF & _
	$hFile&@LF&@LF & _
	"This JSON contains no price data")
	Return 1
EndIf

GUISetState(@SW_DISABLE, $parentGUI) ;; After Error Checking the JSON - Disable Main GUI


$currency = JSON_ObjGet($obj,"price_prefix")
;$currency = "$"

;; WORKING!!
ConsoleWrite(Json_Get($abc[0],"[0]")&@lf&Json_Get($abc[0],"[1]")&@lf&Json_Get($abc[0],"[2]")&@lf) ;; WORKING!!
;; WORKING!!

Local $priceHistory[0][3], $maxPrice = 0, $priceCount[1][3], $count=-1, $lastDate, $hours=1, $minPrice = 400
For $i = 0 to Ubound($abc)-1
	;ConsoleWrite(StringLeft(Json_get($abc[$i],"[0]"),6) &@LF)
	if $lastDate <> StringLeft(Json_get($abc[$i],"[0]"),6) Then
		if $hours > 1 Then
			$priceHistory[$count][1] = $priceHistory[$count][1]/$hours
		EndIf
	$count +=1
	ReDim $priceHistory[$count+1][3]
	$priceHistory[$count][0] = Json_get($abc[$i],"[0]")
	$lastDate = StringLeft(Json_get($abc[$i],"[0]"),6)
	$priceHistory[$count][1] = Json_get($abc[$i],"[1]")
	if $priceHistory[$count][1] > $maxPrice Then
		$maxPrice = $priceHistory[$count][1]
	Endif
	if $priceHistory[$count][1] < $minPrice Then
		$minPrice = $priceHistory[$count][1]
	Endif
	$priceHistory[$count][2] = Json_get($abc[$i],"[2]")
	$hours = 1
	Else
	$hours += 1
	$priceHistory[$count][1] += Json_get($abc[$i],"[1]")


	if Json_get($abc[$i],"[1]") > $maxPrice Then
		$maxPrice = Json_get($abc[$i],"[1]")
	Endif
	if Json_get($abc[$i],"[1]") < $minPrice Then
		$minPrice = Json_get($abc[$i],"[1]")
	Endif
	$priceHistory[$count][2] += Json_get($abc[$i],"[2]")
	Endif
Next
if $hours > 1 Then
			$priceHistory[$count][1] = $priceHistory[$count][1]/$hours
EndIf

;	_ArrayDisplay($priceHistory)
$split = StringSplit($hFile,"\")
$length = Ubound($priceHistory)-1
$start = $length - $days

$GUI = GUICreate($split[Ubound($split)-1],630,600)

;GUICtrlCreateLabel("TUNNEL SNAKES RUUUUUULE",200,10,200,-1,$SS_CENTER)
If $days < $length Then
GUICtrlCreateLabel("Price History over " & $days &" Days",200,580,200,-1,$SS_CENTER)
Else
GUICtrlCreateLabel("Price History over " & $length &" Days",200,580,200,-1,$SS_CENTER)
EndIf


GUISetState()

GUICtrlCreateLabel("Price in " & $currency, 5, 280,85, 200,0x001)
_GuiCtrlSetFont(-1, 15, 400, 1, -90)



;----- Create Graph area -----
$left = 70
$Graph = _GraphGDIPlus_Create($GUI,$left,20,530,530,0xFF000000,0xFFCFCFCF);0xFF88B3DD)

If $days < $length Then
$maxPrice = 0
$minPrice = 400

For $a = $start to $length
	if $pricehistory[$a][1] > $maxPrice Then
	 $maxPrice = $pricehistory[$a][1]
	EndIf
	if $pricehistory[$a][1] < $minPrice Then
	 $minPrice = $pricehistory[$a][1]
	EndIf
Next
$varMin = Round($minPrice-($maxPrice/10),1)
If $varMin < 0 Then $varmin = 0
$varMax = Round($maxPrice+($maxPrice/10),1)

;----- Set X axis range from -5 to 5 -----
$xTicks = 10
_GraphGDIPlus_Set_RangeX($Graph,$length-($days),$length,$xTicks,1,1)
$yTicks = 10

_GraphGDIPlus_Set_RangeY($Graph,$varMin,$varMax,$yTicks,1,2)
Else
$varMin = Round($minPrice-($maxPrice/10),1)
If $varMin < 0 Then $varmin = 0
$varMax = Round($maxPrice+($maxPrice/10),1)
	$xTicks = 10
_GraphGDIPlus_Set_RangeX($Graph,0,$length,$xTicks,1,1)
$yTicks = 10

_GraphGDIPlus_Set_RangeY($Graph,$varMin,$varMax,$yTicks,1,2)

Endif

;----- Set Y axis range from -5 to 5 -----
If $days > $length Then
_GraphGDIPlus_Set_GridX($Graph,$length/10,0xFF6993BE)
Else
_GraphGDIPlus_Set_GridX($Graph,$days/10,0xFF6993BE)
EndIf
_GraphGDIPlus_Set_GridY($Graph,($varMax-$varMin)/10,0xFF6993BE)


;----- Draw the graph -----
$roar = $Graph[13]
	For $s = 1 to $yTicks+1
		GUICtrlSetPos($roar[$s],$left-50,-1,40)
	Next
;----- Set line color and size -----
    _GraphGDIPlus_Set_PenColor($Graph,0xFF325D87)
    _GraphGDIPlus_Set_PenSize($Graph,2)
	$blah = $Graph[11]
	if $days < $length Then
	For $s = 1 to $xTicks+1
		$fraction = $days/$xTicks
		GUICtrlSetData($blah[$s],$priceHistory[$start+(($s-1)*$fraction)][0])
	Next

    ;----- draw lines -----
    $First = True
    For $i = $start to $length
        $y = $priceHistory[$i][1]
        If $First = True Then _GraphGDIPlus_Plot_Start($Graph,$i,$y)
		$First = False
		_GraphGDIPlus_Plot_Line($Graph,$i,$y)
        _GraphGDIPlus_Refresh($Graph)

	Next
	Else

	;----- Set Date as Footer Ticks
	For $s = 1 to $xTicks+1
		$fraction = (Ubound($priceHistory)-1)/$xTicks
		GUICtrlSetData($blah[$s],$priceHistory[($s-1)*$fraction][0])
	Next

    ;----- draw lines -----
    $First = True
    For $i = 0 to $length
        $y = $priceHistory[$i][1]
        If $First = True Then _GraphGDIPlus_Plot_Start($Graph,$i,$y)
		$First = False
		_GraphGDIPlus_Plot_Line($Graph,$i,$y)
        _GraphGDIPlus_Refresh($Graph)

	Next
	Endif

;_ArrayDisplay($Graph[11])

While 1
	$msg = GUIGetMSg()

	Switch $msg
		Case $GUI_EVENT_CLOSE
			GUISetState(@SW_ENABLE, $parentGUI)
			_GraphGDIPlus_Delete($GUI,$Graph)
			_FontCleanUp()
			GUIDelete($gui)
			ExitLoop
	EndSwitch
WEnd


EndFunc

Global $ahFontEx[1] = [0]

Func _GuiCtrlSetFont($controlID, $size, $weight = 400, $attribute = 0, $rotation = 0, $fontname= "", $quality = 2)
    Local $fdwItalic = BitAND($attribute, 1)
    Local $fdwUnderline = BitAND($attribute, 2)
    Local $fdwStrikeOut = BitAND($attribute, 4)

    ReDim $ahFontEx[UBound($ahFontEx) + 1]
    $ahFontEx[0] += 1

    $ahFontEx[$ahFontEx[0]] = _WinAPI_CreateFont($size, 0, $rotation * 10, $rotation, $weight, _
                            $fdwItalic, $fdwUnderline, $fdwStrikeOut, -1, 0, 0, $quality, 0, $fontname)

    GUICtrlSendMsg($controlID, 48, $ahFontEx[$ahFontEx[0]], 1)
EndFunc

Func _FontCleanUp()
    For $i = 1 To $ahFontEx[0]
        _WinAPI_DeleteObject($ahFontEx[$i])
    Next
EndFunc

