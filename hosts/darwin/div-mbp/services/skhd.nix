##########################################################################
#                               NOTES                                    #
##########################################################################
################### Dependencies
# skhd
# yabai
# dash
# jq
# spaceman
# hammerspoon
# cliclick

################### Modify the launchctl plist (improved performance)
# plist xml can be found at "skhd --install-service"
# Setting dash as the shell for the service to run from.
#
#  <key>EnvironmentVariables</key>
#  <dict>
#    <key>PATH</key>
#    <string>#{HOMEBREW_PREFIX}/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
# +  <key>SHELL</key>
# +  <string>/usr/local/bin/dash</string>
#  </dict>

# ################################################################ #
# THE FOLLOWING IS AN EXPLANATION OF THE GRAMMAR THAT SKHD PARSES. #
# ################################################################ #
# A list of all built-in modifier and literal keywords can
# be found at https://github.com/koekeishiya/skhd/issues/1
#
# A hotkey is written according to the following rules:
#
#   hotkey       = <mode> '<' <action> | <action>
#
#   mode         = 'name of mode' | <mode> ',' <mode>
#
#   action       = <keysym> '[' <proc_map_lst> ']' | <keysym> '->' '[' <proc_map_lst> ']'
#                  <keysym> ':' <command>          | <keysym> '->' ':' <command>
#                  <keysym> ';' <mode>             | <keysym> '->' ';' <mode>
#
#   keysym       = <mod> '-' <key> | <key>
#
#   mod          = 'modifier keyword' | <mod> '+' <mod>
#
#   key          = <literal> | <keycode>
#
#   literal      = 'single letter or built-in keyword'
#
#   keycode      = 'apple keyboard kVK_<Key> values (0x3C)'
#
#   proc_map_lst = * <proc_map>
#
#   proc_map     = <string> ':' <command> | <string>     '~' |
#                  '*'      ':' <command> | '*'          '~'
#
#   string       = '"' 'sequence of characters' '"'
#
#   command      = command is executed through '$SHELL -c' and
#                  follows valid shell syntax. if the $SHELL environment
#                  variable is not set, it will default to '/bin/bash'.
#                  when bash is used, the ';' delimeter can be specified
#                  to chain commands.
#
#                  to allow a command to extend into multiple lines,
#                  prepend '\' at the end of the previous line.
#
#                  an EOL character signifies the end of the bind.
#
#   ->           = keypress is not consumed by skhd
#
#   *            = matches every application not specified in <proc_map_lst>
#
#   ~            = application is unbound and keypress is forwarded per usual, when specified in a <proc_map>
#
# A mode is declared according to the following rules:
#
#   mode_decl = '::' <name> '@' ':' <command> | '::' <name> ':' <command> |
#               '::' <name> '@'               | '::' <name>
#
#   name      = desired name for this mode,
#
#   @         = capture keypresses regardless of being bound to an action
#
#   command   = command is executed through '$SHELL -c' and
#               follows valid shell syntax. if the $SHELL environment
#               variable is not set, it will default to '/bin/bash'.
#               when bash is used, the ';' delimeter can be specified
#               to chain commands.
#
#               to allow a command to extend into multiple lines,
#               prepend '\' at the end of the previous line.
#
#               an EOL character signifies the end of the bind.
{ pkgs, ... }:

