# km.awesome.conf (kmaedaさん用 awesome 設定ファイル)

## 概要

これはkmaedaさんが普段使っている awesome >=4.0 の設定ファイルです．自分用 layout と tasklist を含みます．完全に自分のニーズに合わせてプログラムしていますので，そのままでは使い物にならないと思います．参考程度にご覧下さい．

バージョンが 3.5 から 4.0 になって，API も色々変わったらしいのですが，とりあえず動作がおかしくなったところを直して，deprecated functions を置き換える程度の応急処置しかしていません．また上げておかしくなったらその都度直していくつもりです．

## awesome とは

[awesome window manager](https://awesomewm.org/) は X 用のいわゆるタイル型ウインドウマネージャーです．Lua を用いて柔軟に設定できるのが魅力です．

## kmaedaさんの生態

私は基本的に GUI プログラムは以下のものしか使いません：

 * Emacs (with GTK+ 3): エディタ
 * Luakit（Firefox から移行中）: Web ブラウザ
 * Claws Mail: MUA
 * Audacious: 音楽プレイヤー
 * st: 端末
 * zathura & Evince: PDF ビューワ

（もちろん必要に応じて他のプログラムも使います．）常駐は最初の4つで，これらには専用のタグを割り当て，他のプログラムには1番から順にタグを割り当てていく設定になっています．基本的に1タグ1ウインドウで，プログラムが起動すると自動的に新しく割り当てられたタグが selected になります．

なお，スクリーンは1枚しかないことを前提に書いてあります．2枚以上への対応は自分の中で必要性が出てきたら考えます．

## 自動起動

以下のプログラムが最初に自動的に起動します．

 * xset: キーボードの反応速度などの設定
 * xmodmap: キーの入れ替え（CapsLock -> Ctrl, Muhenkan -> Special など）
 * hsetroot: 背景色を黒に
 * xcompmgr: ウインドウ透過．背景色を黒にして，unfocus 時に opacity = 0.5 にすることで，フォーカスのウインドウ以外は暗くなります．
 * xscreensaver: スクリーンセーバー
 * ibus-daemon: 日本語入力

## キーバインド

Emacs 使いなので，デフォルトの vi 風から Emacs 風に変更しています．余計な機能は誤って作動するとイライラの原因になるため，自分が使う機能以外は切っています．

 * s-1, s-2, ..., s-9, s-0: それぞれの番号のタグのみを表示．ただし，Emacs はこれによる影響を受けない．
 * s-c: フォーカスのあるウインドウを閉じる．
 * s-e: Emacs を表示．Emacs が起動していない場合は起動して表示．
 * s-m: Audacious のみ表示（Emacs はそのまま）．Audacious が起動していない場合は起動して表示．
 * s-n: 次のウインドウにフォーカス.
 * s-p: 前のウインドウにフォーカス．
 * s-s: Claws Mail のみ表示（Emacs はそのまま）．Claws Mail が起動していない場合は起動して表示．
 * s-w: Luakit のみ表示（Emacs はそのまま）．Luakit が起動していない場合は起動して表示．
 * s-Return: st を起動する．
 * s-space: layout を切り替える（実質的に全画面表示）．
 * s-Shift-1, s-Shift-2, ..., s-Shift-9, s-Shift-0: それぞれの番号のタグへとフォーカスのあるウインドウを移動する．ただし，Emacs, Luakit, Claws Mail, Audacious を移動することはできない．
 * s-Shift-n: 現在フォーカスのあるウインドウのインデックスを +1 する．
 * s-Shift-p: 現在フォーカスのあるウインドウのインデックスを -1 する．
 * C-s-1, C-s-2, ..., C-s-9, C-s-0: それぞれの番号のタグの表示を切り替える．
 * C-s-b: Audacious のプレイリストを1つ進める．
 * C-s-c: Audacious のプレイリストをクリアする．
 * C-s-e: Emacs の表示を切り替える．Emacs が起動していない場合は起動して表示．
 * C-s-m: Audacious の表示を切り替える．Audacious が起動していない場合は起動して表示．
 * C-s-n: split layout のとき，前にあるウインドウの表示比率を大きくする．
 * C-s-p: split layout のとき，前にあるウインドウの表示比率を小さくする．
 * C-s-r: awesome を再起動する．
 * C-s-s: Claws Mail の表示を切り替える．Claws Mail が起動していない場合は起動して表示．
 * C-s-v: Audacious の再生を停止する．
 * C-s-w: Luakit の表示を切り替える．Luakit が起動していない場合は起動して表示．
 * C-s-x: Audacious のプレイリストを再生する．
 * C-s-z: Audacious のプレイリストを1つ前に戻す．
 * C-s-Return: フォーカスのあるウインドウをマスターと入れ替える．
 * C-s-space: フォーカスのあるウインドウを float にする．

## マウス

基本的な機能のみです．

 * 左クリック: ポインタのあるウインドウにフォーカス．
 * s-左ドラッグ: float なウインドウの移動．
 * s-右ドラッグ: float なウインドウのサイズ変更．

## Split layout

素朴な layout ですが，既存の layout には合うものがなかったので作りました．使えばわかります．

## Tasklist

通常の awesome の tasklist と違い，タグの selected に関係なく全てのプログラムが表示されます．ただし，Emacs, Luakit, Claws Mail, Audacious は表示されません．Luakit, Claws Mail については，2つ目以降のウインドウにはタグが割り合てられます．プログラム名の前には，そのプログラムのタグ番号が表示され，selected なものは明るく，さらにフォーカスのあるものはプログラム名が黄色で表示されます．

## License

GNU General Publice License v2 or later.

## 意見・要望など

前田一貴 (kmaeda at kmaeda.net) までお願いします．GitHub 経由でも構いません．
