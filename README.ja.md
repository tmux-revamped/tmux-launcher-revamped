<div align="center">

# tmux-launcher-revamped

<strong>lazygit や yazi などのターミナルアプリを、1 つのメニューから tmux のポップアップ、ウィンドウ、分割で開きます。開く場所はプロジェクトのルートです。</strong>

[English](README.md) &nbsp;|&nbsp; 日本語 &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; [繁體中文（香港）](README.zh-HK.md)

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-launcher-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-launcher-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-launcher-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#クイックスタート"><strong>クイックスタート</strong></a> &nbsp;|&nbsp;
  <a href="#使い方">使い方</a> &nbsp;|&nbsp;
  <a href="#アプリ">アプリ</a> &nbsp;|&nbsp;
  <a href="#画面">画面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="prefix M-a でランチャーのメニューを開き、tig をプロジェクトのルートでポップアップとして開く tmux" width="800">
</p>

```console
$ launcher-revamped doctor
tmux               ok       /usr/bin/tmux, 3.6
awk                ok       /usr/bin/awk, mawk 1.3.4
sed                ok       /usr/bin/sed, gnu 4.9
tr                 ok       /usr/bin/tr, uutils 0.10.0
fzf                warn     the picker needs it: brew install fzf, or apt install fzf
lazygit            warn     lazygit is not installed
yazi               warn     yazi is not installed
```

使うアプリを並べます。たとえば lazygit、yazi、htop、k9s です。`prefix M-a` でそのすべてのメニューが開き、どのアプリにも専用のキーを付けられます。アプリはポップアップ、ウィンドウ、分割のどれかで、ペインのフォルダーか、その上にあるプロジェクトのルートで開きます。

---

## クイックスタート

### 前提条件

| ツール | バージョン | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 以降 | ファミリー共通の最低バージョン。古い版ではポップアップのアプリがウィンドウで開きます |
| fzf | 任意 | アプリピッカー。`@launcher_revamped_picker_key` を設定したときだけ使います |
| gum | 任意 | `launcher-revamped` のメニュー、表、色。なくてもすべてのコマンドがプレーンテキストで動きます |

アプリ自体はインストールしておく必要があります。プラグインは指定されたコマンドをそのまま実行します。

### インストール

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

続けて `prefix + I` を押します。TPM を使わない場合は、リポジトリをクローンし、`~/.tmux.conf` からエントリーポイントを実行します。

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

クローンで `make install` を実行すると、`launcher-revamped` が `~/.local/bin` に、manページと補完が `~/.local/share` の下に入ります。

### 確認

```bash
~/.tmux/plugins/tmux-launcher-revamped/bin/launcher-revamped doctor
```

## 使い方

`prefix M-a` を押します。メニューには `@launcher_revamped_apps` のすべてのアプリが並びます。既定は、ポップアップで開く lazygit とウィンドウで開く yazi です。プラグインの読み込み前に自分で割り当てたメニューキーはそのまま残り、`doctor` がそれを知らせます。

| コマンド | 動作 |
|:--------|:-------------|
| `launcher-revamped apply` | 適用時のキーをすべて割り当てます。プラグインの読み込み時にエントリーポイントが実行します |
| `launcher-revamped list` | apply が行う割り当てをすべて表示します。`--json` で 1 つのオブジェクトを出力します |
| `launcher-revamped launch ID [ARG...]` | アプリ `ID` を開きます。後ろの各単語は、クォートされた 1 つの引数になります |
| `launcher-revamped pick` | fzf でアプリを選び、`launch-picked` のために記録します |
| `launcher-revamped launch-picked` | `pick` が記録したアプリを開きます |
| `launcher-revamped doctor` | 依存関係ごと、アプリごとに 1 行。先に自分で割り当てていたメニューキーも表示します |
| `launcher-revamped version` | バージョンと tmux のバージョン |
| `launcher-revamped help` | ヘルプ。`man launcher-revamped` にも同じコマンドと設定があります |
| `launcher-revamped` | 端末ではメニュー |

