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
setopt prompt_subst
setopt re_match_pcre
# vcs_info 設定

autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
autoload -Uz colors

# 以下の3つのメッセージをエクスポートする
#   $vcs_info_msg_0_ : 通常メッセージ用 (緑)
#   $vcs_info_msg_1_ : 警告メッセージ用 (黄色)
#   $vcs_info_msg_2_ : エラーメッセージ用 (赤)
zstyle ':vcs_info:*' max-exports 3

zstyle ':vcs_info:*' enable git svn hg bzr
# 標準のフォーマット(git 以外で使用)
# misc(%m) は通常は空文字列に置き換えられる
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

if is-at-least 4.3.10; then
	# git 用のフォーマット
	# git のときはステージしているかどうかを表示
	zstyle ':vcs_info:git:*' formats '(%s)-[%b]' '%c%u %m'
	zstyle ':vcs_info:git:*' actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
	zstyle ':vcs_info:git:*' check-for-changes true
	zstyle ':vcs_info:git:*' stagedstr "+"		# %c で表示する文字列
	zstyle ':vcs_info:git:*' unstagedstr "-"	# %u で表示する文字列
fi
# hooks 設定
if is-at-least 4.3.11; then
	# git のときはフック関数を設定する

	# formats '(%s)-[%b]' '%c%u %m' , actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
	# のメッセージを設定する直前のフック関数
	# 今回の設定の場合はformat の時は2つ, actionformats の時は3つメッセージがあるので
	# 各関数が最大3回呼び出される。
	zstyle ':vcs_info:git+set-message:*' hooks \
										git-hook-begin \
										git-untracked \
										git-push-status \
										git-nomerge-branch \
										git-stash-count

	# フックの最初の関数
	# git の作業コピーのあるディレクトリのみフック関数を呼び出すようにする
	# (.git ディレクトリ内にいるときは呼び出さない)
	# .git ディレクトリ内では git status --porcelain などがエラーになるため
	function +vi-git-hook-begin() {
		if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
			# 0以外を返すとそれ以降のフック関数は呼び出されない
			return 1
		fi

		return 0
	}

	# untracked フィアル表示
	#
	# untracked ファイル(バージョン管理されていないファイル)がある場合は
	# unstaged (%u) に ? を表示
	function +vi-git-untracked() {
		# zstyle formats, actionformats の2番目のメッセージのみ対象にする
		if [[ "$1" != "1" ]]; then
			return 0
		fi

		if command git status --porcelain 2> /dev/null \
			| awk '{print $1}' \
			| command grep -F '??' > /dev/null 2>&1 ; then

			# unstaged (%u) に追加
			hook_com[unstaged]+='?'
		fi
	}

	# push していないコミットの件数表示
	#
	# リモートリポジトリに push していないコミットの件数を
	# pN という形式で misc (%m) に表示する
	function +vi-git-push-status() {
		# zstyle formats, actionformats の2番目のメッセージのみ対象にする
		if [[ "$1" != "1" ]]; then
			return 0
		fi

		if [[ "${hook_com[branch]}" != "master" ]]; then
			# master ブランチでない場合は何もしない
			return 0
		fi

		# push していないコミット数を取得する
		local ahead
		ahead=$(command git rev-list origin/master..master 2>/dev/null \
			| wc -l \
			| tr -d ' ')

		if [[ "$ahead" -gt 0 ]]; then
			# misc (%m) に追加
			hook_com[misc]+="(p${ahead})"
		fi
	}

	# マージしていない件数表示
	#
	# master 以外のブランチにいる場合に、
	# 現在のブランチ上でまだ master にマージしていないコミットの件数を
	# (mN) という形式で misc (%m) に表示
	function +vi-git-nomerge-branch() {
		# zstyle formats, actionformats の2番目のメッセージのみ対象にする
		if [[ "$1" != "1" ]]; then
			return 0
		fi

		if [[ "${hook_com[branch]}" == "master" ]]; then
			# master ブランチの場合は何もしない
			return 0
		fi

		local nomerged
		nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')

		if [[ "$nomerged" -gt 0 ]] ; then
			# misc (%m) に追加
			hook_com[misc]+="(m${nomerged})"
		fi
	}

	# stash 件数表示
	#
	# stash している場合は :SN という形式で misc (%m) に表示
	function +vi-git-stash-count() {
		# zstyle formats, actionformats の2番目のメッセージのみ対象にする
		if [[ "$1" != "1" ]]; then
			return 0
		fi

		local stash
		stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
		if [[ "${stash}" -gt 0 ]]; then
			# misc (%m) に追加
			hook_com[misc]+=":S${stash}"
		fi
	}

fi

function _update_vcs_info_msg() {
	local -a messages
	local prompt

	LANG=en_US.UTF-8 vcs_info

	if [[ -z ${vcs_info_msg_0_} ]]; then
		# vcs_info で何も取得していない場合はプロンプトを表示しない
		prompt=""
	else
		# vcs_info で情報を取得した場合
		# $vcs_info_msg_0_ , $vcs_info_msg_1_ , $vcs_info_msg_2_ を
		# それぞれ緑、黄色、赤で表示する
		[[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{green}${vcs_info_msg_0_}%f" )
		[[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
		[[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )

		# 間にスペースを入れて連結する
		prompt="${(j: :)messages}"
	fi

	RPROMPT="$prompt"
}
add-zsh-hook precmd _update_vcs_info_msg
## ホスト毎にホスト名の部分の色を作る http://absolute-area.com/post/6664864690/zsh

# まだよくわかってないので、また今度＾ｑ＾ #

## かわいいプロンプトの設定 http://qiita.com/items/c200680c26e509a4f41c
# PCRE 互換の正規表現使用

# プロンプト指定
PROMPT="
%{$fg[red]%}%n%{$reset_color%}@%{$fg[cyan]%}%m%{$reset_color%} %{${fg[yellow]}%}%~%{${reset_color}%}
%(?.%{$fg[green]%}.%{$fg[blue]%})%(?!／(*'ヮ')＼ %{$fg[yellow]%}⚡%{$reset_color%}!／(*;-;%)＼? ⚡)%{${reset_color}%} "

# プロンプト指定(コマンドの続き)
PROMPT2='[%n]⚡ '

# スペルミスの補完時のプロンプト指定
SPROMPT="%{$fg[red]%}%{$suggest%}／(*'~'%)＼ <ひょっとして %B%r%b %{$fg[red]%}なのかな? [そう!(y), 違う!(n),a,e]:}${reset_color} "

# 右プロンプト指定
# 時間表示 #
RPROMPT="%{$fg[cyan]%}[%*]%{$reset_color%}"

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
