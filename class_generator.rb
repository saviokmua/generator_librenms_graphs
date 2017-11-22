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
    devices = []
    get('devices')['devices'].map{|device| devices << device['hostname']}
    devices
  end

  def post(url, data, to_json = true)
    RestClient.post("#{@url}#{url}", data, @headers)
  end

  def get_device_ports hostname
    ports = []
    get("devices/#{hostname}/ports")['ports'].map{ |v| ports <<  v['ifName']}
    ports
  end

  def get_port_graph hostname, port, period = 'day'
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
    api_url = "devices/#{hostname}/ports/#{URI::encode(port).gsub('/','%2F')}/port_bits#{params}"
    puts "API:#{api_url}"
    graph = get(api_url,false)

    filename = "#{@path}#{hostname}_#{port.gsub('Port','').gsub('1/','').gsub(' ','')}_#{period}.png"
    File.open(filename, 'w') { |file| file.write(graph) }
  end
end

