# Use powerline
#USE_POWERLINE="true"
# Source manjaro-zsh-configuration
if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
  source /usr/share/zsh/manjaro-zsh-config
fi
# Use manjaro zsh prompt
#if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
  #source /usr/share/zsh/manjaro-zsh-prompt
#fi

alias cp='xcp'
alias grep='rg'
alias ls='exa'
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less
alias maxima=rmaxima
alias x='gio trash'
umask 027

#pueue
alias pa='pueue add --'
alias pl='pueue log'
alias ps='pueue status'

# screen
#if [[ -z "$STY" ]]; then
   #export TERM=screen-256color
   #screen -xRR autoscreen
#fi
# Zellij
if [[ -z "$ZELLIJ_RUN" ]]; then
	export ZELLIJ_RUN=1234
	if zellij -s main
	then
	else
		zellij attach main
	fi
fi

PATH=$PATH:~/.cargo/bin
PATH="/home/eugene/.local/share/solana/install/active_release/bin:$PATH"

export EDITOR='vim'
export VISUAL='vim'

# Main-pc (un)mounting
alias mount-pc='sshfs 192.168.1.68:/mnt/Media /mnt/Media/' 
alias unmount-pc='umount /mnt/Media'
export TERM=xterm-256color-italic

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
