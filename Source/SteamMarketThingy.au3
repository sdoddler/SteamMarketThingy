#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Main.ico
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Inet.au3>
#include <JSON.au3>
#include <array.au3>
#include <string.au3>
#include <Date.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Editconstants.au3>
#include <GDIPlus.au3>
#include <WinAPIEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiMenu.au3>
#include <ProgressConstants.au3>
#include "_PriceHistory.au3"
#include <GUIHyperlink.au3>
#include <IniEx.au3>

;Check Link execute function.. (after hours)


;; ---- TO DO LIST
; Need to add additional Games and Test
;
;;  ----

$appDir = EnvGet("APPDATA") & "\SteamMarketThingy\"
DirCreate($appDir)
$appDirJSON = $appDir&"\JSON\"
DirCreate($appDirJSON)
$appDirIcons = $appDir&"Icons\"
DirCreate($appDirIcons)
DirCreate(@ScriptDir & "\IniFiles\")

FileInstall("C:\Work\Projects\Scripts\Steam\Steam_Icon.ico", $appDir & "Steam_Icon.ico", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Twitter_Icon.ico", $appDir & "Twitter_Icon.ico", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Youtube_icon.ico", $appDir & "Youtube_icon.ico", 1)
;FileInstall("C:\Work\Projects\Scripts\Steam\Main.ico", $appDir & "Main.ico", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Splash1.jpg", $appDir & "Splash1.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\No_Image.png", $appDirIcons & "No_Image.png", 1)


$tFade = 2500

$Fade = 0x80000

$hSplash = GUICreate("", 500, 300, -1, -1, BitOR($WS_DLGFRAME, $WS_POPUP))

GUICtrlCreatePic($appDir&"Splash1.jpg",0,0,500,300)
GUISetFont(12)
$splashLabel = GUICtrlCreateLabel("",5,270,200,30)
GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT)

DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hSplash, "int", $tFade, "long", $Fade)

$Fade = 0x90000

;$hDownload = _INetGetSource("http://steamcommunity.com/market/priceoverview/?currency=1&appid=730&market_hash_name=StatTrak%E2%84%A2%20P250%20%7C%20Steel%20Disruption%20%28Factory%20New%29", True)
;$appID = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "AppID", "730,440,570,753");,310560";; CHANGIN THIS TO 753 for Trading Cards
;$inventoryType = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "InventoryID", "2,2,2,6") ;;753 above & 6 for Trading Cards
$userID = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserID", "sDoddler")
$searchID = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "SearchType", "All Apps")
Switch $searchID
				Case "All Apps"
					$appID = "730,440,570,753"
					$inventoryType =  "2,2,2,6"
				Case "CSGO"
					$appID = "730"
					$inventoryType = "2"
				Case "TF2"
					$appID= "440"
					$inventoryType = "2"
				Case "Dota 2"
					$appID = "570"
					$inventoryType = "2"
				Case "Trading Cards & Emotes"
					$appID = "753"
					$inventoryType = "6"
				Case Else
					$appID = "730,440,570,753"
					$inventoryType =  "2,2,2,6"
EndSwitch
$displayLocal = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "DisplayLocal", True)
If $displayLocal = "True" Then
	$displayLocal = True
Else
	$displayLocal = False
EndIf
$marketableOnly = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "MarketableOnly", False)
If $marketableOnly = "True" Then
	$marketableOnly = True
Else
	$marketableOnly = False
EndIf
$tradeOnly = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "TradeFilter", False)
If $tradeOnly = "True" Then
	$tradeOnly= True
Else
	$tradeOnly= False
EndIf

$debug = 0
Global Enum $idproc1 = 1000, $idproc2, $idproc3,$idProc4
Global $webAPIKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
Global $listItems[0]

$hGUI = GUICreate("sDoddler's Steam Market Thingy", 1000, 530, -1, -1, $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX + $WS_SIZEBOX)


GUISetFont(12)
$gcApp = GUICtrlCreateCombo("", 10, 10, 150)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetData(-1, "All Apps|CSGO|TF2|Dota 2|Trading Cards & Emotes", $searchID)
GUICtrlSetTip(-1, "Pick which Game(s) you want to update" & @LF & "Will add more in future")

GUISetFont(8.5)
GUICtrlCreateLabel("User ID: ", 180, 13,50)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
$gUserID = GUICtrlCreateInput($userID, 235, 10, 60, -1, BitOR($ES_AUTOHSCROLL, $ES_RIGHT))
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Found at: steamcommunity.com/id/<UserID> " & @LF & "OR: steamcommunity.com/profiles/<UserID>", "User ID")

GUICtrlCreateLabel("App ID: ", 550, 13)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
$gAppID = GUICtrlCreateInput($appID, 600, 10, 55, -1, BitOR($ES_AUTOHSCROLL, $ES_RIGHT, $ES_READONLY))
GUICtrlSetResizing(-1,$GUI_DOCKALL)

GUICtrlCreateLabel("Inv Type: ", 670, 13)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
$gItype = GUICtrlCreateInput($inventoryType, 720, 10, 55, -1, BitOR($ES_NUMBER, $ES_RIGHT, $ES_READONLY))
GUICtrlSetResizing(-1,$GUI_DOCKALL)

$gGUIGrabData = GUICtrlCreateButton("Update selected Inventory(s)", 10, 42, -1, 24)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Updates the Selected Game Inventory(s) from web data", "Update Selected")



$gCheckLocal = GUICtrlCreateCheckbox("Display Local inventory with Updated", 180, 45)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
If $displayLocal = True Then
	GUICtrlSetState(-1,$GUI_CHECKED)
Else
	GUICtrlSetState(-1,$GUI_UNCHECKED)
Endif

$gCheckFilter = GUICtrlCreateCheckbox("Show Marketables Only", 385, 45)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1,"Use for sorting, else other stuff gets in the way")
If $marketableOnly = True Then
	GUICtrlSetState(-1,$GUI_CHECKED)
Else
	GUICtrlSetState(-1,$GUI_UNCHECKED)
Endif

$gCheckTrade = GUICtrlCreateCheckbox("Show Tradeables Only", 520, 45)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1,"Use for sorting, else other stuff gets in the way")
If $tradeOnly = True Then
	GUICtrlSetState(-1,$GUI_CHECKED)
Else
	GUICtrlSetState(-1,$GUI_UNCHECKED)
Endif

$progress = GUICtrlCreateProgress(670, 40, 170, 27)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "GRATS YOU HOVERED ON THE PROGRESS BAR WOOOOOOO")

$readIni = GUICtrlCreateButton("Read Local Selected", 310, 8)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Based off the User ID field", "Read Local Inventory")


$readAll = GUICtrlCreateButton("Read Local All Apps", 425, 8)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Based off the User ID field", "Read Local Inventory")

$seperator = GUICtrlCreateGraphic(850, 0, 10, 40)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetGraphic($seperator, $GUI_GR_MOVE, 0, 5)
GUICtrlSetGraphic($seperator, $GUI_GR_COLOR, 0x939696)
GUICtrlSetGraphic($seperator, $GUI_GR_LINE, 0, 65)

