#
# Author: Juha-Matti Ohvo
# Github: @juhmtti
#

class sshd {

        # An array of required packages
        $packages = ["openssh-server", "ufw"]

        # Install packages
        package { $packages:
                ensure => "installed",
        }

	# SSH service, start on boot and ensure it's running
        service { "ssh":
                ensure => "running",
                enable => true,
        }

	# Template file
        file { "/etc/ssh/sshd_config":
                content => template("sshd/sshd_config"),
                require => Package["openssh-server"],
                notify  => Service["ssh"],
        }

	# Ufw setup
        exec { "ufw_allow":
                path    => "usr/sbin",
                command => "/usr/sbin/ufw enable && /usr/sbin/ufw allow 33300/tcp && /usr/sbin/ufw reload",
                require => Package["ufw"],
		notify	=> Service["ssh"],
	}
}

