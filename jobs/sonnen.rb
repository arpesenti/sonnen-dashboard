SCHEDULER.every '2s' do
  send_event('charge', { value: rand(100) })
  send_event('battery-power', { current: rand(100) })
  send_event('consumption', { current: rand(100) })
  send_event('production', { current: rand(100) }) 
end