GUICtrlCreateLabel("Days", 860, 13)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
$gDays = GUICtrlCreateInput("30", 910, 10, -1, -1, $ES_NUMBER)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetData(-1, IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "Days", "30"))
GUICtrlSetTip(-1, "Days to Graph in Price History")

$gPriceHistory = GUICtrlCreateButton("Load PriceHistory.JSON", 860, 40)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Load a PriceHistory.JSON from file")

$gItemLabel = GUICtrlCreateLabel("Items Displayed: ",10,480)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
$gItemsDisplayed = GUICtrlCreateLabel(0,100,480,200)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)

GUICtrlCreateLabel("Sell all at Lowest prices: ",150,480)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
$gItemsLowestSell = GUICtrlCreateLabel(0,280,480,200)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)

GUICtrlCreateLabel("Links: ", 700,480)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)

$gMarket = _GUICtrlHyperLink_Create("Steam Market", 740, 480, -1, 15, 0x0000FF, 0x551A8B, _
    -1, 'https://steamcommunity.com/market', "Straight to the Steam Community Marketplace", $hGUI)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)

$gDonate = _GUICtrlHyperLink_Create("Donate", 810, 480, -1, 15, 0x0000FF, 0x551A8B, _
    -1, 'https://steamcommunity.com/tradeoffer/new/?partner=32466175&token=CKdP6-B2', "You don't need to give me real money, "&@LF&"shoot me a sweet skin if you like the program", $hGUI)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)

;GUICtrlCreateLabel("sDoddler's Profiles: ", 770,480)

$gSteamIcon = GUICtrlCreateIcon($appdir & "Steam_Icon.Ico",-1,870,470,32,32)
GUICtrlSetTip($gSteamIcon," ","sDoddler's Steam Profile")
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
$gTwitterIcon = GUICtrlCreateIcon($appdir & "Twitter_Icon.Ico",-1,910,470,32,32)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)
GUICtrlSetTip($gTwitterIcon," ","sDoddler's Twitter Page")
$gYoutubeIcon = GUICtrlCreateIcon($appdir & "Youtube_Icon.Ico",-1,950,470,32,32)
GUICtrlSetTip($gYoutubeIcon," ","sDoddler's YouTube Channel")
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKRIGHT+$GUI_DOCKSIZE)


_GDIPlus_Startup()

If FileExists(@ScriptDir & "\IniFiles\" & $userID & "-Inventory.ini") Then
GUICtrlSetData($splashLabel,"Reading Local Inventory..")
EndIf
$theInventory = InventoryIniRead($userID)
Local $iStylesEx = BitOR($LVS_EX_GRIDLINES, $LVS_EX_FULLROWSELECT, $LVS_EX_SUBITEMIMAGES, $LVS_EX_CHECKBOXES)
$idListview = GUICtrlCreateListView("", 10, 70, 980, 390, BitOR($LVS_SHOWSELALWAYS, $LVS_REPORT))
GUICtrlSetResizing(-1,$GUI_DOCKLEFT+$GUI_DOCKTOP+$GUI_DOCKBOTTOM)
_GUICtrlListView_SetExtendedListViewStyle($idListview, $iStylesEx)

;[0]		[1]			[2]					[3]			[4]				[5]		[6]			[7]
;Item Name	Hash Name	Ini Json String		Icon URL	Local IconPath	AppID	Marketable	Tradable

;[8]		[9]			[10]	[11]		[12]			[13]			[14]		[15]					[16]			[17]
;Amount		CacheExp	Type	NameClr		$lowestPrice	$medianPrice	Volume		Inspect in Game Link	I bought for?	BoughtFor*1.15
_GUICtrlListView_AddColumn($idListview, "Item", 200)
_GUICtrlListView_AddColumn($idListview, "Lowest Price", 80)
_GUICtrlListView_AddColumn($idListview, "Median Price", 50)
_GUICtrlListView_AddColumn($idListview, "Volume", 50)
_GUICtrlListView_AddColumn($idListview, "Amount", 50)
_GUICtrlListView_AddColumn($idListview, "Tradeable", 50)
_GUICtrlListView_AddColumn($idListview, "Purchase Price", 100)
_GUICtrlListView_AddColumn($idListview, "Lowest Resell", 100)
_GUICtrlListView_AddColumn($idListview, "Type", 190)
_GUICtrlListView_AddColumn($idListview, "App ID", 30)
_GUICtrlListView_AddColumn($idListview, "Cache Exp", 50)
_GUICtrlListView_AddColumn($idListview, "Link", 200)

; The are dummy controls that will be actioned by the applications message handler based on the message id associated with the popup (RIGHT CLICK) menu.
; E.G. $dummy_proc1 will be actioned by application message $idproc1 from message handler WM_COMMAND.
Local $dummy_proc1 = GUICtrlCreateDummy()
Local $dummy_proc2 = GUICtrlCreateDummy()
Local $dummy_proc3 = GUICtrlCreateDummy()
Local $dummy_proc4 = GUICtrlCreateDummy()

; Set in the notification message handler (WM_NOTIFY) to get the item number of the listview item clicked on.
Local $iItem = 0

; Popup menu...each item is associated with an application defined message ($idproc1 and $idproc2).
Local $hMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($hMenu, 0, "View Image\Art", $idproc4)
_GUICtrlMenu_InsertMenuItem($hMenu, 1, "View item Wiki\Inspect In-game", $idproc1)
_GUICtrlMenu_InsertMenuItem($hMenu, 2, "I bought this for", $idproc3)



Local $marketMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($marketMenu, 0, "View Image\Art", $idproc4)
_GUICtrlMenu_InsertMenuItem($marketMenu, 1, "View item Wiki\Inspect In-game", $idproc1)
_GUICtrlMenu_InsertMenuItem($marketMenu, 2, "I bought this for", $idproc3)
_GUICtrlMenu_InsertMenuItem($marketMenu, 3, "Save Price History (requires Steam Login on def. browser)", $idproc2)


Local $BSIDEMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($BSIDEMenu, 0, "View Image\Art", $idproc4)
_GUICtrlMenu_InsertMenuItem($BSIDEMenu, 1, "View item Wiki\Inspect In-game", $idproc1)

DestroyListView($idListview, $theInventory)

$Fade = 2000
DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hSplash, "int", $tFade, "long", $Fade)

GUISetState()
GUIDelete($hSplash)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

_GUICtrlListView_RegisterSortCallBack($idListview)

