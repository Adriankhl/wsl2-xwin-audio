# auto start cron service
[ -z "$(ps -ef | grep cron | grep -v grep)" ] && sudo /etc/init.d/cron start &> /dev/null

# alias and paths
export PATH="$HOME/bin":$PATH

# x11 opengl rendering options
export LIBGL_ALWAYS_INDIRECT=0
export LIBGL_ALWAYS_SOFTWARE=0

# display to Xserver, sound to audiopulse server
export DISPLAY=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}'):0.0
export PULSE_SERVER=tcp:$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')

# Fix directory color in /mnt
export LS_COLORS='ow=01;36;40'

# run when start if not in tmux
if [ -z "$TMUX" ]; then
    xpa &> /dev/null
fi

# run when exit if not in tmux
if [ -z "$TMUX" ]; then
    trap "killxpa" EXIT
fi
