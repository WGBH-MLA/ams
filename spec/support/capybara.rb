Capybara.register_driver :selenium do |app|
  opts = {
      extensions: ["#{Rails.root}/spec/support/disable_animations.js"]
  }
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end
