require 'net/http'
require 'json'

BATTERY_HOSTNAME = '192.168.1.125'
CHART_HISTORY_COUNT = 150
CHART_SKIP_NUMBER = 10
uri = URI('http://' + BATTERY_HOSTNAME + ':8080/api/v1/status')

class ChartRepo

  def initialize()
    @history = []
    @counter = 0
  end

  def add(value)
    
    @history.pop if @counter != 0
    @history << { 'x' => DateTime.now.to_time.to_i, 'y' => value }
    @history = @history.last(CHART_HISTORY_COUNT)

    @counter += 1
    @counter %= CHART_SKIP_NUMBER
  end

  attr_accessor :history, :counter
end

battery_power_repo = ChartRepo.new()
consumption_repo = ChartRepo.new()
production_repo = ChartRepo.new()
grid_repo = ChartRepo.new()

SCHEDULER.every '2s' do
  begin 
    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    battery_power_repo.add(json['Pac_total_W'])
    consumption_repo.add(json['Consumption_W'])
    production_repo.add(json['Production_W'])
    grid_repo.add(json['GridFeedIn_W'])

    send_event('charge', { value: json['USOC'] })
    send_event('battery-power-chart', points: battery_power_repo.history, displayed_value: battery_power_repo.history.first['y'])
    send_event('consumption-chart', points: consumption_repo.history, displayed_value: consumption_repo.history.first['y'])
    send_event('grid-chart', points: grid_repo.history, displayed_value: grid_repo.history.first['y'])
    send_event('production-chart', points: production_repo.history, displayed_value: production_repo.history.first['y'])
  rescue StandardError => err
    puts err
  end
end