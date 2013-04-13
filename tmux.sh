#!/bin/sh

die()
{
    echo "$@" >&2
    exit 1
}

die_with_usage()
{
    (
        if [ -n "$1" ]; then
            echo "Error: $@"
        fi
        echo "Usage: tmux.sh SESSION-NAME"
    ) >&2
    exit 1
}

tmux_session_exists()
{
    tmux has-session -t "$TMUX_SESSION_NAME"
}

tmux_session_has_clients_attached()
{
    [ $(tmux list-clients -t "$TMUX_SESSION_NAME" | wc -l) -gt 0 ]
}

tmux_create_grouped_session()
{
    tmux new-session -t "$TMUX_SESSION_NAME"
}

tmux_attach_to_session()
{
    tmux attach-session -t "$TMUX_SESSION_NAME"
}

tmux_create_new_session()
{
    tmux new-session -s  "$TMUX_SESSION_NAME"
}

if [ -z "$1" ]; then
    die_with_usage "SESSION-NAME is mandatory"
else
    export TMUX_SESSION_NAME="$1"
fi

if tmux_session_exists; then
    if tmux_session_has_clients_attached; then
        tmux_create_grouped_session
    else
        tmux_attach_to_session
    fi
else
    tmux_create_new_session
fi
