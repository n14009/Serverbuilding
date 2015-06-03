# Section 3 Ansibleによる自動化とテスト

## 3-0 Ansibleのインストール

[公式サイト](http://docs.ansible.com/intro_installation.html#latest-releases-via-apt-ubuntu)
に書いてあるコマンドを実行し、ansibleをインストールする

   sudo apt-get install software -properties-common
   sudo apt-add repository ppa:ansible/ansible
   sudo apt-get update
   sudo apt-get install ansible

## 3-1 ansibleでwordpressを動かす

## 疎通確認
sshpassをインストールする

    sudo apt-get install sshpass　

echoでhostsファイルを作成

    echo 192.168.33.14 > hosts

実際にコマンドを実行

    ansible 192.168.33.14 -i hosts -m ping --private-key ~/.vagrant.d/insecure_private_key -u vagrant -k

passwordを聞かれるのでvagrantと入力

## proxyの設定

proxyを設定するためにvagrantのpluginをインストール

    vagrant plugin install vagrant-proxyconf
    vagrant plugin install vagrant -vbguest

その後Vagrantfileに下の行を追加
    
    if Vagrant.has_plugin?("vagrant-proxyconf")                             
      config.proxy.http = "http://172.16.40.1:8888/"
      config.proxy.https = "http://172.16.40.1:8888/"
      config.proxy.no_proxy = "localhost,127.0.0.1,.it-college.local"
    end

これでproxyは通ります。

## playbookを書く

[playbook]{./playbook}

playbookを書いたらブラウザで自分のipアドレスに接続したら3-1終了です

##Section3-1-2

Vagrantfileに下記を追加！

    config.vm.provision "ansible" do |ansible|
      ansible.playbook = "playbook.yml"
    end

下記のコマンドを実行する

    vagrant provision

うごいたら終了です。
