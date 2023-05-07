require 'selenium-webdriver'

Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '..\edgedriver.112.0.1722.39\edgedriver_win64', 'msedgedriver.exe'

urls = {
  twitter:  'https://twitter.com/home',
  facebook: 'https://www.facebook.com/',
}
cookies = JSON File.read('../cookies.json'), symbolize_names: true
handles = {}
message = 'テスト投稿'

driver = Selenium::WebDriver.for :edge
driver.get "https://www.google.com/"

# twitter
driver.get urls[:twitter]
cookies[:twitter].each{ driver.manage.add_cookie _1 }
driver.get urls[:twitter]
handles[:twitter] = driver.window_handle

#driver.find_element(class: 'public-DraftEditor-content').send_keys message
#driver.find_element(xpath: '//div[@data-testid="tweetButtonInline"]').click

sleep 10

# facebook
#driver.manage.new_window :tab
driver.get urls[:facebook]



driver.quit

