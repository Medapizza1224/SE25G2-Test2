# システムプログラミングの本番環境にデプロイする

## 本番環境の説明

- 櫨山研究室のサーバルームには何台かサーバがありますが、そのうちの1台（`onyx.u-gakugei.ac.jp`）が、システムプログラミングなどのソフトウェア開発PBLの本番環境用として割り当てられています。
- 本番環境には、次のものが備わっています。
    - **コンテナレジストリ**: 開発したアプリをコンテナイメージとして保存するためのシステム。
    - **コンテナ実行環境**: コンテナイメージを実行するためのソフトウェア。
    - **Portainer**: コンテナ実行環境を操作するためのWebアプリ。
- したがって、デプロイのために次の作業を行っていただきます。
    - GitHub Actionsを使ってコンテナイメージを作成して、コンテナレジストリにアップロードさせる作業
    - Portainerでコンテナを実行する作業

## 事前準備：本番環境のSSHサーバに接続できるようにする

## 初回のデプロイを行う

### 1. コミットにタグを付けて本番環境のコンテナレジストリにコンテナイメージをアップロードする

1. Webブラウザで[GitHubのリポジトリのホーム画面](../../)にアクセスします。
2. `Releases`をクリックして、タグの一覧を表示します。
    ![GitHubのリポジトリのホーム画面のスクリーンショット](./github-releases.png)
3. `Create new release`をクリックして、タグの作成画面を表示します。
    ![GitHubのタグ一覧画面のスクリーンショット](./github-tags.png)
4. タグを作成します。
    ![GitHubのタグ作成画面のスクリーンショット](github-create-tag.png)
    - Choose a tag: クリックすると入力欄が現れます。入力欄にバージョン名（`v1.0.0`など。最初に`v`を付けてください）を入力してタグを作成してください。
    - Target: どのブランチが指すコミットにタグを付けるのか、選んでください。
    - Release Title: `v1.0.0`などと入力します。最初に`v`を付けてください。
    - `Generate release notes`ボタンをクリックすると、リリースまでのプルリクエストなどの一覧をまとめてくれます。
    - 最後に`Publish release`ボタンをクリックしてください。
5. タグが作成されます。タグが作成されると、タグを付けたブランチが指すコミットのソースコードを基にコンテナイメージが作成され、本番環境のコンテナレジストリにアップロードされます。
    - 本番環境のコンテナレジストリにアップロードされるまでには、初回の場合は約2分の時間を要します。GitHubの画面の`Actions`タブから、コンテナイメージ作成の進捗状況を確認することができます。
    - ![GitHub Actionsの画面のスクリーンショット](<github-actions-workflows.png>)

### 2. Portainerにログインする

https://onyx.u-gakugei.ac.jp/portainer/ にアクセスすると、ログイン画面が表示されます。
画面の指示に従い、インスペクタから渡された認証情報を使ってログインしてください。

ログインに成功すると、PortainerのHome画面が表示されます。
### 3. PortainerでStackを作成する

Portainerでは各アプリのシステムに必要なコンテナ群を「Stack」という単位で管理しています。デプロイするためにはStackを作成してください。

1. Home画面には本番環境のサーバの一覧が表示されています。`onyx`の`Live connect`ボタンをクリックして、ダッシュボードを表示します。
    - ![PortainerのHome画面のスクリーンショット](./portainer-home.png)
2. `Stacks`をクリックして、Stackの一覧画面を表示します。
    - ![Portainerのダッシュボードのスクリーンショット](portainer-environment.png)
3. `Add stack`をクリックして、Stackの作成画面を表示します。
    - ![PortainerのStack一覧画面のスクリーンショット](portainer-empty-stacks.png)