While 1

	$msg = GUIGetMsg()

	Switch $msg
		Case $GUI_EVENT_CLOSE
			ExitLoop

		Case $gSteamIcon
			ShellExecute('https://steamcommunity.com/id/sdoddler')
		Case $gTwitterIcon
			ShellExecute('https://twitter.com/sdoddler')
		Case $gYoutubeIcon
			ShellExecute('https://youtube.com/user/doddddy')
		Case $readIni
			$userID = GUICtrlRead($gUserID)
			ConsoleWrite(GUICtrlread($gAppID))
			$theInventory = InventoryIniRead($userID,GUICtrlread($gAppID))
			DestroyListView($idListview, $theInventory)
		Case $readAll
			$userID = GUICtrlRead($gUserID)
			$theInventory = InventoryIniRead($userID)
			DestroyListView($idListview, $theInventory)

		Case $idListview
			; Kick off the sort callback
			_GUICtrlListView_SortItems($idListview, GUICtrlGetState($idListview))
		Case $gcApp
			$whatUpdate = GUICtrlRead($gcApp)
			Switch $whatUpdate ;"Update All Apps|Update CSGO|Update TF2|Update Dota 2|Update Steam Community","Update All Apps")
				Case "All Apps"
					GUICtrlSetData($gAppID, "730,440,570,753")
					GUICtrlSetData($gItype, "2,2,2,6")

				Case "CSGO"
					GUICtrlSetData($gAppID, "730")
					GUICtrlSetData($gItype, "2")

				Case "TF2"
					GUICtrlSetData($gAppID, "440")
					GUICtrlSetData($gItype, "2")
				Case "Dota 2"
					GUICtrlSetData($gAppID, "570")
					GUICtrlSetData($gItype, "2")
				Case "Trading Cards & Emotes"
					GUICtrlSetData($gAppID, "753")
					GUICtrlSetData($gItype, "6")
			EndSwitch
		Case $gCheckFilter

			If GUICtrlRead($gCheckFilter) = $GUI_CHECKED Then
				$marketableOnly = True
			Else
				$marketableOnly = False
			EndIf
		Case $gCheckTrade

			If GUICtrlRead($gCheckTrade) = $GUI_CHECKED Then
				$tradeOnly = True
			Else
				$tradeOnly = False
			EndIf
		Case $gCheckLocal
			If GUICtrlRead($gCheckLocal) = $GUI_CHECKED Then
				$displayLocal = True
			Else
				$displayLocal = False
			EndIf
		Case $gGUIGrabData
			_GUICtrlSetState($GUI_DISABLE)
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserID", GUICtrlRead($gUserID))
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "SearchType", GUICtrlRead($gcApp))
			If GUICtrlRead($gCheckLocal) = $GUI_CHECKED Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "DisplayLocal", True)
			Else
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "DisplayLocal", False)
			Endif
			If GUICtrlRead($gCheckFilter) = $GUI_CHECKED Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "MarketableOnly",True)
			Else
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "MarketableOnly", False)
			Endif
			$userID = GUICtrlRead($gUserID)
			$appID = GUICtrlRead($gAppID)
			$inventoryType = GUICtrlRead($gItype)

			$theInventory = InventoryItemFind($appID, $inventoryType, $userID)

			If $theInventory[0][0] = "Error" Then
				MsgBox(0, "", $theInventory[0][0] & ": " & $theInventory[1][0])
			ElseIf UBound($theInventory) > 1 Then
				$appSplit = StringSplit(GUICtrlRead($gAppID), ",")
				For $i = 1 To $appSplit[0]
					IniDelete(@ScriptDir & "\IniFiles\" & $userID &"-"& $appSplit[$i]&  "-Inventory.ini", $appSplit[$i])
				Next
				InventoryWrite($theInventory, $userID)
				If $displayLocal Then
					$theInventory = InventoryIniRead($userID)
				Else
					$theInventory = InventoryIniRead($userID, $appID)
				EndIf
				DestroyListView($idListview, $theInventory)


			EndIf

			_GUICtrlSetState($GUI_ENABLE)
		Case $dummy_proc2
			;http://steamcommunity.com/market/pricehistory/?appid=730&market_hash_name=P90%20%7C%20Asiimov%20%28Factory%20New%29
			ConsoleWrite('You have choosen to run Procedure #1 on ' & _GUICtrlListView_GetItemText($idListview, $iItem) & @CRLF)
				;$hDownload = InetGet("http://steamcommunity.com/market/pricehistory/?appid=" & $theInventory[$listItems[$iItem]][5] & "&market_hash_name=" & $theInventory[$listItems[$iItem]][1], "test.json", -1, $INET_DOWNLOADBACKGROUND)
				$marketHash = _URIEncode(_GUICtrlListView_GetItemText($idListview, $iItem))
				ConsoleWrite("http://steamcommunity.com/market/pricehistory/?appid=" & _GUICtrlListView_GetItemText($idListview,$iItem,9) & "&market_hash_name=" & $marketHash)
				ShellExecute("http://steamcommunity.com/market/pricehistory/?appid=" & _GUICtrlListView_GetItemText($idListview,$iItem,9) & "&market_hash_name=" & $marketHash)
		Case $dummy_proc1

			If _GUICtrlListView_GetItemText($idListview,$iItem,11) <> "" Then
				ShellExecute(_GUICtrlListView_GetItemText($idListview,$iItem,11))
			Else
				MsgBox(0,"","This Item has no Link Assosciated with it")
			EndIf
			ConsoleWrite('You have choosen to run Procedure #2 on ' & _GUICtrlListView_GetItemText($idListview, $iItem) & @CRLF & _GUICtrlListView_GetItemText($idListview,$iItem,9))
		Case $dummy_proc3
			;	$iBought = ""
			$iBought = _iBoughtForGUI(_GUICtrlListView_GetItemText($idListview, $iItem))
			ConsoleWrite($iBought & @LF)
			If $iBought <> "" Then
				If StringInStr($iBought, "Keys") Then
					$iBoughtFor = $iBought
					$iSellFor = $iBought
				Else
					$iBoughtFor = Round($iBought, 2)
					$iSellFor = Round($iBought * 1.15, 2)
				EndIf
				IniWrite(@ScriptDir & "\IniFiles\" & $userID & "-Inventory.ini", "iBought", _GUICtrlListView_GetItemText($idListview, $iItem), $iBoughtFor)

				_GUICtrlListView_AddSubItem($idListview, $iItem, $iBoughtFor, 6)
				_GUICtrlListView_AddSubItem($idListview, $iItem, $iSellFor, 7)
			EndIf
		Case $dummy_proc4
			$imageArt = $appDirIcons & _URIEncode(_GUICtrlListView_GetItemText($idListview, $iItem)) & ".png"
			ConsoleWrite($imageArt&@LF)
			If FileExists($imageArt) Then
			ShellExecute($imageArt)
			Else
			MsgBox(48,"No Image Found","No Image found for "& _GUICtrlListView_GetItemText($idListview, $iItem))
			EndIf
		Case $gPriceHistory
			ConsoleWrite(GUICtrlRead($gDays) & @LF)
			$priceHistoryJSON = FileOpenDialog("Choose a PriceHistory.Json", @ScriptDir & "\", "Json Files (*.json)")
			If $priceHistoryJSON = "" Then
				ConsoleWrite("No file Selected")
			Else
				IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "Days", GUICtrlRead($gDays))
				_PriceGraph($priceHistoryJSON, GUICtrlRead($gDays), $hGUI)
			EndIf

	EndSwitch

	Sleep(20)
WEnd
_GDIPlus_Shutdown()

Func _iBoughtForGUI($bItem)
	Local $iCurrent = 1
	GUISetState(@SW_DISABLE, $hGUI)
	$guiBought = GUICreate("iBought", 300, 100)
	GUISetFont(10, 700)
	GUICtrlCreateLabel($bItem, 10, 10)
	GUISetFont(8.5, 400)

	GUICtrlCreateLabel("I bought this for:", 10, 40)
	$inputBought = GUICtrlCreateInput(StringFormat("%#.2f", $iCurrent), 90, 35, 45, -1, -1)

	GUICtrlCreateLabel("Seller Received:", 145, 40)
	$percentOff = GUICtrlCreateInput(Round($iCurrent * 0.85, 2), 240, 35, 45)

	GUICtrlCreateLabel("Sell for more than:", 10, 70)
	$breakEven = GUICtrlCreateInput(Round($iCurrent * 1.15, 2), 90, 65, 45)

	$checkKeys = GUICtrlCreateCheckbox("Bought With Keys", 145, 65)
	$keysState = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "BoughtInKeys", "No")
	If $keysState = "Yes" Then
		GUICtrlSetState($checkKeys, $GUI_CHECKED)
		GUICtrlSetState($breakEven, $GUI_HIDE)
		GUICtrlSetState($percentOff, $GUI_HIDE)
	Else
		GUICtrlSetState($checkKeys, $GUI_UNCHECKED)
		GUICtrlSetState($breakEven, $GUI_SHOW)
		GUICtrlSetState($percentOff, $GUI_SHOW)
	EndIf

	$btn = GUICtrlCreateButton("Save", 250, 70)

	GUISetState()
	While 1

		Switch GUIGetMsg($guiBought)
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_ENABLE, $hGUI)
				GUIDelete($guiBought)
				Return ""
			Case $checkKeys
				If GUICtrlRead($checkKeys) = $GUI_CHECKED Then
					ConsoleWrite("Bought With keys" & @LF)
					GUICtrlSetState($breakEven, $GUI_HIDE)
					GUICtrlSetState($percentOff, $GUI_HIDE)
				Else
					ConsoleWrite("Bought with Dolla dolla" & @LF)
					GUICtrlSetState($breakEven, $GUI_SHOW)
					GUICtrlSetState($percentOff, $GUI_SHOW)
				EndIf


			Case $inputBought
				;GUICtrlSetData($percentOff,Round(Guictrlread($inputBought)*0.85,2))
			Case $btn
				$boughtFor = GUICtrlRead($inputBought)
				;ConsoleWrite("Input should read: " & $boughtFor &@LF & "String is Float: " & StringIsFloat($boughtFor));StringFormat("%.02f",Round(GUICtrlRead($inputBought),2)))
				If StringIsFloat($boughtFor) Then
					ConsoleWrite("Is Float " & @LF)
					If GUICtrlRead($checkKeys) = $GUI_CHECKED Then
						IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "BoughtInKeys", "Yes")
						$boughtFor &= " Keys"
					Else
						IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "BoughtInKeys", "No")
					EndIf
					GUISetState(@SW_ENABLE, $hGUI)
					GUIDelete($guiBought)
					Return $boughtFor
				ElseIf StringIsInt($boughtFor) Then
					ConsoleWrite("Is Int " & @LF)
					If GUICtrlRead($checkKeys) = $GUI_CHECKED Then
						IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "BoughtInKeys", "Yes")
						$boughtFor &= " Keys"
					Else
						IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "BoughtInKeys", "No")
					EndIf
					GUISetState(@SW_ENABLE, $hGUI)
					GUIDelete($guiBought)
					Return $boughtFor
				Else
					$iChoice = MsgBox(1, "This is not a number", "The Value given is not a number" & @LF _
							 & "Please try again or Cancel to close")
					If $iChoice = 2 Then
						GUISetState(@SW_ENABLE, $hGUI)
						GUIDelete($guiBought)
						Return ""
					EndIf
					ConsoleWrite("Is not Number " & @LF)
				EndIf
		EndSwitch
		If GUICtrlRead($inputBought) <> $iCurrent Then
			$iCurrent = GUICtrlRead($inputBought)
			If StringIsFloat($iCurrent) Then
				GUICtrlSetData($percentOff, Round(GUICtrlRead($inputBought) * 0.85, 2))
				GUICtrlSetData($breakEven, Round(GUICtrlRead($inputBought) * 1.15, 2))
			ElseIf StringIsInt($iCurrent) Then
				GUICtrlSetData($percentOff, Round(GUICtrlRead($inputBought) * 0.85, 2))
				GUICtrlSetData($breakEven, Round(GUICtrlRead($inputBought) * 1.15, 2))
			Else

			EndIf
		EndIf
	WEnd
