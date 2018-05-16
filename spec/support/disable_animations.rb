module DisableAnimationHelper
  def disable_js_animation
    page_js =  <<-SCRIPT.strip.gsub(/\s+/,' ')
      (function () {
        $.support.transition = false
      })()
    SCRIPT
    page.execute_script(page_js)
  end
end

# Include helper methods for all specs that are tagged with
# `include: :disable_animation`
RSpec.configure do |config|
  config.include DisableAnimationHelper, disable_animation: true
end
