module WaitHelpers
  def wait_for(seconds, &block)
    seconds = seconds.to_i.abs
    start = Time.now
    result = block.call if block_given?
    while !!!result
      return if (Time.now - start).to_i >= seconds
      result = block.call if block_given?
    end
    result
  end
end

RSpec.configure { |c| c.include WaitHelpers }