EndFunc   ;==>_iBoughtForGUI

Func _GUICtrlSetState($state)
	GUICtrlSetState($idListview, $state)
	GUICtrlSetState($readIni, $state)
	GUICtrlSetState($gGUIGrabData, $state)
	GUICtrlSetState($gAppID, $state)
	GUICtrlSetState($gUserID, $state)
	GUICtrlSetState($gItype, $state)
	GUICtrlSetState($gcApp, $state)
	GUICtrlSETSTATE($gCheckFilter, $state)
	GUICtrlSetState($gCheckLocal,$state)
	GUICtrlSetState($gDays, $state)
	GUICtrlSetState($gPriceHistory, $state)
	GUICtrlSetState($gCheckTrade, $state)
	GUICtrlSetState($readAll, $state)

EndFunc   ;==>_GUICtrlSetState

Func InventoryIniRead($iniUID, $readApps = "730,440,570,753")
	Local $localInventory[1][18], $iTemp, $int = 0, $rIni = @ScriptDir & "\IniFiles\" & $iniUID & "-Inventory.ini"

	;$rSecNames = _IniReadSectionNamesEx($rIni)
	$rSecNames = StringSplit($readApps,",")
	If $debug Then
		_ArrayDisplay($rSecNames)
	EndIf

		For $i = 1 To $rSecNames[0]
			ConsoleWrite($rSecNames[$i] & @LF)
			If FileExists(@ScriptDir & "\IniFiles\" & $iniUID & "-"&$rSecNames[$i]&"-Inventory.ini") Then
				$iTemp = _IniReadSectionEx(@ScriptDir & "\IniFiles\" & $iniUID & "-"&$rSecNames[$i]&"-Inventory.ini", $rSecNames[$i])
			;	_ArrayDisplay($iTemp)
				$iTemp[0][1] = $rSecNames[$i]
				ConsoleWrite($iTemp[0][1] & @LF)
				;If $debug Then
				;	_ArrayDisplay($iTemp)
				;EndIf
				For $e = 1 To $iTemp[0][0]
					;;Array Columns:
					;[0]		[1]			[2]					[3]				[4]					[5]		[6]			[7]
					;Item Name	Hash Name	Ini Json String		Icon URL(local)	Local IconPath		AppID	Marketable	Tradable
					;[8]		[9]			[10]	[11]	[12]			[13]			[14]	[15]					[16]			[17]
					;Amount		CacheExp	Type	NameClr	$lowestPrice	$medianPrice	Volume	Inspect in Game Link	I bought For	I Bought For -15% (Resell Above)

					ReDim $localInventory[$int + 1][18]
					$localInventory[$int][0] = $iTemp[$e][0]
					$localInventory[$int][1] = _URIEncode($iTemp[$e][0]);HashItUpBro($iTemp[$e][0])
					$localInventory[$int][2] = $iTemp[$e][1]
					$localInventory[$int][3] = $appDirIcons & $localInventory[$int][1] & ".png"
					If FileExists($localInventory[$int][3]) Then
						$localInventory[$int][4] = $localInventory[$int][3]
					Else;PlaceholderIcon
						$localInventory[$int][4] = $appDirIcons & "No_Image.png"
					EndIf
					$localInventory[$int][5] = $iTemp[0][1]
					$keyChain = JSON_Decode($localInventory[$int][2])
					If Json_IsObject($keyChain) Then
						$localInventory[$int][6] = Json_ObjGet($keyChain, "marketable")
						;ConsoleWrite(@LF& "MARKETABLE: " & $localInventory[$int][6] &@LF)
						$localInventory[$int][7] = Json_ObjGet($keyChain, "tradable")
						$localInventory[$int][8] = Json_ObjGet($keyChain, "amount")
						$localInventory[$int][9] = Json_ObjGet($keyChain, "cache_expiration")
						$localInventory[$int][10] = Json_ObjGet($keyChain, "type")
						$localInventory[$int][11] = Json_ObjGet($keyChain, "name_color")
						$localInventory[$int][12] = Json_ObjGet($keyChain, "lowest_price")
						$localInventory[$int][13] = Json_ObjGet($keyChain, "median_price")
						$localInventory[$int][14] = Json_ObjGet($keyChain, "volume")
						$localInventory[$int][15] = Json_ObjGet($keyChain, "link")
					EndIf
					$localInventory[$int][16] = IniRead($rIni, "iBought", $localInventory[$int][0], "")
					If $localInventory[$int][16] = "" Then
						$localInventory[$int][17] = ""
					ElseIf StringInStr($localInventory[$int][16], "Keys") Then
						$localInventory[$int][17] = $localInventory[$int][16]
					Else
						$localInventory[$int][17] = Round($localInventory[$int][16] * 1.15, 2)
					EndIf
					$int += 1
				Next

			EndIf

		Next
		If $debug Then
			_ArrayDisplay($localInventory)
		EndIf
	Return $localInventory
EndFunc   ;==>InventoryIniRead

Func InventoryWrite($inVent, $user)
	For $i = 0 To UBound($inVent) - 1

		IniWrite(@ScriptDir & "\IniFiles\" & $user & "-"&$inVent[$i][5]&"-Inventory.ini", $inVent[$i][5], $inVent[$i][0], $inVent[$i][2])

		IniWrite(@ScriptDir & "\IniFiles\" & $user &"-Inventory.ini",$inVent[$i][5],"Items",True)

	Next
EndFunc   ;==>InventoryWrite

Func HashItUpBro($sString)
	$tString = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($sString, "#", "%23"),"&","%26"), "'", "%27"), ":", "%3A"), "™", "%E2%84%A2"), " ", "%20"), "|", "%7C"), "(", "%28"), ")", "%29")
	Return $tString
