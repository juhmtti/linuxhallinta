##
## Author: Juha-Matti Ohvo
## github: juhmtti
##

class apache2 {

	# Ensure apache2 is installed and the latest version is present
	package { "apache2":
		ensure	=> "latest",
	}

	# Start apache2 on boot and ensure the service is running
	service { "apache2":
		enable	=> true,
		ensure	=> "running"
	}

	# Delete the default Apache index.html file
	file { "/var/www/html/index.html":
		ensure	=> "absent",
	}
	
	# Ensure public_html directory exists in /etc/skel
	file { "/etc/skel/public_html":
		ensure	=> directory,
	}

	# Enable Apache userdir mod and notify the service
	file { '/etc/apache2/mods-enabled/userdir.load':
                ensure	=> 'link',
                target	=> '/etc/apache2/mods-available/userdir.load',
                notify	=> Service["apache2"],
                require	=> Package["apache2"],
        }

        file { '/etc/apache2/mods-enabled/userdir.conf':
                ensure	=> 'link',
                target	=> '/etc/apache2/mods-available/userdir.conf',
                notify	=> Service["apache2"],
                require	=> Package["apache2"],
        }


}
