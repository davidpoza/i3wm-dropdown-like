#!/bin/bash

DROPDOWN_SCREEN='HDMI-1-1' # Screen reserved for dropdown. Use xrandr to figure out the name of your screens
DROPDOWN_WORKSPACE='dropdown' # Name of dropdown workspace

# current screen (focused screen)
currScr=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')

# current Workspace in focused screen
currWsp=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

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
  i3Command="i3-msg \"workspace $prevResWsp\""
  eval $i3Command

  #####
  echo $prevResWsp > ~/.resWsp
  echo $DROPDOWN_WORKSPACE > ~/.prevResWsp

# We ARE IN RESERVED SCREEN but dropdown is CLOSED -> open dropdown
elif [[ $currScr == $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE ]]; then

  # actualizamos el workspace en prevResWsp
  echo $currWsp > ~/.prevResWsp

  # mostramos el workspace reservado
  i3Command="i3-msg \"workspace $DROPDOWN_WORKSPACE\""
  eval $i3Command

  # actualizamos el workspace en reserved screen
  echo $DROPDOWN_WORKSPACE > ~/.resWsp

# We ARE NOT IN RESERVED SCREEN but dropdown is OPEN -> close dropdown = Recover prevResWsp
elif [[ $currScr != $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE && $resWsp == $DROPDOWN_WORKSPACE ]]; then
  # hide dropdown and return to current screen

  # focus reserved screens
  i3Command="i3-msg \"focus output $DROPDOWN_SCREEN\""
  eval $i3Command

  # re-focus previous workspace in reserved screen
  i3Command="i3-msg \"workspace $prevResWsp\""
  eval $i3Command

  # focus last current screen again
  i3Command="i3-msg \"focus output $currScr\""
  eval $i3Command

  #####
  echo $prevResWsp > ~/.resWsp
  echo $DROPDOWN_WORKSPACE > ~/.prevResWsp

# We ARE NOT IN RESERVED SCREEN and dropdown is CLOSED -> open dropdown
elif [[ $currScr != $DROPDOWN_SCREEN && $currWsp != $DROPDOWN_WORKSPACE && $resWsp != $DROPDOWN_WORKSPACE ]]; then
  # Apuntamos el monitor actual (salida tipo "HDMI-1-1")
  #echo $currScr > ~/.currScr

  # Apuntamos el workspace actual (salida tipo "9", dependiendo del label que tenga el workspace)
  #echo $currWsp > ~/.currWsp

  # movemos el foco al monitor reservado
  i3Command="i3-msg \"focus output $DROPDOWN_SCREEN\""
  eval $i3Command

  # current Workspace in focused screen
  currWsp=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

  # guardamos el workspace que tenia el monitor reservado pero antes apuntamos el valor anterior en prevResWsp
  echo $currWsp > ~/.prevResWsp

  # mostramos el workspace que hemos reservado para el efecto
  i3Command="i3-msg \"workspace $DROPDOWN_WORKSPACE\""
  eval $i3Command

  echo $DROPDOWN_WORKSPACE > ~/.resWsp

fi
