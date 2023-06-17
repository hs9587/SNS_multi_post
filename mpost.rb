require 'selenium-webdriver'

Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '..\edgedriver.114.0.1823.18\edgedriver_win64', 'msedgedriver.exe'
  #= File.join '..\edgedriver.112.0.1722.39\edgedriver_win64', 'msedgedriver.exe'

class Browser 
  URLs = {
  twitter:   'https://twitter.com/home',
  facebook:  'https://www.facebook.com/',
  instagram: 'https://www.instagram.com/',
  mixi:      'https://mixi.jp/home.pl',
  fedibird:  'https://fedibird.com/web/timelines/home',
}
end # class Browser 
cookies = JSON File.read('../cookies.json'), symbolize_names: true
handles = {}
sleeping = 5
message = 'おはようございます'
message = 'テスト投稿'
images, downloads = [], 'C:\Users\hs9587\Downloads'  
post    = true
post    = false 

def none
if ARGV.size > 0 then
  message = ARGV.shift
  images  = ARGV
  post    = true
end # if ARGV.size > 0

driver = Selenium::WebDriver.for :edge
driver.get "https://www.google.com/"

# twitter
driver.get urls[:twitter]
cookies[:twitter].each{ driver.manage.add_cookie _1 }
driver.get urls[:twitter]
handles[:twitter] = driver.window_handle

if post and false then
  driver.find_element(class: 'public-DraftEditor-content').send_keys message
  input = driver.find_element(tag_name: "input") if images.size > 0
  images.each do |img|
    input.send_keys File.join(downloads, img)
  end # images.each do |img|
  driver.find_element(xpath: '//div[@data-testid="tweetButtonInline"]').click
end # if post

sleep sleeping

# facebook
#driver.manage.new_window :tab
driver.get urls[:facebook]
cookies[:facebook].each{ driver.manage.add_cookie _1 }
driver.get urls[:facebook]
handles[:facebook] = driver.window_handle

if post then
  ## クッキー設定後の描画後少しすると全体がグレイアウトするので画面をクリック
  ### スクリプト実行では違うのでコメントアウト。クリックするとむしろ駄目
  driver.find_element(tag_name: 'body').click
  ## 入力欄をクリックすると投稿ダイアローグが開く
  driver.find_element(
    xpath: '//span[text()="Hi Shimuraさん、その気持ち、シェアしよう"]'
  ).click
  ## 投稿ダイアローグにて # 準備できるまでちょっと時間掛かる 
  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  post_form = wait.until do
    driver.find_element(
      xpath: '//div[@aria-label="Hi Shimuraさん、その気持ち、シェアしよう"]'
    )
  end # post_form = Selenium::WebDriver::Wait.new(:timeout => 10).until do
  post_form.send_keys message
  if images.size > 0 then
    shashin = driver.find_element(xpath: '//div[@aria-label="写真・動画"]') 
    shashin.click
    #shashin = driver.find_element(xpath: '//div[@aria-label="写真・動画"]') 
    #sleep sleeping
    input = wait.until do
      driver.find_element(xpath: '//input[@type="file"]')
    end # input = wait.until do
    #input.attribute('outerHTML').+("\n").display
    # 初回の input要素は動画っぽくて駄目なの一回書き飛ばす
    input.send_keys File.join(downloads, images.first)
    sleep sleeping
    images.each do |img|
      input = wait.until do
        driver.find_element(xpath: '//input[@type="file"]')
      end # input = wait.until do
      #input.attribute('outerHTML').+("\n").display
      input.send_keys File.join(downloads, img)
      sleep sleeping
    end # images.each do |img|
  end # if images.size > 0
  driver.find_element(
    xpath: '//div[@aria-label="投稿"]'
  ).click
end # if post

sleep sleeping

# instagram
#driver.manage.new_window :tab
driver.get urls[:instagram]
cookies[:instagram].each{ driver.manage.add_cookie _1 }
driver.get urls[:instagram]
handles[:instagram] = driver.window_handle

# ログイン再開時、お知らせをオンにするかのダイアローグ開くので、後で
driver.find_element(xpath: '//button[text()="後で"]').click
sleep sleeping

if post and images.size > 0 then # インスタは画像がないとね
  # 以下、なんか、xpath: //svg が効かなくて、tag_name: svg から選んでる
  svgs = driver.find_elements(tag_name: 'svg')
  # 投稿ダイアローグを出す
  svgs.select{_1.attribute('aria-label')=='新規投稿'}.first.click

  wait = Selenium::WebDriver::Wait.new(:timeout => 10)
  input_multi = wait.until do
    driver.find_element(xpath: '//input[@multiple]')
  end # input_multi = wait.until do
  images_multi = images.map{File.join downloads, _1}.join("\n")
  input_multi.send_keys images_multi
  # multiplle へはファイル名を改行区切りで転結する
  sleep sleeping
  driver.find_element(xpath: '//div[text()="次へ"]').click
  sleep sleeping
  driver.find_element(xpath: '//div[text()="次へ"]').click

  caption = wait.until do
    driver.find_element(xpath: '//div[@aria-label="キャプションを入力…"]')
  end # caption = wait.until do
  caption.send_keys message

  driver.find_element(xpath: '//div[text()="シェア"]').click
end # if post and images.size > 0

sleep sleeping

# mixi
#driver.manage.new_window :tab
driver.get urls[:mixi]
cookies[:mixi].each{ driver.manage.add_cookie _1 }
driver.get urls[:mixi]
handles[:mixi] = driver.window_handle

