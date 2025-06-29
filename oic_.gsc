// .------------------------------------------------------------------------------.
// | /$$$$$$$                       /$$                     /$$                   |
// || $$__  $$                     | $$                    | $$                   |
// || $$  \ $$ /$$$$$$   /$$$$$$  /$$$$$$    /$$$$$$   /$$$$$$$                   |
// || $$$$$$$//$$__  $$ /$$__  $$|_  $$_/   /$$__  $$ /$$__  $$                   |
// || $$____/| $$  \ $$| $$  \__/  | $$    | $$$$$$$$| $$  | $$                   |
// || $$     | $$  | $$| $$        | $$ /$$| $$_____/| $$  | $$                   |
// || $$     |  $$$$$$/| $$        |  $$$$/|  $$$$$$$|  $$$$$$$                   |
// ||__/      \______/ |__/         \___/   \_______/ \_______/                   |
// |                                                                              |
// |                                                                              |
// |                                                                              |
// | /$$                                                                          |
// || $$                                                                          |
// || $$$$$$$  /$$   /$$                                                          |
// || $$__  $$| $$  | $$                                                          |
// || $$  \ $$| $$  | $$                                                          |
// || $$  | $$| $$  | $$                                                          |
// || $$$$$$$/|  $$$$$$$                                                          |
// ||_______/  \____  $$                                                          |
// |           /$$  | $$                                                          |
// |          |  $$$$$$/                                                          |
// |           \______/                                                           |
// | /$$$$$$$$                         /$$$$$$$$                               /$$|
// ||__  $$__/                        |__  $$__/                              | $$|
// |   | $$  /$$$$$$  /$$$$$$$  /$$   /$$| $$  /$$$$$$  /$$$$$$  /$$  /$$  /$$| $$|
// |   | $$ /$$__  $$| $$__  $$| $$  | $$| $$ /$$__  $$|____  $$| $$ | $$ | $$| $$|
// |   | $$| $$  \ $$| $$  \ $$| $$  | $$| $$| $$  \__/ /$$$$$$$| $$ | $$ | $$| $$|
// |   | $$| $$  | $$| $$  | $$| $$  | $$| $$| $$      /$$__  $$| $$ | $$ | $$| $$|
// |   | $$|  $$$$$$/| $$  | $$|  $$$$$$$| $$| $$     |  $$$$$$$|  $$$$$/$$$$/| $$|
// |   |__/ \______/ |__/  |__/ \____  $$|__/|__/      \_______/ \_____/\___/ |__/|
// |                            /$$  | $$                                         |
// |                           |  $$$$$$/                                         |
// |                            \______/                                          |
// '------------------------------------------------------------------------------'

main()
{
    if ( getdvar( "mapname" ) == "mp_background" )
        return;

    maps\mp\gametypes\_globallogic::init();
    maps\mp\gametypes\_callbacksetup::setupcallbacks();
    maps\mp\gametypes\_globallogic::setupcallbacks();

    if ( isusingmatchrulesdata() )
    {
        level.initializematchrules = ::initializematchrules;
        [[ level.initializematchrules ]]();
        level thread maps\mp\_utility::reinitializematchrulesonmigration();
    }
    else
    {
        maps\mp\_utility::registerroundswitchdvar( level.gametype, 0, 0, 9 );
        maps\mp\_utility::registertimelimitdvar( level.gametype, 10 );
        maps\mp\_utility::registerscorelimitdvar( level.gametype, 30 );
        maps\mp\_utility::registerroundlimitdvar( level.gametype, 1 );
        maps\mp\_utility::registerwinlimitdvar( level.gametype, 1 );
        maps\mp\_utility::registernumlivesdvar( level.gametype, 3 ); // Set 3 lives
        maps\mp\_utility::registerhalftimedvar( level.gametype, 0 );
        level.matchrules_damagemultiplier = 0;
        level.matchrules_vampirism = 0;
    }

    level.teambased = 0; // Free For All mode
    level.classicgamemode = 1;
    level.onstartgametype = ::onstartgametype;
    level.getspawnpoint = ::getspawnpoint;
    level.onnormaldeath = ::onnormaldeath;
    level.onspawnplayer = ::onspawnplayer;
    level.onplayerkilled = ::onplayerkilled;
    level.onplayerconnect = ::onplayerconnect;
    level.modifyplayerdamage = ::modifyplayerdamage;
    level.onrespawn = ::onrespawn; // New respawn handler
	 precacheshader( "hud_icon_desert_eagle" );
    precacheshader( "waypoint_escort" );

    game["dialog"]["gametype"] = "one_in_the_chamber";
    game["strings"]["overtime_hint"] = &"MP_ONE_IN_THE_CHAMBER";
	setdvar( "ui_allow_teamchange", 0 );
    setdvar( "scr_player_forcerespawn", 1 );
	setdvar( "g_gametype", "dm" );
	setDvar("scr_game_allowkillstreaks", "0");

    level thread monitorplayers();
	
}

