require 'net/http'
raise "AAPB hostname not set" unless ENV['AAPB_HOST'] && ENV['AAPB_HOST'].length > 0
begin
  response = Net::HTTP.get( URI.parse('http://'+ENV['AAPB_HOST']) )
rescue SocketError => e
  raise "AAPB host unreachable"
end
