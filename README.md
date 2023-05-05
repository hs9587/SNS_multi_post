# SNS_multi_post
Multi post to some SNS: twitter, mixi, mastodon, or more ...

複数の SNS に同時投稿します、ツイッター、ミクシィ、マストドン、他

## 背景
2023/4/ mixi の Twitter連携がきれ、
Instagram の同時シェアが Facebook だけになって Twitter・Tumblr・ミクシィ・等への同時シェアがなくなった。  
それまで Instagramからの同時シェアと mixi の Twitter連携の合わせ技で複数SNS への同時投稿をしていたのが出来なくなった。

ということで、複数の SNS に同時投稿するスクリプトを作ります。

## 条件・目標
1. 各SNS へはブラウザでログイン済みとします。なのでスクリプトに認証情報は入りません。
2. はじめはテキスト一行だけ、朝の「おはようございます」の投稿が目標です。
3. その後、写真一枚つけて投稿できるようにしましょう。
   1. 写真の指定どうしましょうか。
4. 複数写真の指定もできるようにしたいです。
   1. この辺で写真のために SNS 選んだり、準備投稿とかあるかもしれません。
5. サーバに仕込んで遠隔から投稿できるようになれば最高ですが、流石に難しいかな。

## Win32OLE
OLE でのブラウザオートメーションを試すのだけど、
Edge, Chrome, Firefox は OLE 非対応。
Windows11 の IE はふつうに起動すると Edge に誘導されるが、OLE からのオートメーションには使える。
でも、多くの(SNS)サイトは対応ブラウザではないと断られる。
Navigateメソッドで各サイトを訪う時、header引数で指定すると User-Agent: 指定できるけど、どうかな。

というか、Navigateメソッド呼んだ時点で、OLEオブジェクトとの接続が切れる。
ブラウザウィンドウ開いてる(事前に Visible属性は true にしてる)のに、WIN32OLE.connect 'InternetExplorer.Application' で接続できない。
.new 'InternetExplorer.Application' (そして Visible属性 true に)すると新しいブラウザ開いてしまう。

というわけで、OLE の IE で、ブラウザオートメーションするのも無理っぽい。

## Selenium::WebDriver
そうしたら、セレニウムでウェブドライバー使ってのオートメーションしましょう。
検索や ChatGPT の示唆にしたがって
1. 「gem install selenium-webdriver」
2. Microsoft Edge WebDriver
https://developer.microsoft.com/ja-jp/microsoft-edge/tools/webdriver/
より、「edgedriver_win64.zip」のダウンロード
  1. バージョンは Edgeで「edge://settings/help」で確認、それに合わせたものを選びます、ドライバーのリストの最新よりちょっと前みたい。
  2. 展開して「msedgedriver.exe」、どこに置きましょう。
3. それで最低限こんな感じでブラウザ開きます、取り敢えず Edge
```ruby
require 'selenium-webdriver'

Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '＜ドライバーの置き場所＞', 'msedgedriver.exe'

driver = Selenium::WebDriver.for :edge
driver.get "https://www.google.com/"
  sleep 10
driver.quit
```
## 認証とクッキー
それでツイッターを見に行くのだけど```driver.get 'https://twitter.com/home'```
ID・パスワード画面になってしまう。
別に Edge 開いててそちらでは認証できててもこちらの Edge では認証引き継げない。
まあ、開いたブラウザウィンドウの上辺に「Microsoft Edge は、自動テスト ソフトウェアによって制御されています。」とあるし、その辺分離されているのでしょう。
だからといってそのID・パスワード欄に入力して認証する気にもなれない。プログラムに ID・パスワード書くわけにもいかないし、プログラムの動作に際に毎回認証するのも煩わしい、認証の度にツイッターから確認の連絡いろいろくるし。

というわけでクッキーに認証情報を探します。
