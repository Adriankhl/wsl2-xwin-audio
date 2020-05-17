# wsl2-xwin-audio
Tips to setup GUI in wsl2.

## Introduction
See [Awesome-wsl](https://github.com/sirredbeard/Awesome-WSL)

The following assume that the Ubuntu 18.04 distros `CanonicalGroupLimited.Ubuntu18.04onWindows_1804.2018.817.0_x64__79rhkp1fndgsc.Appx` has been downloaded.

## Installation
The followings are executed on a [git bash](https://gitforwindows.org/) shell. They can be easily translated to powershell script.

Install: 
`powershell "Add-AppxPackage .\CanonicalGroupLimited.Ubuntu18.04onWindows_1804.2018.817.0_x64__79rhkp1fndgsc.Appx"`

Default to wsl2 instead of wsl1:
`wsl --set-default-version 2`

Verify your installation:
`wsl -l -v`

(Optional) Create and go to another directory to store wsl filesystem (see [issue](https://github.com/MicrosoftDocs/WSL/issues/412)):
```
wsl --export Ubuntu-18.04 ./ubuntu-wsl.tar
mkdir ubuntu-wsl
wsl --unregister Ubuntu-18.04
wsl --import Ubuntu-18.04 ./ubuntu-wsl ./ubuntu-wsl.tar
```

Create a user as `your-user-name`:
`powershell "ubuntu1804 config --default-user your-user-name"`


## Fix [Ram Issue](https://github.com/microsoft/WSL/issues/4166)
Open wsl shell.

Run `sudo crontab -e -u root`, add the following to `drop_cache` automatically every 15 min`:
```
*/15 * * * * sync; echo 3 > /proc/sys/vm/drop_caches; touch /root/drop_caches_last_run
```

Assume you use `zsh`, add the following to `~/.zshrc` (`~/.bashrc` if you use bash) to start `cron` service automatically:
```
[ -z "$(ps -ef | grep cron | grep -v grep)" ] && sudo /etc/init.d/cron start &> /dev/null
```

To allow starting cron service without asking by root password, run `sudo visudo` and add:
```
%sudo ALL=NOPASSWD: /etc/init.d/cron start
```

To check when did you last clear your caches, run:
```
sudo stat -c '%y' /root/drop_caches_last_run
```

(Optional) Leave wsl and open Git Bash, limit the memory usage by placing `.wslconfig` ([sample](dotfiles/.wslconfig)) to `~/.wslconfig`.

## Install GUI (X Server) and Audio (PulseAudio)
There are a few ways to install [X Server](https://www.x.org/wiki/) and [PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/) for Windows, my choice here is the good old [Cygwin](https://www.cygwin.com/).

Install [Cygwin](https://www.cygwin.com/) and add the directory of `cygwin.exe` to your environment variable `PATH`. I recommend doing this via [scoop](https://scoop.sh/): `scoop install cygwin`.

Check this in the wsl shell: `which cygwin.exe`

Run `cygwin-setup.exe`, install `xinit`, `pulseaudio`, and `pulseaudio-module-x11`. 

Install packages in Ubuntu wsl:
```
sudo apt install x11-apps ubuntu-restricted-extras
```

### Configuration
Copy [xpa](bin/xpa) and [killxpa](bin/killxpa) to `~/bin` and do `export PATH="$HOME/bin":$PATH`. Make sure that you can call `cygwin.exe`.

Export the following environment variables:
```
# x11 opengl rendering options
export LIBGL_ALWAYS_INDIRECT=0
export LIBGL_ALWAYS_SOFTWARE=0

# display to Xserver, sound to audiopulse server
export DISPLAY=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0
export PULSE_SERVER=tcp:$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')
```

[xpa](bin/xpa): run X server + PulseAudio 

[killxpa](bin/killxpa): kill X server + PulseAudio 


Add the following to run [xpa](bin/xpa) automatically when you start the terminal and run [killxpa](bin/killxpa) automatically when you close the terminal.

```
# run when start if not in tmux
if [ -z "$TMUX" ]; then
    xpa &> /dev/null
fi

# run when exit if not in tmux
if [ -z "$TMUX" ]; then
    trap "killxpa" EXIT
fi
```

See [.zshrc](dotfiles/.zshrc) for a sample configuration.

### Test
Test X Server - run: `xeyes`

Test PulseAudio - run: `paplay /usr/share/sounds/freedesktop/stereo/bell.oga`

## Fix Color Display
Color display in `/mnt` and [tmux](https://github.com/tmux/tmux/wiki) can be weird in wsl2.

Add (to `~/.zshrc` or `~/.bashrc` if you use bash)
```
# Fix directory color in /mnt
export LS_COLORS='ow=01;36;40'

```

and (to `~/.tmux.conf`)
```
set -g default-terminal "xterm-256color"
```