EndFunc   ;==>HashItUpBro

Func InventoryItemFind($sID, $iType, $uID)

	Local $bArray[1][18], $n = 0, $m = 0, $removed = 0, $errorCount = 0, $errorArray[0], $vanityName, $idNumber = ""
	;;Array Columns:
	;[0]		[1]			[2]					[3]			[4]				[5]		[6]			[7]
	;Item Name	Hash Name	Ini Json String		Icon URL	Local IconPath	AppID	Marketable	Tradable

	;[8]		[9]			[10]	[11]		[12]			[13]			[14]		[15]					[16]			[17]
	;Amount		CacheExp	Type	NameClr		$lowestPrice	$medianPrice	Volume		Inspect in Game Link	I bought For	I Bought For -15% (Resell Above)
	$apps = StringSplit($sID, ",")
	$types = StringSplit($iType, ",")
	$apPercent = 100 / $apps[0]
	ConsoleWrite($apPercent)
	For $a = 1 To $apps[0]
		$hDownload = InetGet("http://steamcommunity.com/id/" & $uID & "/inventory/json/" & $apps[$a] & "/" & $types[$a], $appDirJSON & $apps[$a] & " " & $types[$a] & ".JSON", -1, $INET_DOWNLOADBACKGROUND)
		Do
			Sleep(20)
		Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

		ConsoleWrite("http://steamcommunity.com/id/" & $uID & "/inventory/json/" & $apps[$a] & "/" & $types[$a] & @LF & "Download Complete" & @LF)
		$file = FileRead($appDirJSON & $apps[$a] & " " & $types[$a] & ".JSON")
		If $debug = 0 Then
			FileDelete($appDirJSON & $apps[$a] & " " & $types[$a] & ".JSON")
		EndIf

		Local $Obj = JSON_Decode($file), $rg = "rgDescriptions", $quickobj, $qObj, $info
			If Json_IsObject($Obj) Then
				ConsoleWrite("OBJECT YAY" & @LF)
				$vanityName = $uID
				$hDownload = InetGet("http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/?key="&$webAPIKey&"&vanityurl="&$vanityName,$appDirJSON & $vanityName & "ID.JSON", -1, $INET_DOWNLOADBACKGROUND)
				Do
					Sleep(20)
				Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

				ConsoleWrite("http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/?key="&$webAPIKey&"&vanityurl="&$vanityName & @LF & "Download Complete = "& InetGetInfo($hDownload, $INET_DOWNLOADSuccess) & @LF)
				$vanityFile = FileRead($appDirJSON & $vanityName & "ID.JSON")
				FileDelete($appDirJSON & $vanityName & "ID.JSON")

				Local $vanObj = JSON_Decode($vanityFile)

				If Json_IsObject($vanObj) Then
					$blah = Json_ObjGet($vanObj,"response")

					$rawr = Json_ObjGetKeys($blah)
					ConsoleWrite(IsArray($rawr))
					If $rawr[0] = "steamid" Then
						$idNumber = Json_objGet($blah,$rawr[0])
					EndIf
				EndIf
		Else
			$hDownload = InetGet("http://steamcommunity.com/profiles/" & $uID & "/inventory/json/" & $apps[$a] & "/" & $types[$a], $appDirJSON & $apps[$a] & " " & $types[$a] & ".JSON", -1, $INET_DOWNLOADBACKGROUND)
			Do
				Sleep(20)
			Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)

			ConsoleWrite("http://steamcommunity.com/profiles/" & $uID & "/inventory/json/" & $apps[$a] & "/" & $types[$a] & @LF & "Download Complete" & @LF)
			$file = FileRead($appDirJSON & $apps[$a] & " " & $types[$a] & ".JSON")
			If $debug = 0 Then
				FileDelete($appDirJSON & $apps[$a] & " " & $types[$a] & ".JSON")
			EndIf
			$Obj = JSON_Decode($file)
			If Not (Json_IsObject($Obj)) Then
				Local $bArray[2][1] = [["Error"], ["User ID \ AppID May be incorrect"]]
				ConsoleWrite("No JSON Found - Likely Incorrect User\App ID or Inventory type" & @LF & "Could also be Network issues")
				Return $bArray
			Else
				$idNumber = $uID
			EndIf
		EndIf


		$success = Json_ObjGet($Obj, "success")
		ConsoleWrite("Success = " & $success & @LF)
		;_ArrayDisplay($success)

		If $success = False Then
			$errorCount += 1

			$error = Json_ObjGet($Obj, "Error")
			If $error Then
				ReDim $errorArray[$errorCount][4]
				$errorArray[$errorCount - 1][0] = "Error"
				$errorArray[$errorCount - 1][1] = $error
				$errorArray[$errorCount - 1][2] = $apps[$a]
				$errorArray[$errorCount - 1][3] = $types[$a]
				If $debug Then _ArrayDisplay($errorArray)
			Else
				ReDim $errorArray[$errorCount][4]
				$errorArray[$errorCount - 1][0] = "Error"
				$errorArray[$errorCount - 1][1] = "User Does not own Game or JSON Syntax incorrect"
				$errorArray[$errorCount - 1][2] = $apps[$a]
				$errorArray[$errorCount - 1][3] = $types[$a]
				If $debug Then _ArrayDisplay($errorArray)
			EndIf

		Else


			#Region rgInventory

			$rgInvObj = Json_ObjGet($Obj, "rgInventory")
			If Json_IsObject($rgInvObj) Then

				$indivIDs = Json_ObjGetKeys($rgInvObj)

				Local $rgInventory

				For $i = 0 To UBound($indivIDs) - 1
					$qq = Json_ObjGet($rgInvObj, $indivIDs[$i])
					$rgInfo = Json_ObjGetKeys($qq)

					$v = $rgInfo
					For $j = 0 To UBound($rgInfo) - 1
						$v[$j] = Json_ObjGet($qq, $rgInfo[$j])
					Next

					_ArrayTranspose($v)
					If IsArray($rgInventory) Then
						_ArrayConcatenate($rgInventory, $v)
					Else
						$rgInventory = $v
					EndIf
				Next
				If $debug Then
					_ArrayDisplay($rgInventory)
		endIf

				#EndRegion rgInventory


				$numbers = Json_ObjGet($Obj, $rg)
				$ids = Json_ObjGetKeys($numbers)

				If $debug Then
				;			_ArrayDisplay($ids)
				EndIf
				$fraction = $apPercent / (UBound($ids) - 1)
				ConsoleWrite($fraction)
				For $i = 0 To UBound($ids) - 1
					$assetID = $rgInventory[$i][0]

					$quickobj = Json_ObjGet($numbers, $ids[$i])
					$info = Json_ObjGetKeys($quickobj)

					If $debug Then
						;ConsoleWrite($quickobj)
					EndIf
					$value = $info
					For $j = 0 To UBound($info) - 1
						$value[$j] = Json_ObjGet($quickobj, $info[$j])
					Next
