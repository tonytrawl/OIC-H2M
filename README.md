Version 0.5

I noticed there wasn’t a One in the Chamber mode in the game, so I ported the functionality over this afternoon.  You can run this by either replacing dm.gsc, or by calling it separately from your own GSC calling on main() Just make sure if you’re not replacing dm.gsc, you launch it under Free For All , that’s needed to keep everything working correctly.

I used the escort waypoint as the visual to track player lives, if you’d rather use a different hud element to track this you can switch the HUD by Ctrl+F  "waypoint_escort" and inputing whatever you prefer. The code is far from pretty or polished so if anyone has any questions on how to impliment or adjust features feel free to shoot me a message. 
