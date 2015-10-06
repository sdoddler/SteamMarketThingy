#################################################################################
#			sDoddler's Steam Market Thingy				#
#			   Created by Stephen Dodd				#
#				06-10-2015					#
#				   v.01						#
#################################################################################


				What is it?
---------------------------------------------------------------------------------
This program was created to help manage and view Steam Inventories.

-It gathers data from both the Steam Market JSONs and Steam WebAPI.
-It allows users to view the associated content for each item: Icon, Wallpaper & 
Link to website(or wiki) or to inspect in game. As well as displaying the current 
market value.

-It can also display a price history graph for items (further back than 30 days)
-And allows users to filter and display items per AppID, Only Marketable items and/or
only Tradeable items.
-Users can also add how much they bought the item for in $ or Keys.

				Installation
---------------------------------------------------------------------------------
The Program runs as a standalone executable (.exe) and should run on most Windows
devices. Osias has tested and confirmed it works on Windows 10 however there
may be some compatibility issues - let me know if you experience anything.

The Program creates a IniFiles Folder & a Settings.ini in the same Directory as 
the executeable (I would put the Executeable in a folder wherever you like then
shortcut it.)

The Program also stores some files in AppData\SteamMarketThingy such as the
.ico files and the Images downloaded from the steam Servers. The temporary .JSON
files are also stored here however they are normally deleted as soon as they are
used within the program (instantaneous).

				Source
----------------------------------------------------------------------------------
I have included the source files for anyone else to take a look at and use if they
can. Apologies in advance for my poor coding standards\practices.
There is only one EXCLUSION from the source code which is my webAPIKey. (variable:
$webAPIKey = XXXXXXXXXXXXXXXXXX in the source code)
As Steam requires users to signup for a webAPIKey via their website:
http://steamcommunity.com/dev/apikey
Due to the fact that it is unique to everyone I think this could be exploited if
left in the source code.

				Thanks
----------------------------------------------------------------------------------
Thanks to the Authors of the User Defined Functions Included in this script:
Ward (json.au3)
FichteFoll (Iniex.au3)
CreatoR's Lab (G.Sandler) (GUIHyperlink.au3)
And to those that helped Create the other Included Files in this script:
 <Inet.au3>
 <array.au3>
 <string.au3>
 <Date.au3>
 <GUIConstantsEx.au3>
 <WindowsConstants.au3>
 <Editconstants.au3>
 <GDIPlus.au3>
 <WinAPIEx.au3>
 <GuiImageList.au3>
 <GuiListView.au3>
 <GuiMenu.au3>
 <ProgressConstants.au3>

Thanks to the AutoIT Community and Forum Members.
Thanks to Osias and CynicalCynanide for Testing and providing valuable feedback.

				About
----------------------------------------------------------------------------------
This Program was written in AutoIT Language (3.3.12.0)
Using SciTE v.3.5.4.0

				License
----------------------------------------------------------------------------------
Copyright (c) 2015, Stephen Dodd

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.