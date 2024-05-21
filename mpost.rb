require 'selenium-webdriver'
Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '..\edgedriver.125.0.2535.51\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.123.0.2420.65\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.121.0.2277.83\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.119.0.2151.44\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.118.0.2088.46\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.116.0.1938.62\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.114.0.1823.18\edgedriver_win64', 'msedgedriver.exe'
 #= File.join '..\edgedriver.112.0.1722.39\edgedriver_win64', 'msedgedriver.exe'

class Object
  def   display_n(out = $stdout) =  out.puts self
  def   display_s(out = $stdout) = (self.display out;  ' '.display   out)
  def s_display_n(out = $stdout) = ( ' '.display out; self.display_n out)
  def n_display_n(out = $stdout) = ("\n".display out; self.display_n out)
end # class Object

class Browser 
  URLs = {
    google:    'https://www.google.com/',
    twitter:   'https://twitter.com/home',
    facebook:  'https://www.facebook.com/',
    instagram: 'https://www.instagram.com/',
    mixi:      'https://mixi.jp/home.pl',
    fedibird:  'https://fedibird.com/web/timelines/home',
    threads:   'https://www.threads.net/',
  }

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
    if message then
      wait = Selenium::WebDriver::Wait.new :timeout => 20
      e = wait.until do
        @driver.find_element class: 'public-DraftEditor-content'
      end # e = wait.until do
      e.send_keys message

      if images.size > 0 then
        e = @driver.find_element tag_name: "input"
        images.each do |img|
          e.send_keys File.join(@downloads, img)
        end # images.each do |img|
      end # if images.size > 0

      e = @driver.find_element xpath: '//div[@data-testid="tweetButtonInline"]'
      e.click
      sleep @sleeping
    end # if message
  end # def twitter(message, images)

  def facebook(message, images)
    auth_cookie __method__
    ## クッキー設定後の描画後少しすると全体がグレイアウトするので画面をクリック
    ## グレイアウト解けてても.click可なのでそれを繰り返してもいい感じで 
    ## グレイアウトまで時間掛かったりしてタイミング難しくて、
    ### ちょっと待ったり、次の場面でエラートラップしたり
    sleep @sleeping
    e = @driver.find_element tag_name: 'body'
    e.click
 
    if message then
      ## 入力欄をクリックすると投稿ダイアローグが開く
      e = @driver.find_element \
        xpath: '//span[text()="Hi Shimuraさん、その気持ち、シェアしよう"]'
      # グレイアウトが解けてなくてエラーになったら画面.clickから繰り返す
      begin# rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        e .click
      rescue Selenium::WebDriver::Error::ElementClickInterceptedError
        @driver.find_element(tag_name: 'body').click
        e .click
      end  # rescue Selenium::WebDriver::Error::ElementClickInterceptedError

      ## 投稿ダイアローグにて # 準備できるまでちょっと時間掛かる
      wait = Selenium::WebDriver::Wait.new :timeout => 20
      e =  wait.until do
        @driver.find_element \
        xpath: '//div[@aria-label="Hi Shimuraさん、その気持ち、シェアしよう"]'
      end # e =  wait.until do
      e.send_keys message

      if images.size > 0 then
        e = @driver.find_element xpath: '//div[@aria-label="写真・動画"]'
        e.click
        e = wait.until do
          @driver.find_element xpath: '//input[@type="file"]'
        end # e = wait.until do
        #e.attribute('outerHTML').+("\n").display

        # 初回の input要素は動画っぽくて駄目なの一回書き飛ばす
        e.send_keys File.join(@downloads, images.first)
        sleep @sleeping

        images.each do |img|
          e = wait.until do
            @driver.find_element xpath: '//input[@type="file"]'
          end # e = wait.until do
          #e.attribute('outerHTML').+("\n").display
          e.send_keys File.join(@downloads, img)
          sleep @sleeping
        end # images.each do |img|
      end # if images.size > 0

      e = @driver.find_element xpath: '//div[@aria-label="投稿"]'
      e.click
      sleep @sleeping
    end # if message
    @driver.get URLs[:google]
  end # def facebook(message, images)

  def instagram(message, images)
    auth_cookie __method__
    # ログイン再開時、お知らせをオンにするかのダイアローグ開くので、後で
    begin# rescue Selenium::WebDriver::Error::NoSuchElementError
      e = @driver.find_element xpath: '//button[text()="後で"]'
      e.click
    rescue Selenium::WebDriver::Error::NoSuchElementError
    # ログインすぐだと出ないこともある
    end # rescue Selenium::WebDriver::Error::NoSuchElementError

    # インスタグラムは画像があるの前提
    if message and images.size > 0 then
      # 以下、なんか、xpath: //svg が効かなくて、tag_name: svg から選んでる
      es = @driver.find_elements tag_name: 'svg'
      # 投稿ダイアローグを出す
      e = es.select{ _1.attribute('aria-label')=='新規投稿' }.first
      e.click

      ## 投稿ダイアローグにて # 準備できるまでちょっと時間掛かる
      wait = Selenium::WebDriver::Wait.new :timeout => 20

      e = wait.until do
        @driver.find_element xpath: '//input[@multiple]'
      end # e = wait.until do
      # multiplle へはファイル名を改行区切りで連結する
      images_multi = images.map{File.join @downloads, _1}.join("\n")
      e.send_keys images_multi
      sleep @sleeping

      e = @driver.find_element xpath: '//div[text()="次へ"]' 
      e.click
      #sleep @sleeping
      e = @driver.find_element xpath: '//div[text()="次へ"]'
      e.click
      e = wait.until do
        @driver.find_element xpath: '//div[@aria-label="キャプションを入力…"]'
      end # e = wait.until do
      e.send_keys message

      e = @driver.find_element xpath: '//div[text()="シェア"]'
      e.click
      e = wait.until do
        @driver.find_element xpath: '//div[text()="投稿をシェアしました"]'
      end # e = wait.until do
      sleep @sleeping
    end # if message and images.size > 0
  end # def instagram(message, images)

  def mixi(message, images)
    auth_cookie __method__
    if message then
      e = @driver.find_element id: 'voiceComment'
      e.send_keys message

      if images.size > 0 then
        e = @driver.find_element xpath: '//a[@title="写真を追加"]'
        e.click
        #ファイル選択が出てくる
        e = @driver.find_element xpath: '//input[@name="photo"]'
        #前項.click しないと見付からない
        e.send_keys File.join(@downloads, images.first)
        # mixiつぶやきは写真ひとつだけ、先頭を投稿します
      end # if images.size > 0
      
      e = @driver.find_element id: 'voicePostSubmit'
      e.click
      sleep @sleeping
    end # if message
  end # def mixi(message, images)
 
  def fedibird(message, images)
    auth_cookie __method__
    if message then
      e= @driver.find_element xpath: '//textarea[@placeholder="今なにしてる？"]'
      e.send_keys message

      images.each do |img|
        e = @driver.find_element xpath: '//input[@type="file"]'
        e.send_keys File.join(@downloads, img)
        # 複数画像、(xpath: '//input[@type="file"]')  から繰り返す
        
        uing = true # 画像アップロード中は待ちます
        while uing do
          sleep @sleeping
          begin# rescue Selenium::WebDriver::Error::NoSuchElementError
            @driver.find_element class: 'upload-progress__message'
          rescue Selenium::WebDriver::Error::NoSuchElementError
            uing = false
          end  # rescue Selenium::WebDriver::Error::NoSuchElementError
        end # while uing do
      end # images.each do |img|

      e = @driver.find_element xpath: '//button[text()="トゥート！"]'
      e.click
      sleep @sleeping
    end # if message
  end # def fedibird(message, images)

  def blueskay(message, images)
  end # def blueskay(message, images)

  def threads(message, images)
    @driver.get URLs[:threads]
    @authents[:threads].each{ @driver.manage.add_cookie _1 }
  end # def threads(message, images)
  
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
  message.inspect.display
  images   = ARGV
  images.inspect.s_display_n
  raise 'Instagram needs image(s)' if mpost[:instagram] and images.size==0
  authents = JSON File.read(cookies), symbolize_names: true

  # mpost はSNS名=>諾否(true/false)のハッシュ、その諾の物だけ数える/選ぶ
  if mpost.count{_2} > 0 then
    Browser.new authents, downloads, sleeping: 5, browser: :edge do |browser|
      mpost.select{_2}.each do |sns,|
        sns.display_s
        browser.send sns, message, images
      end # mpost.each do |sns,|
    end # Browser.new authents, downloads, sleeping: 5, browser: :edge do
  end # if mpost.count{_2} > 0 
end # if $PROGRAM_NAME == __FILE__
