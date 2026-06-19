# dotfiles

```
██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
```

## installation

[GNU Stow](https://www.gnu.org/software/stow/) is required
add modules to local config with `stow <module-name>`
using `stow .` adds them to the `~` directory, not the required one

## nvim

check `:checkhealth` for additional required tools

## tmux

Install plugins: `CTRL + B` + `I`

- [TPM](https://github.com/tmux-plugins/tpm)
- [list of plugins](https://github.com/tmux-plugins/list)

## Hyprland

### create hyprland-session.target

A Wayland compositor is expected to tell systemd that it is a graphical session. This is a minimal way of starting the graphical-session.target if you don’t want to use UWSM. This target will autostart user services like bars and notification daemons, but some services like XDG Desktop Portal (and therefore XDPH) may even refuse to start without it. You can manage this yourself by creating a hyprland-session.target that binds to the graphical-session.target, then launching it in your config. [Wiki-Link](https://wiki.hypr.land/Useful-Utilities/Systemd-start/#hyprland-sessiontarget)

`systemctl --user edit --full --force hyprland-session.target`

```
[Unit]
Description=Hyprland session
BindsTo=graphical-session.target
Wants=graphical-session-pre.target
After=graphical-session-pre.target
PropagatesStopTo=graphical-session.target
```
