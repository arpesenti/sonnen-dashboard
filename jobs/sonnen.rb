SCHEDULER.every '2s' do
  send_event('charge', { value: rand(100) })
  send_event('battery-power', { value: rand(100) })
  send_event('consumption', { value: rand(100) })
  send_event('production', { value: rand(100) }) 
end