;~ 				_ArrayColInsert($info,1)
;~ 				_ArrayColInsert($value,0)
;~ 				_ArrayAdd($info,$value,1)
					;	_ArrayInsert($info,1,$value,1)
					_ArrayTranspose($info)
					_ArrayTranspose($value)
					_ArrayConcatenate($info, $value)
					_ArrayTranspose($info)


					#CS ---------------------------- DEBUG INDIVIDUAL ITEMS
						If $debug Then
						_ArrayDisplay($info)
						EndIf
					#CE --------------------------- DEBUG INDIVIDUAL ITEMS



					$n = ($i + $m) - $removed
					ReDim $bArray[$n + 1][18]
					$percent = ($a - 1) * $apPercent
					GUICtrlSetData($progress, ($i * $fraction) + $percent)
					For $p = 0 To UBound($info) - 1

						Switch $info[$p][0]
							Case "market_hash_name"
								$bArray[$n][0] = $info[$p][1];StatTrak™ UMP-45 | Corporal (Minimal Wear)
								$bArray[$n][16] = IniRead(@ScriptDir & "\" & $uID & "Inventory.ini", "iBought", $bArray[$n][0], "N/A")
								If $bArray[$n][16] = "N/A" Then
									$bArray[$n][17] = "N/A"
								Else
									$bArray[$n][17] = Round($bArray[$n][16] * 1.15, 2)
								EndIf
								$bArray[$n][1] = _URIEncode($info[$p][1]);HashItUpBro($info[$p][1])
							Case "name_color"
								$bArray[$n][11] = $info[$p][1]
							Case "tradable"
								$bArray[$n][7] = $info[$p][1]
							Case "marketable"
								$bArray[$n][6] = $info[$p][1]
							Case "appid"
								$bArray[$n][5] = $info[$p][1]
							Case "type"
								$bArray[$n][10] = $info[$p][1]
							Case "cache_expiration"
								$bArray[$n][9] = $info[$p][1]
							Case "icon_url"
								ConsoleWrite("IconURL" & @LF)
								$bArray[$n][3] = $info[$p][1]
							Case "icon_url_large"
								ConsoleWrite("IconURL_Large Overwrite" & @LF)
								$bArray[$n][3] = $info[$p][1]
							Case "actions"
								$actions0 = Json_ObjGet($quickobj, $info[$p][0])
								;$name = Json_ObjGet($actions0[0],"name")
								$tempLink = Json_ObjGet($actions0[0], "link")
								If StringInStr($tempLink,"%owner_steamid%") AND $idNumber <> "" Then
									ConsoleWrite("Getting to Here: " & @LF &@TAB &$idNumber& @LF &@TAB &$assetID &@LF)
									$templink = StringReplace($tempLink,"%owner_steamid%",$idNumber)
									$templink = StringReplace($tempLink,"%assetid%",$assetID)
								EndIf
								$bArray[$n][15] = $tempLink
								;If $debug Then
									ConsoleWrite("Link:" & $bArray[$n][15] & @LF)


						EndSwitch
						If $info[$p][0] = "classid" Then
							$classID = $info[$p][1]
						EndIf
					Next
					;-------------------------------------------------------------------------------------
					;-------------------------------------------------------THIS AREA MAY NEED WORK
					If $bArray[$n][5] = "753" Or $bArray[$n][6] = 0 Then
						$amount = 0
						For $reggie = 0 To UBound($rgInventory) - 1
							If $rgInventory[$reggie][1] = $classID Then
								$amount += 1

							EndIf
						Next

					Else
						$amount = 1
						$ubound = UBound($bArray) - 1
						For $mrMeeces = 0 To $ubound
							If $bArray[$n][1] = $bArray[$mrMeeces][1] Then
								If Not ($n = $mrMeeces) Then
									$amount = $bArray[$mrMeeces][8] + 1
									ConsoleWrite("deleting row " & $mrMeeces & @LF)
									_ArrayDelete($bArray, $mrMeeces)
									$n -= 1
									$removed += 1
									ExitLoop
								EndIf
							EndIf
						Next
					EndIf
					ConsoleWrite("Amount: " & $amount & @LF)
					$bArray[$n][8] = $amount
					ConsoleWrite("$n = " & $n & @LF & "Ubound($barray)-1 = " & UBound($bArray) - 1)
					;-------------------------------------------------------------------------------------
					;-------------------------------------------------------------------------------------

					If $bArray[$n][5] = "730" Then
						;;Find Inspect ingame Link
;~ 			$actions0 = Json_ObjGet($info, "actions")
;~ 			$actions1 = Json_ObjGetKeys($actions0)
;~ 			_ArrayDisplay($actions1)
					Else
						;;Not CSS Item
					EndIf
					$file = ""
					If $bArray[$n][6] = 1 Then
						$hDownload = InetGet("http://steamcommunity.com/market/priceoverview/?currency=1&appid=" & $apps[$a] & "&market_hash_name=" & $bArray[$n][1], $appDirJSON & $bArray[$n][1] & ".JSON", -1, $INET_DOWNLOADBACKGROUND) ;; Change AppID to 753 works for Trading Cards
						Do
							Sleep(20)
						Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
						ConsoleWrite("http://steamcommunity.com/market/priceoverview/?currency=1&appid=" & $apps[$a] & "&market_hash_name=" & $bArray[$n][1] & @LF & "Download Complete" & @LF)
						$file = FileRead($appDirJSON & $bArray[$n][1] & ".JSON")
						$lel = JSON_Decode($file)
						If Json_IsObject($lel) Then
							$itemSuccess = Json_ObjGet($Obj, "success")
							if $itemSuccess = True Then
							$bArray[$n][12] = Json_ObjGet($lel, "lowest_price")
							$bArray[$n][13] = Json_ObjGet($lel, "median_price")
							$bArray[$n][14] = StringReplace(Json_ObjGet($lel, "volume"), ",", "")
							Json_ObjDelete($lel, "volume")
							$additional = ",""volume""" & ":""" & $bArray[$n][14] & """"
							$additional &= ","
							Else
							$additional = "{"
						EndIf
						EndIf
					Else
						$additional = "{"
					EndIf

					$additional = $additional & """Date""" & ":" & """" & _Now() & """"
					$additional = $additional & ",""marketable""" & ":""" & $bArray[$n][6] & """"
					$additional = $additional & ",""tradable""" & ":""" & $bArray[$n][7] & """"
					$additional = $additional & ",""name_color""" & ":""" & $bArray[$n][11] & """"
					$additional = $additional & ",""type""" & ":""" & $bArray[$n][10] & """"
					$additional = $additional & ",""appid""" & ":""" & $bArray[$n][5] & """"

					If $bArray[$n][9] <> "" Then
						$additional = $additional & ",""cache_expiration""" & ":""" & $bArray[$n][9] & """"
						;	ConsoleWrite($bArray[$n][2])
					EndIf
					$additional = $additional & ",""amount""" & ":""" & $bArray[$n][8] & """"
					If $bArray[$n][15] <> "" Then
						$additional = $additional & ",""link""" & ":""" & $bArray[$n][15] & """"
					EndIf


					$file = StringTrimRight($file, 1) & $additional & "}"
					FileDelete($appDirJSON & $bArray[$n][1] & ".JSON")
					$bArray[$n][2] = $file
;~ 			EndIf




					If Not (FileExists($appDirIcons & $bArray[$n][1] & ".png")) Then
						$sDownload = InetGet("http://steamcommunity-a.akamaihd.net/economy/image/" & $bArray[$n][3], $appDirIcons & $bArray[$n][1] & ".png", -1, $INET_DOWNLOADBACKGROUND)
						$abc = 8
						Do
							If $abc < 10 Then
								$abc += 1
							EndIf
							Sleep(20)
						Until InetGetInfo($sDownload, $INET_DOWNLOADCOMPLETE)
						If InetGetInfo($sDownload, $INET_DOWNLOADSUCCESS) Then
							$bArray[$n][4] = $appDirIcons & $bArray[$n][1] & ".png"
						Else;PlaceholderIcon
							$bArray[$n][4] = $appDirIcons & "No_Image.png"
						EndIf
					Else

						$bArray[$n][4] = $appDirIcons & $bArray[$n][1] & ".png"
						ConsoleWrite($appDirIcons & $bArray[$n][1] & ".png already exists" & @LF)
					EndIf

					$n += 1

					;ConsoleWrite($sTemp[8][$i]& @LF)

				Next
			Else
				$errorCount += 1
				ReDim $errorArray[$errorCount][4]
				$errorArray[$errorCount - 1][0] = "Error"
				$errorArray[$errorCount - 1][1] = "This Inventory was probably empty"
				$errorArray[$errorCount - 1][2] = $apps[$a]
				$errorArray[$errorCount - 1][3] = $types[$a]
				If $debug Then _ArrayDisplay($errorArray)
			EndIf


		EndIf
		$m = UBound($bArray) - 1


	Next
	GUICtrlSetData($progress, 0)
	If $debug Then
		_ArrayDisplay($bArray)
	EndIf
	If $errorCount > 0 Then
		$iString = "Errors Occured during Inventory Data grab:" & @LF
		For $i = 0 To $errorCount - 1
			$iString &= "App ID: " & $errorArray[$i][2] & " & Inventory Type: " & $errorArray[$i][3] & @LF & @TAB & "- " & $errorArray[$i][1] & @LF
		Next
		MsgBox(48, "Errors Occured", $iString)
	EndIf
	Return $bArray

EndFunc   ;==>InventoryItemFind

Func DestroyListView($lView, $invArray)
	;;Array Columns:
	;[0]		[1]			[2]					[3]			[4]				[5]		[6]			[7]
	;Item Name	Hash Name	Ini Json String		Icon URL	Local IconPath	AppID	Marketable	Tradable

	;[8]		[9]			[10]	[11]		[12]			[13]			[14]		[15]
	;Amount		CacheExp	Type	NameClr		$lowestPrice	$medianPrice	Volume		Inspect in Game Link
	Local $i = 0, $listCount = 0, $totalLowestSell = 0
	_GUICtrlListView_DeleteAllItems($lView)
	Redim $listItems[0]
	$lolol = _GUIImageList_Create(48, 48)
	For $i = 0 To UBound($invArray) - 1
		If $marketableOnly AND $invArray[$i][6] = 0 Then
			ContinueLoop
		EndIf
		If $tradeOnly AND $invArray[$i][7] = 0 Then
			ContinueLoop
		EndIf

		;ConsoleWrite("$i = " & $i &@LF &"Item: " & $invArray[$i][0])
		$hBitmap = _GDIPlus_BitmapCreateFromFile($invArray[$i][4])
		$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, 48, 48)
		$hImagePNG = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap_Scaled)
		_GUIImageList_Add($lolol, $hImagePNG)
		;Item \ Column 0
		_GUICtrlListView_AddItem($lView, $invArray[$i][0], $listCount)

		If $invArray[$i][6] = 0 Then ; If not Marketable Then say so in column 1, 2 & 3
			_GUICtrlListView_AddSubItem($lView, $listCount, "Not Marketable", 1)
			_GUICtrlListView_AddSubItem($lView, $listCount, "N/A", 2)
			_GUICtrlListView_AddSubItem($lView, $listCount, "N/A", 3)
		Else; If Marketable
			;Lowest Price \ Column 1
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][12], 1)
			If StringInStr($invArray[$i][12],"$") Then
			$tempLow = StringReplace($invArray[$i][12],"$","")
			$templow = $tempLow * $invArray[$i][8]
			$totalLowestSell = Round($totalLowestSell + $tempLow,2)
			ConsoleWrite("Item: " & $invArray[$i][0] & "||  Price: " & $tempLow & "|| Total Price: " & $totalLowestSell &@LF)
			GUICtrlSetData($gItemsLowestSell,$totalLowestSell)
			Elseif StringInStr($invArray[$i][13],"$") Then
			$tempLow = StringReplace($invArray[$i][13],"$","")
			$templow = $tempLow * $invArray[$i][8]
			$totalLowestSell = Round($totalLowestSell + $tempLow,2)
			ConsoleWrite("Item: " & $invArray[$i][0] & "||  Price: " & $tempLow & "|| Total Price: " & $totalLowestSell &@LF)
			GUICtrlSetData($gItemsLowestSell,$totalLowestSell)
			EndIf
			;Median Price \ Column 2
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][13], 2)
			;Volumee (24hr) \ Column 3
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][14], 3)
		EndIf
		;Amount (In inv) \ Column 4
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][8], 4)
		;Tradeable \ Column 5
		If $invArray[$i][7] = 1 Then
			_GUICtrlListView_AddSubItem($lView, $listCount, "Yes", 5)
		Else
			_GUICtrlListView_AddSubItem($lView, $listCount, "No", 5)
		EndIf
		;Purchase Price \ Column 6
		If $invArray[$i][16] <> "" Then
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][16], 6)
		Else
			;	_GUICtrlListView_AddSubItem($lView, $i, "N/A", 6)
		EndIf
		;Lowest Resell Price \ Column 7
		If $invArray[$i][17] <> "" Then
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][17], 7)
		Else
			;_GUICtrlListView_AddSubItem($lView, $i, "N/A", 7)
		EndIf
		;Type \ Column 8
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][10], 8)
		;AppID \ Column 9
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][5], 9)
		;CacheExp \ Column 10
		If $invArray[$i][9] <> "" Then
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][9], 10)
		Else
			_GUICtrlListView_AddSubItem($lView, $listCount, "N/A", 10)
		EndIf
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][15], 11)
		_GDIPlus_ImageDispose($hBitmap)
		_WinAPI_DeleteObject($hImagePNG)
		ReDim $listItems[$listCount+1]
		$listItems[$listCount] = $i

		$listCount +=1

	Next
	GUICtrlSetData($gItemsDisplayed, $listCount)
	GUICtrlsetdata($gItemsLowestSell, "$" & $totalLowestSell)
	_GUICtrlListView_SetImageList($lView, $lolol, 1)
	_GUICtrlListView_Scroll($lView,0,20)
EndFunc   ;==>DestroyListView


Func _URIEncode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(BinaryToString(StringToBinary($sData,4),1),"")
    Local $nChar
    $sData=""
    For $iVar = 1 To $aData[0]
        ;ConsoleWrite($aData[$iVar] & " - " )
        $nChar = Asc($aData[$iVar])
		; ConsoleWrite($nChar & @CRLF)
        Switch $nChar
			Case 45, 46, 48-57, 65 To 90, 95, 97 To 122, 126
                $sData &= $aData[$iVar]
			Case 48 to 57
                $sData &= $aData[$iVar]
            Case 32
                $sData &= "%20"
            Case Else
                $sData &= "%" & Hex($nChar,2)
        EndSwitch
    Next
	;ConsoleWrite($sData &@LF)
    Return $sData
EndFunc

Func _URIDecode($sData)
    ; Prog@ndy
    Local $aData = StringSplit(StringReplace($sData,"+"," ",0,1),"%")
    $sData = ""
    For $i = 2 To $aData[0]
        $aData[1] &= Chr(Dec(StringLeft($aData[$i],2))) & StringTrimLeft($aData[$i],2)
    Next
    Return BinaryToString(StringToBinary($aData[1],1),4)
EndFunc

; Notification message handler.  This is what will detect the right click.
Func WM_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)

	; structure to map $ilParam ($tNMHDR - see Help file)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)

	Switch $tNMHDR.IDFrom
		Case $idListview
			Switch $tNMHDR.Code
				Case $NM_RCLICK
					; another structure to remap $ilParam...used to get the item that was right clicked
					$tInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
					If $tInfo.Item > -1 Then
						$iItem = $tInfo.Item
						If _GUICtrlListView_GetItemText($idListview,$iItem,1) <> "Not Marketable" Then
							; positions the popup menu at the right clicked item
							_GUICtrlMenu_TrackPopupMenu($marketMenu, $hGUI)

						ElseIf _GUICtrlListView_GetItemText($idListview,$iItem,5) = "Yes" Then
							_GUICtrlMenu_TrackPopupMenu($hMenu, $hGUI)
						Else
							_GUICtrlMenu_TrackPopupMenu($BSIDEMenu, $hGUI)
						EndIf
					EndIf
			EndSwitch
	EndSwitch

	Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_NOTIFY

; Application message handler...this is what will action the controls in the message loop
Func WM_COMMAND($hWnd, $iMsg, $iwParam, $ilParam)
	; $iwParam contains the application messages that we defined earlier
	Switch $iwParam
		Case $idproc1
			GUICtrlSendToDummy($dummy_proc1)
		Case $idproc2
			GUICtrlSendToDummy($dummy_proc2)
		Case $idproc3
			GUICtrlSendToDummy($dummy_proc3)
		Case $idproc4
			GUICtrlSendToDummy($dummy_proc4)
	EndSwitch
EndFunc   ;==>WM_COMMAND