initializematchrules()
{
    maps\mp\_utility::setcommonrulesfrommatchrulesdata();
    setdynamicdvar( "scr_dm_roundswitch", 0 );
    maps\mp\_utility::registerroundswitchdvar( "dm", 0, 0, 9 );
    setdynamicdvar( "scr_dm_roundlimit", 1 );
    maps\mp\_utility::registerroundlimitdvar( "dm", 1 );
    setdynamicdvar( "scr_dm_winlimit", 1 );
    maps\mp\_utility::registerwinlimitdvar( "dm", 1 );
    setdynamicdvar( "scr_dm_halftime", 0 );
    maps\mp\_utility::registerhalftimedvar( "dm", 0 );
    setdynamicdvar( "scr_dm_numlives", 3 ); // Reinforce 3 lives
}

onstartgametype()
{
    setclientnamemode( "auto_change" );

    maps\mp\_utility::setobjectivetext( "all", &"OBJECTIVES_OITC" );
    if ( level.splitscreen )
        maps\mp\_utility::setobjectivescoretext( "all", &"OBJECTIVES_OITC" );
    else
        maps\mp\_utility::setobjectivescoretext( "all", &"OBJECTIVES_OITC_SCORE" );

    maps\mp\_utility::setobjectivehinttext( "all", &"OBJECTIVES_OITC_HINT" );
    initspawns();
    var_0[0] = level.gametype;
    maps\mp\gametypes\_gameobjects::main( var_0 );

    // Disable class selection and enforce respawn
    setdvar( "ui_allow_teamchange", 0 );
    setdvar( "scr_player_forcerespawn", 1 );
    setdvar( "scr_dm_numlives", 3 ); // Ensure global lives setting
		setdvar( "scr_dm_scorelimit", 5000 );// Ensure global lives setting
	setdvar( "sv_disableCustomClasses", 1 );
	setdvar( "ui_allow_teamchange", 0 );
	setdvar( "scr_game_perks", 0 );
	setdvar( "scr_disable_cac", 1 );
	setdvar( "scr_disable_weapondrop", 1 );
	setdvar( "ammocounterhide", 1 );
	setdvar( "actionslotshide", 1 );
}

initspawns()
{
    level.spawnmins = ( 0, 0, 0 );
    level.spawnmaxs = ( 0, 0, 0 );
    maps\mp\gametypes\_spawnlogic::addspawnpoints( "all", "mp_tdm_spawn" );
    level.mapcenter = maps\mp\gametypes\_spawnlogic::findboxcenter( level.spawnmins, level.spawnmaxs );
    setmapcenter( level.mapcenter );
}

getspawnpoint()
{
    if ( level.usestartspawns && level.ingraceperiod )
        var_0 = maps\mp\gametypes\_spawnlogic::getbeststartspawn( "mp_tdm_spawn" );
    else
    {
        var_1 = maps\mp\gametypes\_spawnlogic::getteamspawnpoints( "all" );
        var_0 = maps\mp\gametypes\_spawnscoring::getspawnpoint_awayfromenemies( var_1, "all" );
    }

    maps\mp\gametypes\_spawnlogic::recon_set_spawnpoint( var_0 );
    return var_0;
}

monitorplayers()
{
    level endon( "game_ended" );
    for ( ;; )
    {
        level waittill( "connected", player );
        player thread onplayerconnect();
        player thread onplayerspawnloop();
        player thread onplayerkilledloop();
        player thread cleanupHUDOnDisconnect(); // Clean up HUD on disconnect\
		
    }
}

