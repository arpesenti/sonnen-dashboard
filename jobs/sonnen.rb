SCHEDULER.every '2s' do
  send_event('charge', { value: rand(100) })
  send_event('battery-power', { current_value: rand(100) })
  send_event('consumption', { current_value: rand(100) })
  send_event('production', { current_value: rand(100) }) 
end