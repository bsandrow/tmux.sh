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

base_session_exists()
{
    tmux_session_exists "$TMUX_SESSION_NAME"
}

tmux_session_exists()
{
    session_name="$1"
    tmux has-session -t "$session_name" 2>/dev/null
}

base_session_is_free()
{
    tmux_session_has_clients_attached "$TMUX_SESSION_NAME"
    [ "$?" != "0" ]
}

create_base_session()
{
    tmux new-session -s  "$TMUX_SESSION_NAME"
}

tmux_session_has_clients_attached()
{
    session_name="$1"
    [ $(tmux list-clients -t "$session_name" | wc -l) -gt 0 ]
}

find_available_slave_session()
{
    list_slave_sessions | while read session_name; do
        if ! tmux_session_has_clients_attached "$session_name"; then
            echo "$session_name"
            exit
        fi
    done
}

get_slave_session_name()
{
    # Look through existing slave sessions for one without a client attached
    session_name=$(find_available_slave_session)
    if [ -n "$session_name" ]; then
        return
    fi

    # we couldn't find an existing session to use, so create one, and return
    # the name
    session_name="$(new_session_name)"
    tmux new-session -d -t "$TMUX_SESSION_NAME" -s "$session_name"
    echo "$session_name"
    return
}

tmux_attach_to_session()
{
    session_name="$1"
    tmux attach-session -t "$session_name"
}

list_slave_sessions()
{
    tmux list-sessions | grep '^'"$TMUX_SESSION_NAME"'-[[:digit:]]\+' | cut -d: -f1
}

tmux_slave_session_next_number()
{
    max_number=$(list_slave_sessions | sed -e 's/^.*-\([[:digit:]]\+\)$/\1/' | sort -nr | head -1)
    [ -n "$max_number" ] || max_number=0
    echo  "$max_number" + 1 | bc
}

new_session_name()
{
    next_number=$(tmux_slave_session_next_number)
    echo "$TMUX_SESSION_NAME-$next_number"
}

if [ -z "$1" ]; then
    die_with_usage "SESSION-NAME is mandatory"
elif [ "$1" = "-h" -o "$1" = "--help" ]; then
    die_with_usage
else
    export TMUX_SESSION_NAME="$1"
fi

if base_session_exists; then
    if base_session_is_free; then
        tmux_attach_to_session "$TMUX_SESSION_NAME"
    else
        tmux_attach_to_session "$(get_slave_session_name)"
    fi
else
    create_base_session
fi
