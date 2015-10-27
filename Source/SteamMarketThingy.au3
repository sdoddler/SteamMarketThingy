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
#include <ComboConstants.au3>
#include <GDIPlus.au3>
#include <WinAPIEx.au3>
#include <GuiImageList.au3>
#include <GuiListView.au3>
#include <GuiMenu.au3>
#include <GuiToolTip.au3>
#include <ProgressConstants.au3>
#include "_PriceHistory.au3"
#include <GUIHyperlink.au3>
#include <IniEx.au3>
#include "_FloatValues.au3"

;Request Feedback on Layout \ Menus
;Request feedback on New Graph

;; ---- TO DO LIST
; In v.03 - Re-write IniWrite Section so that it can keep float values intact by also Writing Asset\ID numbers. (USING THE JSON Functions) JSON GET\PUT Etc..

; Add User ID Combo so that saved UserIDs are able to be reselected.. -- Done
; Need to add additional Games and Test || Rust and BattleBlock added
; Fix Difficult Names not displaying images (even though they download) - Done
; Add Menu above \ Preferences for Search options.. Done - Will move Price history to "View Menu" soon. - Done
; Add Game name to Error in Data Grab (Either at Error Array or Final Error read) || Done
;;  ----

$appDir = EnvGet("APPDATA") & "\SteamMarketThingy\"
DirCreate($appDir)
$appDirJSON = $appDir&"\JSON\"
DirCreate($appDirJSON)
$appDirIcons = $appDir&"Icons\"
DirCreate($appDirIcons)
DirCreate(@ScriptDir & "\IniFiles\")

$debug = 0

Global $DefaultApps = "730,440,570,753,753,238460,252490"
Global $DefaultTypes = "2,2,2,6,1,2,2"
Global $DefaultNames = "All Apps|Preferred Games|CSGO|TF2|Dota 2|Trading Cards & Emotes|Games & Gifts|BattleBlock Theater|Rust"

FileInstall("C:\Work\Projects\Scripts\Steam\Steam_Icon.ico", $appDir & "Steam_Icon.ico", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Twitter_Icon.ico", $appDir & "Twitter_Icon.ico", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Youtube_icon.ico", $appDir & "Youtube_icon.ico", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Splash1.jpg", $appDir & "Splash1.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\No_Image.png", $appDirIcons & "No_Image.png", 1)

FileInstall("C:\Work\Projects\Scripts\Steam\csgo.jpg", $appDir & "csgo.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Rust.jpg", $appDir & "Rust.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Dota 2.jpg", $appDir & "Dota 2.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\BattleBlock Theater.jpg", $appDir & "BattleBlock Theater.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Trading Cards & Emotes.jpg", $appDir & "Trading Cards & Emotes.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\Games & Gifts.jpg", $appDir & "Games & Gifts.jpg", 1)
FileInstall("C:\Work\Projects\Scripts\Steam\TF2.jpg", $appDir & "TF2.jpg", 1)


$tFade = 2000

$Fade = 0x80000

$hSplash = GUICreate("", 500, 300, -1, -1, BitOR($WS_DLGFRAME, $WS_POPUP))

GUICtrlCreatePic($appDir&"Splash1.jpg",0,0,500,300)
GUISetFont(12)
$splashLabel = GUICtrlCreateLabel("Starting Up",5,270,200,30)
GUICtrlSetBkColor(-1,$GUI_BKCOLOR_TRANSPARENT)
If $debug = 0 Then
DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hSplash, "int", $tFade, "long", $Fade)
EndIf
$Fade = 0x90000
GUICtrlSetData($splashLabel,"Loading Local Inventory")


$userID = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserID", "sDoddler")
$searchID = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "SearchType", "All Apps")
$userSearchHistory = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserSearchHistory", "")
Switch $searchID
				Case "All Apps"
					$appID = $DefaultApps
					$inventoryType =  $DefaultTypes
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
				Case "Games & Gifts"
					$appID = "753"
					$inventoryType = "1"
				Case "BattleBlock Theater"
					$appid = "238460"
					$inventoryType = "2"
				Case Else
					$appID = $DefaultApps
					$inventoryType =  $DefaultTypes
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
Endif

$percentFloat = IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "FloatInPercent", False)
If $percentFloat = "True" Then
	$percentFloat= True
Else
	$percentFloat= False
EndIf
$saveSearch = IniRead(@ScriptDir & "\" & "Settings.ini", "Settings", "SaveSearch", True)
If $saveSearch = "True" Then
	$saveSearch= True
Else
	$saveSearch= False
EndIf

$prefRead = IniRead("Settings.ini","Settings","PreferredGames","CSGO,Trading Cards & Emotes")
$prefSplit = StringSplit($prefRead,",")
Global $preferredApps = ""
Global $preferredTypes = ""
For $i = 1 to $prefSplit[0]
						$iTemp = _GameLookup($prefSplit[$i],-1,1)
						If $preferredApps = "" Then
							$preferredApps = $iTemp[0]
							$preferredTypes = $iTemp[1]
						Else
							$preferredApps &= "," & $iTemp[0]
							$preferredTypes &= "," & $iTemp[1]
						EndIf
Next



Global Enum $idproc1 = 1000, $idproc2, $idproc3,$idProc4, $idProc5
Global $webAPIKey = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
Global $listItems[0]
Global $listPreferred

$hGUI = GUICreate("sDoddler's Steam Market Thingy", 1000, 550, -1, -1, $WS_MAXIMIZEBOX + $WS_MINIMIZEBOX + $WS_SIZEBOX)


$hFileMenu = GUICtrlCreateMenu("File")
$menuExit = GUICtrlCreateMenuItem("Exit",$hFileMenu)

$hSearchMenu = GUICtrlcreatemenu("Search Options")
$menuDisplayLocal = GUICtrlCreateMenuItem("Display All with Updated",$hSearchMenu)
If $displayLocal Then
	Guictrlsetstate(-1,$GUI_CHECKED)
EndIf
$menuMarketOnly = GUICtrlCreateMenuItem("Show Only Marketables",$hSearchMenu)
If $marketableOnly Then
	Guictrlsetstate(-1,$GUI_CHECKED)
EndIf
$menuTradeOnly = GUICtrlCreateMenuItem("Show Only Tradables",$hSearchMenu)
If $tradeOnly Then
	Guictrlsetstate(-1,$GUI_CHECKED)
EndIf
$menuPercentFloat = GUICtrlCreateMenuItem("Show Float Value in %",$hSearchMenu)
If $percentFloat Then
	Guictrlsetstate(-1,$GUI_CHECKED)
EndIf
$menuSaveSearch = GUICtrlCreateMenuItem("Save Search Settings",$hSearchMenu)
If $SaveSearch Then
	Guictrlsetstate(-1,$GUI_CHECKED)
EndIf
;---------------------------------
GUICtrlCreateMenuItem("",$hSearchMenu)
$menuSetPreferred = GUICtrlCreateMenuItem("Set Preferred Search Games",$hSearchMenu)

$menuClearUserHistory = GUICtrlCreateMenuItem("Clear User Search History",$hSearchMenu)

$hViewMenu = GUICtrlCreateMenu("View")
$menuLoadPH = GUICtrlCreateMenuItem("Load Pricehistory.JSON",$hViewMenu)

$hDataGrabMenu = GUIctrlcreatemenu("Grab Data")
$menuGrabFloat = GUICtrlCreateMenuItem("Retry Float values for current Search",$hDataGrabMenu)


GUISetFont(12)
$gcApp = GUICtrlCreateCombo("", 10, 10, 150,-1,$CBS_DROPDOWNLIST)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetData(-1, $DefaultNames, $searchID)
GUICtrlSetTip(-1, "Pick which Game(s) you want to update" & @LF & "Will add more in future")


GUICtrlCreateLabel("User ID: ", 180, 13,70)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Found at: steamcommunity.com/id/<UserID> " & @LF & "OR: steamcommunity.com/profiles/<UserID>", "User ID")
$gUserID = GUICtrlCreateCombo("", 255, 10, 150); Input Values , -1, BitOR($ES_AUTOHSCROLL, $ES_RIGHT))
If StringInStr($userSearchHistory,$userID) Then
GUICtrlSetData(-1,$userSearchHistory,$userID)
Else
	GUICtrlSetData(-1,$userID & "|" & $userSearchHistory,$userID)
