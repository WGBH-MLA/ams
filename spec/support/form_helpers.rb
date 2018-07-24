module FormHelper
  def get_random_string(length=5)
    source=("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ["_","-","."]
    key=""
    length.times{ key += source[rand(source.size)].to_s }
    return key
  end

  # For use with javascript collection selector that allows for searching for an existing collection from add to collection modal.
  # Does not save the selection.  The calling test is expected to click Save and validate the collection membership was added to the work.
  # @param [Collection] collection to select
  def select_collection(collection)
    sleep 1
    first('a.select2-choice').click
    find('.select2-input').set(collection.title.first)
    sleep 2
    expect(page).to have_css('.select2-result')
    within ".select2-result" do
      find("span", text: collection.title.first).click
    end
  end
end

RSpec.configure { |c| c.include FormHelper }
