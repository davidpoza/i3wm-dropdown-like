#!/bin/bash

DROPDOWN_SCREEN='HDMI-1-1' # Screen reserved for dropdown. Use xrandr to figure out the name of your screens
DROPDOWN_WORKSPACE='dropdown' # Name of dropdown workspace

setWorkspace () {
  local command="i3-msg \"workspace $@\""
  eval $command
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
}

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



# We are IN RESERVED SCREEN with dropdown OPEN -> close dropdown = Recover prevResWsp
if [[ $currScr == $DROPDOWN_SCREEN && $currWsp == $DROPDOWN_WORKSPACE ]]; then
  # re-focus previous workspace in reserved screen
  setWorkspace $prevResWsp

  recoverLastWorkspace

  #####
  echo $prevResWsp > ~/.resWsp
  echo $DROPDOWN_WORKSPACE > ~/.prevResWsp

# We ARE IN RESERVED SCREEN but dropdown is CLOSED -> open dropdown
elif [[ $currScr == $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE ]]; then

  # actualizamos el workspace en prevResWsp
  echo $currWsp > ~/.prevResWsp

  # mostramos el workspace reservado
  setWorkspace $DROPDOWN_WORKSPACE

  # actualizamos el workspace en reserved screen
  echo $DROPDOWN_WORKSPACE > ~/.resWsp

# We ARE NOT IN RESERVED SCREEN but dropdown is OPEN -> close dropdown = Recover prevResWsp
elif [[ $currScr != $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE && $resWsp == $DROPDOWN_WORKSPACE ]]; then
  # hide dropdown and return to current screen

  # focus reserved screens
  setOutput $DROPDOWN_SCREEN

  # re-focus previous workspace in reserved screen
  setWorkspace $prevResWsp

  recoverLastWorkspace

  #####
  echo $prevResWsp > ~/.resWsp
  echo $DROPDOWN_WORKSPACE > ~/.prevResWsp

# We ARE NOT IN RESERVED SCREEN and dropdown is CLOSED -> open dropdown
elif [[ $currScr != $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE && $resWsp != $DROPDOWN_WORKSPACE ]]; then
  # Apuntamos el monitor actual (salida tipo "HDMI-1-1")
  echo $currScr > ~/.prevScr

  # Apuntamos el workspace actual (salida tipo "9", dependiendo del label que tenga el workspace)
  echo $currWsp > ~/.prevWsp

  # movemos el foco al monitor reservado
  setOutput $DROPDOWN_SCREEN

  # current Workspace in focused screen
  currWsp=$(currentWorkspace)

  # guardamos el workspace que tenia el monitor reservado pero antes apuntamos el valor anterior en prevResWsp
  echo $currWsp > ~/.prevResWsp

  # mostramos el workspace que hemos reservado para el efecto
  setWorkspace $DROPDOWN_WORKSPACE

  echo $DROPDOWN_WORKSPACE > ~/.resWsp

fi