onplayerconnect()
{
    self endon( "disconnect" );

    // Initialize lives and elimination status
	self.pers["class"] = 0; 
    self.pers["lives"] = 3;
    self.pers["eliminated"] = 0;
    self setclientdvar( "scr_dm_numlives", 3 ); // Set client-side lives
	self setClientDvar("ui_allow_classchange", "0");  // Disables class change UI
            self setClientDvar("ui_allow_weaponchange", "0"); // Optional: Disables weapon swap menu
            self setClientDvar("class", "Assault"); // Force to custom1 class

    // Assign weapon
    self maps\mp\_utility::_giveweapon( "h2_deserteagle_mp" );
    self setweaponammoclip( "h2_deserteagle_mp", 1 );
    self setweaponammostock( "h2_deserteagle_mp", 0 );
    self switchtoweapon( "h2_deserteagle_mp" );

    self iprintlnbold( "Ported by TonyTrawl" );

    // Initialize life counter HUD
    self thread updateLifeCounter();
	self thread playIntroText();
}

onplayerspawnloop()
{
    self endon( "disconnect" );
    for ( ;; )
    {
        self waittill( "spawned_player" );
        self onspawnplayer();
		self testSimpleHud();
		self unsetPerk( "all" );
		self setPerk( "specialty_unlimitedsprint" );
    }
}

onspawnplayer()
{

    // Ensure player is in playing state if they have lives
    if ( self.pers["lives"] > 0 && !isdefined( self.pers["eliminated"] ) || self.pers["eliminated"] == 0 )
    {
        self.sessionstate = "playing";
        self allowspectateteam( "all", false ); // Prevent spectating while alive

        // Clear all weapons
        self takeallweapons();

        // Assign pistol with one bullet
        self maps\mp\_utility::_giveweapon( "h2_deserteagle_mp" );
        wait( 0.1 ); // Ensure weapon is registered
        if ( self hasweapon( "h2_deserteagle_mp" ) )
        {
            self setweaponammoclip( "h2_deserteagle_mp", 1 );
            self setweaponammostock( "h2_deserteagle_mp", 0 );
            self switchtoweapon( "h2_deserteagle_mp" );
        }
        else
        {
            self iprintlnbold( "ERROR: Failed to assign Desert Eagle" );
            // Retry weapon assignment
            self takeallweapons();
            self maps\mp\_utility::_giveweapon( "h2_deserteagle_mp" );
            wait( 0.1 );
            self setweaponammoclip( "h2_deserteagle_mp", 1 );
            self setweaponammostock( "h2_deserteagle_mp", 0 );
            self switchtoweapon( "h2_deserteagle_mp" );
            self iprintlnbold( "Retried weapon assignment" );
        }

        // Update life counter HUD
        self thread updateLifeCounter();
    }
    else
    {
        self.pers["eliminated"] = 1;
        self.sessionstate = "spectator";
        self setclientdvar( "ui_hud_hardcore", 1 );
        self iprintlnbold( "Eliminated! No lives remaining." );

        // Clear life counter HUD
        self thread clearLifeCounter();
    }
}

onplayerkilledloop()
{
    self endon( "disconnect" );
    for ( ;; )
    {
        self waittill( "killed_player", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
        self onplayerkilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration );
    }
}

onplayerkilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
    if ( isdefined( attacker ) && isplayer( attacker ) && attacker != self )
    {
        if ( attacker hasweapon( "h2_deserteagle_mp" ) )
        {
            attacker setweaponammoclip( "h2_deserteagle_mp", attacker getweaponammoclip( "h2_deserteagle_mp" ) + 1 );
            attacker iprintlnbold( "Bullet gained for kill!" );
        }
        else
        {
            attacker iprintlnbold( "ERROR: Attacker missing Desert Eagle" );
        }
    }
    if ( self.pers["lives"] <= 0 )
    {
        self.pers["eliminated"] = 1;
        self.sessionstate = "spectator";
        self setclientdvar( "ui_hud_hardcore", 1 );
        self iprintlnbold( "Eliminated! No lives remaining." );

        // Clear life counter HUD
        self thread clearLifeCounter();
    }
    else
    {
        // Ensure respawn
        self notify( "menuresponse", game["menu_team"], "autoassign" );

        // Update life counter HUD
        self thread updateLifeCounter();
    }

    level thread checkgameend();
}