EndIf
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Found at: steamcommunity.com/id/<UserID> " & @LF & "OR: steamcommunity.com/profiles/<UserID>", "User ID")

GUISetFont(8.5)
GUICtrlCreateLabel("App ID: ", 430, 13)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
$gAppID = GUICtrlCreateInput($appID, 480, 10, 100, -1, BitOR($ES_AUTOHSCROLL, $ES_RIGHT, $ES_READONLY))
GUICtrlSetResizing(-1,$GUI_DOCKALL)

GUICtrlCreateLabel("Inv Type: ", 600, 13)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
$gItype = GUICtrlCreateInput($inventoryType, 650, 10, 100, -1, BitOR($ES_AUTOHSCROLL,$ES_NUMBER, $ES_RIGHT, $ES_READONLY))
GUICtrlSetResizing(-1,$GUI_DOCKALL)

$gGUIGrabData = GUICtrlCreateButton("Update selected Inventory(s)", 10, 42, 150, 24)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Updates the Selected Game Inventory(s) from web data", "Update Selected")

$progress = GUICtrlCreateProgress(770, 8, 200, 27)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "GRATS YOU HOVERED ON THE PROGRESS BAR WOOOOOOO")

$readIni = GUICtrlCreateButton("Read Local Selected", 430, 42)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Based off the User ID field", "Read Local Inventory")


$readAll = GUICtrlCreateButton("Read Local All Apps", 550, 42)
GUICtrlSetResizing(-1,$GUI_DOCKALL)
GUICtrlSetTip(-1, "Based off the User ID field", "Read Local Inventory")

;~ $seperator = GUICtrlCreateGraphic(850, 0, 10, 40)
;~ GUICtrlSetResizing(-1,$GUI_DOCKALL)
;~ GUICtrlSetGraphic($seperator, $GUI_GR_MOVE, 0, 5)
;~ GUICtrlSetGraphic($seperator, $GUI_GR_COLOR, 0x939696)
;~ GUICtrlSetGraphic($seperator, $GUI_GR_LINE, 0, 65)

;~ GUICtrlCreateLabel("Days", 860, 13)
;~ GUICtrlSetResizing(-1,$GUI_DOCKALL)
;~ $gDays = GUICtrlCreateInput("30", 910, 10, -1, -1, $ES_NUMBER)
;~ GUICtrlSetResizing(-1,$GUI_DOCKALL)
;~ GUICtrlSetData(-1, IniRead(@ScriptDir & "\" & "Settings.ini", "LastSearch", "Days", "30"))
;~ GUICtrlSetTip(-1, "Days to Graph in Price History")

;~ $gPriceHistory = GUICtrlCreateButton("Load PriceHistory.JSON", 860, 40)
;~ GUICtrlSetResizing(-1,$GUI_DOCKALL)
;~ GUICtrlSetTip(-1, "Load a PriceHistory.JSON from file")

$gItemLabel = GUICtrlCreateLabel("Items Displayed: ",10,480)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
$gItemsDisplayed = GUICtrlCreateLabel(0,100,480,200)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)

GUICtrlCreateLabel("Sell all at Lowest prices: ",150,480)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
$gItemsLowestSell = GUICtrlCreateLabel(0,280,480,100)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)


$gFloatInfo = GUICtrlCreateLabel("Hover for Float Value Info", 380, 480,150)
GUICtrlSetFont(-1,8.5,700)
$hFloatInfo = GUICtrlGetHandle($gFloatInfo)
GUICtrlSetResizing(-1,$GUI_DOCKBOTTOM+$GUI_DOCKLEFT+$GUI_DOCKSIZE)
$hToolTip = _GUIToolTip_Create($hGUI)
_GUIToolTip_SetTitle($hToolTip,"Float Value Info")
_GUIToolTip_SetMaxTipWidth($hToolTip, 400)
_GUIToolTip_AddTool($hToolTip,0,"Factory New: 0.00-0.07" &@LF _ ;
& "Minimal Wear: 0.07-0.15" &@LF _
& "Field-Tested: 0.15-0.37" &@LF _
& "Well-Worn: 0.37-0.44" &@LF _
& "Battle-Scarred: 0.44-1.00" &@LF _
& "Percent is based on how close your weapon is to the next quality." &@LF _
& "It is also using the full decimal places rather than rounding to 2." &@LF _
& "This has the potential to change an items quality (only in the Float Column)",$hFloatInfo,380,480,410,600);,;"Float Info")
_GUIToolTip_SetDelayTime($hToolTip, $TTDT_AUTOPOP, 15000)


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

