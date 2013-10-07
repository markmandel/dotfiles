import XMonad
import XMonad.Config.Gnome
import qualified Data.Map as M
import XMonad.Actions.WindowBringer

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
	[  ((modm, xK_p), spawn "dmenu_run -l 20 -fn ubuntu-mono-10") 
	, ((modm .|. shiftMask, xK_p), spawn "p=`find -type d | dmenu -fn ubuntu-mono-10 -l 20` && nautilus $p")
	, ((modm .|. shiftMask, xK_g     ), gotoMenuArgs ["-fn", "ubuntu-mono-10", "-l", "20"])
	, ((modm .|. shiftMask, xK_b     ), bringMenuArgs ["-fn", "ubuntu-mono-10", "-l", "20"]) ]

main = xmonad gnomeConfig {
	modMask = mod4Mask,
	keys = myKeys <+> keys gnomeConfig
}
