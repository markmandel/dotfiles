{-|
Copyright 2021 Google LLC All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
-}

import qualified Data.Map                              as M
import           XMonad
import           XMonad.Actions.CopyWindow
import           XMonad.Actions.CycleRecentWS
import           XMonad.Actions.DynamicWorkspaceGroups
import           XMonad.Actions.GridSelect
import           XMonad.Actions.WindowBringer
import           XMonad.Config.Gnome
import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers
import           XMonad.Hooks.SetWMName
import           XMonad.Layout.NoBorders
import           XMonad.Layout.Spiral
import           XMonad.Layout.Tabbed
import           XMonad.Layout.ThreeColumns
import           XMonad.Prompt
import qualified XMonad.StackSet                       as W
import           XMonad.Util.EZConfig
import           XMonad.Util.EZConfig
import           XMonad.Util.NamedScratchpad
import           Graphics.X11.ExtraTypes.XF86
import           XMonad.Util.WindowProperties

myWorkspaces = ["1","2","3","4","5","6","7","8","9","0"]

myModKey = mod4Mask
altMask = mod1Mask

-- Non-numeric num pad keys, sorted by number
numPadKeys = [ xK_KP_End,  xK_KP_Down,  xK_KP_Page_Down -- 1, 2, 3
             , xK_KP_Left, xK_KP_Begin, xK_KP_Right     -- 4, 5, 6
             , xK_KP_Home, xK_KP_Up,    xK_KP_Page_Up   -- 7, 8, 9
             , xK_KP_Insert] -- 0

isTermScratchPad = (className =? "Gnome-terminal") <&&> (stringProperty "WM_WINDOW_ROLE" =? "Scratchpad")
isKeepass = (className =? "KeePassXC")
isCopyQ = (className =? "copyq")
isGTKFileChooser = (propertyToQuery (Role "GtkFileChooserDialog"))
isPeek = (className =? "Peek")

myTmuxCommand = "tmux -2 new"
myScratchCommand = "gnome-terminal --role=Scratchpad -e '" ++ myTmuxCommand ++ "'"
myTerminal = "gnome-terminal -e '" ++ myTmuxCommand ++ "'"
volumeNotify = " --max-volume 100 --get-volume | awk '{print $1}' | xargs -I{} notify-send Volume: {}% -i audio-volume-medium -h string:synchronous:volume"

myScratchpads =
	[
        NS "keepassxc" "keepassxc" isKeepass nonFloating
        , NS "terminal" myScratchCommand isTermScratchPad nonFloating
        , NS "copyq" "copyq show" isCopyQ nonFloating
	]

