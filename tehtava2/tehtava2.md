##Linuxin keskitetty hallinta

####Juha-Matti Ohvo

###Tehtävänanto

Tehtävässä luomme yhteyden Puppet master- ja orjakoneen välillä ja ajamme moduuleja koneiden 
välillä. Teemme kaksi virtuaalikonetta Vagrantilla ja molemmissa koneissa pyörii Ubuntu 16.04.1 
Xenial 64-bittiset käyttöjärjestelmät. Koneille on varattu 512 mb keskusmuistia.


###Virtuaalikoneiden luonti

Teemme harjoituksen käyttäen Vagrant-virtuaalikoneita. Koneet on provisioitu siten, että 
Puppet asennetaan molemmille koneille automaattisesti käynnistyksen yhteydessä.
	
Vagrantfile näyttää tältä:

	config.vm.box = "base"

		config.vm.define "master" do |master|
			master.vm.box = "ubuntu/trusty64"
			master.vm.network "private_network", ip: "192.168.0.11"
			master.vm.provision "shell", path: "master.sh"
		end

		config.vm.define "slave" do |slave|
			slave.vm.box = "ubuntu/trusty44"
			slave.vm.network "private_network", ip: "192.168.0.22"
			slave.vm.provision "shell", path: "slave.sh"
		end	

Master-koneen provisiointi:

	#!/bin/bash

	sudo apt-get update
	sudo apt-get install puppetmaster -y

SLave-koneen provisiointi:

	#!/bin/bash

	sudo apt-get update
	sudo apt-get install puppet -y

Harjoituksessa käytetään valmiita Vagrant-koneiden boxeja ja muussa käytössä olen kohdannut ongelmia Ubuntu 16.04.1 64-bittisten koneiden kanssa, joten käytämme versiota 14.0.4.5 64-bit jonka olen todennut täysin toimivaksi muissa projekteissani.

Käynnistetään virtuaalikoneet.

	vagrant up

Kun koneet ovat käynnistetty, otetaan niihin SSH-yhteydet.

	vagrant ssh [koneen nimi, tässä tapauksessa master/slave]


###Koneiden nimien muuttaminen

Asennamme molempiin koneisiin avahi-daemonin

	sudo apt-get install -y avahi-daemon

Asetetaan koneille uusi hostname hostnamectl-komennolla.

	sudo hostnamectl set-hostname [hostnimi, eli master/slave]

Kun nimet ovat muutettu molemmilla koneilla, käynnistetään avahi-daemon uudelleen.

	sudo service avahi-daemon restart

Pingataan koneilla itseään ja myös toista konetta, jolla tiedämme, toimiiko asettamamme .local-nimet

	ping master.local
	ping slave.local

Pingaaminen toimi molemmin päin, joten .local-nimien asettaminen tehtiin onnistuneesti.



###Puppetmasterin konfigurointi

Master-koneella olemme valmiiksi asentaneet Puppetmasterin provisioinnin yhteydessä, joten ensiksi 
sammutetaan kyseinen palvelu.

	sudo service puppetmaster stop

Poistetaan ssl-sertifikaatit

	sudo rm -r /var/lib/puppet/ssl

Lisätään dns-nimet Puppetin asetustiedostoon.

	echo "dns_alt_names = master.local" | sudo tee -a /etc/puppet/puppet.conf

Käynnistetään Puppetmaster-palvelu.

	sudo service puppetmaster restart



###Slave-koneen konfigurointi

Myös slave-koneella on Puppet valmiina asennettuna, joten aloitetaan lisäämällä master-koneen nimi 
/etc/puppet -tiedostoon.

	echo -e "[agent]\nserver = master.local" | sudo tee -a /etc/puppet/puppet.conf

Ajetaan Puppet käynnistymään aina käynnistyksen yhteydessä.

	echo "START=yes" | sudo tee -a /etc/default/puppet

Käynnistetään Puppet-palvelu uudelleen.

	sudo service puppet restart



###Sertifikaatin allekirjoitus

Master-koneella tehdään sertifikaatin allekijoitus, jolloin slave-kone saadaan master-koneen 
ohjattavksi.

	sudo puppet cert --list

Master-kone ei tulosta lainkaan koneita, joten yritetään vielä ssl-sertifikaattien poistoa 
molemmilla koneilla.

Ensiksi slave-koneella:

	sudo service puppet stop
	sudo rm -r /var/lib/puppet/ssl

Sitten master-koneella samat komennot. Käynnistetään seuraavaksi palvelut.

	#Master koneella
	sudo service puppetmaster start

	#Slave-koneella
	sudo service puppet start

Nyt kun ajetaan aiempi "sudo puppet cert --list" -komento, niin ilmestyy uusi kone, joka on 
slave-kone, koska muita koneita ei ympäristössä ole. Allekirjoitetaan sertifikaatti.

	sudo puppet cert --sign --all

Sertifikaatin allekirjoittamisessa ei ilmene virheilmoituksia, joten olemme onistuneesti liittäneet 
slave-koneen Puppetmasterin haltuun.

![certkuva](./linux2_2.png)



###Moduulin luominen

Luomme moduulin, joka asentaa SSH-palvelun ja asettaa uuden porttinumeron palvelulle. Luodaan 
ensiksi tarvittavat hakemistot /etc/puppet -hakemistoon.

	cd /etc/puppet
	sudo mkdir -p manifests/ modules/testi/manifests