| tmux オプション | 既定値 | 意味 |
|:------------|:--------|:--------|
| `@launcher_revamped_apps` | `lazygit yazi` | メニューに並ぶアプリの ID |
| `@launcher_revamped_menu_key` | `M-a` | メニューの prefix キー。`off` または `none` でメニューを割り当てません |
| `@launcher_revamped_picker_key` | なし | fzf のアプリピッカーの prefix キー |
| `@launcher_revamped_marker` | なし | 専用のマーカーを持たないアプリが使う、プロジェクトのルートを示すファイルかフォルダー。たとえば `.git` |
| `@launcher_revamped_max_depth` | `20` | マーカーを探して上にたどるフォルダーの数 |
| `@launcher_revamped_skip_missing` | `off` | `on` で、コマンドがインストールされていないアプリにキーを割り当てません。ホストを持つアプリは確認しません |

どのオプションも、ダッシュ区切りのコマンドオプション（例 `--menu-key M-o`）と環境変数（例 `LAUNCHER_REVAMPED_MENU_KEY`）で指定できます。優先順位はコマンドライン、環境変数、tmux オプションの順です。tmux オプションで指定した設定はアプリを起動するたびに読まれ、`launcher-revamped apply` にコマンドラインまたは環境変数で渡したものは割り当てたキーに引き継がれます。空の tmux オプションは既定値を意味します。`doctor` は、プラグインが認識できない値を持つ設定の名前を表示します。

3.0.0 より前はオプション名が `@launcher_*` で、その名前はもう使えません。

<a id="アプリ"></a>

## アプリ

`@launcher_revamped_apps` の各 ID は、それぞれのオプション `@launcher_revamped_<id>_<field>` を読みます。

```tmux
set -g @launcher_revamped_apps 'lazygit yazi htop k9s man dash'

set -g @launcher_revamped_lazygit_key 'C-g'
set -g @launcher_revamped_lazygit_marker '.git'
set -g @launcher_revamped_lazygit_if 'git -C "$LAUNCHER_PATH" rev-parse 2>/dev/null'

set -g @launcher_revamped_htop_mode 'split'
set -g @launcher_revamped_k9s_host 'devbox'
set -g @launcher_revamped_man_prompt 'man:'
set -g @launcher_revamped_dash_group 'lazygit htop'
```

| フィールド | 既定値 | 意味 |
|:------|:--------|:--------|
| `_key` | なし | アプリ専用の prefix キー |
| `_command` | ID | 実行するもの |
| `_mode` | `popup`、yazi は `window` | `popup`、`window`、`split` のどれか。ポップアップには tmux 3.2 が必要です |
| `_name` | ID | ウィンドウ名とメニューの表示名 |
| `_width`、`_height` | `80%` | ポップアップの大きさ |
| `_marker` | なし | アプリ専用のプロジェクトマーカー |
| `_if` | なし | 先に実行するシェルのチェック。0 以外で終わるとアプリは開きません。`LAUNCHER_PATH` に開く予定のフォルダーが入ります |
| `_prompt` | なし | 先に表示するプロンプト。入力した各単語がクォートされた引数になります |
| `_group` | なし | 1 つの新しいウィンドウにタイル状に開くアプリの ID |
| `_host` | なし | `ssh -t` で実行するホスト |
| `_reuse` | `off` | `on` で、同じ名前のウィンドウが開いていればそれを選びます |
| `_env` | なし | コマンドの前に設定する変数。たとえば `A=1` |
| `_pre` | なし | 先に成功する必要があるコマンド |
| `_exit` | なし | 終了後に実行するコマンド |

yazi、lf、ranger のように画像をプレビューするファイルマネージャーは `window` モードが向いています。tmux のポップアップは画像のエスケープシーケンスを通さないためです。

