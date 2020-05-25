require 'net/http'

class Request
  def self.get(url, authorization)
    url = URI.parse(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(url.request_uri)
    req["Authorization"] = authorization
    JSON.parse(http.request(req).body)
  end

  def self.post(url, authorization, body)
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    
    request = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
    request.body = body.to_json
    request["Authorization"] = authorization
    request['Accept'] = 'application/json'
    
    response = http.request(request)
  end

end