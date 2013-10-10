import XMonad
import XMonad.Config.Gnome
import XMonad.Actions.WindowBringer
import XMonad.Actions.GridSelect
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.NoBorders
import XMonad.Util.EZConfig
import qualified Data.Map as M
import qualified XMonad.StackSet as W

myWorkspaces = ["1","2","3","4","5","6","7","8","9","0"]

myModKey = mod4Mask

-- Non-numeric num pad keys, sorted by number 
numPadKeys = [ xK_KP_End,  xK_KP_Down,  xK_KP_Page_Down -- 1, 2, 3
             , xK_KP_Left, xK_KP_Begin, xK_KP_Right     -- 4, 5, 6
             , xK_KP_Home, xK_KP_Up,    xK_KP_Page_Up   -- 7, 8, 9
             , xK_KP_Insert] -- 0

-- general keys
myKeys =[  ((myModKey, xK_p), spawn "dmenu_run -l 20 -fn ubuntu-mono-10") 
	, ((myModKey .|. shiftMask, xK_p), spawn "p=`find -type d | dmenu -fn ubuntu-mono-10 -l 20` && nautilus $p")
	, ((myModKey .|. shiftMask, xK_g     ), gotoMenuArgs ["-fn", "ubuntu-mono-10", "-l", "20"])
	, ((myModKey, xK_g), goToSelected defaultGSConfig)
	, ((myModKey .|. shiftMask, xK_b     ), bringMenuArgs ["-fn", "ubuntu-mono-10", "-l", "20"]) ]
	++
	-- numberpad
	[((m .|. myModKey, k), windows $ f i)
		| (i, k) <- zip myWorkspaces numPadKeys
		, (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
	]

myManageHook = 
	[
		className =? "Guake" --> doFloat
		,isFullscreen --> doFullFloat
		,isDialog <&&> className =? "jetbrains-idea" --> doIgnore --ignore IntelliJ autocomplete
	]

main = xmonad $ gnomeConfig {
	modMask = myModKey
	,workspaces = myWorkspaces
	,layoutHook = smartBorders (layoutHook gnomeConfig)
	,manageHook = manageHook gnomeConfig <+> composeAll myManageHook
	,startupHook = do
           startupHook gnomeConfig
           setWMName "LG3D"
} `additionalKeys` myKeys

{-|
	## TODO list ##
	- make the 0 workspace work ((mod .|. shiftMask, xK_0), withFocused (\w -> do { windows $ W.shift "0" }))
	((mod,xK_0), windows $ W.view "0")
	((mod .|. shiftMask, xK_0), withFocused (\w -> do { windows $ W.shift "0" }))
	- work out what is up with Keypass
	- scratchpad to replace guake
	- scratchpad for Keepass
	- dmenu open-terminal?
-}