-- general keysimport XMonad.Prompt[
myKeys =
	[
	((myModKey, xK_p), spawn ("rofi -modi combi -show combi -combi-modi run,drun"))
	, ((myModKey .|. shiftMask, xK_p), spawn ("p=$(rofi -dmenu -p 'Open File:') && locate \"$p\" | rofi -dmenu -p 'open: ' | xargs xdg-open"))
	, ((myModKey .|. shiftMask .|. controlMask, xK_j), spawn ("q=$(rofi -dmenu -p 'Emoji:') && curl -G https://api.getdango.com/api/emoji --data-urlencode \"q=$q\" | jq '.results[].text' -r | rofi -multi-select -dmenu | xclip -sel clip"))
	, ((myModKey .|. controlMask, xK_j), spawn ("rofimoji --skin-tone ask --action clipboard"))
	, ((myModKey, xK_g), spawn ("rofi -show window"))
	, ((myModKey .|. shiftMask, xK_b), bringMenuArgs' "rofi" [ "-dmenu" ])
	, ((myModKey, xK_grave), cycleRecentWS [xK_Super_L] xK_grave xK_grave)
	-- , ((mod1Mask .|. shiftMask, xK_a), spawn ("keepassxc"))
	, ((myModKey, xK_x), kill) -- close focused window
	, ((myModKey .|. shiftMask, xK_x), kill1) -- close only the copy of the window
        -- these shortcut keys aren't working under gnome anymore, so let's define them
        , ((altMask .|. controlMask, xK_l ), spawn ("cinnamon-screensaver-command -l"))
	]
	-- Media/Function keys
	++
	[ ((0, xF86XK_AudioRaiseVolume), spawn ("pulsemixer --unmute --change-volume +5" ++ volumeNotify))
	, ((0, xF86XK_AudioLowerVolume), spawn ("pulsemixer --change-volume -5" ++ volumeNotify))
	, ((0, xF86XK_AudioMute), spawn "pulsemixer --toggle-mute --get-mute | xargs -I{} notify-send Muted: {} -i audio-volume-medium -h string:synchronous:volume")

	, ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
	, ((0, xF86XK_AudioPrev), spawn "playerctl previous")
	, ((0, xF86XK_AudioNext), spawn "playerctl next")
	, ((0, xF86XK_AudioStop), spawn "playerctl stop")

	, ((0, xF86XK_MonBrightnessUp), spawn "lux -a 5% && notify-send \"Brightness: $(lux -G)\" -i video-display -h string:synchronous:brightness")
	, ((0, xF86XK_MonBrightnessDown), spawn "lux -s 5% && notify-send \"Brightness: $(lux -G)\" -i video-display -h string:synchronous:brightness")
  , ((0, xF86XK_Sleep), spawn "systemctl suspend")
  , ((0, xK_Print), spawn "flameshot gui")
	]
	++
	-- map all my workspaces
	-- mod-[1..9] @@ Switch to workspace N
	-- mod-shift-[1..9] @@ Move client to workspace N
	-- mod-control-shift-[1..9] @@ Copy client to workspace N
	[((m .|. myModKey, k), windows $ f i)
	    | (i, k) <- zip myWorkspaces [xK_1 ..]
	    , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]
	++
        -- make the 0 button go to the 0 workspace
        [((myModKey, xK_0), windows $ W.greedyView "0")
        , ((myModKey .|. shiftMask, xK_0), withFocused (\w -> do { windows $ W.shift "0" }))
        , ((myModKey .|. shiftMask .|. controlMask, xK_0), withFocused (\w -> do { windows $ copy "0" }))]
        ++
	-- numberpad
	[((m .|. myModKey, k), windows $ f i)
		| (i, k) <- zip myWorkspaces numPadKeys
		-- shift will send, but ctrl+shift will copy the window to the workspace
		, (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask), (copy, shiftMask .|. controlMask)]]
	++
	-- named scratch pads
	[
        ((myModKey .|. controlMask, xK_k), namedScratchpadAction myScratchpads "keepassxc")
        ,((myModKey, xK_F12), namedScratchpadAction myScratchpads "terminal")
        , ((shiftMask .|. controlMask, xK_a ), namedScratchpadAction myScratchpads "copyq")
	]
	-- dynamic workspace groups
	++
	[
		((myModKey .|. controlMask, xK_a), promptWSGroupAdd myXPConfig "Name this group: ")
		, ((myModKey, xK_m), promptWSGroupView myXPConfig "Go to group: ")
		, ((myModKey .|. controlMask, xK_f), promptWSGroupForget myXPConfig "Forget group: ")
	]
	where
	myXPConfig = defaultXPConfig
	             {
              		font = "xft: ubuntu-mono-10"
              		,promptBorderWidth = 0
              	     }


myLayout = tiled ||| Mirror tiled ||| ThreeCol 1 (3/100) (1/2) ||| spiral (toRational (2/(1+sqrt(5)::Double))) ||| noBorders simpleTabbed ||| noBorders Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio

     -- The default number of windows in the master pane
     nmaster = 1

     -- Default proportion of screen occupied by master pane
     ratio   = 1/2

     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

myManageHook =
	[
		isFullscreen --> doFullFloat
		,isTermScratchPad --> floatRect
		,isKeepass --> doCenterFloat
		,(className =? "Zenity") --> doCenterFloat
		,isCopyQ --> doRectFloat (W.RationalRect 0.25 0.25 0.5 0.75)
		,isGTKFileChooser --> doRectFloat (W.RationalRect 0 0 0.75 0.75)
		,isPeek --> doIgnore
		
	]
	where floatRect = doRectFloat(W.RationalRect 0 0 0.9 0.9)
	

main = xmonad $ gnomeConfig {
	modMask = myModKey
	, terminal = myTerminal
	, focusedBorderColor = "#2aa198"
	, workspaces = myWorkspaces
	, layoutHook = avoidStruts $ smartBorders $ myLayout
	, manageHook = manageHook gnomeConfig <+> composeAll myManageHook
	, startupHook = do
           startupHook gnomeConfig
           setWMName "LG3D"
} `additionalKeys` myKeys
