# Section 2 その他のWebサーバー環境

## 2-1 Vagrantを使用したCentOS 7環境の起動

サーバーを構築するたびにOSのインストールからやってられないので事前に用意したCentOS 6.5の環境をVagrantで起動します。

### Vagrantで起動できるCentOS 6.5のイメージを登録

usbからコピーしたboxをaddする
    
    vagrant box add CentOS65 コピーしたboxファイル --force

### Vagrantの初期設定

作業用ディレクトリを作成し、その中で初期設定を行ないます。

    vagrant init

上記コマンドを実行するとVagrantfileというファイルが作成されます。このファイルにVagrantの設定が書かれています。
そのままではデフォルトのOS(存在しない)起動してしまうので、CentOS6.5を起動するようにします。

viでVagrantfileを開き、

    config.vm.box = "base"

と書かれているのを

    config.vm.box = "CentOS65"

とします。ここで指定するものはvagrant box addで指定したものの名前(上記の例だとCentOS7)を指定します。

### 仮想マシンの起動

    vagrant up

### 仮想マシンの停止

    vagrant halt

### 仮想マシンの一時停止

    vagrant suspend

### 仮想マシンの破棄

最初からやり直したい…そんな時に破棄するとCentOSが初期化されます。
また`vagrant up`をすると立ち上がります…

    vagrant destroy

### 仮想マシンへ接続

実際の仮想マシンへはsshで接続します。

    vagrant ssh

### ホストオンリーアダプターの設定

サーバーを設定したあと、動作確認するために接続するためのIPアドレスを設定します。
また、そのためのNICを追加します。

Vagrantfileの

    Vagrant.configure(2) do |config|

から一番最後の

    end

の間に

    config.vm.network :private_network, ip:"192.168.56.129"

と書くと仮想マシンのNIC2に192.168.56.129のIPアドレスが振られます。
`config.vm.box = "CentOS7"` の下にでも書くといいと思います。

※ 当然のことながら、複数台の仮想マシンを立ち上げる時には異なるIPアドレスを割り当てる必要があります。

### Vagrantfileの反映

Vagrantfileで変更した設定を反映させるには

    vagrant reload

すると反映されます。ただし、再起動されますので注意してね。

## 2-2 Wordpressを動かす(2)

1-2ではWordpressをApache + PHP + MySQLで動作させたが、今度はNginx + PHP + MariaDBで動作させます。

