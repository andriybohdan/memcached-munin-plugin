#!/usr/bin/ruby

def check_symlink
    if File.basename(__FILE__).split("___").size!=3
        puts "No symlink or incorrect symlink name\n\tCreate symlink to memcached-stats.rb named like memcached___<param1>__<param2>....___<host>__<port>.rb\n\tSee '#{File.basename(__FILE__)} usage' for more information"
	exit 1
    end
end

def get_params 
    File.basename(__FILE__).split("___")[1].split("__").map {|p| p.to_sym} 
end

def get_socket_conf
    arr = File.basename(__FILE__,".rb").split("___")[2].split("__")
    {:host => arr[0], :port => arr[1]}    
end

labels = { 
    :hit_percent => 'hit %',
    :fill_percent => 'fill %',
    :get_set_rate => 'get/set',
    :connections => 'connections',
    :evictions => 'evictions'
}

graph_params = { 
    :evictions =>  {
	    :type => "DERIVE",
	    :min => "0"
	}
}

if ARGV[0] == 'usage' 
	puts "\nMunin plugin for memcached"
	puts "Author: a.bohdan@gmail.com"
	puts "\nUsage: #{File.basename(__FILE__)} [(install <host> <port>|config)]"
	puts "\tInstall plugin: #{File.basename(__FILE__)} install localhost 11211\n\n"	
	exit 0
end

if ARGV[0] == 'config' 
    check_symlink
    params = get_params
    socket_conf = get_socket_conf
    host = socket_conf[:host]
    port = socket_conf[:port]
    
    puts "graph_title memcached #{host}:#{port} ("+params.join(', ')+")"
    puts "graph_vlabel value"
    puts "graph_category memcached"
    puts "graph_scale no"
    params.each do |param|
	    puts "#{param}.label #{labels[param]} at #{host}:#{port}"
	    graph_params[param].each do |k,gp| 
		    puts "#{param}.#{k} #{gp}"
	    end if graph_params.include? param
    end
else 
    if ARGV[0] == 'install'
	    if ARGV.size!=3
	      puts "Usage: #{File.basename(__FILE__)} install <host> <port>"
	      exit 1
	    end
	    if `whoami`.strip == 'root' 
	      plugin_params = [[:connections],[:evictions],[:get_set_rate],[:hit_percent,:fill_percent]]
	      host = if ARGV.size>1 then ARGV[1] else "localhost" end
	      port = if ARGV.size>2 then ARGV[2] else "11211" end
	      conf_dir="/etc/munin/plugins/"
	      plugin_file="/usr/share/munin/plugins/#{File.basename(__FILE__)}"
	      system("cp -v -f #{File.expand_path(__FILE__)} #{plugin_file}")
	      system("chown munin #{plugin_file}")
	      plugin_params.each do |pp| 
		      system("ln -v -f -s #{plugin_file} #{conf_dir}memcached___#{pp.map{|p|  p.to_s}.join('__')}___#{host}__#{port}.rb")
	      end
	    else
	      puts "Must be run with root access"
	    end
    else
	    check_symlink
	    params = get_params
      socket_conf = get_socket_conf
      host = socket_conf[:host]
      port = socket_conf[:port]
	    stats_raw = `echo -ne "stats\r\nquit\r\n" | nc #{host} #{port}`
	    stats = {}
	    stats_raw.split("\r\n").each do |row| 
    	  fields = row.split(' ')
	      stats[fields[1].to_sym] = fields[2] if fields[0]=='STAT' and fields.size == 3
	    end
	    values = {}
      values[:hit_percent] = "%.2f" % [stats[:get_hits].to_f/(stats[:get_misses].to_f+stats[:get_hits].to_f) * 100]
      values[:fill_percent] = "%.2f" % [stats[:bytes].to_f/stats[:limit_maxbytes].to_f * 100]
      values[:get_set_rate] = "%.2f" % [stats[:cmd_get].to_f/stats[:cmd_set].to_f]
      values[:connections] = "%d" % [stats[:curr_connections].to_i]
      values[:evictions] = "%d" % [stats[:evictions].to_i]
      params.each do |param| 
    	  if values[param] 
		      puts "#{param}.value %s" % [values[param]]
	      end
      end
    end
end