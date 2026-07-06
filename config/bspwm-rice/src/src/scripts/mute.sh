# Define una variable para almacenar el estado actual del mute
current_state=$(pactl list sinks | awk '/Mute/ {print $2}' | head -n 1)

# Comprueba el estado actual del mute y alterna el estado
if [ "$current_state" == "yes" ]; then
    pactl set-sink-mute @DEFAULT_SINK@ 0   # Si está muteado, desmutear
else
    pactl set-sink-mute @DEFAULT_SINK@ 1   # Si no está muteado, mutear
fi