testSimpleHud()
{
    
}

onrespawn()
{
    self endon( "disconnect" );
    self waittill( "spawned_player" );

    // Ensure player respawns only if they have lives
    if ( self.pers["lives"] > 0 )
    {
		self.pers["lives"] = self.pers["lives"]-1;
        self iprintlnbold( "Respawned with " + self.pers["lives"] + " lives" );

        // Update life counter HUD
        self thread updateLifeCounter();
    }
    if( self.pers["lives"] == 0)
    {
        self.pers["eliminated"] = 1;
        self.sessionstate = "spectator";
        self setclientdvar( "ui_hud_hardcore", 1 );
        self iprintlnbold( "Cannot respawn: No lives remaining" );

        // Clear life counter HUD
        self thread clearLifeCounter();
    }
}

onnormaldeath( var_0, var_1, var_2 )
{
    var_1 maps\mp\gametypes\_gamescore::giveplayerscore( "kill", 100 );

    if ( game["state"] == "postgame" && maps\mp\gametypes\_gamescore::gethighestscoringplayer() == var_1 )
        var_1.finalkill = 1;
}

checkgameend()
{
    level endon( "game_ended" );

    wait( 0.1 );

    var_0 = 0;
    var_1 = undefined;
    foreach ( var_3 in level.players )
    {
        if ( isdefined( var_3.pers["eliminated"] ) && var_3.pers["eliminated"] )
            continue;
        var_0++;
        var_1 = var_3;
    }

    if ( var_0 <= 1 )
    {
        if ( isdefined( var_1 ) )
        {
            var_1 maps\mp\gametypes\_gamescore::giveplayerscore( "victory", 500 );
            var_1 iprintlnbold( "You are the last player standing!" );
        }
        [[ level.endgame ]]( "all", game["strings"]["game_over"] );
    }
}

modifyplayerdamage( victim, attacker, damage, meansOfDeath, weapon, inflictor, hitLoc )
{
    // Ensure one-shot kills for h2_deserteagle_mp
    if ( isdefined( weapon ) && weapon == "h2_deserteagle_mp" && isdefined( victim ) && isplayer( victim ) )
    {
        damage = 9999;
        victim iprintlnbold( "Killed by Desert Eagle one-shot!" );
    }

    return damage;
}

