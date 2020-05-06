
#!/bin/bash

scrot /tmp/screen.png
convert /tmp/screen.png -scale 10% -scale 1000% /tmp/screen.png

if [[ -f /tmp/screen.png ]]
then
	i3lock -i /tmp/screen.png

else
	echo "Error"

fi

dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.Stop
rm /tmp/screen.png