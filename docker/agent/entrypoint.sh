#!/bin/bash
export TERM=xterm
tmux new-session -d -s dev -n master
tmux send-keys salt-master C-m
tmux new-window -t dev:1 -n api
tmux send-keys salt-api C-m
tmux new-window -t dev:2 -n minion
tmux send-keys sleep 2 && salt-minion C-m
# Sleep many many days :-)
exec sleep 99999d
