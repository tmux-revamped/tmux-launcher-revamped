<div align="center">

# tmux-launcher-revamped

<strong>在彈出視窗或新視窗中啟動任何 TUI 應用程式，從目前窗格的目錄開始，每個應用程式可設定一個按鍵。</strong>

[English](README.md) &nbsp;|&nbsp; [日本語](README.ja.md) &nbsp;|&nbsp; [简体中文](README.zh-Hans.md) &nbsp;|&nbsp; 繁體中文（香港）

[![Tests](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml/badge.svg)](https://github.com/tmux-revamped/tmux-launcher-revamped/actions/workflows/tests.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](CHANGELOG.md)

<p align="center">
  <a href="#what-it-does">功能</a> &nbsp;|&nbsp;
  <a href="#installation">安裝</a> &nbsp;|&nbsp;
  <a href="#usage">用法</a> &nbsp;|&nbsp;
  <a href="#configuration">設定</a> &nbsp;|&nbsp;
  <a href="#key-bindings">按鍵綁定</a> &nbsp;|&nbsp;
  <a href="#how-it-works">運作原理</a>
</p>

</div>

**21** 個選項，**3** 種啟動模式，預設只綁定 **1** 個按鍵，支援 tmux **3.2** 或以上版本。

---

<a id="what-it-does"></a>

## 功能

將你常用的終端機應用程式列出來，例如 `lazygit`、`yazi`、`htop` 或 `k9s`。每個應用程式會在彈出視窗、新視窗或分割窗格中開啟，並從目前窗格的目錄開始。

| 功能 | 選項 |
|:-----|:-----|
| 從一個選單開啟所有已列出的應用程式 | `@launcher_menu_key` |
| 為應用程式指定專用按鍵 | `@launcher_<id>_key` |
| 為每個應用程式選擇彈出視窗、視窗或分割窗格 | `@launcher_<id>_mode` |
| 從專案根目錄而不是窗格目錄開始 | `@launcher_<id>_marker`、`@launcher_marker` |
| 檢查失敗時不啟動 | `@launcher_<id>_if` |
| 啟動前輸入參數 | `@launcher_<id>_prompt` |
| 在一個平鋪視窗中同時開啟多個應用程式 | `@launcher_<id>_group` |
| 透過 `ssh -t` 在另一部主機上執行應用程式 | `@launcher_<id>_host` |
| 用 fzf 選擇應用程式 | `@launcher_picker_key` |

<a id="requirements"></a>

## 系統要求

| 要求 | 版本 |
|:-----|:-----|
| tmux | 3.2 或以上 |
| bash | 3.2 或以上 |
| fzf | 任何版本，只有 `@launcher_picker_key` 需要 |

可在 Linux 和 macOS 上執行，支援 BSD、GNU 或 uutils coreutils。要啟動的應用程式須自行安裝，插件只會執行你指定的指令。

<a id="installation"></a>

## 安裝

使用 [TPM](https://github.com/tmux-plugins/tpm) 時，將插件加入 `~/.tmux.conf`，然後按 `prefix + I`：

```tmux
set -g @plugin 'tmux-revamped/tmux-launcher-revamped'
```

手動安裝時，複製儲存庫，並在 `~/.tmux.conf` 中執行入口腳本：

```bash
git clone https://github.com/tmux-revamped/tmux-launcher-revamped ~/.tmux/plugins/tmux-launcher-revamped
```

```tmux
run-shell ~/.tmux/plugins/tmux-launcher-revamped/launcher-revamped.tmux
```

<a id="usage"></a>

## 用法

按 `prefix + M-a`，選單會列出 `@launcher_apps` 中的所有應用程式。預設是在彈出視窗中開啟的 `lazygit` 和在視窗中開啟的 `yazi`。

加入你自己的應用程式，並為最常用的應用程式指定專用按鍵：

```tmux
set -g @launcher_apps 'lazygit yazi lazydocker htop k9s'

set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
set -g @launcher_htop_key 'C-t'
set -g @launcher_htop_mode 'split'
```

更多啟動選項：

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

`yazi`、`lf`、`ranger` 等會顯示圖片預覽的檔案管理工具較適合使用 `window` 模式，因為 tmux 彈出視窗不會轉送圖片的轉義序列（[tmux#4329](https://github.com/tmux/tmux/issues/4329)）。

<a id="configuration"></a>

## 設定

`@launcher_apps` 是以空格分隔的應用程式 ID 清單。每個 ID 讀取下列的應用程式選項。

### 整體選項

| 選項 | 預設值 | 意思 |
|:-----|:-------|:-----|
| `@launcher_apps` | `lazygit yazi` | 在選單中顯示並檢查專用按鍵的應用程式 ID |
| `@launcher_menu_key` | `M-a` | 開啟所有應用程式 `display-menu` 的 prefix 按鍵；設為 `off` 即取消綁定 |
| `@launcher_picker_key` | 無 | 在彈出視窗中開啟 fzf 應用程式選擇器的 prefix 按鍵 |
| `@launcher_marker` | 無 | 沒有自己標記的應用程式所用的標記檔案或目錄 |
| `@launcher_max_depth` | `20` | 尋找標記時向上搜尋的上層目錄數目 |
| `@launcher_skip_missing` | off | 設為 `on` 時，指令不在 `PATH` 中的應用程式不會綁定專用按鍵；設定了主機的應用程式不作檢查 |

### 應用程式選項

| 選項 | 預設值 | 意思 |
|:-----|:-------|:-----|
| `@launcher_<id>_key` | 無 | 該應用程式的 prefix 按鍵；設定之前不會綁定任何按鍵 |
| `@launcher_<id>_command` | 與 ID 相同 | 要執行的 shell 指令 |
| `@launcher_<id>_mode` | `popup`，`yazi` 為 `window` | `popup`、`window` 或 `split` |
| `@launcher_<id>_name` | 與 ID 相同 | `window` 模式下的視窗名稱，以及選單中的標籤 |
| `@launcher_<id>_width` | `80%` | 彈出視窗闊度 |
| `@launcher_<id>_height` | `80%` | 彈出視窗高度 |
| `@launcher_<id>_marker` | 無 | 由窗格目錄向上尋找包含此標記（例如 `.git`）的目錄；找不到時使用窗格目錄 |
| `@launcher_<id>_if` | 無 | 啟動前執行的 shell 判斷；結束碼非零即取消啟動。`LAUNCHER_PATH` 存放起始目錄 |
| `@launcher_<id>_prompt` | 無 | 提示文字；輸入的每個字詞都會作為加上引號的參數附加到指令後 |
| `@launcher_<id>_group` | 無 | 以空格分隔的應用程式 ID，在一個新視窗中開啟並平鋪 |
| `@launcher_<id>_host` | 無 | 遠端主機；組合後的指令透過 `ssh -t` 執行 |
| `@launcher_<id>_reuse` | off | 在 `window` 模式下設為 `on` 時，選取同名視窗而不是再開一個 |
| `@launcher_<id>_env` | 無 | 用 `env` 放在指令前的變數，例如 `FOO=bar` |
| `@launcher_<id>_pre` | 無 | 先執行的指令；只有它成功時才啟動應用程式 |
| `@launcher_<id>_exit` | 無 | 應用程式結束後執行的指令 |

### 內部狀態

以下選項由插件自行寫入，請勿設定。

| 選項 | 存放內容 |
|:-----|:---------|
| `@launcher_prompt_value` | 在應用程式提示中輸入的文字，啟動時讀取一次 |
| `@launcher_picked` | 在 fzf 選擇器中選取的應用程式，啟動後清除 |

<a id="key-bindings"></a>

## 按鍵綁定

| 按鍵 | 動作 | 預設 |
|:-----|:-----|:-----|
| `prefix + M-a` | `@launcher_apps` 中所有應用程式的選單 | 已綁定 |
| `@launcher_<id>_key` | 啟動該應用程式 | 未綁定 |
| `@launcher_picker_key` | fzf 應用程式選擇器 | 未綁定 |

2.0.0 版移除了以往的專用按鍵。要還原它們：

```tmux
set -g @launcher_lazygit_key 'C-g'
set -g @launcher_yazi_key 'C-y'
```

<a id="how-it-works"></a>

## 運作原理

tmux 載入插件時，[`launcher-revamped.tmux`](launcher-revamped.tmux) 會執行一次 [`src/launcher.sh`](src/launcher.sh)。該腳本讀取選項，並綁定選單、選擇器和每個應用程式的按鍵。每個綁定都透過 `run-shell -b` 以 `dispatch <id>` 回呼同一個腳本，所以實際工作在按下按鍵時才進行。

啟動時，`dispatch` 決定起始目錄，執行 `_if` 判斷，然後按以下次序組合指令：`pre &&`、`env` 變數、指令及其提示參數、`; exit`。設定主機後，整個結果會用 `ssh -t` 包裝。模式決定使用 `display-popup -E`、`new-window` 還是 `split-window`。在沒有 `display-popup` 的 tmux 3.2 以下版本中，彈出視窗應用程式會改為在視窗中開啟。

fzf 選擇器在 `display-popup -E` 中執行，將選取的 ID 存放到 `@launcher_picked`，並在彈出視窗關閉後啟動它。這樣彈出視窗應用程式亦可開啟自己的彈出視窗。

純函數輔助程式碼位於 [`src/lib/launcher/launcher.sh`](src/lib/launcher/launcher.sh)。設定 `LAUNCHER_DRY_RUN` 後，腳本會列印每個 tmux 呼叫而不執行，測試套件就是用這方法檢查按鍵綁定。

<a id="development"></a>

## 開發

| 指令 | 作用 |
|:-----|:-----|
| `make test` | 執行 bats 測試套件 |
| `make lint` | 對所有 shell 檔案執行 shellcheck |
| `make coverage` | 在 Linux 上用 kcov 量度行覆蓋率，低於 95% 時失敗 |

變更紀錄見 [CHANGELOG.md](CHANGELOG.md)。

<a id="license"></a>

## 授權

[MIT](LICENSE)

<!-- family:begin -->

## tmux-revamped 插件家族

本插件是 tmux-revamped 插件家族的成員。每個成員都帶有 [`FAMILY.md`](FAMILY.md) 中的同一份約定、`family/` 下的同一套工具和同一個共用程式庫，並由校驗和清單確保逐位元組一致。這些成員可以一併安裝：任何成員都不會佔用其他成員使用的按鍵或 tmux 選項。

在一個成員中發現的缺陷，要在全部成員中排查後才算修正完成。這項責任寫在約定之中，而不是依靠記憶，`family/bin/sweep` 負責執行。

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
| [`tmux-plugin-template`](https://github.com/tmux-revamped/tmux-plugin-template) | tmux-revamped 插件的起點：共用程式庫、bats 測試框架、CI 和系列工具 |
| [`tmux-pomodoro-revamped`](https://github.com/tmux-revamped/tmux-pomodoro-revamped) | tmux 狀態列中的番茄鐘計時器，所有狀態都儲存在 tmux 選項中，不使用暫存檔 |
| [`tmux-ram-revamped`](https://github.com/tmux-revamped/tmux-ram-revamped) | 在 tmux 狀態列顯示記憶體、交換空間及記憶體壓力，在背景取樣，繪製從不等待 |
| [`tmux-reorder-revamped`](https://github.com/tmux-revamped/tmux-reorder-revamped) | 用滑鼠在 tmux 狀態列上拖動視窗標籤來移動該視窗 |
| [`tmux-scroll-revamped`](https://github.com/tmux-revamped/tmux-scroll-revamped) | 將滑鼠滾輪交給能自行捲動的應用程式，其他情況下進入 tmux 複製模式 |
| [`tmux-sensible-revamped`](https://github.com/tmux-revamped/tmux-sensible-revamped) | 按 tmux 版本和終端機區分的合理預設設定，不會改動你自己設定的選項 |
| [`tmux-tiling-revamped`](https://github.com/tmux-revamped/tmux-tiling-revamped) | tmux 的平鋪視窗管理：八種版面，包括 BSP dwindle 和 spiral，並支援復原版面 |
| [`tmux-time-revamped`](https://github.com/tmux-revamped/tmux-time-revamped) | 狀態列中的本地時鐘和世界時鐘，按一天中的時段著色，並提供倒數和夏令時間提示 |
| [`tmux-weather-revamped`](https://github.com/tmux-revamped/tmux-weather-revamped) | 在背景從 wttr.in 取得天氣並顯示在狀態列，狀態列毋須等待 |

### 檢查安裝

所有成員都在磁碟上時，一個指令即可報告它們之間的任何衝突：

```sh
family/bin/doctor --live
```

它讀取每個成員和正在運行的 tmux 伺服器，報告重複的按鍵、重複的狀態佔位符、不符合命名規則的選項，以及約定版本落後的成員。

<!-- family:end -->
