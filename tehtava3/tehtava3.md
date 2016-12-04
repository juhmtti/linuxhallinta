#Linuxin keskuitetty hallinta

####Juha-Matti Ohvo

##Tehtävänanto

"Tee tavallisia työpöydän asetuksia puppet moduleiksi. Laita ne versionhallintaan. Konfiguroi tyhjä 
kone, vaikkapa juuri bootattu live-USB, lataamalla puppet-asetukset versionhallinnasta."

Teemme moduulin, joka muuttaa työpöydän taustakuvan, asentaa Firefox-selaimen ja muokkaa käyttäjän 
profiilia, eli muuttaa kotisivun.


##1. Alkuasetelma

Tehtävässä on käytössä kaksi Vagrantilla luotua virtuaalikonetta, joissa molemmissa pyörii Ubuntu 
14.04.5 64-bittinen käyttöjärjestelmä ja joille on varattu 512 megatavua keskusmuistia. Koneet ovat nimetty masteriksi ja slaveksi.

Tehtävässä on jo valmiiksi luotu Puppetmasterin ja agentin välille sertifikaatti ja komentojen 
suorittaminen verkon yli toimii [tehtävän 2 
mukaisesti.](https://github.com/juhmtti/linuxhallinta/blob/master/tehtava2/tehtava2.md)

Olemme ottaneet Vagrantissa käyttöön graafisen ulkoasun, jotta voimme käyttää työpöytää 
slave-koneella. Muutos tehdään Vagrantfileen.

	config.vm.provider "virtualbox" do |vb|
		# Display the VirtualBox GUI when booting the machine
		vb.gui = true
	end


##2. Moduulien luonti

Luomme kaksi moduulia, jotka nimemämme "firefox":ksi ja "desktop":ksi. Tämä tehdään master-koneella.

	cd /etc/puppet
	sudo mkdir -p modules/firefox/manifests modules/firefox/templates modules/desktop/manifests

