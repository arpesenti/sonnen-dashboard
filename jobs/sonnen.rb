require 'net/http'
require 'json'

BATTERY_HOSTNAME = 'SB-62312.local'
uri = URI('http://' + BATTERY_HOSTNAME + ':8080/api/v1/status')

SCHEDULER.every '2s' do
  begin 
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)
    send_event('charge', { value: json['USOC'] })
    send_event('battery-power', { current: json['Pac_total_W'] })
    send_event('consumption', { current: json['Consumption_W'] })
    send_event('grid', { current: json['GridFeedIn'] }) 
    send_event('production', { current: json['Production_W'] })
  rescue StandardError
    false
  end
end