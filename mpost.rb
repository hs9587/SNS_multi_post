require 'selenium-webdriver'

Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '..\edgedriver.112.0.1722.39\edgedriver_win64', 'msedgedriver.exe'

urls = {
  twitter:  'https://twitter.com/home',
  facebook: 'https://www.facebook.com/',
  mixi:     'https://mixi.jp/home.pl'
}
cookies = JSON File.read('../cookies.json'), symbolize_names: true
handles = {}
message = 'おはようございます'
message = 'テスト投稿'
post    = true
post    = false 

driver = Selenium::WebDriver.for :edge
driver.get "https://www.google.com/"

# twitter
driver.get urls[:twitter]
cookies[:twitter].each{ driver.manage.add_cookie _1 }
driver.get urls[:twitter]
handles[:twitter] = driver.window_handle

if post then
  driver.find_element(class: 'public-DraftEditor-content').send_keys message
  driver.find_element(xpath: '//div[@data-testid="tweetButtonInline"]').click
end # if post

sleep 10

# facebook
#driver.manage.new_window :tab
driver.get urls[:facebook]
cookies[:facebook].each{ driver.manage.add_cookie _1 }
driver.get urls[:facebook]
handles[:facebook] = driver.window_handle

if post then
  ## クッキー設定後の描画ではすぐに全体がグレイアウトするので画面をクリック
  driver.find_element(tag_name: 'body').click
  ## 入力欄をクリックすると投稿ダイアローグが開く
  driver.find_element(
    xpath: '//span[text()="Hi Shimuraさん、その気持ち、シェアしよう"]'
  ).click
  ## 投稿ダイアローグにて
  driver.find_element(
    xpath: '//div[@aria-label="Hi Shimuraさん、その気持ち、シェアしよう"]'
  ).send_keys message
  driver.find_element(
    xpath: '//div[@aria-label="投稿"]'
  ).click
end # if post

sleep 10

# mixi
#driver.manage.new_window :tab
driver.get urls[:mixi]
cookies[:mixi].each{ driver.manage.add_cookie _1 }
driver.get urls[:mixi]
handles[:mixi] = driver.window_handle

if post then
  driver.find_element(id: 'voiceComment'   ).send_keys message
  driver.find_element(id: 'voicePostSubmit').click
end # if post

sleep 10

#
#driver.manage.new_window :tab
if post then
end # if post

sleep 10

driver.quit

