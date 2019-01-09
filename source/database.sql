clear
unbindall
bind "1" "slot1"
bind "2" "slot2"
bind "3" "slot3"
bind "4" "slot4"
bind "5" "slot5"
bind "6" "slot6"

//https://amp-reddit-com.cdn.ampproject.org/c/s/amp.reddit.com/r/GlobalOffensive/comments/50ud4j/command_csgo_bots_like_a_pro_the_complete_guide/
//https://steamcommunity.com/sharedfiles/filedetails/?id=171993722
bind uparrow holdpos
bind leftarrow roger
bind rightarrow negative
bind downarrow getout
echo "bind t getout"

alias +knife "use weapon_knife"
alias -knife lastinv
bind "q" "+knife"

alias "+attack1" "+attack;cl_crosshairstyle 2;"; 
alias "-attack1" "-attack;cl_crosshairstyle 5;"; 
bind "MOUSE1" "+attack1" 
bind "MOUSE2" "+attack2"
//bind "MWHEELUP" "invprev"
//bind "MWHEELDOWN" "invnext"
bind "MWHEELUP" "+jump"
bind "MWHEELDOWN" "+jump"

cl_crosshair_drawoutline "1"
cl_crosshair_dynamic_maxdist_splitratio "0"
cl_crosshair_dynamic_splitalpha_innermod "1"
cl_crosshair_dynamic_splitalpha_outermod "0.300000"
cl_crosshair_dynamic_splitdist "7"
cl_crosshair_outlinethickness "1"
cl_crosshair_sniper_show_normal_inaccuracy "0"
cl_crosshair_sniper_width "1"
cl_crosshair_t "0"
cl_crosshairalpha "250"
cl_crosshaircolor "5"
cl_crosshaircolor_b "0"
cl_crosshaircolor_g "0"
cl_crosshaircolor_r "255"
cl_crosshairdot "1"
cl_crosshairgap "-4.5"
cl_crosshairgap_useweaponvalue "0"
cl_crosshairscale "0"
cl_crosshairsize "0.5"
cl_crosshairstyle "2"
cl_crosshairthickness "1"
cl_crosshairusealpha "1"
cl_fixedcrosshairgap "0"

//color
alias cenable "cl_crosshaircolor_r 255; cl_crosshaircolor_g 255;cl_crosshaircolor_b 0; cl_crosshair_drawoutline 1;" 
alias cdisable "cl_crosshaircolor_r 255; cl_crosshaircolor_g 0; cl_crosshaircolor_b 0; cl_crosshair_drawoutline 1;" 

alias +step1 "cenable; alias +mov +step2;" 
alias -step1 "cdisable; alias +mov +step1; alias -mov -step1;" 

alias +step2 "alias +mov +step3; alias -mov -step2;" 
alias -step2a "alias +mov +step1; alias -mov -step1; cdisable;" 
alias -step2 "alias +mov +step2; alias -mov -step2a;" 

alias +step3 "alias +mov donothing; alias -mov -step3;" 
alias -step3a "alias +mov +step2; alias -mov -step2a;" 
alias -step3 "alias +mov +step3; alias -mov -step3a;" 

alias +mov +step1 
alias -mov -step1 

alias +fwd "+forward; +mov" 
alias -fwd "-forward; -mov" 
alias +bck "+back; +mov" 
alias -bck "-back; -mov" 
alias +lft "+moveleft; +mov" 
alias -lft "-moveleft; -mov" 
alias +rgt "+moveright; +mov" 
alias -rgt "-moveright; -mov" 

bind w "+fwd" 
bind a "+lft" 
bind s "+bck" 
bind d "+rgt" 

alias "dropc4" "use weapon_c4;drop"
bind x dropc4

bind "e" "+use_x"  //makes the radar zoom in when you press the E key but still allows you to use the key as your "use" key 
alias "+use_x" "+use; cl_radar_always_centered 0; cl_radar_scale 0.3; r_cleardecals; gameinstructor_enable 1" 
alias "-use_x" "-use; cl_radar_always_centered 1; cl_radar_scale 0.45; r_cleardecals; gameinstructor_enable 0" 
cl_radar_always_centered "0" 
cl_radar_icon_scale_min "0.5" 
cl_radar_rotate "1" 
cl_radar_scale "0.5"


bind "b" "buymenu"
bind "c" "+voicerecord"
alias +inspect "-lookatweapon; +reload; sm_tp"
alias -inspect "+lookatweapon; -reload"
bind j cheer
bind "f" "+inspect"
//bind "f" "+lookatweapon"
bind "g" "dropc4"
//bind "h" "toggle gameinstructor_enable"
bind "i" "toggle voice_enable 1 0"
bind "p" "toggle cl_mute_enemy_team 0 1"

bind "`" "toggleconsole"

