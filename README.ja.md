<div align="center">

# tmux-launcher-revamped

<strong>任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![Tests](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">機能</a> &nbsp;|&nbsp;
  <a href="#installation">インストール</a> &nbsp;|&nbsp;
  <a href="#usage">使い方</a> &nbsp;|&nbsp;
  <a href="#configuration">設定</a> &nbsp;|&nbsp;
  <a href="#key-bindings">キーバインド</a> &nbsp;|&nbsp;
  <a href="#how-it-works">仕組み</a>
</p>

</div>

**21** 個のオプション、**3** つの起動モード、既定で割り当てるキーは **1** つ、tmux **3.2** 以降に対応します。

---

<a id="what-it-does"></a>

## 機能

`lazygit`、`yazi`、`htop`、`k9s` など、使っている端末アプリを一覧に登録します。各アプリはポップアップ、新しいウィンドウ、または分割ペインで開き、現在のペインのディレクトリから始まります。

| 機能 | オプション |
|:-----|:-----------|
| 登録したすべてのアプリを 1 つのメニューから開く | `@launcher_menu_key` |
| アプリに専用のキーを割り当てる | `@launcher_<id>_key` |
| アプリごとにポップアップ、ウィンドウ、分割を選ぶ | `@launcher_<id>_mode` |
| ペインのディレクトリではなくプロジェクトのルートから始める | `@launcher_<id>_marker`、`@launcher_marker` |
| 条件を満たさないときは起動しない | `@launcher_<id>_if` |
| 起動前に引数を入力する | `@launcher_<id>_prompt` |
| 複数のアプリを 1 つのウィンドウにタイル状に並べて開く | `@launcher_<id>_group` |
| `ssh -t` で別のホストのアプリを実行する | `@launcher_<id>_host` |
| fzf でアプリを選ぶ | `@launcher_picker_key` |

<a id="requirements"></a>

## 動作要件

| 要件 | バージョン |
|:-----|:-----------|
| tmux | 3.2 以降 |
| bash | 3.2 以降 |
| fzf | 任意のバージョン、`@launcher_picker_key` を使う場合のみ |

Linux と macOS で、BSD、GNU、uutils のいずれの coreutils でも動作します。起動するアプリは別途インストールが必要です。プラグインは指定されたコマンドをそのまま実行します。

<a id="installation"></a>

## インストール

[TPM](https://github.com/tmux-plugins/tpm) を使う場合は、`~/.tmux.conf` にプラグインを追加して `prefix + I` を押します。

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

手動でインストールする場合は、リポジトリをクローンし、`~/.tmux.conf` からエントリポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

<a id="usage"></a>

## 使い方

`prefix + M-a` を押すと、`@launcher_apps` に登録したすべてのアプリがメニューに表示されます。既定では、ポップアップで開く `lazygit` とウィンドウで開く `yazi` です。

自分のアプリを追加し、よく使うものには専用のキーを割り当てます。

```tmux
set -g @launcher_apps 'lazygit yazi lazydocker htop k9s'

set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
set -g @launcher_htop_key 'C-t'
set -g @launcher_htop_mode 'split'
```

そのほかの起動オプションの例です。

```tmux
set -g @launcher_lazygit_if 'git -C "$LAUNCHER_PATH" rev-parse 2>/dev/null'
set -g @launcher_lazygit_marker '.git'
set -g @launcher_lazygit_exit 'tmux refresh-client -S'

set -g @launcher_man_key 'C-m'
set -g @launcher_man_prompt 'man:'

set -g @launcher_dash_key 'C-d'
set -g @launcher_dash_group 'lazygit htop'

set -g @launcher_k9s_key 'C-s'
set -g @launcher_k9s_host 'box.example'

set -g @launcher_picker_key 'C-p'
set -g @launcher_skip_missing 'on'
```

`yazi`、`lf`、`ranger` など画像のプレビューを表示するファイルマネージャーは、`window` モードのほうが適しています。tmux のポップアップは画像のエスケープシーケンスを通さないためです（[tmux#4329](https://github.com/tmux/tmux/issues/4329)）。

<a id="configuration"></a>

## 設定

`@launcher_apps` はアプリ ID をスペースで区切った一覧です。各 ID は以下のアプリ別オプションを読み取ります。

### 全体のオプション

| オプション | 既定値 | 意味 |
|:-----------|:-------|:-----|
| `@launcher_apps` | `lazygit yazi` | メニューに表示し、専用キーを確認するアプリ ID |
| `@launcher_menu_key` | `M-a` | 全アプリの `display-menu` を開く prefix キー。`off` で割り当てを解除します |
| `@launcher_picker_key` | なし | fzf のアプリ選択をポップアップで開く prefix キー |
| `@launcher_marker` | なし | 独自のマーカーを持たないすべてのアプリが使うマーカーのファイルまたはディレクトリ |
| `@launcher_max_depth` | `20` | マーカーの検索でさかのぼる親ディレクトリの数 |
| `@launcher_skip_missing` | off | `on` にすると、コマンドが `PATH` にないアプリには専用キーを割り当てません。ホストを指定したアプリは確認しません |

### アプリ別のオプション

| オプション | 既定値 | 意味 |
|:-----------|:-------|:-----|
| `@launcher_<id>_key` | なし | このアプリの prefix キー。設定するまでキーは割り当てられません |
| `@launcher_<id>_command` | ID と同じ | 実行するシェルコマンド |
| `@launcher_<id>_mode` | `popup`、`yazi` は `window` | `popup`、`window`、`split` のいずれか |
| `@launcher_<id>_name` | ID と同じ | `window` モードでのウィンドウ名と、メニューでの表示名 |
| `@launcher_<id>_width` | `80%` | ポップアップの幅 |
| `@launcher_<id>_height` | `80%` | ポップアップの高さ |
| `@launcher_<id>_marker` | なし | ペインのディレクトリから上にたどり、`.git` などのマーカーを含むディレクトリから始めます。見つからなければペインのディレクトリを使います |
| `@launcher_<id>_if` | なし | 起動前に実行するシェルの条件。終了コードが 0 以外なら起動しません。`LAUNCHER_PATH` に開始ディレクトリが入ります |
| `@launcher_<id>_prompt` | なし | プロンプトの文字列。入力した単語はそれぞれクォートされた引数としてコマンドに追加されます |
| `@launcher_<id>_group` | なし | スペース区切りのアプリ ID。1 つの新しいウィンドウで開いてタイル状に並べます |
| `@launcher_<id>_host` | なし | リモートホスト。組み立てたコマンドを `ssh -t` で実行します |
| `@launcher_<id>_reuse` | off | `window` モードで `on` にすると、新しく開かずに同じ名前のウィンドウを選択します |
| `@launcher_<id>_env` | なし | `env` でコマンドの前に置く変数。例：`FOO=bar` |
| `@launcher_<id>_pre` | なし | 最初に実行するコマンド。成功した場合だけアプリを起動します |
| `@launcher_<id>_exit` | なし | アプリの終了後に実行するコマンド |

### 内部状態

以下のオプションはプラグイン自身が書き込みます。設定しないでください。

| オプション | 保持する内容 |
|:-----------|:-------------|
| `@launcher_prompt_value` | アプリのプロンプトに入力した文字列。起動時に 1 回だけ読み取ります |
| `@launcher_picked` | fzf の選択画面で選んだアプリ。起動するとクリアされます |

<a id="key-bindings"></a>

## キーバインド

| キー | 動作 | 既定 |
|:-----|:-----|:-----|
| `prefix + M-a` | `@launcher_apps` の全アプリのメニュー | 割り当て済み |
| `@launcher_<id>_key` | そのアプリを起動 | 未割り当て |
| `@launcher_picker_key` | fzf のアプリ選択 | 未割り当て |

バージョン 2.0.0 で以前の専用キーは削除されました。元に戻すには次のように設定します。

```tmux
set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
```

<a id="how-it-works"></a>

## 仕組み

tmux がプラグインを読み込むと、[`launcher-revamped.tmux`](launcher-revamped.tmux) が [`src/launcher.sh`](src/launcher.sh) を 1 回実行します。このスクリプトはオプションを読み取り、メニュー、選択画面、各アプリのキーを割り当てます。どのキーも `run-shell -b` 経由で同じスクリプトを `dispatch <id>` として呼び出すため、処理はキーを押したときに行われます。

起動時に `dispatch` は開始ディレクトリを決め、`_if` の条件を実行し、`pre &&`、`env` の変数、コマンドとプロンプトの引数、`; exit` の順にコマンドを組み立てます。ホストを指定すると、その結果全体を `ssh -t` で包みます。モードによって `display-popup -E`、`new-window`、`split-window` のどれを使うかが決まります。`display-popup` のない tmux 3.2 未満では、ポップアップのアプリはウィンドウで開きます。

fzf の選択画面は `display-popup -E` の中で動き、選んだ ID を `@launcher_picked` に保存して、ポップアップが閉じた後に起動します。そのため、ポップアップのアプリも自分のポップアップを開けます。

純粋な補助関数は [`src/lib/launcher/launcher.sh`](src/lib/launcher/launcher.sh) にあります。`LAUNCHER_DRY_RUN` を設定すると、スクリプトは tmux の呼び出しを実行せずに表示します。テストスイートはこれを使ってキーの割り当てを確認します。

<a id="development"></a>

## 開発

| コマンド | 内容 |
|:---------|:-----|
| `make test` | bats のテストスイートを実行します |
| `make lint` | すべてのシェルファイルに shellcheck を実行します |
| `make coverage` | Linux で kcov を使って行カバレッジを測定し、95% 未満なら失敗します |

変更点は [CHANGELOG.md](CHANGELOG.md) にあります。

<a id="license"></a>

## ライセンス

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約、`family/` 配下の同じツール、同じ共有ライブラリを持ち、チェックサムの一覧によってバイト単位で同一に保たれています。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。この義務は記憶に頼らず規約に書かれており、`family/bin/sweep` がその作業を行います。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmux の設定ファイルを編集して保存すると、キーもコマンドも使わずに自動で再読み込みします |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | ステータスバーにバッテリーの状態を表示し、ステータスの描画を止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべての Bluetooth デバイスとそのバッテリーをステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPU の負荷、温度、周波数をステータスバーに表示し、描画を止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | ステータスバーにディスク使用量を表示し、ステータスの描画を止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。シェルのみで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップの fzf 選択画面から、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前の変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインの Git ブランチ、変更、プロバイダーの件数をステータスバーに表示し、描画を止めません |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリをステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間をステータスバーに表示します。kubectl を使わず kubeconfig を解析します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **このプラグイン**、任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux の標準的なペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、すべて設定できます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmux のすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存し、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | 描画を止めない tmux ステータスプラグインを作るためのテンプレート |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | ステータスバーのポモドーロタイマー。状態はすべて tmux のオプションに保持し、一時ファイルは使いません |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリ圧迫をステータスバーに表示します。計測はバックグラウンドで行うため、描画が待つことはありません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | ステータスバーのウィンドウタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | マウスホイールを、自分でスクロールするアプリにはそのまま送り、それ以外では tmux のコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmux のバージョンと端末に応じて適用する妥当な既定値。ユーザーが設定したオプションには触れません |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux のタイリングによるウィンドウ管理。BSP の dwindle と spiral を含む 8 つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバー用のローカル時計と世界時計。時間帯で色が変わり、カウントダウンと夏時間の警告があります |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.in の天気をステータスバーに表示します。取得はバックグラウンドで行うため、ステータスラインが待つことはありません |

### インストールの確認

全メンバーがディスク上にあれば、1 つのコマンドでメンバー間の衝突を報告できます。

```sh
family/bin/doctor --live
```

各メンバーと実行中の tmux サーバーを読み取り、重複したキー、重複したステータスのプレースホルダー、命名規則に合わないオプション、規約のバージョンが古いメンバーを報告します。

<!-- family:end -->
