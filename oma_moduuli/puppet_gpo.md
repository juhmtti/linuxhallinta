#Linuxin keskitetty hallinta

####Juha-Matti Ohvo

#####13.12.2016


##1. Moduulin esittely

Moduuli on Linuxin keskitetty hallinta -kurssia varten luotu Puppet-moduuli. 


##2. Työympäristö

Työssä on käytetty kahta fyysistä tietokonetta, joista toinen toimii Puppetmaster-palvelimena (Ubuntu 16.04.1 LTS 64-bit) ja toiselle on asennettu Windows 8.1 64-bittinen käyttöjärjestelmä ja joka toimii Puppet agenttina. Puppetmasterpalvelimena toimii Haaga-Helian laboratorioluokan 5005 tietokone ja agenttikoneena HP Elitebook 2560p.


##3. Alkuvalmistelut

Puppetilla on mahdollista tehdä Windows-tietokoneista Puppet agentteja, mutta Puppetmaster vaatii Linux-palvelimen. Puppetin virallisilla sivuilla löysin ensimmäiseksi [tämän ohjeen](https://docs.puppet.com/pe/latest/windows_installing.html), jossa Puppetmaster valmistellaan ottamalla SSH-yhteys Windows koneelta Linux-palvelimelle, viemällä Puppetmasterin asennus palvelimelle ja ajetaan lopuksi asennus palvelimella. Asennuksen aikana siirrytään Windows-koneella selaimelle ja suoritetaan asennus loppuun graafisessä käyttöliittymässä.

Kyseinen ohje toimi, mutta itse Puppetmasterin asennus ei onnistunut ollenkaan. Asennuslokissa virheviestit valittivat puuttuvista tiedostoista /opt -hakemistossa, mutta jos asennus ajetaan ensimmäistä kertaa, miksi ohjeissa ei mainita lainkaan että /opt -hakemistossa täytyisi olla valmiina asennukseen tarvittavia tiedostoja. Neljän tunnin selvittämisen jälkeen luovutin tämän asennuksen suhteen.

![alkuasetelma](puppet_failed.jpg)

Mietin ongelmatilanteiden jälkeen, miksi Windows-koneesta ei voisi tehdä agenttia samaan tapaan kuin Linuxilla, eli asennetaan Puppet client-ohjelmisto agentille, lisätään master-palvelin asetuksiin ja allekirjoitetaan sertifikaatit Puppetmasterilla. Googlella löysinkin Puppetin [virallisen ohjeen tätä varten](https://docs.puppet.com/puppet/latest/install_windows.html).

![alkuasetelma](alkuasetelma.jpg)

##4 Koniden valmistelu

####4.1 Puppetmasterin valmistelu

Tämän vaiheen alkaessa meillä on Linux-palvelin, jossa pyörii Ubuntu 16.04.1 LTS 64-bittinen käyttöjärjestelmä. Päivitetään pakettilistat ja asennetaan Puppetmaster. Tietokoneen hostname on "puppetmaster".

	$ sudo apt-get update && sudo apt-get install Puppetmaster -y

Kun Puppetmaster on asennettu, pysäytetään Puppetmaster-palvelu poistetaan sertifikaatit.

	$ sudo service puppetmaster stop && sudo rm -r /var/lib/puppet/ssl

Lisätään masterin dns-nimet Puppetin asennustiedostoon. Hostname on "puppetmaster", jolloin luonnollisesti tämä on dns_alt_name.

	$ echo "dns_alt_names = puppetmaster" | sudo tee -a /etc/puppet/puppet.conf


####4.2 Windows Puppet agentin valmistelu

Tämä vaihe edellyttää, että Windows on asennettuna koneelle, UAC on poistettu käytöstä sekä palomuurista on avattu TCP-portti 8140 Puppettia varten. Ladataan ensiksi Puppet agentin .msi-asennuspakettin Windows-koneelle. Asennuspaketit Windowsille löytyvät [Puppetin sivuilta](https://downloads.puppetlabs.com/windows/).



