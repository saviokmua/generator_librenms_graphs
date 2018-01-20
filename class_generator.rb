# Generator Device's ports graps by LibraNMS
class Generator
  def initialize
    require 'rest-client'
    require 'open-uri'
    require 'json'
    require 'addressable/uri'
    require 'byebug'
    require_relative  'config'
    @url = "http://#{ENV['api_host']}/api/v0/"
    @headers = {'X-Auth-Token': ENV['api_key']}
    @path = "/opt/librenms/rrd/graphs/"
  end

  def get(url,to_json = true)
    answer = JSON.load(RestClient.get("#{@url}#{url}", @headers )) if to_json
    answer = RestClient.get("#{@url}#{url}", @headers ) unless to_json
    answer
  end

  def get_devices
    get('devices')['devices']
  end

  def get_device(host)
    devices = []
    get('devices')['devices'].map{|device| devices << device if device['hostname'] == host }
    devices
  end

  def post(url, data, to_json = true)
    RestClient.post("#{@url}#{url}", data, @headers)
  end

  def get_device_ports device
    ports = []
    get("devices/#{device['hostname']}/ports")['ports'].map{ |v| ports <<  v['ifName']}
    ports
  end

  def get_port_graph device, port, port_id, period = 'day'
    params = ''
    case period
    when 'week'
    	params = {from: Time.now.to_i - (7*24*60*60) }
    when 'month'
    	params = {from: Time.now.to_i - (4*7*24*60*60) }
    when 'year'
    	params = {from: Time.now.to_i - (12*4*7*24*60*60) }
    end

    unless params.empty?
      uri = Addressable::URI.new
      uri.query_values = params
      params = '?'+uri.query
    end    
    api_url = "devices/#{device['hostname']}/ports/#{URI::encode(port).gsub('/','%2F')}/port_bits#{params}"
    graph = get(api_url,false)
    filename = "#{@path}#{device['hostname']}_#{port_id}_#{period}.png"
    File.open(filename, 'w') { |file| file.write(graph) }
  end
end

