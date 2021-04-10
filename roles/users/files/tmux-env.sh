#!/bin/sh
name=$(whoami)
tmux new-session -s 'cluster' \
			   -n 'asuna' "ssh $name@asuna" \; \
	new-window -n 'zelda' "ssh $name@zelda" \; \
	new-window -n 'ichika' "ssh $name@ichika" \; \
	new-window -n 'nino' "ssh $name@nino" \; \
	new-window -n 'miku' "ssh $name@miku" \; \
	new-window -n 'yotsuba' "ssh $name@yotsuba" \; \
	new-window -n 'itsuki' "ssh $name@itsuki" \; \
	new-window -n 'rikka' "ssh $name@rikka" \; \
	select-window -t 0 \;

	# new-window -n 'metroid' "ssh $name@metroid" \; \
	# new-window -n 'yukinon' "ssh $name@yukinon" \; \
