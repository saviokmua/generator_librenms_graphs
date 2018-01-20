require_relative  'class_generator'

g = Generator.new
g.get_devices.each do |device|
  puts "=== DEVICE: #{device['hostname']} ==="
  g.get_device_ports(device).each_with_index do |port, index|
    g.get_port_graph device, port, index+1, 'week'
  end
end