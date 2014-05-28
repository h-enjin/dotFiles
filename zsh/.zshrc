# .zshrc をコンパイルして .zshrc.zwc を生成するコマンド
# zcompile .zshrc


## 環境変数PATH設定
export PATH=$PATH:/cygdrive/c/Program\ Files/Java/jdk1.7.0_21/bin
## 言語・文字セット指定
export LANG=ja_JP.UTF-8
# export OUTPUT_CHARSET=utf8

## 履歴など
HISTFILE=$HOME/.dotFiles/zsh/history/.zsh_history
HISTSIZE=10000
SAVEHIST=100000
LISTMAX=1000

if [ $UID = 0 ]; then
 unset HISTFILE
 SAVEHIST=0
fi

## 補完
autoload -U compinit && compinit
# 補完時、大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
# 補完候補を方向キーで選択
zstyle ':completion:*:default' menu select=1

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

## プロンプト
# カラー設定
autoload -U colors && colors

## Gitのブランチ名などを表示するやつ
autoload -Uz VCS_INFO_get_data_git; VCS_INFO_get_data_git 2> /dev/null

function rprompt-git-current-branch {
	local name st color gitdir action
	if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
		return
	fi

	name=`git rev-parse --abbrev-ref=loose HEAD 2> /dev/null`
	if [[ -z $name ]]; then
		return
	fi

	gitdir=`git rev-parse --git-dir 2> /dev/null`
	action=`VCS_INFO_git_getaction "$gitdir"` && action="($action)"

	if [[ -e "$gitdir/rprompt-nostatus" ]]; then
		echo "$name$action"
		return
	fi

	st=`git status 2> /dev/null`
	if [[ "$st" =~ "(?m)^nothing to" ]]; then
		color=%F{green}
	elif [[ "$st" =~ "(?m)^nothing added" ]]; then
		                color=%F{yellow}
	elif [[ "$st" =~ "(?m)^# Untracked" ]]; then
		color=%B%F{red}
	else
		color=%F{red}
	fi

	echo "$color$name$action%f%b"
}
## ホスト毎にホスト名の部分の色を作る http://absolute-area.com/post/6664864690/zsh

# まだよくわかってないので、また今度＾ｑ＾ #

## かわいいプロンプトの設定 http://qiita.com/items/c200680c26e509a4f41c
# PCRE 互換の正規表現使用
setopt re_match_pcre
setopt prompt_subst

# プロンプト指定
PROMPT="
%{$fg[red]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} %{${fg[yellow]}%}%~%{${reset_color}%} [`rprompt-git-current-branch`]
%(?.%{$fg[green]%}.%{$fg[blue]%})%(?!／(*'ヮ')＼ %{$fg[yellow]%}⚡%{$reset_color%}!／(*;-;%)＼? ⚡)%{${reset_color}%} "

# プロンプト指定(コマンドの続き)
PROMPT2='[%n]⚡ '

# スペルミスの補完時のプロンプト指定
SPROMPT="%{$fg[red]%}%{$suggest%}／(*'~'%)＼ <ひょっとして %B%r%b %{$fg[red]%}なのかな? [そう!(y), 違う!(n),a,e]:}${reset_color} "

# 右プロンプト指定
# 時間表示 #
RPROMPT="%{$fg[cyan]%}[%*]%{$reset_color%}"
#RPROMPT='[`rprompt-git-current-branch`%~]'

# 場所表示ver #
# RPROMPT="%{$fg_bold[white]%}[%{$reset_color%}%{$fg[cyan]%}%~%{$reset_color%}%{$fg_bold[white]%}]%{$reset_color%}"

## プロンプトのその他設定など
# 環境変数を通す

setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt share_history
setopt hist_expand
setopt list_packed

setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt list_types
setopt auto_param_slash
setopt mark_dirs

setopt correct

setopt auto_cd
setopt no_beep
setopt extended_glob
setopt print_eight_bit

setopt auto_pushd
setopt pushd_ignore_dups

setopt transient_rprompt
setopt complete_aliases
setopt rm_star_wait

## エイリアス設定
alias ls='ls -ap --color=auto'
alias grep='grep --color=auto -n'
alias vi='vim'
alias apt-cyg='apt-cyg -u '
alias java='java -Dfile.encoding=UTF-8'
alias javac='javac -J-Dfile.encoding=UTF-8'
