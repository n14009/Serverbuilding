# Section 6 AWS(Amazon Web Services)

このセクションではAWS(Amazon Web Services)を使用したサーバー構築を行ないます。

## 講義関連リンク

* [AWS公式サイト](http://aws.amazon.com/jp/)
* [Cloud Design Pattern](http://aws.clouddesignpattern.org/index.php/%E3%83%A1%E3%82%A4%E3%83%B3%E3%83%9A%E3%83%BC%E3%82%B8)

## 6-0 AWSコマンドラインインターフェイスのインストール

1. 以下のコマンドを実行
    sudo apt-get install awscli

awsコマンドが使えることを確認する

ブラウザで[https://it-college.signin.aws.amazon.com/console](https://it-college.signin.aws.amazon.com/console)に接続する。

よなしろ先生がアカウントを作っているのでpasswordを変更する。(defaultはhogehoge)

##インスタンスの作成
1. 先ほど開いたサイトでEC2→インスタンス→インスタンスの作成をクリックする。

2. Amazonマシンイメージ(AMI)をAmazon Linux AMI 2015.03 (HVM), SSD Volume Type - ami-cbf90ecbと選択

3. 作成をクリック

4.キーペアを作成ここではn14009

##AWSの設定

端末で以下のコマンドを実行
    aws configure

よなしろ先生からいただいたアクセスキーを入力する。

regionはap-northeast-1にしてformatはjsonにする。

サイトで自分のインスタンスを選び接続を押すとkeyにpermisionを設定してと言われるのでコマンドラインで
    
    chmod 400 n14009.pem
と実行

以下のコマンドを実行

    aws ec2 describe-in

ssh接続の確認

    ssh -i n14009.pem ec2-user@52.26.107.138

[公式サイト](http://aws.amazon.com/jp/cli/)参照。

## 6-1	AWS EC2 + Ansible

Amazon Elastic Computing Cloud(EC2)を使用してWordpressが動作するサーバーを作ります。

3-1を終了している場合、Ansibleで構築できるようになっているのでAnsibleを使って構築する。
終わってない場合は手動でがんばってね。

### AMI(Amazon Machine Image)を作る
1. EC2→インスタンス→自分のインスタンスを右クリック→イメージ作成

2. IMGが無事作成されていれば完了です。

3. インスタンスの作成→マイAMI→自分のAMIを選択→そのまま作成

4. 作成したインスタンスにssh接続し、mysqlを動かす。

    sudo service mysqld start

1. ブラウザでパブリックIPに接続

2. wordpressに接続できれば完了

3. インスタンスの作成→マイAMI→自分のAMIを選択→そのまま作成

4. 作成したインスタンスにssh接続し、mysqlを動かす

    sudo service mysqld start

1. ブラウザでパブリックIPに接続(さっきとは違うIP)

2. wordpressに接続できれば完了
## 6-2 AWS EC2(AMIMOTO)

3. amimotoの公式サイトにアクセスし使い方にしたがって進める

4.リージョンをasia のtokyoに設定する

5. continueをクリックする

6. EC2 Instance Type を t2.microに設定する

7.セキュリティグループとキーペアを設定する

8. Accept Terms & Launch with 1-click をクリック

9.インスタンスができているのでsshで接続できるか確認する。

10.パブリックIDでブラウザからアクセス、wordpressが立ち上がればおけです。
## 6-3 Route53

Route53はAWSが提供するDNSサービス。

5-1で作ったDNSの情報をRoute53に突っ込んでみよう。

## 6-4 S3
1. 適当にhtmlファイルを作る

2. amazon consoleからs3を選択、バケットを作成する。

3. コマンドラインからファイルをアップロード以下のコマンドを実行

    aws s3 cp ファイル名 s3://バケット名

4. バケットの中にファイルがアップロードされていればおけです。


## 6-5 CloudFront

1. AMIからインスタンスを作成

2. AWSコンソール画面からcloud front を選択

3. Create Distribution を選択する

4. Origin ID に EC2のパブリックDNSを入力、そして Create Distribution Origin をクリックする。

5. 作ったDistributionがIn Progress からDeployedになったらDomain Nameをwebで入力してベンチマークを取る。同様にEC2からもwebアクセスしてベンチマークを取る。cloud front からアクセスした場合は243で普通にアクセスした場合は212で

6. 5の結果からcloud front を使った方が早いことがわかったので6-5終了です。

## 6-6 RDS

RDSは…MySQLっぽい奴です。

RDSを立ち上げて、6-1で作ったAMIのWordpressのDBをRDSに向けてみよう。

## 6-7 ELB

ELBはロードバランサーです。すごいよ。

6-1で作ったAMIを3台ぶんくらい立ち上げてELBに登録し、負荷が割り振られているか確認してみよう。

## 6-8 API叩いてみよう

AWSは自分で作ったプログラムからもいろいろ制御できます!
なんでもいいのでがんばってプログラム書いてみてね(おすすめはSES)。
