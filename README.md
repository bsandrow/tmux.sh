# tmux.sh

By default, if two tmux clients connect to the same session it acts like a
mirror (since 'current window' is an attribute of the session rather than of
the client). This is a simple script meant to allow behaviour more similar to
GNU screen.

## Example Usage


    # Terminal 1
    tmux.sh my-session

    # Terminal 2
    tmux.sh my-session
