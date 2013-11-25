" カラー設定
syntax on
colorscheme desert
" viとの互換性をとらない
set nocompatible
" バックスペースキーで削除できるものを指定
set backspace=indent,eol,start
" 新しい行のインデントを現在行と同じにする。
set autoindent
" バックアップを取らない
set nobackup
" 行番号を表示する
set number
" TAB幅を4文字にする
set tabstop=4
" タブや改行を表示する。trailなどの可視化。
set list
set listchars=tab:>-,eol:¶,trail:-
" 折り返しをしない
set nowrap
" 括弧入力時の対応する括弧を表示
set showmatch
" ルーラーを表示
set ruler
" タイトルをウインドウ枠に表示する
set title
" 文字コードの設定
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=ucs-bom,euc-jp,cp932,iso-2022-jp
set fileencodings+=,ucs-2le,ucs-2,utf-8

set viminfo=