// New function to update life counter HUD
updateLifeCounter()
{
    self endon("disconnect");


    self thread clearLifeCounter(); // Assume this clears `self.lifeIcons` safely
	Self.fixicons = self.pers["lives"] +1;
	
	self.huddy = NewClientHudElem(self);
	self.huddy.x = -30;
		self.huddy.y = 15;
		self.huddy.alignY = "top";
		self.huddy.alignX = "right";
		self.huddy.horzAlign = "right";
		self.huddy.vertAlign = "top";
		self.huddy.font = "objective";
		self.huddy.fontscale = 1.25;
		self.huddy.alpha = 1;
		self.huddy.color = (0, 0, 0); // Gold color
		self.huddy.glowColor = (0, 0.8, 0.8); // Red glow
		self.huddy.glowAlpha = 0.6;
		self.huddy SetText("LIVES LEFT");
		self.huddy setPulseFX(30, 2000);

    if (isdefined(self.pers["lives"]) && Self.fixicons > 0)
    {
        for (i = 0; i < Self.fixicons && i < 3; i++)
        {
            if (!isdefined(self.lifeIcons[i]) && self.pers["lives"] != 1 )
            {
                self.lifeIcons[i] = newClientHudElem(self);
                self.lifeIcons[i].x = (-42 * i) - 10; // Push icons left from right edge
                self.lifeIcons[i].y = 35;
                self.lifeIcons[i].alignX = "right";
                self.lifeIcons[i].alignY = "top";
                self.lifeIcons[i].horzAlign = "right";
                self.lifeIcons[i].vertAlign = "top";
                self.lifeIcons[i].alpha = 1.0;
                self.lifeIcons[i].foreground = true;
                self.lifeIcons[i].sort = 1;

                self.lifeIcons[i] setShader("waypoint_escort", 32, 32);
            }
			if (!isdefined(self.lifeIcons[i]) && self.pers["lives"] == 1 )
            {
                self.lifeIcons[1] = newClientHudElem(self);
                self.lifeIcons[1].x = -42-10; // Push icons left from right edge
                self.lifeIcons[1].y = 35;
                self.lifeIcons[1].alignX = "right";
                self.lifeIcons[1].alignY = "top";
                self.lifeIcons[1].horzAlign = "right";
                self.lifeIcons[1].vertAlign = "top";
                self.lifeIcons[1].alpha = 1.0;
                self.lifeIcons[1].foreground = true;
                self.lifeIcons[1].sort = 1;

                self.lifeIcons[1] setShader("waypoint_escort", 32, 32);
            }
			if (!isdefined(self.lifeIcons[i]) && self.pers["lives"] == 1 )
            {
                self.lifeIcons[1] = newClientHudElem(self);
                self.lifeIcons[1].x = -42-10; // Push icons left from right edge
                self.lifeIcons[1].y = 35;
                self.lifeIcons[1].alignX = "right";
                self.lifeIcons[1].alignY = "top";
                self.lifeIcons[1].horzAlign = "right";
                self.lifeIcons[1].vertAlign = "top";
                self.lifeIcons[1].alpha = 1.0;
                self.lifeIcons[1].foreground = true;
                self.lifeIcons[1].sort = 1;

                self.lifeIcons[1] setShader("waypoint_escort", 32, 32);
				
				self.lifeIcons[2] = newClientHudElem(self);
                self.lifeIcons[2].x = (-42*2)-10; // Push icons left from right edge
                self.lifeIcons[2].y = 35;
                self.lifeIcons[2].alignX = "right";
                self.lifeIcons[2].alignY = "top";
                self.lifeIcons[2].horzAlign = "right";
                self.lifeIcons[2].vertAlign = "top";
                self.lifeIcons[2].alpha = 1.0;
                self.lifeIcons[2].foreground = true;
                self.lifeIcons[2].sort = 1;

                self.lifeIcons[2] setShader("waypoint_escort", 32, 32);
            }
        }

    }
}


// New function to clear life counter HUD
clearLifeCounter()
{
    self endon( "disconnect" );

    if ( isdefined( self.lifeIcons ) )
    {
        for ( i = 0; i < 3; i++ )
        {
            if ( isdefined( self.lifeIcons[i] ) )
            {
                self.lifeIcons[i] destroy();
                self.lifeIcons[i] = undefined;
            }
        }
    }

}

// New function to clean up HUD on disconnect
cleanupHUDOnDisconnect()
{
    self endon( "game_ended" );
    self waittill( "disconnect" );
    self thread clearLifeCounter();
}

playIntroText()
{
    self endon("disconnect");

    // Create HUD element
    titleHud = newClientHudElem(self);
    titleHud.alignX = "center";
    titleHud.alignY = "middle";
    titleHud.horzAlign = "center";
    titleHud.vertAlign = "middle";
    titleHud.x = 0;
    titleHud.y = -200;
	titleHud.glowColor = (1, 0, 0); // Red glow
    titleHud.alpha = 0;
    titleHud.foreground = true;
    titleHud.fontScale = 2.5;
    titleHud.font = "objective";
    titleHud.sort = 10;
    titleHud setText(" ");
	
  titleHud FadeOverTime(1.5);
    titleHud.alpha = 1;

    // Play sound/music (must exist in fastfile)
    self PlayLocalSound("mp_announcer_start"); // Replace with your custom sound alias
    fullText = "One in the Chamber";
    typedText = "";

    for (i = 0; i < fullText.size; i++)
    {
        typedText += fullText[i];
        titleHud setText(typedText);
        wait 0.08; // Typewriter speed
    }
    wait 5;

    // Fade out
    titleHud FadeOverTime(4);
    titleHud.alpha = 0;
	

    wait 4;

    // Clean up
    titleHud destroy();
}