# tmux.sh

By default, if two tmux clients connect to the same session it acts like a
mirror (since 'current window' is an attribute of the session rather than of
the client). This is a simple script meant to allow behaviour more similar to
GNU screen.

To be clear, this is *not* the same as running `tmux -s /tmp/pair-socket` to
pair program. This is just a way to make the ability for two clients to connect
and switch windows indepentendly from each other. A common use-case for this is
to have a single session with a bunch of windows, and connect two separate
terminals, each looking at a different window in the same session (e.g. vim on
one terminal, and scrolling server output on another). See below a more
[in-depth explanation](#explanation).

## Requirements

* tmux 1.8+ (session grouping was introduced in tmux 1.8)

## Usage

Usage is meant to be brain-dead simple. Just run `tmux.sh` with a session name:

    $ tmux.sh my-session

Running it a second time from a second terminal will create a session grouped
with my-session, and connect to that session.

The session names (other than the initial session) all follow the pattern:
`SESSION_NAME-##`. If you try to connect an additional client, any sessions
matching this pattern will be 'reclaimed' if there are currently no clients
attached to them.

## Customization

This is pretty easy to customize. If you have a specific session that you want
to be setup initially, just modify the create_base_session function to setup
your customizations (e.g. create windows, rename them, lauch processes, etc)
and leave the rest alone. You may want to just rename `tmux.sh` to something
else with a better name, but that's about it.

## Explanation

tmux has a slightly different architecture than GNU screen, which leads to the
behaviour this script seeks to remedy[1]. The tmux architecture looks like this:

                +--------+
                | server |
                +--------+
                 /      \
         +----------+ +----------+
         | session0 | | session1 |
         +----------+ +----------+
           /             /     \
    +---------+   +---------+ +---------+
    | client0 |   | client1 | | client2 |
    +---------+   +---------+ +---------+

The `server` is the back-end process that is parent to all of the processes
that are running in tmux. The `sessions` are collections of `windows` running
on the `server`. The `clients` are terminals that are connected to the `server`
(over the Unix socket, which is configurable with the `-s` tmux option). Each
`client` connects to a specific `session` on the `server`.

The trouble comes about because the 'active window' is an attribute of the
`session`, so when two `clients` connect to the same `session` they can only
ever view the same `window` at the same time (e.g. when `client1` switches from
one `window` to another, `client2` also switches `windows`). This can be
surprising to people switching from GNU screen, because if you connect to the
same screen session[2] twice, you can switch windows independently.

tmux 1.8 remedied this by adding a `-t target-session` option to the
`new-session` command. This allows you to 'group' multiple `sessions` together,
so that they share the same collection of `windows` (i.e. when you remove a
`window` from one `session` in the group, it's removed from all `sessions` in
the group; ditto for creating a `window`). Now the two `clients` can connect to
separate, but linked `sessions`. Since each `session` has its own 'active
window' attribute, this allows each `client` to switch `windows` independent of
the others.

[1] Note that the functionality is all built into tmux. This script just exposes it in a more user-friendly fashion.

[2] GNU screen's archicture is setup so that each 'screen session' is a completely separate process. In terms of the tmux architecture, it would be like having a new server with a single session for every collection of windows.

## References

* [Unix & Linux Stack Exchange: tmux - attach to different windows in a session](http://unix.stackexchange.com/questions/24274/attach-to-different-windows-in-session)
* [tmux manpage](http://linux.die.net/man/1/tmux)