;[8]		[9]			[10]	[11]		[12]			[13]			[14]		[15]					[16]			[17]			[
;Amount		CacheExp	Type	NameClr		$lowestPrice	$medianPrice	Volume		Inspect in Game Link	I bought for?	BoughtFor*1.15
_GUICtrlListView_AddColumn($idListview, "Item", 200)
$floatCol = _GUICtrlListView_AddColumn($idListview, "Float Value", 50)

_GUICtrlListView_AddColumn($idListview, "Lowest Price", 80)
_GUICtrlListView_AddColumn($idListview, "Median Price", 50)
_GUICtrlListView_AddColumn($idListview, "Volume", 50)
_GUICtrlListView_AddColumn($idListview, "Amount", 50)
_GUICtrlListView_AddColumn($idListview, "Tradeable", 50)
_GUICtrlListView_AddColumn($idListview, "Purchase Price", 70)
_GUICtrlListView_AddColumn($idListview, "Lowest Resell", 70)
_GUICtrlListView_AddColumn($idListview, "Type", 170)
_GUICtrlListView_AddColumn($idListview, "Game", 100)
_GUICtrlListView_AddColumn($idListview, "App ID", 40)
_GUICtrlListView_AddColumn($idListview, "Cache Exp", 50)
_GUICtrlListView_AddColumn($idListview, "Link", 200)

; The are dummy controls that will be actioned by the applications message handler based on the message id associated with the popup (RIGHT CLICK) menu.
; E.G. $dummy_proc1 will be actioned by application message $idproc1 from message handler WM_COMMAND.
Local $dummy_proc1 = GUICtrlCreateDummy()
Local $dummy_proc2 = GUICtrlCreateDummy()
Local $dummy_proc3 = GUICtrlCreateDummy()
Local $dummy_proc4 = GUICtrlCreateDummy()
Local $dummy_proc5 = GUICtrlCreateDummy()

; Set in the notification message handler (WM_NOTIFY) to get the item number of the listview item clicked on.
Local $iItem = 0

; Popup menu...each item is associated with an application defined message ($idproc1 and $idproc2).
;Tradeables
Local $hMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($hMenu, 0, "View Image\Art", $idproc4)
_GUICtrlMenu_InsertMenuItem($hMenu, 1, "View item Wiki\Inspect In-game", $idproc1)
_GUICtrlMenu_InsertMenuItem($hMenu, 2, "I bought this for", $idproc3)


;Marketables
Local $marketMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($marketMenu, 0, "View Image\Art", $idproc4)
_GUICtrlMenu_InsertMenuItem($marketMenu, 1, "View item Wiki\Inspect In-game", $idproc1)
_GUICtrlMenu_InsertMenuItem($marketMenu, 2, "I bought this for", $idproc3)
_GUICtrlMenu_InsertMenuItem($marketMenu, 3, "View Market Listings", $idproc5)
_GUICtrlMenu_InsertMenuItem($marketMenu, 4, "Save Price History (requires Steam Login on def. browser)", $idproc2)

;Non Tradable - Non Marketable
Local $BSIDEMenu = _GUICtrlMenu_CreatePopup()
_GUICtrlMenu_InsertMenuItem($BSIDEMenu, 0, "View Image\Art", $idproc4)
_GUICtrlMenu_InsertMenuItem($BSIDEMenu, 1, "View item Wiki\Inspect In-game", $idproc1)



$Fade = 2000
If $debug = 0 Then
DllCall("user32.dll", "int", "AnimateWindow", "hwnd", $hSplash, "int", $tFade, "long", $Fade)
EndIf

GUISetState()
_GUICtrlSetState($GUI_DISABLE)
DestroyListView($idListview, $theInventory)
_GUICtrlSetState($GUI_ENABLE)
GUIDelete($hSplash)
GUIRegisterMsg($WM_NOTIFY, "WM_NOTIFY")
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")

_GUICtrlListView_RegisterSortCallBack($idListview)

While 1

	$msg = GUIGetMsg()

	Switch $msg
		Case $GUI_EVENT_CLOSE
			ExitLoop
		Case $menuExit
			ExitLoop
		Case $gSteamIcon
			ShellExecute('https://steamcommunity.com/id/sdoddler')
		Case $gTwitterIcon
			ShellExecute('https://twitter.com/sdoddler')
		Case $gYoutubeIcon
			ShellExecute('https://youtube.com/user/doddddy')
		Case $readIni
			_GUICtrlSetState($GUI_DISABLE)
			$userID = GUICtrlRead($gUserID)
			$appID = GUICtrlread($gAppID)
			$inventoryType = GUICtrlRead($gItype)
			;ConsoleWrite(GUICtrlread($gAppID))
			$theInventory = InventoryIniRead($userID,$appid,$inventoryType)

			DestroyListView($idListview, $theInventory)
			_GUICtrlSetState($GUI_ENABLE)
		Case $readAll
			_GUICtrlSetState($GUI_DISABLE)
			$userID = GUICtrlRead($gUserID)
			$theInventory = InventoryIniRead($userID)
			DestroyListView($idListview, $theInventory)

			_GUICtrlSetState($GUI_ENABLE)
		Case $idListview
			; Kick off the sort callback
			_GUICtrlListView_SortItems($idListview, GUICtrlGetState($idListview))
		Case $gcApp
			$whatUpdate = GUICtrlRead($gcApp)
			Switch $whatUpdate ;"Update All Apps|Update CSGO|Update TF2|Update Dota 2|Update Steam Community","Update All Apps")
				Case "All Apps"
					GUICtrlSetData($gAppID, $DefaultApps)
					GUICtrlSetData($gItype, $DefaultTypes)
				Case "Preferred Games"
					GUICtrlSetData($gAppID, $preferredApps)
					GUICtrlsetdata($gItype, $preferredTypes)
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
				Case "Games & Gifts"
					GUICtrlSetData($gAppID, "753")
					GUICtrlSetData($gItype, "1")
				Case "BattleBlock Theater"
					GUICtrlSetData($gAppID, "238460")
					GUICtrlSetData($gItype, "2")
				Case "Rust"
					GUICtrlSetData($gAppID, "252490")
					GUICtrlSetData($gItype, "2")

			EndSwitch
		Case $menuDisplayLocal
			If	BitAND(GUICtrlread($menuDisplayLocal),$GUI_CHECKED) = $GUI_CHECKED Then
				$displayLocal = False
				GUICtrlSetState($menuDisplayLocal,$GUI_UNCHECKED)
			Elseif BitAND(GUICtrlread($menuDisplayLocal),$GUI_UNCHECKED) = $GUI_UNCHECKED Then
				$displayLocal = True
				GUICtrlSetState($menuDisplayLocal,$GUI_CHECKED)
			Endif
		Case $menuTradeOnly
			If	BitAND(GUICtrlread($menuTradeOnly),$GUI_CHECKED) = $GUI_CHECKED Then
				$tradeOnly = False
				GUICtrlSetState($menuTradeOnly,$GUI_UNCHECKED)
			Elseif BitAND(GUICtrlread($menuTradeOnly),$GUI_UNCHECKED) = $GUI_UNCHECKED Then
				$tradeOnly = True
				GUICtrlSetState($menuTradeOnly,$GUI_CHECKED)
			Endif
		Case $menuMarketOnly
			If	BitAND(GUICtrlread($menuMarketOnly),$GUI_CHECKED) = $GUI_CHECKED Then
				$marketableOnly = False
				GUICtrlSetState($menuMarketOnly,$GUI_UNCHECKED)
			Elseif BitAND(GUICtrlread($menuMarketOnly),$GUI_UNCHECKED) = $GUI_UNCHECKED Then
				$marketableOnly = True
				GUICtrlSetState($menuMarketOnly,$GUI_CHECKED)
			Endif
		Case $menuPercentFloat
			If	BitAND(GUICtrlread($menuPercentFloat),$GUI_CHECKED) = $GUI_CHECKED Then
				$percentFloat = False
				GUICtrlSetState($menuPercentFloat,$GUI_UNCHECKED)
			Elseif BitAND(GUICtrlread($menuPercentFloat),$GUI_UNCHECKED) = $GUI_UNCHECKED Then
				$percentFloat = True
				GUICtrlSetState($menuPercentFloat,$GUI_CHECKED)
			Endif
		Case $menuSaveSearch
			If	BitAND(GUICtrlread($menuSaveSearch),$GUI_CHECKED) = $GUI_CHECKED Then
				$SaveSearch = False
				GUICtrlSetState($menuSaveSearch,$GUI_UNCHECKED)
				IniWrite(@ScriptDir & "\" & "Settings.ini", "Settings", "SaveSearch", False)
			Elseif BitAND(GUICtrlread($menuSaveSearch),$GUI_UNCHECKED) = $GUI_UNCHECKED Then
				$SaveSearch = True
				GUICtrlSetState($menuSaveSearch,$GUI_CHECKED)
				IniWrite(@ScriptDir & "\" & "Settings.ini", "Settings", "SaveSearch", True)
			Endif
		Case $menuClearUserHistory
			$userID = GUICtrlRead($gUserID)
			IniDelete(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserSearchHistory")
			IniDelete(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserID")
			GUICtrlSetData($gUserID,"")
		Case $menuGrabFloat
					_GUICtrlSetState($GUI_DISABLE)
					;IniRead(@ScriptDir&"\IniFiles\VanityNames.ini","VanityNames",$userID,$userID)
					$floatValues = _FloatValues($webAPIKey, IniRead(@ScriptDir&"\IniFiles\VanityNames.ini","VanityNames",$userID,$userID), $appDirJSON,$progress)
					if $floatValues[0][0] = "Error" Then
						ConsoleWrite("$floatValues[0][0] = Error" & @LF)
						MsgBox(48,"Could not get Float Data","Float data was not able to be downloaded :(",5)
						$float = False
					Else

						$float = True
						For $j = 0 to Ubound($theInventory)-1
							if $theInventory[$j][5] = "730" Then
							For $i = 0 to Ubound($floatValues)-1
								If $floatValues[$i][0] = $theInventory[$j][21] Then
									$theInventory[$j][22] = $floatValues[$i][1]
									ExitLoop
								EndIf
							Next
							EndIf
						Next
						DestroyListView($idListview, $theInventory)
					EndIf
					_GUICtrlSetState($GUI_ENABLE)
		Case $gGUIGrabData
			_GUICtrlSetState($GUI_DISABLE)
			$userID = GUICtrlRead($gUserID)
			$appID = GUICtrlRead($gAppID)
			$inventoryType = GUICtrlRead($gItype)
			If $saveSearch Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserID", GUICtrlRead($gUserID))
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "SearchType", GUICtrlRead($gcApp))
			If $displayLocal Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "DisplayLocal", True)
			Else
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "DisplayLocal", False)
			Endif
			If $marketableOnly Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "MarketableOnly",True)
			Else
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "MarketableOnly", False)
			Endif
			If $tradeOnly Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "TradeOnly",True)
			Else
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "TradeOnly", False)
			Endif
			If $percentFloat Then
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "FloatInPercent",True)
			Else
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "FloatInPercent", False)
			Endif
			if not(StringInStr($userSearchHistory,$userID)) Then
				if $userSearchHistory <> "" Then
					$userSearchHistory &= "|" & $userID
				Else
					$userSearchHistory = $userID
				EndIf
			EndIf
			IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "UserSearchHistory", $userSearchHistory)
			EndIf
			GUICtrlSetData($gUserID,"")
			GUICtrlSetData($gUserID,$userSearchHistory,$userID)
			$theInventory = InventoryItemFind($appID, $inventoryType, $userID)

			If $theInventory[0][0] = "Error" Then
				MsgBox(0, "", $theInventory[0][0] & ": " & $theInventory[1][0])
			Else
				$appSplit = StringSplit($appID, ",")
				$invSplit = StringSplit($inventoryType,",")
				For $i = 1 To $appSplit[0]
					IniDelete(@ScriptDir & "\IniFiles\" & $userID &"-"& $appSplit[$i]&  "-Inventory.ini", $appSplit[$i])
					if $appSplit[$i] = "753" Then
						IniDelete(@ScriptDir & "\IniFiles\" & $userID &"-"& $appSplit[$i] & "-" & $invSplit[$i] &  "-Inventory.ini", $appSplit[$i])
					EndIf
				Next
				InventoryWrite($theInventory, $userID, $inventoryType)
				If $displayLocal Then
					$theInventory = InventoryIniRead($userID)
				Else
;~ 					If $appID = "753" Then
					$theInventory = InventoryIniRead($userID, $appID, $inventoryType)
;~ 					Else
;~ 					$theInventory = InventoryIniRead($userID, $appID, $inventoryType)
;~ 					EndIf
				EndIf
				DestroyListView($idListview, $theInventory)


			EndIf

			_GUICtrlSetState($GUI_ENABLE)
		Case $menuSetPreferred
			_SetPreferredGUI()
			if GUICtrlread($gcApp) = "Preferred Games" Then
				GUICtrlSetData($gAppID, $preferredApps)
				GUICtrlsetdata($gItype, $preferredTypes)
			Endif
		Case $dummy_proc2
			;http://steamcommunity.com/market/pricehistory/?appid=730&market_hash_name=P90%20%7C%20Asiimov%20%28Factory%20New%29
			ConsoleWrite('You have choosen to run Procedure #1 on ' & _GUICtrlListView_GetItemText($idListview, $iItem) & @CRLF)
				;$hDownload = InetGet("http://steamcommunity.com/market/pricehistory/?appid=" & $theInventory[$listItems[$iItem]][5] & "&market_hash_name=" & $theInventory[$listItems[$iItem]][1], "test.json", -1, $INET_DOWNLOADBACKGROUND)
				$marketHash = _URIEncode(_GUICtrlListView_GetItemText($idListview, $iItem))
				ConsoleWrite("http://steamcommunity.com/market/pricehistory/?appid=" & _GUICtrlListView_GetItemText($idListview,$iItem,10) & "&market_hash_name=" & $marketHash)
				ShellExecute("http://steamcommunity.com/market/pricehistory/?appid=" & _GUICtrlListView_GetItemText($idListview,$iItem,10) & "&market_hash_name=" & $marketHash)
		Case $dummy_proc1

			If _GUICtrlListView_GetItemText($idListview,$iItem,12) <> "" Then
				ShellExecute(_GUICtrlListView_GetItemText($idListview,$iItem,12))
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
		Case $dummy_proc5
			ConsoleWrite("http://steamcommunity.com/market/listings/"&_GUICtrlListView_GetItemText($idListview,$iItem,10)&"/"&_URIEncode(_GUICtrlListView_GetItemText($idListview, $iItem))&@LF)
			ShellExecute("http://steamcommunity.com/market/listings/"&_GUICtrlListView_GetItemText($idListview,$iItem,10)&"/"&_URIEncode(_GUICtrlListView_GetItemText($idListview, $iItem)))
		Case $menuLoadPH

			$priceHistoryJSON = FileOpenDialog("Choose a PriceHistory.Json", @ScriptDir & "\", "Json Files (*.json)",0,"",$hGUI)

			If $priceHistoryJSON = "" Then
				; - Displays the window in its current state
				ConsoleWrite("No file Selected")

			Else
				;IniWrite(@ScriptDir & "\" & "Settings.ini", "LastSearch", "Days", GUICtrlRead($gDays))
				_GUICtrlSetState($GUI_DISABLE)
				_PriceGraph($priceHistoryJSON, $hGUI)
				_GUICtrlSetState($GUI_ENABLE)
			EndIf

	EndSwitch

	Sleep(20)
WEnd
_GDIPlus_Shutdown()

Func _SetPreferredGUI()
	GUISetState(@SW_DISABLE, $hGUI)
	Local $iRead = IniRead("Settings.ini","Settings","PreferredGames","CSGO,Trading Cards & Emotes")
	Local $iPrefer = StringSplit($iRead,",")
	Local $iArray = StringSplit($DefaultNames,"|");$iRead,",")
	Local $iCount = 0
	Local $iStr = ""

	$guiPreferred = GUICreate("Preferred Search Games",220,330)

	$listPreferred = GUICtrlCreateListView("", 10, 10, 200, 280, BitOR($LVS_SHOWSELALWAYS, $LVS_REPORT))
	_GUICtrlListView_SetExtendedListViewStyle($listPreferred, $iStylesEx)

	_GUICtrlListView_AddColumn($listPreferred, "Preferred Games", 175)

	$prefImages = _GUIImageList_Create(32, 32)
	For $i = 3 to $iArray[0]
		$hBitmap = _GDIPlus_BitmapCreateFromFile($appdir&$iArray[$i]&".jpg")
		ConsoleWrite($appdir&$iArray[$i]&".jpg"&@LF)
;~ 		$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, 48, 48)
		$hImagePNG = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap)
		_GUIImageList_Add($prefImages, $hImagePNG)
		_GUICtrlListView_AddItem($listPreferred,$iArray[$i],$i-3)
		For $j = 1 to $iPrefer[0]
			if $iArray[$i] = $iPrefer[$j] Then
				_GUICtrlListView_SetItemChecked($listPreferred,$i-3)
			EndIf
		Next
;~ 		_GDIPlus_ImageDispose($hBitmap_Scaled)
		_GDIPlus_ImageDispose($hBitmap)
		_WinAPI_DeleteObject($hImagePNG)
	Next
	_GUICtrlListView_SetImageList($listPreferred,$prefImages, 1)
	_GUICtrlListView_Scroll($listPreferred,0,20)


	$prefSave = GUICtrlCreateButton("Save",160,300)

	GUISetState()
	GUIRegisterMsg($WM_NOTIFY, "_Preferred_NOTIFY")
	While 1

		Switch GUIGetMsg($guiPreferred)
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_ENABLE, $hGUI)
				GUIDelete($guiPreferred)
				ExitLoop
			Case $prefSave
				$iStr = ""
				$iCount = _GUICtrlListView_GetItemCount($listPreferred)
				Dim $pArray[$iCount][2]
				For $i = 0 to $iCount
					If _GUICtrlListView_GetItemChecked($listPreferred,$i) Then
						$pText = _GUICtrlListView_GetItemText($listPreferred,$i)
						ConsoleWrite($pText& " - Checked"&@LF)
						$pTemp = _GameLookup($pText,-1,1)
						$pArray[$i][0] = $pTemp[0]
						$pArray[$i][1] = $pTemp[1]
						If $iStr = "" Then
							$preferredApps = $pArray[$i][0]
							$preferredTypes = $pArray[$i][1]
							$iStr &= $pText
						Else
							$preferredApps &= "," & $pArray[$i][0]
							$preferredTypes &= "," & $pArray[$i][1]
							$iStr &= ","&$pText
						EndIf
					EndIf
				Next
				If $iStr = "" Then
					MsgBox(48,"Nothing Selected","No items selected"&@LF&"Please select the games you will most regularly search for.")
				Else
					IniWrite("Settings.ini","Settings","PreferredGames",$iStr)
					;_ArrayDisplay($pArray)
					ConsoleWrite("Preferred Apps: " &$preferredApps &@LF & "Preferred Types: " &$preferredTypes &@LF)
					if not(@error) Then MsgBox(64,"Preferences Saved","Preferred games saved :)")
					GUISetState(@SW_ENABLE, $hGUI)
					GUIDelete($guiPreferred)
					ExitLoop

				EndIf

		EndSwitch
	WEnd



