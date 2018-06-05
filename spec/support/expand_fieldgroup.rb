module FieldGroupHelper
  def disable_collapse
    page_js =  <<-SCRIPT.strip.gsub(/\s+/,' ')
      $('#accordion .collapse').collapse('show');
    SCRIPT
    page.execute_script(page_js)
    sleep(1)
  end
end

# Include helper methods for all specs that are tagged with
# `include: :expand_fieldgroup`
RSpec.configure do |config|
  config.include FieldGroupHelper, expand_fieldgroup: true
end
