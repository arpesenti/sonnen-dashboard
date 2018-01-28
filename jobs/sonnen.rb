require 'net/http'
require 'json'

BATTERY_IP = '192.168.1.110'
uri = URI('http://' + BATTERY_IP + ':8080/api/v1/status')

SCHEDULER.every '2s' do
  begin 
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
    send_event('charge', { value: json['USOC'] })
    send_event('battery-power', { current: json['Pac_total_W'] })
    send_event('consumption', { current: json['Consumption_W'] })
    send_event('production', { current: json['GridFeedIn'] }) 
  rescue StandardError
    false
  end
end