#!/bin/sh
tmux new-session -d
tmux send-keys "salt-minion" C-m
tmux new-window
tmux send-keys "salt-master" C-m
tmux new-window salt-minion
tmux send-keys "salt-api" C-m
tmux attach