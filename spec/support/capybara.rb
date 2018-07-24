require "selenium/webdriver"

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :selenium do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless disable-gpu) }
  )

  Capybara::Selenium::Driver.new app,
    browser: :chrome,
    desired_capabilities: capabilities
end

if ['true', '1'].include? ENV.fetch('HEADLESS', '1').to_s.downcase
  Capybara.javascript_driver = :selenium
else
  Capybara.javascript_driver = :chrome
end
