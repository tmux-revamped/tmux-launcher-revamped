<div align="center">

# tmux-launcher-revamped

<strong>從一個選單在 tmux 的彈出視窗、視窗或分割窗格中開啟 lazygit、yazi 等終端應用程式，從項目根目錄開始。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![ci](https://img.shields.io/github/actions/workflow/status/tmux-revamped/tmux-launcher-revamped/ci.yml?branch=main&style=flat-square&label=ci)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/ci.yml)
[![release](https://img.shields.io/github/v/release/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=release)](https://github.com/tmux-revamped/tmux-launcher-revamped/releases/latest)
[![openssf scorecard](https://img.shields.io/ossf-scorecard/github.com/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=openssf%20scorecard)](https://scorecard.dev/viewer/?uri=github.com/tmux-revamped/tmux-launcher-revamped)
[![license](https://img.shields.io/github/license/tmux-revamped/tmux-launcher-revamped?style=flat-square&label=license)](LICENSE)

<p align="center">
  <a href="#快速開始"><strong>快速開始</strong></a> &nbsp;|&nbsp;
  <a href="#用法">用法</a> &nbsp;|&nbsp;
  <a href="#應用程式">應用程式</a> &nbsp;|&nbsp;
  <a href="#畫面">畫面</a>
</p>

</div>

<p align="center">
  <img src="screens/hero.gif" alt="prefix M-a 開啟啟動器選單，tig 在項目根目錄以彈出視窗開啟" width="800">
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

列出你使用的應用程式，例如 lazygit、yazi、htop 或 k9s。`prefix M-a` 開啟包含全部應用程式的選單，每個應用程式亦可有自己的按鍵。每個應用程式在彈出視窗、視窗或分割窗格中開啟，位置是窗格所在的資料夾，或其上方的項目根目錄。

---

## 快速開始

### 前提條件

| 工具 | 版本 | 用途 |
|:-----|:--------|:---------|
| tmux | 3.2 或以上 | 系列的最低版本；較舊的版本中彈出視窗應用程式會以視窗開啟 |
| fzf | 任何 | 應用程式選擇器，只在設定了 `@launcher_revamped_picker_key` 時使用 |
| gum | 可選 | `launcher-revamped` 的選單、表格和顏色；沒有它，所有命令都輸出純文字 |

應用程式本身必須已安裝；插件會直接執行你提供的命令。

### 安裝

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

然後按 `prefix + I`。不使用 TPM 時，複製儲存庫，並在 `~/.tmux.conf` 中執行它的入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

在複製的目錄中執行 `make install`，亦會把 `launcher-revamped` 放入 `~/.local/bin`，並把它的 man 手冊和自動完成放在 `~/.local/share` 下。

### 驗證

```bash
~/.tmux/plugins/tmux-launcher-revamped/bin/launcher-revamped doctor
```

## 用法

按 `prefix M-a`。選單列出 `@launcher_revamped_apps` 中的每個應用程式，預設是在彈出視窗中開啟的 lazygit 和在視窗中開啟的 yazi。插件載入前你自己綁定的選單按鍵會保留，`doctor` 會說明這一點。

| 命令 | 作用 |
|:--------|:-------------|
| `launcher-revamped apply` | 立即綁定所有按鍵；插件載入時入口點會執行它 |
| `launcher-revamped list` | 列出 apply 會做的每個綁定；`--json` 輸出一個物件 |
| `launcher-revamped launch ID [ARG...]` | 開啟應用程式 `ID`；後面的每個詞成為一個加引號的參數 |
| `launcher-revamped pick` | 用 fzf 選擇一個應用程式，並為 `launch-picked` 記錄下來 |
| `launcher-revamped launch-picked` | 開啟 `pick` 記錄的應用程式 |
| `launcher-revamped doctor` | 每個依賴一行、每個應用程式一行，以及你事先綁定的選單按鍵 |
| `launcher-revamped version` | 版本，然後是 tmux 版本 |
| `launcher-revamped help` | 說明頁；`man launcher-revamped` 記錄相同的命令和設定 |
| `launcher-revamped` | 在終端機上顯示選單 |

| tmux 選項 | 預設值 | 含義 |
|:------------|:--------|:--------|
| `@launcher_revamped_apps` | `lazygit yazi` | 選單列出的應用程式 ID |
| `@launcher_revamped_menu_key` | `M-a` | 選單的 prefix 按鍵；`none` 表示不綁定選單 |
| `@launcher_revamped_picker_key` | 無 | fzf 應用程式選擇器的 prefix 按鍵 |
| `@launcher_revamped_marker` | 無 | 標示項目根目錄的檔案或資料夾，例如 `.git`，用於沒有自己標記的應用程式 |
| `@launcher_revamped_max_depth` | `20` | 標記搜尋向上查找的資料夾層數 |
| `@launcher_revamped_skip_missing` | `off` | `on` 時不為命令未安裝的應用程式綁定按鍵；有主機的應用程式不檢查 |

每個選項亦可寫成以短橫線連接的命令選項，例如 `--menu-key M-o`，以及環境變數，例如 `LAUNCHER_REVAMPED_MENU_KEY`；命令列優先於環境變數，環境變數優先於 tmux 選項。以 tmux 選項給出的設定在啟動應用程式時讀取；透過命令列或環境變數傳給 `launcher-revamped apply` 的設定會帶到它綁定的按鍵上。空的 tmux 選項表示使用預設值。

3.0.0 之前這些選項名為 `@launcher_*`，舊名稱已不再生效。選單按鍵的關閉值由 `off` 改為 `none`。

<a id="應用程式"></a>

## 應用程式

`@launcher_revamped_apps` 中的每個 ID 讀取自己的選項 `@launcher_revamped_<id>_<field>`：

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

| 欄位 | 預設值 | 含義 |
|:------|:--------|:--------|
| `_key` | 無 | 應用程式自己的 prefix 按鍵 |
| `_command` | ID | 執行的內容 |
| `_mode` | `popup`，yazi 為 `window` | `popup`、`window` 或 `split`；彈出視窗需要 tmux 3.2 |
| `_name` | ID | 視窗名稱和選單標籤 |
| `_width`、`_height` | `80%` | 彈出視窗的大小 |
| `_marker` | 無 | 應用程式自己的項目標記 |
| `_if` | 無 | 先執行的 shell 檢查；非零結束時應用程式不會開啟，`LAUNCHER_PATH` 保存它將開啟的資料夾 |
| `_prompt` | 無 | 先顯示的提示；輸入的每個詞成為一個加引號的參數 |
| `_group` | 無 | 在一個新視窗中平鋪開啟的應用程式 ID |
| `_host` | 無 | 透過 `ssh -t` 執行的主機 |
| `_reuse` | `off` | `on` 時，如果同名視窗已開啟就選取它 |
| `_env` | 無 | 在命令前設定的變數，例如 `A=1` |
| `_pre` | 無 | 必須先成功的命令 |
| `_exit` | 無 | 結束後執行的命令 |

有圖片預覽的檔案管理員，例如 yazi、lf 和 ranger，較適合 `window` 模式：tmux 彈出視窗不會傳遞圖片跳脫序列。

命令按 `pre && env VARS command ARGS; exit` 組合，有主機時整體包在 `ssh -t` 中。選擇器在彈出視窗中執行，把選中的 ID 記錄在 `@launcher_revamped_picked`；`launch-picked` 在彈出視窗關閉後開啟它，因此彈出視窗應用程式亦能開啟自己的彈出視窗。

<a id="畫面"></a>

## 畫面

<details>
<summary>所有畫面，在真實的 tmux 中用 <code>make screens</code> 錄製，每個按鍵顯示在狀態列上</summary>
<br>

<table>
<tr>
<td width="50%" valign="top"><img src="screens/menu.png" alt="launcher-revamped：prefix M-a 上的應用程式選單"><br><sub>prefix M-a 上的應用程式選單，來自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/popup.png" alt="launcher-revamped：在項目根目錄以彈出視窗開啟的 tig"><br><sub>在項目根目錄以彈出視窗開啟的 tig，來自 <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/window.png" alt="launcher-revamped：在獨立視窗中開啟的 vim"><br><sub>在獨立視窗中開啟的 vim，來自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/split.png" alt="launcher-revamped：工作旁邊的分割窗格"><br><sub>工作旁邊的分割窗格，來自 <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/prompt.png" alt="launcher-revamped：輸入的詞成為參數的提示"><br><sub>輸入的詞成為參數的提示，來自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/picker.png" alt="launcher-revamped：fzf 應用程式選擇器"><br><sub>fzf 應用程式選擇器，來自 <code>apps.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/group.png" alt="launcher-revamped：在一個視窗中平鋪的一組應用程式"><br><sub>在一個視窗中平鋪的一組應用程式，來自 <code>apps.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/list.png" alt="launcher-revamped：list"><br><sub><code>list</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/json.png" alt="launcher-revamped：list --json"><br><sub><code>list --json</code>，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/doctor.png" alt="launcher-revamped：doctor"><br><sub><code>doctor</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/plain-menu.png" alt="launcher-revamped：沒有 gum 的選單"><br><sub>沒有 gum 的選單，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/plain-apply.png" alt="launcher-revamped：從選單執行 apply"><br><sub>從選單執行 <code>apply</code>，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/version.png" alt="launcher-revamped：版本"><br><sub>版本，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/error.png" alt="launcher-revamped：不明命令"><br><sub>不明命令，來自 <code>stills.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/themes.png" alt="launcher-revamped：六種主題下的標題"><br><sub>六種主題下的標題，來自 <code>stills.tape</code></sub></td>
<td width="50%" valign="top"><img src="screens/help.png" alt="launcher-revamped：說明頁"><br><sub>說明頁，來自 <code>themes.tape</code></sub></td>
</tr>
<tr>
<td width="50%" valign="top"><img src="screens/accent.png" alt="launcher-revamped：來自 LAUNCHER_REVAMPED_ACCENT 的強調色"><br><sub>來自 <code>LAUNCHER_REVAMPED_ACCENT</code> 的強調色，來自 <code>help.tape</code></sub></td>
<td width="50%" valign="top"></td>
</tr>
</table>

</details>

## 可攜性

插件是 POSIX `sh`。CI 在下列每一行上執行全部測試。

| Shell | 狀態 |
|:------|:-------|
| `dash`、macOS 上的 `/bin/sh` | 支援 |
| `bash` 3.2 和 5.x、系統內建的 `zsh` 和 Homebrew 的 `zsh` | 支援 |

| 系統 | 狀態 |
|:-------|:-------|
| macOS | Apple Silicon 和 Intel 上的 Tahoe，使用內建的工具、Homebrew 的 GNU 工具和 Homebrew 的 uutils |
| Linux | x86_64 和 arm64 上的 Ubuntu 26.04，使用 GNU coreutils、uutils 和 BusyBox |

## 開發

| 指令 | 執行內容 |
|:--------|:-------------|
| `make fmt` | 對每個腳本執行 shfmt `-i 2` |
| `make lint` | shfmt、ShellCheck、mandoc、yamllint 和 actionlint，零警告 |
| `make test` | 在系統 `sh` 下執行 bats 測試 |
| `make test-all` | 在每個已安裝的 shell 下執行測試，macOS 上包括 bash 和 zsh 的兩種版本 |
| `make test-linux` | 在 Ubuntu 容器中執行測試 |
| `make coverage` | 在這部 Mac 和 Ubuntu 容器中執行 bashcov，合併後以 100% 為門檻 |
| `make screens` | 以 VHS 在 tmux 中從真實插件錄製上述畫面，在 macOS 上執行 |
| `make install` | 把指令、man 手冊和自動完成安裝到 `PREFIX` 下 |

在 macOS 上，執行 `brew bundle` 會根據 [`Brewfile`](Brewfile) 安裝這些目標用到的所有工具。

提交遵循 Conventional Commits 格式，直接進入 `main`。`main` 上的 `ci` 通過後，`release.yml` 會執行 semantic-release：自上一個標籤以來的每個 `feat` 或 `fix` 都會發佈新版本，更新版本常數，並把說明寫入 [`CHANGELOG.md`](CHANGELOG.md)。

## 授權

[MIT](LICENSE)，copyright Gustavo Franco。

<!-- family:begin -->

## tmux-revamped 插件家族

這個插件是 tmux-revamped 插件家族的一員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中相同的約定和相同的共用程式庫，並且設計為一起安裝：沒有成員佔用另一個成員佔用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。

| 成員 | 功能 |
|---|---|
| [`tmux-autoreload-revamped`](https://github.com/tmux-revamped/tmux-autoreload-revamped) | 編輯並儲存 tmux 設定後，它會自動重新載入，毋須按鍵，也毋須指令 |
| [`tmux-battery-revamped`](https://github.com/tmux-revamped/tmux-battery-revamped) | 在 tmux 狀態列顯示電池狀態，從不阻塞狀態列繪製 |
| [`tmux-bluetooth-revamped`](https://github.com/tmux-revamped/tmux-bluetooth-revamped) | 在 tmux 狀態列顯示每部已連接的藍牙裝置及其電量，不阻塞繪製 |
| [`tmux-cpu-revamped`](https://github.com/tmux-revamped/tmux-cpu-revamped) | 在 tmux 狀態列顯示 CPU 負載、溫度及頻率，從不阻塞繪製 |
| [`tmux-disk-revamped`](https://github.com/tmux-revamped/tmux-disk-revamped) | 在 tmux 狀態列顯示磁碟用量，從不阻塞狀態列繪製 |
| [`tmux-extract-revamped`](https://github.com/tmux-revamped/tmux-extract-revamped) | 用 fzf 從畫面上揀選 URL、路徑、雜湊值或任何其他字詞，並輸入到游標位置，全部以純 shell 實現 |
| [`tmux-fzf-revamped`](https://github.com/tmux-revamped/tmux-fzf-revamped) | 在彈出視窗的 fzf 選擇器中切換、關閉、重新命名或建立 tmux 工作階段、視窗和窗格 |
| [`tmux-git-revamped`](https://github.com/tmux-revamped/tmux-git-revamped) | 在 tmux 狀態列顯示當前窗格的 git 分支、改動和託管平台數目，而不會阻塞顯示 |
| [`tmux-gpu-revamped`](https://github.com/tmux-revamped/tmux-gpu-revamped) | 在 tmux 狀態列顯示 NVIDIA、AMD、Intel 及 Apple GPU 的負載、溫度、時脈、功耗及記憶體 |
| [`tmux-kube-revamped`](https://github.com/tmux-revamped/tmux-kube-revamped) | 在 tmux 狀態列顯示目前的 Kubernetes 上下文及命名空間，毋須 kubectl，直接解析 kubeconfig |
| [`tmux-launcher-revamped`](https://github.com/tmux-revamped/tmux-launcher-revamped) | **本插件**，在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵 |
| [`tmux-logging-revamped`](https://github.com/tmux-revamped/tmux-logging-revamped) | 將任何窗格儲存到檔案：即時記錄、完整捲動緩衝區或一次性截圖 |
| [`tmux-music-revamped`](https://github.com/tmux-revamped/tmux-music-revamped) | 在 tmux 狀態列顯示正在播放的歌曲，從不阻塞狀態列的繪製 |
| [`tmux-network-revamped`](https://github.com/tmux-revamped/tmux-network-revamped) | 在 tmux 狀態列顯示網絡傳輸量，從不阻塞繪製 |
| [`tmux-pain-control-revamped`](https://github.com/tmux-revamped/tmux-pain-control-revamped) | tmux 的窗格和視窗管理按鍵，配合 tmux 版本，與 vim 相容，每個 prefix 按鍵都可停用 |
| [`tmux-persist-revamped`](https://github.com/tmux-revamped/tmux-persist-revamped) | 儲存 tmux 的所有工作階段、視窗及窗格，按計時器自動儲存，並在重新開機後全部還原 |
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架和 CI |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

<!-- family:end -->
