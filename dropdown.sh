#!/bin/bash

############################################
# CONSTANTS
############################################
readonly DROPDOWN_SCREEN='HDMI-1-1' # Screen reserved for dropdown. Use xrandr to figure out the name of your screens
readonly DROPDOWN_WORKSPACE='dropdown' # Name of dropdown workspace


############################################
# FUNCTIONS
############################################

setWorkspace () {
  local command="i3-msg \"workspace $@\""
  eval $command

  # update workspace status file
  echo $@ > ~/.resWsp
}

setOutput () {
  local command="i3-msg \"focus output $1\""
  eval $command
}

currentWorkspace() {
  local workspace=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
  echo "$workspace"
}

currentScreen() {
  local screen=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')
  echo "$screen"
}

recoverLastWorkspace() {
  local prevScr=`cat ~/.prevScr`
  local prevWsp=`cat ~/.prevWsp`

  # focus last current screen again
  setOutput $prevScr

  # re-focus last workspace in current screeen
  setWorkspace $prevWsp

  # update workspace status files
  echo $prevResWsp > ~/.resWsp
  echo $DROPDOWN_WORKSPACE > ~/.prevResWsp
}

# Save current screen and workspace in order to be able to recover it when dropdown gets closed
saveCurrentWorkspace() {
  # save current screen (looks like "HDMI-1-1")
  echo $currScr > ~/.prevScr

  # save current workspace (looks like "6:<span font_desc='JetBrains Mono Medium 13'> 6 </span>")
  echo $currWsp > ~/.prevWsp
}

# Save current workspace in reserved screen
saveResCurrentWsp() {
  echo $currWsp > ~/.prevResWsp
}


############################################
# GLOBAL VARIABLES
############################################
# current screen (focused screen)
currScr=$(currentScreen)

# current Workspace in focused screen
currWsp=$(currentWorkspace)

# resWsp: current workspace in reserved screen
resWsp=`cat ~/.resWsp`
if [[ $currWsp == $DROPDOWN_WORKSPACE ]]; then
  resWsp=$DROPDOWN_WORKSPACE
fi

# previous workspace in reserved screen
prevResWsp=`cat ~/.prevResWsp`

############################################
# MAIN
############################################


# We are IN RESERVED SCREEN with dropdown OPEN -> close dropdown = Recover prevResWsp
if [[ $currScr == $DROPDOWN_SCREEN && $currWsp == $DROPDOWN_WORKSPACE ]]; then
  setWorkspace $prevResWsp # re-focus previous workspace in reserved screen
  recoverLastWorkspace

# We ARE IN RESERVED SCREEN but dropdown is CLOSED -> open dropdown
elif [[ $currScr == $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE ]]; then
  saveCurrentWorkspace
  saveResCurrentWsp
  setWorkspace $DROPDOWN_WORKSPACE

# We ARE NOT IN RESERVED SCREEN but dropdown is OPEN -> close dropdown = Recover prevResWsp
# hide dropdown and return to current screen
elif [[ $currScr != $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE && $resWsp == $DROPDOWN_WORKSPACE ]]; then
  setOutput $DROPDOWN_SCREEN # focus reserved screen
  setWorkspace $prevResWsp # re-focus previous workspace in reserved screen
  recoverLastWorkspace

# We ARE NOT IN RESERVED SCREEN and dropdown is CLOSED -> open dropdown
elif [[ $currScr != $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE && $resWsp != $DROPDOWN_WORKSPACE ]]; then
  saveCurrentWorkspace
  setOutput $DROPDOWN_SCREEN # movemos el foco al monitor reservado
  currWsp=$(currentWorkspace) # current Workspace in focused screen
  saveResCurrentWsp
  setWorkspace $DROPDOWN_WORKSPACE
fi