let
  cfg = ''
    ########################################################################
    #                                 CONFIG                               #
    ########################################################################
    ############## General rules and keys defined to integrate seamlessly with custom TLTR keyboard layout
    # cmd + ctrl + shift + alt or TL + d : hyper key (meant for popping stuff on the display)
    # cmd + ctrl + alt or TL + w         : window manager key (meant for window manipulation)
    # fn or TL + x                       : function key

    ############## Application specific keyboard shortcuts (not part of skhdrc; for reference purposes)
    # hyper - space : raycast launch
    # hyper - p     : raycast command palatte generated from the menu bar's menu
    # hyper - w     : raycast list windows
    # hyper - f     : homerow hints
    # hyper - /     : homerow search
    # hyper - r     : homerow scroll
    # ctrl + esc    : spaceman refresh current spaces info
    # hyper - m     : menuwhere menu under the mouse cursor
    # hyper - h     : bartender hidden menu bar items

    ############# Launcher stuff onto the screen ##################
    hyper - return            : open -a "wezterm"
    hyper - l                 : open -a "launchpad"
    hyper - e                 : open -a "Finder"
    cmd + ctrl + alt - space  : open -a "Mission Control"

    ############# Window Manipulation ############################
    ######### focus window
    # switch focus linear tree active window within a space in both bsp & floating modes
    cmd + ctrl + alt - down  : yabai -m window --focus "$(yabai -m query --windows | jq -re "sort_by(.display, .space, .frame.x, .frame.y, .id) | map(select(.\"is-visible\" == true and .role != \"AXUnknown\")) | reverse | nth(index(map(select(.\"has-focus\" == true))) - 1).id")"
    cmd + ctrl + alt - up    : yabai -m window --focus "$(yabai -m query --windows | jq -re "sort_by(.display, .space, .frame.x, .frame.y, .id) | map(select(.\"is-visible\" == true and .role != \"AXUnknown\")) | nth(index(map(select(.\"has-focus\" == true))) - 1).id")"
    # manoeuvre focus b/w windows when tiled
    cmd + ctrl + alt - u     : yabai -m window --focus north
    cmd + ctrl + alt - n     : yabai -m window --focus west
    cmd + ctrl + alt - e     : yabai -m window --focus south
    cmd + ctrl + alt - i     : yabai -m window --focus east

    ########### fill window
    # floating window management (must have implemented a numpad layout layer)
    cmd + ctrl + alt - 7     : yabai -m window --grid 2:2:0:0:1:1
    cmd + ctrl + alt - 9     : yabai -m window --grid 2:2:1:0:1:1
    cmd + ctrl + alt - 1     : yabai -m window --grid 2:2:0:1:1:1
    cmd + ctrl + alt - 3     : yabai -m window --grid 2:2:1:1:1:1
    cmd + ctrl + alt - 4     : yabai -m window --grid 1:2:0:0:1:1
    cmd + ctrl + alt - 6     : yabai -m window --grid 1:2:1:0:1:1
    cmd + ctrl + alt - 8     : yabai -m window --grid 2:1:0:0:1:1
    cmd + ctrl + alt - 2     : yabai -m window --grid 2:1:0:1:1:1
    cmd + ctrl + alt - 5     : yabai -m window --grid 1:1:0:0:1:1

    ###### Window size
    # decrease window size 0x1B <-> '-'
    cmd + ctrl + alt - 0x1B         : yabai -m window --resize top_left:+50:+50; yabai -m window --resize bottom_right:-50:-50; yabai -m window --resize top_right:-50:+50; yabai -m window --resize bottom_left:+50:-50

    # increase window size 0x18 <-> '=' & shift+0x18 <-> '+'
    cmd + ctrl + shift + alt - 0x18 : yabai -m window --resize top_left:-50:-50; yabai -m window --resize bottom_right:+50:+50; yabai -m window --resize top_right:+50:-50; yabai -m window --resize bottom_left:-50:+50

    ########## window positioning
    # window mirroring
    # cmd + ctrl + alt - y     : yabai -m space --mirror y-axis
    # cmd + ctrl + alt - x     : yabai -m space --mirror x-axis
    # window warping
    # cmd + ctrl + alt - y     : yabai -m window --warp east
    # cmd + ctrl + alt - l     : yabai -m window --warp north
    # cmd + ctrl + alt -       : yabai -m window --warp north
    # cmd + ctrl + alt -       : yabai -m window --warp south
    # swap managed window
    # cmd + ctrl + alt - q     : yabai -m window --swap east
    # cmd + ctrl + alt - 4     : yabai -m window --swap west

    # Send window to virtual desktop/space
    cmd + ctrl + alt - tab          : yabai -m window --space next
    cmd + ctrl + shift + alt - tab  : yabai -m window --space prev

    ################################# Switching modes ##########################################
    ############ toggle sticky(+float), topmost, picture-in-picture
    cmd + ctrl + alt - p      : yabai -m window --toggle sticky --toggle topmost --toggle pip
    # float / unfloat window and center on screen
    # cmd + ctrl + alt - space : yabai -m window --toggle float --grid 1:1:0:0:1:1

    ############ windowing layout for current space
    # for toggling b/w bsp & floating modes
    cmd + ctrl + alt - t      : yabai -m space --layout $(yabai -m query --spaces --space | jq -r 'if .type == "bsp" then "float" else "bsp" end')

    ################################ Desktop/Space Manipulation ##################################
    ########## manoeuvre b/w spaces
    # cycles the last space back to first when moving to right space & vice versa
    # cmd + ctrl + alt - right  : id="$(yabai -m query --spaces --display | jq 'sort_by(.index) | reverse | .[map(."has-focus") | index(true) - 1].index')" && yabai -m space --focus "''${id}"; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    # cmd + ctrl + alt - left   : id="$(yabai -m query --spaces --display | jq 'sort_by(.index) | .[map(."has-focus") | index(true) - 1].index')" && yabai -m space --focus "''${id}"; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    # switch spaces without cycling
    cmd + ctrl + alt - right  : yabai -m space --focus next; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    cmd + ctrl + alt - left   : yabai -m space --focus prev; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    # switch spaces using hammerspoon ipc(xpc)
    # cmd + ctrl + alt - right  : hs -c "GoNextSpace()"; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    # cmd + ctrl + alt - left   : hs -c "GoPrevSpace()"; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl

    ########## create & delete current space
    cmd + ctrl + alt - c      : yabai -m space --create; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    cmd + ctrl + alt - d      : yabai -m space --destroy; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    # create & delete spaces using hammerspoon ipc(xpc)
    # cmd + ctrl + alt - d      : hs -c "RemoveCurrentSpace()"; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
    # cmd + ctrl + alt - c      : hs -c "AddSpace()"; sleep 0.2; cliclick kd:ctrl kp:esc ku:ctrl
  '';
in
{
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = cfg;
  };
}