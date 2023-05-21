require 'selenium-webdriver'

Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '..\edgedriver.112.0.1722.39\edgedriver_win64', 'msedgedriver.exe'

urls = {
  twitter:  'https://twitter.com/home',
  facebook: 'https://www.facebook.com/',
  mixi:     'https://mixi.jp/home.pl',
  fedibird: 'https://fedibird.com/web/timelines/home',
}
cookies = JSON File.read('../cookies.json'), symbolize_names: true
handles = {}
sleeping = 5
message = 'おはようございます'
message = 'テスト投稿'
images, downloads = [], 'C:\Users\hs9587\Downloads'  
post    = true
post    = false 

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

if post then
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

if post and images.size == 0 then # 画像の時はフェイスブックはなし
  ## クッキー設定後の描画後少しすると全体がグレイアウトするので画面をクリック
  ### スクリプト実行では違うのでコメントアウト。クリックするとむしろ駄目
  #driver.find_element(tag_name: 'body').click
  ## 入力欄をクリックすると投稿ダイアローグが開く
  driver.find_element(
    xpath: '//span[text()="Hi Shimuraさん、その気持ち、シェアしよう"]'
  ).click
  ## 投稿ダイアローグにて # 準備できるまでちょっと時間掛かる 
  post_form = Selenium::WebDriver::Wait.new(:timeout => 10).until do
    driver.find_element(
      xpath: '//div[@aria-label="Hi Shimuraさん、その気持ち、シェアしよう"]'
    )
  end # post_form = Selenium::WebDriver::Wait.new(:timeout => 10).until do
  post_form.send_keys message
  driver.find_element(
    xpath: '//div[@aria-label="投稿"]'
  ).click
end # if post

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

#
#driver.manage.new_window :tab
if post then
end # if post

# sleep sleeping

driver.quit

