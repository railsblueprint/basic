# CI hands the suite a specific Chrome and matching chromedriver through these two variables;
# unset - every ordinary local run - Selenium finds whatever is on the PATH, as before.
Selenium::WebDriver::Chrome::Service.driver_path = ENV["CHROMEDRIVER_BIN"] if ENV["CHROMEDRIVER_BIN"].present?

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["SHOW_BROWSER"] == "true"
      driven_by :selenium_chrome
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400] do |driver_option|
        driver_option.add_argument("--no-sandbox")
        driver_option.add_argument("--disable-dev-shm-usage")
        driver_option.add_argument("--disable-gpu")
        driver_option.binary = ENV["CHROME_BIN"] if ENV["CHROME_BIN"].present?
      end
    end
  end
end
