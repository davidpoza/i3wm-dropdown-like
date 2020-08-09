#!/bin/bash
# Use xrandr to figure out the name of your screens
DROPDOWN_SCREEN='HDMI-1-1'
DROPDOWN_WORKSPACE='dropdown'

currScr=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).output')
currWsp=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')

if [[ $currScr == $DROPDOWN_SCREEN && $currWsp == $DROPDOWN_WORKSPACE ]]
then
lastScr=`cat ~/.currScr`
lastWsp=`cat ~/.currWsp`

# antes de volver, recuperamos el workspace que tenia el monitor reservado
resWsp=`cat ~/.resWsp`
i3Command="i3-msg \"workspace $resWsp\""
eval $i3Command

# volvemos al monitor apuntado
i3Command="i3-msg \"focus output $lastScr\""
eval $i3Command

# volvemos al workspace apuntado
i3Command="i3-msg \"workspace $lastWsp\""
eval $i3Command

else
# Apuntamos el monitor actual (salida tipo "HDMI-1-1")
echo $currScr > ~/.currScr

# Apuntamos el workspace actual (salida tipo "9", dependiendo del label que tenga el workspace)
echo $currWsp > ~/.currWsp

# movemos el foco al monitor que queremos reservar para el efecto
i3Command="i3-msg \"focus output $DROPDOWN_SCREEN\""
eval $i3Command

# guardamos el workspace que tenia el monitor reservado
resWsp=$(i3-msg -t get_workspaces | jq -r '.[] | select(.focused==true).name')
echo $resWsp > ~/.resWsp

# mostramos el workspace que hemos reservado para el efecto
i3Command="i3-msg \"workspace $DROPDOWN_WORKSPACE\""
eval $i3Command
fi