EndFunc

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
	GUICtrlSETSTATE($hMenu, $state)
	GUICtrlSetState($hSearchMenu,$state)
	GUICtrlSetState($hFileMenu,$state)
	GUICtrlSetState($hViewMenu,$state)
	GUICtrlSetState($hDataGrabMenu,$state)
;~ 	GUICtrlSetState($gDays, $state)
;~ 	GUICtrlSetState($gPriceHistory, $state)
	GUICtrlSetState($readAll, $state)

EndFunc   ;==>_GUICtrlSetState

Func InventoryIniRead($iniUID, $readApps = $DefaultApps,$readTypes = $DefaultTypes)
	Local $localInventory[1][23], $iTemp, $int = 0, $rIni = @ScriptDir & "\IniFiles\" & $iniUID & "-Inventory.ini"

	;$rSecNames = _IniReadSectionNamesEx($rIni)
	$rSecNames = StringSplit($readApps,",")
	$invTypes = StringSplit($readTypes,",")
	If $debug Then
		_ArrayDisplay($rSecNames)
	EndIf

		For $i = 1 To $rSecNames[0]
			ConsoleWrite($rSecNames[$i] &" - "&$invTypes[$i] & @LF)
			If FileExists(@ScriptDir & "\IniFiles\" & $iniUID & "-"&$rSecNames[$i]&"-Inventory.ini") OR FileExists(@ScriptDir & "\IniFiles\" & $iniUID & "-"&$rSecNames[$i]&"-"&$invTypes[$i]&"-Inventory.ini") Then
				If $rSecNames[$i] = "753" Then

					$iTemp = _IniReadSectionEx(@ScriptDir & "\IniFiles\" & $iniUID & "-"&$rSecNames[$i]&"-"&$invTypes[$i]&"-Inventory.ini", $rSecNames[$i])
					$iTemp[0][1] = $rSecNames[$i]
				Else
					$iTemp = _IniReadSectionEx(@ScriptDir & "\IniFiles\" & $iniUID & "-"&$rSecNames[$i]&"-Inventory.ini", $rSecNames[$i])
					$iTemp[0][1] = $rSecNames[$i]
				EndIf
			;	_ArrayDisplay($iTemp)

				;ConsoleWrite($iTemp[0][1] & @LF)
				;If $debug Then
				;	_ArrayDisplay($iTemp)
				;EndIf
				For $e = 1 To $iTemp[0][0]
					;;Array Columns:
					;[0]		[1]			[2]					[3]				[4]					[5]		[6]			[7]
					;Item Name	Hash Name	Ini Json String		Icon URL(local)	Local IconPath		AppID	Marketable	Tradable
					;[8]		[9]			[10]	[11]	[12]			[13]			[14]	[15]					[16]			[17]
					;Amount		CacheExp	Type	NameClr	$lowestPrice	$medianPrice	Volume	Inspect in Game Link	I bought For	I Bought For -15% (Resell Above)

					ReDim $localInventory[$int + 1][23]
					$localInventory[$int][0] = _URIDecode($iTemp[$e][0])
					$localInventory[$int][1] = $iTemp[$e][0];HashItUpBro($iTemp[$e][0])
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
						$localInventory[$int][21] = Json_ObjGet($keyChain, "id")
						$localInventory[$int][22] = Json_ObjGet($keyChain, "float_value")
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

Func InventoryWrite($inVent, $user, $wType)
	For $i = 0 To UBound($inVent) - 1
		If $inVent[$i][5]= "753" Then
		IniWrite(@ScriptDir & "\IniFiles\" & $user & "-" &$inVent[$i][5]& "-" &$inVent[$i][18]&"-Inventory.ini", $inVent[$i][5], $inVent[$i][1], $inVent[$i][2])
		Else
		IniWrite(@ScriptDir & "\IniFiles\" & $user & "-"&$inVent[$i][5]&"-Inventory.ini", $inVent[$i][5], $inVent[$i][1], $inVent[$i][2])
		EndIf
	Next
EndFunc   ;==>InventoryWrite

Func HashItUpBro($sString)
	$tString = StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace(StringReplace($sString, "#", "%23"),"&","%26"), "'", "%27"), ":", "%3A"), "™", "%E2%84%A2"), " ", "%20"), "|", "%7C"), "(", "%28"), ")", "%29")
	Return $tString
