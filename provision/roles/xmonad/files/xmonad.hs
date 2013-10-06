import XMonad
import XMonad.Config.Gnome
import qualified Data.Map as M

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
	[  ((modm, xK_p), spawn "dmenu_run") 
	, ((modm .|. shiftMask, xK_p), spawn "p=`find -type d | dmenu -l 20` && nautilus $p") ]

main = xmonad gnomeConfig {
	modMask = mod4Mask,
	keys = myKeys <+> keys gnomeConfig
}
