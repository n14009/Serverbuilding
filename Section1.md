# Section 1 基本のサーバー構築

virualboxで新規作成、名前をcentos7
種類をlinux redhat64bitにする。

## 1-1 CentOS 7のインストール VirtualBoxへのインストール 

1.公式サイトからcentos 7 minimal iso(x86_64)isoファイルをダウンロードしてvirualboxS上にインストール。
2.インストール時にroot以外の作業用のユーザーを作成する。
3.メモリサイズは1GB
4.ストレージ容量は8GBに設定。
5.インストールが終わると/etc/sysconfig/network-script/ifcfg-enp0s3を開くそこでonboot=yesにする。

## ネットワークアダプター1/2へのIPアドレスの設定とssh接続の確認

1. まずvirualboxの環境設定⇒ネットワークを開く
2. そこのアダプダ２をホストオンリーアダプダに設定、dhcpサーバーを有効にする
3. centos7の設定で、アダプタ２をホストオンリーアダプタに設定。
4. コマンドラインで
5. `ip a` でipアドレスが取得できているか確認する。

## SSH接続の確認
ubuntu上から`ssh 192.16.56.101`(先ほどdhcpで取得したipアドレス。)でsshでcentos7 に接続できるか確認する。


## インストール後の設定(yum,wgetのプロキシ設定)

/etc/yum.confを開き、最後の行に
`proxy=http://172.16.40.1:8888`と記入。
これでyumのprozyの設定完了。

    #yum install wget 
でwgetをインストールをして
/etc/wgetrcを開き

    https_proxy = http://172.16.40.1:8888/
    http_proxy = http://172.16.40.1:8888/
    ftp_proxy = http://172.16.40.1:8888/

を記入。これで設定完了

## アップデート
プロキシを設定するとアップでードができるようになっているので`yum update` を実行!

## 1-2 Wordpressを動かす(1)
 Wordpressを動作させるためには下記のソフトウェアが必要になります。 [※1](#LAMP)

* Apache HTTP Server
* MySQL
* PHP

yumで上記のものをインストール。
    yum -y install php-mysql php php-gd php-mbstring
    yum -y install mariadb mariadb-server

mariaDBでユーザーとデータベースを作る。

「terminalにて」

*   # mysql -u root -p　←MariaDBeへrootでログイン
*Enter password ←MariaDBのrootパスワード

これでrootにログインできる。

    # create database wpress(データベースの名前、自分でつける);　←　「wpress」という名のデータベース作成

    # grant all privileges on wpress.* to ユーザー名@localhost identified by 'パスワード';←　「自分のユーザー名」という名のデータベースを読み書きできるユーザー「ユーザー名」をパスワード「自分のパスワード」で作成

これができたら exit でMariaDBからログアウト 

##wordpressダウンロード＆インストール

公式サイトからwgetを使いwordpressをダウンロード
    # wget https://ja.wordpress.org/wordpress-4.2.2-ja.tar.gz

    # `tar zxvf wordpress-3.9.1-ja.tar.gz` ←WordPress解凍

    # `mv wordpress/ /var/www/html/wpress`　←　WordPress解凍先ディレクトリを/var/www/html/wpressディレクトリ下へ移動（「wpress」は例示）

    # `chmod 777 /var/www/html/wpress`　←　WordPressディレクトリwpress（「wpress」は例示）を一時的に書込可にする

    # `chown -R tu:apache /var/www/html/wpress/`　←　WordPressディレクトリとその中の全ファイルの所有者をtu、グループをApache実行ユーザへ変更（「tu」は自分のユーザー名の例示。「apache:apache」も可）

    # `mkdir /var/www/html/wpress/wp-content/uploads`　←　uploadsフォルダの作成

    # `mkdir /var/www/html/wpress/wp-content/upgrade`　←　upgradeフォルダの作成

    # `chmod -R 777 /var/www/html/wpress/wp-content`　←　wp-contentフォルダとその中の全ファイルに読み書き権限の設定

    # `rm -f wordpress-3.9.1-ja.tar.gz`　←　ダウンロードしたファイルを削除

##SELinux有効な場合

    # `getsebool -a | grep http`　←　SELinuxでhttpの下記項目がすべてon であるか確認

    # `setsebool -P httpd_can_network_connect_db 1`←　httpd_can_network_connect_dbをonにする。1を入力してonにする方法もある

(1=on、0=offの意味)

    # `setsebool -P httpd_dbus_avahi 1`　←　httpd_dbus_avahiをonにする。

    # `setsebool -P httpd_tty_comm 1`　←　httpd_tty_commをonにする。

    # `setsebool -P httpd_unified 1`　←　httpd_unifiedをonにする。

    # `yum provides *bin/semanage`　←　semanageをインストールするため確認

    # `yum -y install policycoreutils-python`　←　policycoreutils-pythonをインストールパッケージ policycoreutils-python-2.2.5-11.el7.x86_64 はインストール済みか最新バージョンです何もしません

    # `semanage fcontext -a -t httpd_sys_content_t` "/var/www/html/wpress(/.*)?"←　ウェブコンテンツとしてwpressフォルダへのアクセスを許可

    # `restorecon -R -v /var/www/html/wpress`　←　変更設定を更新

    # `semanage fcontext -a -t httpd_sys_rw_content_t` "/var/www/html/wpress/wp-content(/.*)?"←　ウェブコンテンツとしてwp-contentフォルダへの書込を許可

    # `restorecon -R -v /var/www/html/wpress/wp-content`　←　変更設定を 更新

    # `setsebool -P allow_ftpd_full_access 1`　←　pluginやthemeの追加に 必要なftpへのフルアクセスを許可

    # `systemctl restart httpd`　←　httpdの再起動

##WordPress初期設定

1. http://サーバー名/wpress/へアクセスし、表示される赤枠「設定ファイルを作成する」1をクリック
2. 表示される画面の「さあ、始めましょう！」をクリックj
3. 表示される画面にMySQLで作成した「データベース名」、「ユーザー名」、「パスワード」を入力して、「送信」をクリック
4. 表示される画面の「インストール実行」をクリック
5. 表示される画面のの全項目を埋め、の「WordPressをインストール」をクリック
6. 表示される画面の「ログイン」をクリック
7. ログイン画面が表示されるので、登録したユーザー名を赤枠１に、パスワードをに入力しての「ログイン」をクリック
8. 管理画面が表示されればOK

これでSection1は終了

参考サイト http://ufuso.jp/wp/?p=15315