EndFunc   ;==>HashItUpBro

Func InventoryItemFind($sID, $iType, $uID)

	Local $bArray[1][23], $n = 0, $m = 0, $removed = 0, $errorCount = 0, $errorArray[0], $vanityName, $idNumber = "",$secondaryName
	;;Array Columns:
	;[0]		[1]			[2]					[3]			[4]				[5]		[6]			[7]			[8]		[9]			[10]
	;Item Name	Hash Name	Ini Json String		Icon URL	Local IconPath	AppID	Marketable	Tradable	Amount	CacheExp	Type

	;[[11]		[12]			[13]			[14]		[15]					[16]			[17]			[18]			[19]		[20]			[21]		[22]
	;NameClr	$lowestPrice	$medianPrice	Volume		Inspect in Game Link	I bought For	Resell For		Inventory Type	ClassID		InstanceID		Asset ID	Float Value
	$apps = StringSplit($sID, ",")
	$types = StringSplit($iType, ",")
	$apPercent = 100 / $apps[0]
	;ConsoleWrite($apPercent)
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
				;ConsoleWrite("OBJECT YAY" & @LF)
				$vanityName = $uID
				if IniRead(@ScriptDir&"\IniFiles\VanityNames.ini","VanityNames",$vanityName,"") <> "" Then
					$idNumber = IniRead(@ScriptDir&"\IniFiles\VanityNames.ini","VanityNames",$vanityName,"")
				Else
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
					;ConsoleWrite(IsArray($rawr))
					If $rawr[0] = "steamid" Then
						$idNumber = Json_objGet($blah,$rawr[0])
						IniWrite(@ScriptDir &"\IniFiles\VanityNames.ini","VanityNames",$vanityName,$idNumber)
					EndIf
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
				ReDim $errorArray[$errorCount][5]
				$errorArray[$errorCount - 1][0] = "Error"
				$errorArray[$errorCount - 1][1] = $error
				$errorArray[$errorCount - 1][2] = $apps[$a]
				$errorArray[$errorCount - 1][3] = $types[$a]
				$errorArray[$errorCount - 1][4] = _GameLookup($apps[$a],$types[$a])
				If $debug Then _ArrayDisplay($errorArray)
			Else
				ReDim $errorArray[$errorCount][5]
				$errorArray[$errorCount - 1][0] = "Error"
				$errorArray[$errorCount - 1][1] = "User Does not own Game or JSON Syntax incorrect"
				$errorArray[$errorCount - 1][2] = $apps[$a]
				$errorArray[$errorCount - 1][3] = $types[$a]
				$errorArray[$errorCount - 1][4] = _GameLookup($apps[$a],$types[$a])
				If $debug Then _ArrayDisplay($errorArray)
			EndIf

		Else
			$float = False

			If $apps[$a] = "730" Then
				$floatValues = _FloatValues($webAPIKey,$idNumber,$appDirJSON,$progress);"C:\Work\Projects\Scripts\Steam\JSON\");
				if $debug Then _ArrayDisplay($floatValues)
				ConsoleWrite("Float Values [0][0] = " & $floatValues[0][0]&@LF)
				If $floatValues[0][0] <> "Error" Then
					$float = True
				Else
					$float = False
				EndIf
				ConsoleWrite("$float = " & $float &@LF)
			EndIf

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
;~ 				ConsoleWrite($fraction)  ----- DONT NEED THIS IN CONSOLE FOR NOW
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
					ReDim $bArray[$n + 1][23]
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
							Case "name"
								$secondaryName = $info[$p][1]
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
								;ConsoleWrite("IconURL" & @LF)   ----- DONT NEED THIS IN CONSOLE FOR NOW
								$bArray[$n][3] = $info[$p][1]
							Case "icon_url_large"
								;ConsoleWrite("IconURL_Large Overwrite" & @LF)   ----- DONT NEED THIS IN CONSOLE FOR NOW
								$bArray[$n][3] = $info[$p][1]
							Case "actions"
								$actions0 = Json_ObjGet($quickobj, $info[$p][0])
								;$name = Json_ObjGet($actions0[0],"name")
								$tempLink = Json_ObjGet($actions0[0], "link")
								If StringInStr($tempLink,"%owner_steamid%") AND $idNumber <> "" Then
									;ConsoleWrite("Getting to Here: " & @LF &@TAB &$idNumber& @LF &@TAB &$assetID &@LF)
									$templink = StringReplace($tempLink,"%owner_steamid%",$idNumber)
									$templink = StringReplace($tempLink,"%assetid%",$assetID)
								EndIf
								$bArray[$n][15] = $tempLink
								If $debug Then ConsoleWrite("Link:" & $bArray[$n][15] & @LF)

							Case "classid"
								$classID = $info[$p][1]
								$bArray[$n][19] = $classID
							Case "instanceid"
								$instanceID = $info[$p][1]
								$bArray[$n][20] = $instanceID

						EndSwitch
					Next

					$bArray[$n][18] = $types[$a]
					$bArray[$n][21] = $assetID



					If $bArray[$n][0] = "" Then
						$bArray[$n][0] = $secondaryName
						$bArray[$n][1] = _URIEncode($secondaryName)
					Endif

					if $float AND $bArray[$n][5] = "730" Then
						For $l = 0 to Ubound($floatValues)-1
							if $bArray[$n][21] = $floatValues[$l][0] Then
								$bArray[$n][22] = $floatValues[$l][1]
								ConsoleWrite("Float value for MarketHashName: " & $bArray[$n][1] & " is = " & $bArray[$n][22] &@LF)
								ExitLoop
							EndIf
						Next
					EndIf
					;-------------------------------------------------------------------------------------
					;-------------------------------------------------------THIS AREA MAY NEED WORK

						$amount = 0
						For $reggie = 0 To UBound($rgInventory) - 1
							If $rgInventory[$reggie][1] = $classID And $rgInventory[$reggie][2] = $instanceID Then
								$amount += 1

							EndIf
						Next


						$ubound = UBound($bArray) - 1
						For $mrMeeces = 0 To $ubound
							If $bArray[$n][1] = $bArray[$mrMeeces][1] Then
								If $n = $mrMeeces Then
									ContinueLoop
								Elseif Not($bArray[$mrMeeces][19] = $classID AND $bArray[$mrMeeces][20] = $instanceID) Then
									For $reggie = 0 To UBound($rgInventory) - 1
										If $rgInventory[$reggie][1] = $bArray[$mrMeeces][19] And $rgInventory[$reggie][2] = $bArray[$mrMeeces][20] Then
											$amount += 1
											;CONSOLEWRITE("UPINTHEHISOUSE") ------ DONT NEED THIS IN CONSOLE FOR NOW
										EndIf
									Next

									;ConsoleWrite(@LF&"Get to here?"&@LF)------ DONT NEED THIS IN CONSOLE FOR NOW



								EndIf
							EndIf
						Next

					;ConsoleWrite("Amount: " & $amount & @LF) ------ DONT NEED THIS IN CONSOLE FOR NOW
					$bArray[$n][8] = $amount
					;ConsoleWrite("$n = " & $n & @LF & "Ubound($bArray)-1 = " & UBound($bArray) - 1&@LF)------ DONT NEED THIS IN CONSOLE FOR NOW
					;-------------------------------------------------------------------------------------
					;-------------------------------------------------------------------------------------


					$file = ""
					If $bArray[$n][6] = 1 Then
						$hDownload = InetGet("http://steamcommunity.com/market/priceoverview/?currency=1&appid=" & $apps[$a] & "&market_hash_name=" & $bArray[$n][1], $appDirJSON & $bArray[$n][1] & ".JSON", -1, $INET_DOWNLOADBACKGROUND) ;; Change AppID to 753 works for Trading Cards
						Do
							Sleep(20)
						Until InetGetInfo($hDownload, $INET_DOWNLOADCOMPLETE)
						ConsoleWrite("Download Complete - http://steamcommunity.com/market/priceoverview/?currency=1&appid=" & $apps[$a] & "&market_hash_name=" & $bArray[$n][1]  & @LF)
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
					$additional = $additional & ",""id""" & ":""" & $bArray[$n][21] & """"
					If $bArray[$n][22] > 0 Then
					$additional = $additional & ",""float_value""" & ":""" & $bArray[$n][22] & """"
					EndIf

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
				ReDim $errorArray[$errorCount][5]
				$errorArray[$errorCount - 1][0] = "Error"
				$errorArray[$errorCount - 1][1] = "This Inventory was probably empty"
				$errorArray[$errorCount - 1][2] = $apps[$a]
				$errorArray[$errorCount - 1][3] = $types[$a]
				$errorArray[$errorCount - 1][4] = _GameLookup($apps[$a],$types[$a])

				If $debug Then _ArrayDisplay($errorArray)
			EndIf


		EndIf
		$m = UBound($bArray)


	Next
	GUICtrlSetData($progress, 0)
	If $debug Then
		_ArrayDisplay($bArray)
	EndIf
	If $errorCount > 0 Then
		$iString = "Errors Occured during Inventory Data grab:" & @LF
		For $i = 0 To $errorCount - 1
			$iString &= $errorArray[$i][4] & "-" &@LF&"App ID: " & $errorArray[$i][2] & " & Inventory Type: " & $errorArray[$i][3] & @LF & @TAB & "- " & $errorArray[$i][1] & @LF &@LF
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
	Local $i = 0, $listCount = 0, $totalLowestSell = 0, $lstate, $totalCount = 0
	if $marketableOnly AND $tradeOnly Then
			$lState = 2
	Elseif $marketableOnly and NOT ($tradeOnly) Then
	$lstate = 1
	ElseIf	$tradeOnly and NOT ($marketableOnly) Then
	$lstate = 3
	Else
	$lstate = 0
	EndIf
	ConsoleWrite("State = " & $lstate)
	_GUICtrlListView_DeleteAllItems($lView)
	Redim $listItems[0]
	$lolol = _GUIImageList_Create(48, 48)
	For $i = 0 To UBound($invArray) - 1
		Switch $lstate
			Case 2
				if $invArray[$i][6] = 0 OR $invArray[$i][7] = 0 Then
					ContinueLoop
				EndIf

			Case 1
				if $invArray[$i][6] = 0 Then
					ContinueLoop
				EndIf
			Case 3
				if $invArray[$i][7] = 0 Then
					ContinueLoop
				EndIf
		EndSwitch
;~ 		If $marketableOnly AND $invArray[$i][6] = 0 Then
;~ 			ContinueLoop
;~ 		EndIf
;~ 		If $tradeOnly AND $invArray[$i][7] = 0 Then
;~ 			ContinueLoop
;~ 		EndIf

		;ConsoleWrite("$i = " & $i &@LF &"Item: " & $invArray[$i][0])
		$hBitmap = _GDIPlus_BitmapCreateFromFile($invArray[$i][4])
		$hBitmap_Scaled = _GDIPlus_ImageResize($hBitmap, 48, 48)
		$hImagePNG = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hBitmap_Scaled)
		_GUIImageList_Add($lolol, $hImagePNG)
		;Item \ Column 0
		_GUICtrlListView_AddItem($lView, $invArray[$i][0], $listCount)

		if $invArray[$i][22] <> "" Then
			If $percentFloat Then
				_GUICtrlListView_AddSubItem($lView, $listCount, _FloatToPercent($invArray[$i][22]), 1)
			Else
				_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][22], 1)
			EndIf
		EndIf

		If $invArray[$i][6] = 0 Then ; If not Marketable Then say so in column 2, 3 & 4
			_GUICtrlListView_AddSubItem($lView, $listCount, "Not Marketable", 2)
			_GUICtrlListView_AddSubItem($lView, $listCount, "N/A", 3)
			_GUICtrlListView_AddSubItem($lView, $listCount, "N/A", 4)
		Else; If Marketable
			;Lowest Price \ Column 1
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][12], 2)
			If StringInStr($invArray[$i][12],"$") Then
			$tempLow = StringReplace($invArray[$i][12],"$","")
			$templow = $tempLow * $invArray[$i][8]
			$totalLowestSell = Round($totalLowestSell + $tempLow,2)
			;ConsoleWrite("Item: " & $invArray[$i][0] & "||  Price: " & $tempLow & "|| Total Price: " & $totalLowestSell &@LF)
			GUICtrlSetData($gItemsLowestSell,$totalLowestSell)
			Elseif StringInStr($invArray[$i][13],"$") Then
			$tempLow = StringReplace($invArray[$i][13],"$","")
			$templow = $tempLow * $invArray[$i][8]
			$totalLowestSell = Round($totalLowestSell + $tempLow,2)
			;ConsoleWrite("Item: " & $invArray[$i][0] & "||  Price: " & $tempLow & "|| Total Price: " & $totalLowestSell &@LF)
			GUICtrlSetData($gItemsLowestSell,$totalLowestSell)
			EndIf
			;Median Price \ Column 3
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][13], 3)
			;Volumee (24hr) \ Column 4
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][14], 4)
		EndIf
		;Amount (In inv) \ Column 5
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][8], 5)
		;Tradeable \ Column 6
		If $invArray[$i][7] = 1 Then
			_GUICtrlListView_AddSubItem($lView, $listCount, "Yes", 6)
		Else
			_GUICtrlListView_AddSubItem($lView, $listCount, "No", 6)
		EndIf
		;Purchase Price \ Column 7
		If $invArray[$i][16] <> "" Then
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][16], 7)
		Else
			;	_GUICtrlListView_AddSubItem($lView, $i, "N/A", 6)
		EndIf
		;Lowest Resell Price \ Column 8
		If $invArray[$i][17] <> "" Then
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][17], 8)
		Else
			;_GUICtrlListView_AddSubItem($lView, $i, "N/A", 7)
		EndIf
		;Type \ Column 9
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][10], 9)
		;Game \ Column 10
		_GUICtrlListView_AddSubItem($lView, $listCount, _GameLookup($invArray[$i][5]), 10)
		;AppID \ Column 11
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][5], 11)
		;CacheExp \ Column 12
		If $invArray[$i][9] <> "" Then
			_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][9], 12)
		Else
			_GUICtrlListView_AddSubItem($lView, $listCount, "N/A", 12)
		EndIf
		;Link \ Column 13
		_GUICtrlListView_AddSubItem($lView, $listCount, $invArray[$i][15], 13)
		_GDIPlus_ImageDispose($hBitmap)
		_WinAPI_DeleteObject($hImagePNG)
		ReDim $listItems[$listCount+1]
		$listItems[$listCount] = $i

		$listCount +=1
		$totalCount +=1*$invArray[$i][8]

	Next
	GUICtrlSetData($gItemsDisplayed, $listCount&"("&$totalCount&")")
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

Func _Preferred_NOTIFY($hWnd, $iMsg, $iwParam, $ilParam)
; structure to map $ilParam ($tNMHDR - see Help file)
	Local $tNMHDR = DllStructCreate($tagNMHDR, $ilParam)

	Local $hWndFrom, $iIDFrom, $iCode, $hWndListView, $tInfo

    $hWndFrom = HWnd(DllStructGetData($tNMHDR, "hWndFrom"))
    $iIDFrom = DllStructGetData($tNMHDR, "IDFrom")
    $iCode = DllStructGetData($tNMHDR, "Code")

	Switch $tNMHDR.IDFrom
		Case $listPreferred
			Switch $tNMHDR.Code
				Case $NM_CLICK
				Local $tInfo = DllStructCreate($tagNMITEMACTIVATE, $ilParam)
                If @error Then Return $GUI_RUNDEFMSG
                Local $Item = DllStructGetData($tInfo, "Index")
                If @error Or $Item = -1 Then Return $GUI_RUNDEFMSG

                Local $tTest = DllStructCreate($tagLVHITTESTINFO)
                DllStructSetData($tTest, "X", DllStructGetData($tInfo, "X"))
                DllStructSetData($tTest, "Y", DllStructGetData($tInfo, "Y"))
                Local $iRet = GUICtrlSendMsg($iIDFrom, $LVM_HITTEST, 0, DllStructGetPtr($tTest))
                If @error Or $iRet = -1 Then Return $GUI_RUNDEFMSG
                Switch DllStructGetData($tTest, "Flags")
                    Case $LVHT_ONITEMICON, $LVHT_ONITEMLABEL, $LVHT_ONITEM
                        If _GUICtrlListView_GetItemChecked($listPreferred, $Item) = False Then
                            _GUICtrlListView_SetItemChecked($listPreferred, $Item, 1)
                        Else
                            _GUICtrlListView_SetItemChecked($listPreferred, $Item, 0)
                        EndIf
                    Case $LVHT_ONITEMSTATEICON
						Consolewrite(";on checkbox"&@LF)
;~ 					$zInfo = DllStructCreate($tagNMLISTVIEW, $ilParam)
;~ 					If $zInfo.Item > -1 Then
;~ 						$zItem = $zInfo.Item;; WORKING BUT ONLY WHEN CLICKING ITEM (NOT CHECKBOX)
;~ 						if _GUICtrlListView_GetItemChecked($listPreferred,$zItem) Then
;~ 							_GUICtrlListView_SetItemChecked($listPreferred,$zItem,False)
;~ 						Else
;~ 							_GUICtrlListView_SetItemChecked($listPreferred,$zItem)
;~ 						EndIf
;~ 					Endif
				EndSwitch
				EndSwitch
	EndSwitch
EndFunc

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
		Case $idproc5
			GUICtrlSendToDummy($dummy_proc5)
	EndSwitch
EndFunc   ;==>WM_COMMAND

Func _GameLookup($iGame, $omfgVariable = -1, $reverse = 0)
	Local $returnArray[2]
	Switch $reverse
		Case 0 ;; From App ID Give Text Info - Game Name
		Switch $iGame
			Case "730"
				Return "CS:GO"
			Case "440"
				Return "TF2"
			Case "570"
				Return "Dota 2"
			Case "753"
				If $omfgVariable > -1 Then
					Switch $omfgVariable
						Case 1
							Return "Steam Community: Games & Gifts"
						Case 6
							Return "Steam Community: Trading Cards & Emotes"
					EndSwitch
					Else
					Return "Steam Community"
				EndIf
			Case "238460"
				Return "BattleBlock Theater"
			Case "252490"
				Return "Rust"

		EndSwitch
		Case 1
			Switch $iGame
				Case "CSGO"
					$returnArray[0] = "730"
					$returnArray[1] = "2"
					Return $returnArray
				Case "TF2"
					$returnArray[0] = "440"
					$returnArray[1] = "2"
					Return $returnArray
				Case "Dota 2"
					$returnArray[0] = "570"
					$returnArray[1] = "2"
					Return $returnArray
				Case "Games & Gifts"
					$returnArray[0] = "753"
					$returnArray[1] = "1"
					Return $returnArray
				Case "Trading Cards & Emotes"
					$returnArray[0] = "753"
					$returnArray[1] = "6"
					Return $returnArray
				Case "BattleBlock Theater"
					$returnArray[0] = "238460"
					$returnArray[1] = "2"
					Return $returnArray
				Case "Rust"
					$returnArray[0] = "252490"
					$returnArray[1] = "2"
					Return $returnArray
			EndSwitch
	EndSwitch
Endfunc

Func _FloatToPercent($iFloat)
	Select
		Case $iFloat >= 0 AND $iFloat < 0.07
			$a = $iFloat/0.07
			$b = 1-$a
			$c = "(Factory New)"
		Case $iFloat >=0.07 AND $iFloat < 0.15
			$a = ($iFloat-0.07)/0.08
			$b = 1-$a
			$c = "(Minimal Wear)"
		Case $iFloat >=0.15 AND $iFloat < 0.37
			$a = ($iFloat-0.15)/0.22
			$b = 1-$a
			$c = "(Field-Tested)"
		Case $iFloat >=0.37 AND $iFloat < 0.44
			$a = ($iFloat-0.37)/0.07
			$b = 1-$a
			$c = "(Well-Worn)"
		Case $iFloat >= 0.44 AND $iFloat <= 1
			$a = ($iFloat-0.44)/0.56
			$b = 1-$a
			$c = "(Battle-Scarred)"
	EndSelect
	$d = Round($b*100,2)
	If $d < 10 Then
		$b = "0" & $d & "% " & $c
	Else
		$b = $d & "% " & $c
	EndIf
	Return $b
EndFunc