Nginxはディストリビューターからrpmが提供されていないため、リポジトリを追加する必要があります。
[公式サイト](http://nginx.org/en/linux_packages.html#stable)からリポジトリ追加用のrpmをダウンロードしてインストールしてください。


###phpをインストールする
    yum -y install php-mysql php-gd php-mbstring php-fpm

phpをインストールでかたかバージョンを確認する。
    
    php --version

###php-fpmを設定する

php-fpmのサービス実行ユーザ、グループを指定します。

ここでは Nginx のユーザに合わせています。

    user = nginx
    group = nginx    

php-fpmのサービスのプロセス数を定量とするように設定しておきます。

-- dynamic を指定すると変動させることができます。

    ;pm = dynamic
    pm = static

php-fpmの最大プロセス数を設定します。
-- ここでは、3としています。
    
    ;pm.max_children = 50
    pm.max_children = 3

php-fpmが受け付ける最大要求数を設定します。

ここで設定した要求数を処理したら子プロセスを再起動します。

-- ここでは、500としています。
    
    pm.max_requests = 500
  
### phpデーモンを起動する

php-fpmデーモンが起動しているか確認します。
    
    $ systemctl list-units |grep php-fpm

&uarr; 何も出力されないので、起動していない状態だとわかります。
  
次に、php-fpmデーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep php-fpm
    php-fpm.service                             disabled
&uarr; disabledなので、再起動してもphp-fpmデーモンのは起動しません。

php-fpm のデーモン（サービス）を起動します。
    
    $ systemctl start php-fpm.service
php-fpm のデーモン（サービス）が起動しているか確認します。
    
    $ systemctl list-units |grep php-fpm
      php-fpm.service                                      \
          loaded active running   The PHP FastCGI Process Manager
&uarr; このようにphp-fpmのデーモン（サービス）が起動していることが確認できます。
       
次に、php-fpmデーモンの登録状態を確認します。
     
       $ systemctl list-unit-files |grep php-fpm
           php-fpm.service                             disabled

&uarr; disabledなので、再起動してもphp-fpmデーモンのは起動しません。
        
次に、php-fpmデーモンがブート時に自動起動するように設定しておきます。
    
    $ systemctl enable php-fpm.service
        
        ln -s '/usr/lib/systemd/system/php-fpm.service' '/etc/systemd/system/multi-user.target.wants/php-fpm.service'
         
再度、php-fpmデーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep php-fpm
    php-fpm.service                             enabled

&uarr; enabledなので、再起動してもphp-fpmデーモンは起動されます。

###mariadbをインストールする。
    yum install mariadb mariadb-server

versionを確認する
    
    mysql --version
###mariadbデーモンを起動させる

mariadbデーモンが起動しているか確認します。

    $ systemctl list-units |grep mariadb

&uarr; 何も出力されないので、起動していない状態だとわかります。
     
次に、mariadbデーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep mariadb
       mariadb.service                             disabled

&uarr; disabledなので、再起動してもmariadbデーモンのは起動しません。

mariadb のデーモン（サービス）を起動します。
    
    $ systemctl start mariadb.service

mariadb のデーモン（サービス）が起動しているか確認します。
    
    $ systemctl list-units |grep mariadb
       mariadb.service                                      \
          loaded active running   MariaDB database server
          
&uarr; このようにmariadb のデーモン（サービス）が起動していることが確認できます。
       
次に、mariadbデーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep mariadb
       mariadb.service                             disabled

&uarr; disabledなので、再起動してもmariadbデーモンのは起動しません。
        
次に、mariadbデーモンがブート時に自動起動するように設定しておきます。
    
    $ systemctl enable mariadb.service
        
        ln -s '/usr/lib/systemd/system/mariadb.service' '/etc/systemd/system/multi-user.target.wants/mariadb.service'
         
再度、mariadbデーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep mariadb
         mariadb.service                             enabled
###2-3 Wordpressを動かす(3)
ここでは、sqlをテキストファイルにまとめて、一気に流してしまいます。
これがファイルの中身のサンプルです。

    /* rootのパスワードを設定します。 */
    nset password for root@localhost=password('roothoge')
    /* hoge というユーザを新規に作成します。のパスワードも設定します。 */
    insert into user set user="hoge", password=password("hogehoge"), host="localhost";
    /* wddb というwordpress用にデータベースを作成します。 */
    create database wddb;
    /* wddb というデータベースに hogeというユーザが常にアクセスできるようにします。 */
    grant all on wddb.* to hoge;
    /* 最新に更新 */
    FLUSH PRIVILEGES;
続けてテキストファイルをmysqlコマンドを使って一気に流します。

    $mysql -uroot -Dmysql < wordpress.sql
    
管理者でログインできるか確認します
    
    $ mysql -uroot(rootの名前) -proothoge(指定したパスワードの名前)
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 4
    Server version: 5.5.37-MariaDB MariaDB Server
 
    Copyright (c) 2000, 2014, Oracle, Monty Program Ab and others.
  
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
   
    MariaDB [(none)]> exit
    Bye
    
続けて新規データベースへ新規ユーザでログインできるか確認します。
    
    $ mysql -uhoge(自分のユーザー名) -phogehoge(パスワード) -Dwddb(データベースの名前)
    
    Welcome to the MariaDB monitor.  Commands end with ; or \g.
    Your MariaDB connection id is 5 
    Server version: 5.5.37-MariaDB MariaDB Server
     
    Copyright (c) 2000, 2014, Oracle, Monty Program Ab and others.
      
       Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
       
    MariaDB [wddb]> exit
       Bye]

↑こう表示されればOK!!!!

###nginxをインストールする。
公式サイトからrpmをダウンロード
    
    wget http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm

その後yumでインストールできるようになっているので
    
    yum install nginx

でインストール
###nginxデーモンを起動する

httpdを停止します。
    
    $ systemctl stop httpd.service
 
再起動してもhttpdが自動起動しないように無効にします。
    
    $ systemctl disable httpd.service

ログ出力先ディレクトリを作成します。

    $ mkdir -p /var/log/nginx/www.example.com

ログ出力先ディレクトリの所有者をnginxとします。
    
    chown nginx: /var/log/nginx/www.example.com
    $ chmod +r+w /var/log/nginx/www.example.com
 
ウェブサーバー(nginx) を起動します。
    
    $ systemctl start nginx.service

ウェブサーバー(nginx) のデーモン（サービス）が起動しているか確認します。
    
    $ systemctl list-units |grep nginx
     nginx.service                                        \
         loaded active running   nginx - high performance web server

&uarr; このようにウェブサーバー(nginx) のデーモン（サービス）が起動していることが確認できます。
         
次に、ウェブサーバー(nginx)デーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep nginx
         nginx.service                               disabled

