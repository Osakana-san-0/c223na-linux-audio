# C223NA Linux audio

Acer Chromebook 311 C223NA（ボード名 **Babymega**）向けに、Debian 上で内蔵スピーカー・ヘッドホン・内蔵マイクを有効にするセットです。

Debian の公式カーネルはスピーカー用 `CONFIG_SND_SOC_INTEL_AVS_MACH_MAX98357A` を無効にしています。このリポジトリはその欠けている AVS マシンドライバをビルドし、Babymega 用の ALSA UCM エントリを追加します。

## 注意

MAX98357A スピーカーアンプにはハードウェアの音量制限がありません。ソフトウェア音量を **20〜40%** 程度に保ってください。100% にするとスピーカーを破損する可能性があります。

## 必要環境

- Acer C223NA / Google Babymega
- Debian 13（Intel AVS、`avs_da7219` が既に見えていること）
- `build-essential` と実行中カーネルの `linux-headers-$(uname -r)`

## インストール

```bash
sudo apt-get install -y build-essential "linux-headers-$(uname -r)"
sudo ./install.sh
systemctl --user restart pipewire wireplumber pipewire-pulse
```

カーネル更新後:

```bash
sudo apt-get install -y "linux-headers-$(uname -r)"
./rebuild.sh
```

## 構成

| ファイル | 内容 |
| --- | --- |
| `max98357a.c` / `utils.h` | Debian で無効化されている Intel AVS MAX98357A マシンドライバ |
| `install.sh` | モジュール・modprobe・UCM をインストール |
| `rebuild.sh` | 新しいカーネル向けにモジュールだけ作り直す |
| `conf/` | WirePlumber headroom と AVS modprobe 設定 |

UCM はカード長名 `Google-Babymega-rev5` を既存の `avs_da7219` / `avs_dmic` / `avs_max98357a` プロファイルへ結びます。
