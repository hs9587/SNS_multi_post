require 'selenium-webdriver'

Selenium::WebDriver::Edge::Service.driver_path \
  = File.join '..\edgedriver.112.0.1722.39\edgedriver_win64', 'msedgedriver.exe'

driver = Selenium::WebDriver.for :edge
driver.get("https://www.google.com/")

driver.quit