&uarr; disabledなので、再起動してもウェブサーバー(nginx)デーモンのは起動しません。
          
次に、ウェブサーバー(nginx)デーモンがブート時に自動起動するように設定しておきます。
    
    $ systemctl enable nginx.service
      ln -s '/usr/lib/systemd/system/nginx.service' '/etc/systemd/system/multi-user.target.wants/nginx.service'
           
再度、ウェブサーバー(nginx)デーモンの登録状態を確認します。
    
    $ systemctl list-unit-files |grep nginx
           nginx.service                               enabled

&uarr; enabledなので、再起動してもウェブサーバー(nginx)デーモンは起動されます。
            
             
ウェブサーバー(nginx) の動作確認用のファイルを作成します。
    
    $ cd /usr/share/nginx/html
             [html]$ sh -c "echo '<?php echo phpinfo(); ?>'  > index.php"
             [html]$]

これだけではできないので

    $ vim /etc/nginx/conf.d/default.conf
を開き

    root /var/www/html

と書かれてるのを
    
    root /usr/share/nginx/html

に変更

    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;

に変更
###Word Pressをインストール

    wget https://wordpress.org/latest.zip 
    
    cd /usr/share/nginx/html

    unzip -q インストールしたwordpress 
    
    chmod 777 wordpress    

実際にwebで'http://ipアドレス/wordpress/wp-admin/install.php'をする

####これにて2-2終了です。

## 2-3 
apache http serverとphp5.5.25からwgetでインストール

フォルダを解凍してそのapacheのフォルダに移動し

    ./configure --enable-so

を実行して。その後に

    make 
    make install 

phpも同様にファルダに移動して
   
    ./configure --enable-so

を実行。その後
   
    make
    make install

phpが取れたか
   
    php -v

でversionを確認する

##php.iniファイルを設定する
cp php.ini-development /usr/local/lib/php.ini

##httpd.confを編集
    LoadModule php5_module modules/libphp5.so
のコメントアウトを外し
    
    <FilesMatch \.php$>
        SetHandler application/x-httpd-php
    </FilesMatch>    

を追加する。

##apacheの起動
   
    /usr/local/apache2/bin/apachectl start

エラーがでたらhttpd.confのservernameを自分で変える。

## mariadbのインストール
2-2と同じなので以下省略
## wordpressのインストール
wordpressを公式サイトからインストール解凍してから、
   /usr/local/apache2/htdocs
に移動する

##権限を変える

    chmod 755 wordpress

##httpd.confにindex.phpを追加する

socketがおかしいとwordpressにログインできないので

    vi /usr/local/lib/php.ini
を編集する。

    mysql.default.socket = /var/lib/mysql/mysql.sock

とかく。

最後にwebでwordpressにアクセスして終了です。

## 2-4 ベンチマークを取る
abコマンドをインストール
    
    sudo apt-get install apache2-utils

実際にabコマンドを実行
    
    ab -n 10 -c 10 http://192.168.56.123/wordpress

google chrome の拡張機能でpagespeedを追加して
ベンチマークを取る

##wordpressを高速化
wordpress高速化のためにプラグインを追加する

ubuntu側に

     wget https://downloads.wordpress.org/plugin/wp-super-cache.1.4.4.zip

installします。

プラグインを入れるには拡張機能が必要なようなので

    ./configure --with-apxs2=/usr/local/apache2/bin/apxs \
                --enable-mbstring \            
                --enable-mbregex \ 
                --with-mysql \ 
                --with-mysqli \
                --with-pdo-mysql \
                --with-pear \ 
                --with-zlib \
                --prefix=/usr/local/php5.5 \
                --enable-module=so \
                --with-openssl 

を実行する。opensslがはいっていなかったので

    yum install openssl-devel

これでできるようになるので

    make
    make install

を実行します。makeが終わるとphp.iniの設定

    cp -i php.ini-production /opt/php/php-5.5.5/libs/php.ini
    vi /opt/php/php-5.5.5/libs/php.ini

でphp.iniを編集

まずはwordpressのプラグインをftpではなくdirectでインストールする設定
    
    define('FS_METHOD', 'direct');

今度はwordpressのプロキシの設定    
    
    define('WP_PROXY_HOST', '172.16.40.1');
    define('WP_PROXY_PORT', '8888');

上の設定をphp.iniの最後尾に書く

apacheのリスタート
    
    /usr/local/apache2/bin/apachectl restart

これでプラグインが入手できます。

##高速化できたかabコマンドで確認

最初の早さが2410だった。

プラグインをあげた後の早さが4028で

##高速化成功です！！！！