bind "KP_INS" "buy vesthelm"
bind "KP_END" "buy deagle"
bind "KP_DOWNARROW" "buy p250"
bind "KP_PGDN" "buy tec9"
bind "KP_LEFTARROW" "buy ak47"
bind "KP_5" "buy p90"
bind "KP_RIGHTARROW" "buy awp"
bind "KP_HOME" "buy hegrenade"
bind "KP_UPARROW" "buy smokegrenade"
bind "KP_PGUP" "buy molotov"
bind "KP_SLASH" "buy famas"
bind "KP_MULTIPLY" "buy mp7"
bind "KP_MINUS" "buy defuser"
bind "KP_PLUS" "buy flashbang"
bind "KP_ENTER" "buy mag7"
bind "KP_DEL" "buy vest"
bind "z" "buy taser; use weapon_taser"


//bind "z" "radio1"
//bind "x" "slam_play"
bind x "use weapon_healthshot"
bind "y" "messagemode"
bind "u" "messagemode2"

bind "m" "teammenu"
bind "r" "+reload"
bind "t" "+spray_menu"

bind "SPACE" "+jump"

net_graph 1
alias +showscores_x "+showscores; net_graphheight 64"
alias -showscores_x "-showscores; net_graphheight 9999"
bind "TAB" "+showscores_x"
cl_showfps "0"  
alias showall "toggle cl_showpos;toggle cl_showfps;net_graphheight 64;"

bind "CAPSLOCK" "toggle cl_righthand 0 1"
bind "ESCAPE" "cancelselect"

//test
//cl_drawhud_force_radar
//drawradar/hideradar
bind "DEL" "toggle cl_drawhud_force_radar -1 0"

bind "SHIFT" "+speed"
alias "+duckj" "+duck;+jump;"
alias "-duckj" "-duck;-jump;"
bind "ALT" "+duckj"
bind "CTRL" "+duck"

bind "F11" "disconnect"


mm_dedicated_search_maxping "100"
//player_competitive_maplist_2v2_7_0_4C128440 "mg_de_inferno,mg_de_cbble,mg_de_overpass,mg_de_train,mg_de_shortdust,mg_gd_rialto,mg_de_lake"
//player_competitive_maplist_8_7_0_77AED00 "mg_de_dust2,mg_de_mirage,mg_de_inferno,mg_de_cache,mg_de_cbble,mg_de_train,mg_de_overpass,mg_de_nuke,mg_de_canals,mg_cs_agency,mg_cs_office"


con_filter_text damage
con_filter_text_out Player:
con_filter_enable 2
developer 1

// Miscellaneous 
cl_autowepswitch "0" 
cl_autohelp "0" 
cl_showhelp "0" 
cl_righthand "1" 
cl_forcepreload "1" 
player_nevershow_communityservermessage "1"     // FFS VALVE 
//cl_teamid_overhead_name_alpha "255"             // Solid overhead names. 
//cl_teamid_overhead_name_fadetime "0"            // No fade time on overhead names. 
cl_spec_mode "4"                                // IN-EYE spec when dead instead of 3rd person default. 
net_graphproportionalfont "1"   // Smaller netgraph font 
                         

m_mouseaccel1 "0" 
m_mouseaccel2 "0" 
m_customaccel "0"                               // Mouse Acceleration. 
m_customaccel_exponent "0"              // Acceleration Amount. 
m_customaccel_scale "0"                 // Custom mouse accel off. 
m_mousespeed "0"    

sv_grenade_trajectory_time_spectator 1      //打开观察者模式下的手雷轨迹显示 

cl_cmdrate "128"
cl_updaterate "128"
rate "120000"
//rate "786432"
cl_interp "0"
cl_interp_ratio "1"


cl_hud_background_alpha "0.5"
cl_hud_bomb_under_radar "1"
cl_hud_color "9"
cl_hud_healthammo_style "0"
cl_hud_playercount_pos "1"
cl_hud_playercount_showcount "1"
cl_hud_radar_scale "1.1"

lobby_voice_chat_enabled 0
cl_use_opens_buy_menu 0
cl_teamid_overhead_always 2

cl_disablehtmlmotd "1" //Removes "Message of the day" page when joining a server

cl_viewmodel_shift_left_amt "1.5"
cl_viewmodel_shift_right_amt "0.75"
viewmodel_fov "68"
viewmodel_offset_x "-2.000000"
viewmodel_offset_y "-2.000000"
viewmodel_offset_z "-2.000000"
viewmodel_presetpos "0"
cl_bob_lower_amt "21"
cl_bobamt_lat "0.33"
cl_bobamt_vert "0.14"
cl_bobcycle "0.98"

voice_enable 1
voice_modenable 1
cl_mute_enemy_team 0
+cl_show_team_equipment

//cpu_frequency_monitoring 2
//net_client_steamdatagram_enable_override -1 //not work
sdr ClientForceRelayCluster sgp

echo "sdr ClientForceRelayCluster"
echo "voice_mixer_volume to change ur mic voice"
echo "Voice_Scale to change ur team voice"

//bind "=" "incrementvar voice_scale 0 1 0.1"
//bind "-" "incrementvar voice_scale 0 1 -0.1"
//exec slam
host_writeconfig
echo "---------------------------------------done!!---------------------------------------"