コマンドは `pre && env VARS command ARGS; exit` の形で組み立てられ、ホストがあれば全体が `ssh -t` で包まれます。ピッカーはポップアップの中で動き、選んだ ID を `@launcher_revamped_picked` に記録します。`launch-picked` はポップアップが閉じてからそれを開くので、ポップアップのアプリも自分のポップアップを開けます。

<a id="画面"></a>

## 画面

<details>
<summary>すべての画面。本物の tmux の中で <code>make screens</code> で録画し、押したキーをステータスラインに表示しています</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="launcher-revamped: prefix M-a のアプリのメニュー"><br><sub>prefix M-a のアプリのメニュー。<code>apps.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="launcher-revamped: プロジェクトのルートでポップアップに開いた tig"><br><sub>プロジェクトのルートでポップアップに開いた tig。<code>apps.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/window.png" alt="launcher-revamped: 専用のウィンドウで開いた vim"><br><sub>専用のウィンドウで開いた vim。<code>apps.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/split.png" alt="launcher-revamped: 作業の横の分割"><br><sub>作業の横の分割。<code>apps.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/prompt.png" alt="launcher-revamped: 入力した単語が引数になるプロンプト"><br><sub>入力した単語が引数になるプロンプト。<code>apps.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/picker.png" alt="launcher-revamped: fzf のアプリピッカー"><br><sub>fzf のアプリピッカー。<code>apps.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/group.png" alt="launcher-revamped: 1 つのウィンドウにタイル状に開いたアプリのグループ"><br><sub>1 つのウィンドウにタイル状に開いたアプリのグループ。<code>apps.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="launcher-revamped: list"><br><sub><code>list</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="launcher-revamped: list --json"><br><sub><code>list --json</code>。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="launcher-revamped: doctor"><br><sub><code>doctor</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="launcher-revamped: gum なしのメニュー"><br><sub>gum なしのメニュー。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="launcher-revamped: メニューからの apply"><br><sub>メニューからの <code>apply</code>。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="launcher-revamped: バージョン"><br><sub>バージョン。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="launcher-revamped: 不明なコマンド"><br><sub>不明なコマンド。<code>stills.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="launcher-revamped: 6 つのテーマのヘッダー"><br><sub>6 つのテーマのヘッダー。<code>stills.tape</code>より</sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="launcher-revamped: ヘルプ"><br><sub>ヘルプ。<code>themes.tape</code>より</sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="launcher-revamped: LAUNCHER_REVAMPED_ACCENT によるアクセント"><br><sub><code>LAUNCHER_REVAMPED_ACCENT</code> によるアクセント。<code>help.tape</code>より</sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 移植性

プラグインは POSIX `sh` です。CI は下の各行ですべてのテストを実行します。

| シェル | 状態 |
|:------|:-------|
| `dash`、macOS の `/bin/sh` | 対応 |
| `bash` 3.2 と 5.x、システムの `zsh` と Homebrew の `zsh` | 対応 |

| システム | 状態 |
|:-------|:-------|
| macOS | Apple Silicon と Intel の Tahoe。付属のツール、Homebrew の GNU ツール、Homebrew の uutils で確認 |
| Linux | x86_64 と arm64 の Ubuntu 26.04。GNU coreutils、uutils、BusyBox で確認 |

## 開発

| コマンド | 実行内容 |
|:--------|:-------------|
| `make fmt` | すべてのスクリプトに shfmt `-i 2` をかけます |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint、actionlint を、指摘ゼロで通します |
| `make test` | システムの `sh` で bats のテスト |
| `make test-all` | インストール済みのすべてのシェルでテスト。macOS では bash と zsh の両方のビルドを含みます |
| `make test-linux` | Ubuntu のコンテナでテスト |
| `make coverage` | この Mac と Ubuntu のコンテナで bashcov を実行し、合算して 100 パーセントで判定します |
| `make screens` | 上の画面を、本物のプラグインから tmux の中で VHS で録画します。macOS で実行します |
| `make install` | コマンド、manページ、補完を `PREFIX` の下に置きます |

macOS では、`brew bundle` を実行すると、これらのターゲットが使うツールがすべて [`Brewfile`](Brewfile) からインストールされます。

