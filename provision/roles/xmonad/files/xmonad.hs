import XMonad
import XMonad.Config.Gnome
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Actions.CycleRecentWS
import XMonad.Actions.DynamicWorkspaceGroups
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.DynamicLog
import XMonad.Layout.NoBorders
import XMonad.Util.EZConfig
import XMonad.Util.NamedScratchpad
import XMonad.Prompt
import qualified Data.Map as M
import qualified XMonad.StackSet as W

myWorkspaces = ["1","2","3","4","5","6","7","8","9","0"]

myModKey = mod4Mask

-- Non-numeric num pad keys, sorted by number 
numPadKeys = [ xK_KP_End,  xK_KP_Down,  xK_KP_Page_Down -- 1, 2, 3
             , xK_KP_Left, xK_KP_Begin, xK_KP_Right     -- 4, 5, 6
             , xK_KP_Home, xK_KP_Up,    xK_KP_Page_Up   -- 7, 8, 9
             , xK_KP_Insert] -- 0

isTermScratchPad = (className =? "term-scratch")
isKeepass = (className =? "KeePass2")
isGuayadeque = (className =? "Guayadeque")

myTmuxCommand = "tmux -2 new"
myScratchCommand = "gnome-terminal --disable-factory --class=term-scratch --window-with-profile=Scratchpad -e '" ++ myTmuxCommand ++ "'"
myTerminal = "gnome-terminal -e '" ++ myTmuxCommand ++ "'"

myScratchpads = 
	[
		NS "keepass2" "keepass2" isKeepass nonFloating
		, NS "terminal" myScratchCommand isTermScratchPad nonFloating
		, NS "guayadeque" "guayadeque" isGuayadeque nonFloating
	]

myXPConfig = defaultXPConfig
	{
		font = "xft: ubuntu-mono-10"
		,promptBorderWidth = 0
	}

myDemuConfig = " -l 20 -fn ubuntu-mono-10 "

-- general keysimport XMonad.Prompt
myKeys =
	[  
	((myModKey, xK_p), spawn ("dmenu_run" ++ myDemuConfig)) 
	, ((myModKey .|. shiftMask, xK_p), spawn ("p=`echo '' | dmenu -fn ubuntu-mono-10 -p 'Open File:'` && d=`locate $p | dmenu" ++ myDemuConfig ++ "` && gnome-open $d"))
	, ((myModKey, xK_g), gotoMenuArgs ["-fn", "ubuntu-mono-10", "-l", "20"])
	, ((myModKey .|. shiftMask, xK_g), goToSelected defaultGSConfig)
	, ((myModKey .|. shiftMask, xK_b), bringMenuArgs ["-fn", "ubuntu-mono-10", "-l", "20"])
	, ((myModKey, xK_grave), cycleRecentWS [xK_Super_L] xK_grave xK_grave)
    	-- close focused window
	, ((myModKey, xK_x), kill)
	]
	++
	-- make the 0 button go to the 0 worksapce
	[
	((myModKey, xK_0), windows $ W.greedyView "0")
	, ((myModKey .|. shiftMask, xK_0), withFocused (\w -> do { windows $ W.shift "0" }))
	]
	++
	-- numberpad
	[((m .|. myModKey, k), windows $ f i)
		| (i, k) <- zip myWorkspaces numPadKeys
		, (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
	]
	++
	-- named scratch pads
	[
		((myModKey .|. controlMask, xK_k), namedScratchpadAction myScratchpads "keepass2")
		,((myModKey, xK_F12), namedScratchpadAction myScratchpads "terminal")
		,((myModKey, xK_F3), namedScratchpadAction myScratchpads "guayadeque")
	]
	-- dynamic workspace groups
	++
	[
		((myModKey .|. controlMask, xK_a), promptWSGroupAdd myXPConfig "Name this group: ")
		, ((myModKey, xK_m), promptWSGroupView myXPConfig "Go to group: ")
		, ((myModKey .|. controlMask, xK_f), promptWSGroupForget myXPConfig "Forget group: ")
	]

myManageHook = 
	[
		isFullscreen --> doFullFloat
		,isTermScratchPad --> doFloat
		,isKeepass --> doCenterFloat
		,isGuayadeque --> doCenterFloat
	]
	-- IntelliJ Tweaks
	++
	[
		--ignore IntelliJ autocomplete
		appName =? "sun-awt-X11-XWindowPeer" <&&> className =? "jetbrains-idea" --> doIgnore
	]

main = xmonad $ gnomeConfig {
	modMask = myModKey
	, terminal = myTerminal
	, focusedBorderColor = "#008db8"
	, workspaces = myWorkspaces
	, layoutHook = smartBorders (layoutHook gnomeConfig)
	, manageHook = manageHook gnomeConfig <+> composeAll myManageHook
	, startupHook = do
           startupHook gnomeConfig
           setWMName "LG3D"
} `additionalKeys` myKeys

{-|
	## TODO list ##
	- dmenu open-terminal?	- dynamic workspace groups: http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Actions-DynamicWorkspaceGroups.html
-}