if post then
  driver.find_element(id: 'voiceComment'   ).send_keys message
  if images.size > 0 then
    driver.find_element(xpath: '//a[@title="写真を追加"]').click 
    #ファイル選択が出てくる
    input = driver.find_element(xpath: '//input[@name="photo"]')
    #前行.click しないて見付からない
    input.send_keys File.join(downloads, images.first)
    # ひとつだけ
  end # if images.size > 0
  driver.find_element(id: 'voicePostSubmit').click
end # if post

sleep sleeping

# mastodon: fedibird
#driver.manage.new_window :tab
driver.get urls[:fedibird]
cookies[:fedibird].each{ driver.manage.add_cookie _1 }
driver.get urls[:fedibird]
handles[:fedibird] = driver.window_handle

if post then
  driver.find_element(
    xpath: '//textarea[@placeholder="今なにしてる？"]'
  ).send_keys message
  images.each do |img|
    input = driver.find_element xpath: '//input[@type="file"]'
    input.send_keys File.join(downloads, img)
    # 複数画像のときは、(xpath: '//input[@type="file"]') から繰り返す
    uing = true
    while uing do  
      sleep sleeping
      begin# rescue Selenium::WebDriver::Error::NoSuchElementError
        driver.find_element(class: 'upload-progress__message')
      rescue Selenium::WebDriver::Error::NoSuchElementError
        uing = false
      end  # rescue Selenium::WebDriver::Error::NoSuchElementError
    end # while uing do  
  end # images.each do |img|
  driver.find_element(
    xpath: '//button[text()="トゥート！"]'
  ).click
end # if post

sleep sleeping

=begin
#
#driver.manage.new_window :tab
if post then
end # if post

# sleep sleeping
=end

driver.quit
end # def none

class Browser
  def initialize(authents, downloads, sleeping: 5,  browser: :edge)
    @authents  = authents
    @downloads = downloads
    @sleeping  = sleeping
    @browser   = browser
    @driver    = Selenium::WebDriver.for @browser
    if block_given? then
      begin
        yield self
      ensure
        quit
        self
      end
    else# if block_given?
      self
    end # if block_given?
  end # def initialize(authents, sleeping: 5,  browser: :edge)
  def quit = @driver.quit

  def twitter(message, images)
    auth_cookie __method__
  end # def twitter(message, images)
  def facebook(message, images)
    auth_cookie __method__
  end # def facebook(message, images)
  def instagram(message, images)
    auth_cookie __method__
  end # def instagram(message, images)
  def mixi(message, images)
    auth_cookie __method__
  end # def mixi(message, images)
  def fedibird(message, images)
    auth_cookie __method__
  end # def fedibird(message, images)
  
  private
    def auth_cookie(sns)
      sym = sns.to_sym
      @driver.get URLs[sym]
      @authents[sym].each{ @driver.manage.add_cookie _1 }
      @driver.get URLs[sym]
    end # def auth_cookie(sns)
  # private
end # class Browser

if $PROGRAM_NAME == __FILE__ then
  require 'optparse'
  mpost = {
    twitter:   false, 
    facebook:  false, 
    instagram: false, 
    mixi:      false, 
    fedibird:  false,
  } # mpost = 
  downloads = 'C:\Users\hs9587\Downloads'  
  cookies   = '../cookies.json'
  message, images = 'おはようございます', []
  ARGV.options do |opts|
    opts.banner += ' <message> <image> (<image> ..)' 
    opts.separator <<-EOhelp
  いくつかのSNSにメッセージと画像を投稿する。
  <message> に空白を挿むときは全体を引用符で囲う
  <image>ファイル名はダウンロードディレクトリとかの下の、名前だけのつもり
  <message> <image> 引数なにも無いときは「おはようございます」
    EOhelp

    opts.on('-t','--twitter'  ,'Twitter')  { mpost[:twitter]  = true }
    opts.on('-f','--facebook' ,'Facebook') { mpost[:facebook] = true }
    opts.on('-i','--instagram','Instagram needs image(s)') \
                                           { mpost[:instagram]= true }
    opts.on('-m','--mixi'     ,'mixi at most one imege') \
                                           { mpost[:mixi]     = true }
    opts.on('-b','--fedibird' ,'Mastodon Fedi*B*ird') \
                                           { mpost[:fedibird] = true }
    opts.on('--tfmb','t f   m b with/without image(s)') \
      {[:twitter,:facebook,          :mixi,:fedibird].each{ mpost[_1] = true }}
    opts.on('--tmb' ,'t     m b with/without image(s)') \
      {[:twitter,                    :mixi,:fedibird].each{ mpost[_1] = true }}
    opts.on('--fimb','  f i m b neads image(s)') \
      {[        :facebook,:instagram,:mixi,:fedibird].each{ mpost[_1] = true }}
    opts.on('--no-message','no post, only cookie authentication') \
      { message   = nil }
    opts.on('--image_path=PATH','image path (DEFAULT: <User>Downloads)') \
      { downloads = _1  }
    opts.on('--cookies=FILE'   ,'authentication cookies JSON file path') \
      { cookies   = _1  }
    opts.separator ' '*40 + '(DEFAULT: ../cookies.json)'

    opts.parse!
  end # ARGV.options do |opts|
  message  = ARGV.shift if ARGV.size > 0
  images   = ARGV
  raise 'Instagram needs image(s)' if mpost[:instagram] and images.size==0
  authents = JSON File.read(cookies), symbolize_names: true
  puts message, images.inspect

  if mpost.count{_2} > 0 then
    Browser.new authents, downloads, sleeping: 5, browser: :edge do |browser|
      mpost.select{_2}.each do |sns,|
        sns.display
        browser.send sns, message, images
      end # mpost.each do |sns,|
    end # Browser.new authents, downloads, sleeping: 5, browser: :edge do
  end # if mpost.count{_2} > 0 
end # if $PROGRAM_NAME == __FILE__