4. Stackを作成してください。
    - ![PortainerのStack作成画面のスクリーンショット](portainer-create-stack-1.png)
    - ![PortainerのStack作成画面のスクリーンショット](portainer-stack-create-2.png)
    - Name: `se24g2`
    - Build method: `Web editor`
    - Web editorに次の内容を入力してください（コピーボタンを押してコピーしてください）。
      ```yaml
      services:
        app:
          image: onyx.u-gakugei.ac.jp:5000/se24g2/se24g2:latest
          depends_on:
            - mysql
          restart: always
          environment:
            - APP_DB_PROPERTIES_FILENAME=se24g2DataSource.properties
          networks:
            - proxy
            - default
        mysql:
          image: mysql:latest
          restart: always
          environment:
            - TZ=Asia/Tokyo
            - MYSQL_ROOT_PASSWORD=password
            - MYSQL_DATABASE=initdb
            - MYSQL_USER=mysql
            - MYSQL_PASSWORD=password
          command: --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --key_buffer_size=1048576 --myisam_sort_buffer_size=1048576 --innodb_buffer_pool_size=5242880 --innodb_log_buffer_size=1048576 --innodb_log_file_size=4194304 --max-connections=24 --open_files_limit=1024 --table_definition_cache=400 --table_open_cache=256
          volumes:
            - mysql_data:/var/lib/mysql
          networks:
            - default

      volumes:
        mysql_data:

      networks:
        default:
        proxy:
          external: true
      ```
    - Enable access control: オンにして`Private`を選択する。
    - 最後に`Deploy the stack`ボタンをクリックしてください。
7. Stackの作成に成功すると、Stackの一覧に`se24g2`が表示されます。
    - ![PortainerのStack一覧画面のスクリーンショット](./portainer-stacks.png)

### 4. mysqlコンテナでデータベースを初期化するためのSQLを実行する

1. Stackの一覧画面から`se24g2`をクリックして、Stackの編集画面を表示します。
    - ![PortainerのStack一覧画面のスクリーンショット](./portainer-stacks.png)
2. コンテナの一覧から`se24g2-mysql-1`をクリックして、コンテナの編集画面を表示します。
    - ![Portainerのコンテナ一覧画面のスクリーンショット](portainer-containers-mysql.png)
3. `Container status`の下部にある`Console`をクリックして、コンテナのコンソール接続画面を表示します。
    - ![Portainerのコンテナ編集画面のスクリーンショット](portainer-container-console.png)
4. Commandを`/bin/bash`にして、`Connect`をクリックして、コンテナのコンソールに接続します。（`/bin/bash`が使えなかった場合は`/bin/sh`を使ってください）
    - ![Portainerのコンソール接続画面のスクリーンショット](portainer-console-connection.png)
5. MySQLに`root`ユーザでログインして、`mysql`ユーザに`database`データベースに対する権限を付与するためのSQLを実行してください。
    ```sh
    # MySQLに`root`ユーザでログインするためのコマンド。
    mysql -u root -p
    ```
    ```sql
    -- `mysql`ユーザに`database`データベースに対する権限を付与するためのSQL

    -- データベース`database`を作成する。
    create database `database`;

    -- `mysql`ユーザーが`database`データベースを操作できるようにする。
    grant all privileges on `database`.* to `mysql`@`%`;
    ```
6. さらに、`database`データベースにテーブルを用意するためのSQLを実行してください。

### 5. 動作確認をする

- https://onyx.u-gakugei.ac.jp/se24g2 配下のURLにアクセスして動作確認をしてください。
- デプロイが完了したらインスペクタに連絡してください。

## 2回目以降のデプロイを行う

### 1. コミットにタグを付けて本番環境にコンテナイメージをアップロードする

[1回目のデプロイと同じ方法](#1-コミットにタグを付けて本番環境のコンテナレジストリにコンテナイメージをアップロードする)で、コミットにタグを付けて本番環境にコンテナイメージをアップロードしてください。

### 2. PortainerでWebアプリのコンテナを再作成する

1. Stackの一覧画面から`se24g2`をクリックして、Stackの編集画面を表示します。
    - ![PortainerのStack一覧画面のスクリーンショット](portainer-stacks.png)
2. コンテナの一覧から`se24g2-app-1`をクリックして、コンテナの編集画面を表示します。
    - ![Portainerのコンテナ一覧画面のスクリーンショット](portainer-containers-app.png)
3. `Actions`の中にある`Recreate`をクリックしてください。
    - ![Portainerのコンテナ編集画面のスクリーンショット](portainer-container-recreate.png)
4. ダイアログの`Re-pull image`をオンにしてから`Recreate`をクリックしてください。
    - ![Portainerのコンテナを再作成するダイアログのスクリーンショット](./portainer-container-recreate-dialog.png)
5. コンテナの再作成に成功すると、右上に`Container successfully re-created`と表示されます。

### 3. 動作確認をする

- https://onyx.u-gakugei.ac.jp/se24g2 配下のURLにアクセスして動作確認をしてください。
- デプロイが完了したらインスペクタに連絡してください。
