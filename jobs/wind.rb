require 'net/http'
require 'json'

if !ENV['SMASHING_WIND_USERNAME'] || !ENV['SMASHING_WIND_PASSWORD'] || !ENV['SMASHING_WIND_LINE_ID'] || !ENV['SMASHING_WIND_CONTRACT_ID']
  puts '*WARNING*: Env vars for wind are not set, skipping wind job'
  return
end

SCHEDULER.every '1h', first_in: 0 do
  begin  
    login_uri = URI.parse('https://apigateway-selfcare.apps.windtre.it/api/v1/authentication/authenticate-app')
    login_req = Net::HTTP::Post.new(
      login_uri,
      'Content-Type' => 'application/json'
    )
    login_req.body = { "username": ENV['SMASHING_WIND_USERNAME'], "password": ENV['SMASHING_WIND_PASSWORD'] }.to_json
    login_res = Net::HTTP.start(login_uri.hostname, login_uri.port, :use_ssl => true) do |http|
      http.request(login_req)
    end
    cookies = login_res.to_hash['set-cookie'].collect{|ea|ea[/^.*?;/]}.join

    info_uri = URI.parse("https://apigateway-selfcare.apps.windtre.it/api/v1/contract/lineunfolded?lineId=#{ENV['SMASHING_WIND_LINE_ID']}&contractId=#{ENV['SMASHING_WIND_CONTRACT_ID']}")
    info_req = Net::HTTP::Get.new(
      info_uri,
    )
    info_req['Content-Type'] = 'application/json'
    info_req['Cookie'] = cookies
    info_res = Net::HTTP.start(info_uri.hostname, info_uri.port, use_ssl: true) do |http|
      http.request(info_req)
    end
    info_json = JSON.parse(info_res.body)
    insights = info_json['lines'][0]['options'][0]['insights'][0]
    send_event('wind-internet', { 
      value: (insights['available'] / 1024 / 1024 / 1024).round(2),
    })
  rescue => err
    puts err
  end
end