# 【🍎macOSセルフホスト用】開発コンテナーの作成・使用方法

## 🧭 Quick Links

- [作業を再開する](#-作業を再開するには)
- [作業を終了する](#-作業を終了するには)

## 👉 開発コンテナーの作成手順

> [!NOTE]
> 以降の説明は、[必要なソフトウェアのインストール](https://github.com/HazeyamaLab/systemdesign2024/blob/main/docs/setup/procedure-for-selfhost-macos.md)が完了していることを前提としています。

### 1. Colimaを起動する

1. ターミナルで次のコマンドを実行します。ここでは、Colimaに3GBのメモリと16GBのストレージを割り当てています。起動に成功すると`INFO[0013] done`のように表示されます。
    ```sh
    colima start -m 3 -d 16
    ```
    ※ 開発環境の使用中に「`Reconnecting to Devcontainer…`」が頻発したり、パフォーマンス上の不具合が多発（VSCodeが固まる、CPU使用率が高いままになるなど）する場合は、Colimaが使用できるメモリのサイズの上限を引き上げてください。
    ```sh
    colima start -m 4 -d 16
    ```

### 2. 開発コンテナーを作成し、作成した開発コンテナーに接続する

1. VSCodeを起動します。
    - Dockの`Launchpad`をクリック→`Visual Studio Code`の順にクリックします。
2. VSCode上で開発コンテナーを作成するために`Dev Containers`拡張機能をインストールします。`⇧⌘P`（`⇧`キーと`⌘`キーを押しながら`P`キーを押す）を押してコマンドパレットを開き、**`>`を消してから**`ext install ms-vscode-remote.remote-containers`と入力して`Enter`キーを押します。
3. 開発コンテナーを作成します。
    1. `⇧⌘P`を押してコマンドパレットを開き、`Dev Containers: Clone Repository in Container Volume`と入力して`Enter`キーを押します（途中まで入力して同名の項目を選択しても構いません）。
    2. 入力欄に`https://github.com/HazeyamaLab/systemdesign2024report`と入力して`Enter`キーを押します。
    3. 開発コンテナーの作成が完了するまで待ちます。開発コンテナーの作成には数分間かかることがあります。作成に成功すると自動的に開発コンテナーに接続され、画面左下のリモートボタンに`Dev Container: systemdesign2024report`と表示されます。

## ℹ️ 開発環境の使用方法

このページにはご自身のPC上で作成した開発コンテナー特有の事柄を記します。それ以外の事柄は[README.md](../../README.md#ℹ️-開発環境の使い方)をご覧ください。

### 🧐 作業を終了するには？

VSCodeと開発コンテナーの接続を切断します。メニューバーの`File`（`ファイル`）→`Close Remote Connection`（`リモート接続を閉じる`）をクリックします。その後、VSCodeのウィンドウを閉じてVSCodeを終了します。

### 🧐 作業を再開するには？

Colimaを起動してからVSCodeを開発コンテナーに接続します。

1. ColimaとVSCodeを起動します。
    - Colimaを起動するには、ターミナルでコマンド`colima start -m 4 -d 16`を実行します。
2. VSCodeの画面左側の`Remote Explorer`（`リモート エクスプローラー`・`🖥️`のようなアイコン）をクリックして、リモートエクスプローラーを表示します。
3. `Remote (Tunnel/SSH)`（`リモート (トンネル/SSH)`）の一覧が表示されている場合は、プルダウンで`Dev Containers`（`開発コンテナー`）の一覧を表示するように切り替えます。
4. `Dev Containers`（`開発コンテナー`）の一覧から`systemdesign2024report_devcontainer-devcontainer-1`を選び、`→`（`Open Container in Current Window`、`現在のウィンドウのコンテナーで開く`）または`Open Container in New Window`（`新しいウィンドウのコンテナーで開く`）をクリックします。
5. 開発コンテナーへの接続に成功すると、画面左下のリモートボタンに`Dev Container: systemdesign2024report`と表示されます。
6. `mysql`コンテナーや`adminer`コンテナーの機能を利用する場合は、`Other Containers`の一覧の`systemdesign2024report_devcontainer-mysql-1`および`systemdesign2024report_devcontainer-adminer-1`が起動していることを確認します。
    - 起動している場合は`▶️`のようなアイコンが付いています。
    - 起動していない場合は右クリック→`Start Container`（`コンテナーの開始`）をクリックします。

### 🧐 Colimaを終了するには？

ターミナルでコマンド`colima stop`を実行します。

### 🧐 開発コンテナーに割り当てられているメモリが足りない。「`Reconnecting to Devcontainer…`」が頻発する。

Colimaが使用できるメモリのサイズの上限を引き上げてください。
一度[Colimaを終了して](#-colimaを終了するには)から、[1. Colimaを起動する](#1-colimaを起動する)の手順を参考にして、Colimaにより大きいメモリを割り当てて起動してください。