コミットは Conventional Commits の形式に従い、そのまま `main` に入ります。`main` で `ci` が成功すると、`release.yml` が semantic-release を実行します。前回のタグ以降に `feat` か `fix` があればリリースを公開し、バージョン定数を更新し、変更内容を [`CHANGELOG.md`](CHANGELOG.md) に追加します。

## ライセンス

[MIT](LICENSE)、copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped ファミリー

このプラグインは tmux-revamped ファミリーの一員です。すべてのメンバーが [`FAMILY.md`](FAMILY.md) の同じ規約と同じ共有ライブラリを持ちます。メンバーは一緒にインストールする前提で作られており、ほかのメンバーが使うキーや tmux オプションを使うメンバーはありません。

あるメンバーで見つかった不具合は、修正完了とする前に全メンバーで同じ不具合を探します。

| メンバー | 機能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | tmuxの設定を編集して保存するだけで、キーもコマンドも使わずに自動で再読み込みされます |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | tmuxのステータスバーに電池の状態を表示し、ステータスの描画を一切止めません |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 接続中のすべてのBluetooth機器とその電池残量をtmuxのステータスバーに表示し、描画を止めません |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | CPUの負荷、温度、周波数をtmuxのステータスバーに表示し、描画を一切止めません |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | tmuxのステータスバーにディスク使用量を表示し、ステータスの描画を一切止めません |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 画面上の URL、パス、ハッシュなどのトークンを fzf で選び、カーソル位置に入力します。純粋なシェルだけで動きます |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | ポップアップ内の fzf ピッカーから、tmux のセッション、ウィンドウ、ペインの切り替え、終了、名前変更、作成を行います |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | アクティブなペインのgitブランチ、変更、プロバイダーの件数を、描画を止めずにtmuxのステータスバーに表示します |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | NVIDIA、AMD、Intel、Apple の GPU の負荷、温度、クロック、電力、メモリを tmux のステータスバーに表示します |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 現在の Kubernetes コンテキストと名前空間を、kubectl を使わずに kubeconfig から解析して tmux のステータスバーに表示します |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **このプラグイン**、任意の TUI アプリを、現在のペインのディレクトリでポップアップまたはウィンドウとして起動します。アプリごとにキーを設定できます |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 任意のペインをファイルに保存します。ライブのログ記録、スクロールバック全体、1 回限りのスクリーンショットに対応します |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 再生中の曲をステータスバーに表示し、ステータスの描画を止めません |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | ネットワークのスループットをステータスバーに表示し、描画を止めません |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux のペインとウィンドウの操作キー。tmux のバージョンに対応し、vim と共存でき、どの prefix キーも無効にできます |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | tmuxのすべてのセッション、ウィンドウ、ペインを保存し、タイマーで自動保存して、再起動後にすべて復元します |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revampedプラグインの出発点です。共有ライブラリ、batsハーネス、CIを含みます |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | すべての状態をtmuxオプションに保持し、一時ファイルを使わない、tmuxステータスバーのポモドーロタイマーです |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | RAM、スワップ、メモリプレッシャーをtmuxのステータスバーに表示します。計測はバックグラウンドで行うため描画を待たせません |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | tmuxのステータスバー上でウィンドウのタブをマウスでドラッグして、そのウィンドウを移動します |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 自分でスクロールできるアプリにはマウスホイールを渡し、それ以外ではtmuxのコピーモードに入ります |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | tmuxのバージョンと端末に合わせて適用され、ユーザーが設定したオプションには触れない、妥当な初期設定です |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmuxのタイル型ウィンドウ管理です。BSPのdwindleとspiralを含む8つのレイアウトと、レイアウトの取り消しがあります |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | ステータスバーにローカル時計と世界時計を時間帯ごとの色で表示し、カウントダウンと夏時間の警告も出します |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | wttr.inの天気をバックグラウンドで取得し、ステータスバーを待たせずに表示します |

<!-- family:end -->
