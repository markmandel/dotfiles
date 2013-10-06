import XMonad
import XMonad.Config.Gnome
import qualified Data.Map as M
import XMonad.Actions.WindowBringer

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
	[  ((modm, xK_p), spawn "dmenu_run") 
	, ((modm .|. shiftMask, xK_p), spawn "p=`find -type d | dmenu -l 20` && nautilus $p")
	, ((modm .|. shiftMask, xK_g     ), gotoMenu)
	, ((modm .|. shiftMask, xK_b     ), bringMenu) ]

main = xmonad gnomeConfig {
	modMask = mod4Mask,
	keys = myKeys <+> keys gnomeConfig
}
