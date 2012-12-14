memcached-munin-plugin
======================

Memcached Statistics Plugin for Munin can be used to track the following:

* Number of connections
* Number of evictions
* Get/Set rate
* Hit rate
* Fill rate


Installation
------------

Run as root

	./memcached-stats.rb install


Result:

	/memcached-stats.rb install 127.0.0.1 11211
	`/root/bav/memcached-stats.rb' -> `/usr/share/munin/plugins/memcached-stats.rb'
	`/etc/munin/plugins/memcached___connections___127.0.0.1__11211.rb' -> `/usr/share/munin/plugins/memcached-stats.rb'
	`/etc/munin/plugins/memcached___evictions___127.0.0.1__11211.rb' -> `/usr/share/munin/plugins/memcached-stats.rb'
	`/etc/munin/plugins/memcached___get_set_rate___127.0.0.1__11211.rb' -> `/usr/share/munin/plugins/memcached-stats.rb'
	`/etc/munin/plugins/memcached___hit_percent__fill_percent___127.0.0.1__11211.rb' -> `/usr/share/munin/plugins/memcached-stats.rb'


After that don't forget to restart munin-node