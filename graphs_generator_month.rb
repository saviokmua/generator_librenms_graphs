require_relative  'class_generator'

g = Generator.new
g.get_devices.each do |hostname|
  puts "=== DEVICE: #{hostname} ==="
  g.get_device_ports(hostname).each do |port|
    g.get_port_graph hostname, port, 'month'
  end
end