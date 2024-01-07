#!/bin/bash

# Store Ubuntu version name
ubuntu_version_name=""

# Arg-1 input
param_one=$1

# Arg-2 input
param_two=$2

function check_version() {

		# Versions are named as jammy, focal, and so on
		ubuntu_version_name=$(lsb_release -cs) ; echo "Ubuntu version:" $ubuntu_version_name
}

function log() {
		local text="$1"
		local status="$2"
		local name="Limankur >"
		local current_time=$(date +"%H:%M:%S")
		local status_text="OK"

		# Status-based logging print system
		case "$status" in
				0) echo -e "\e[32m$name $text\e[0m";;                    # Success
				1) echo -e "\e[31m$name $text\e[0m"; status_text=" -";;  # Warning
				*) echo -e "\e[36m$name $text\e[0m";;                    # Default
		esac

		# Append current log to installer.log file
		echo "$current_time | $status_text | $name $text" | sudo tee -a /liman/installer.log >/dev/null
}

function create_log_file() {

	# Make liman directory if does not exist
	sudo mkdir -p /liman

	# Create installer log
	sudo touch /liman/installer.log

	# Set installation date for installer log
	install_date=$(date +"%F")

	# The -a parameter causes writing to the end of the file
	echo " $install_date Liman Kurulumu" | sudo tee -a /liman/installer.log >/dev/null
}

function add_php() {
		log "Ubuntu'ya güncel php ekleniyor..."

		# 1. Installs software-properties-common
		# 2. Adds the ondrej/php repository
		# 3. Updates the package lists via apt
		if sudo apt install -y software-properties-common \
		&& sudo add-apt-repository -y ppa:ondrej/php \
		&& sudo apt update; then
				log "php başarılı bir şekilde eklendi!" 0
		else
				log "php eklenirken bir sorun oluştu." 1
		fi
}

function add_nodejs() {
		log "Ubuntu'ya güncel NodeJS ekleniyor..."

		# 1. Check and install necessary packages for setup
		# 2. Create directory for keyrings
		# 3. Fetch and store GPG key for NodeJS repository
		# 4. Add NodeJS repository to sources list
		# 5. Updates the package lists via apt
		if sudo apt install -y ca-certificates curl gnupg gnupg2 \
		&& sudo mkdir -p /etc/apt/keyrings \
		&& curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
		&& echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list \
		&& sudo apt update; then
				log "NodeJS başarılı bir şekilde eklendi!" 0
		else
				log "NodeJS eklenirken bir sorun oluştu." 1
		fi
}

function add_postgresql() {
		log "Ubuntu'ya güncel PostgreSQL ekleniyor..."

		# 1. Check and configure PostgreSQL repository
		# 2. Install necessary packages for setup
		# 3. Fetch and store GPG key for PostgreSQL
		# 4. Move the GPG key to trusted keys
		# 5. Update package lists
		if sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' \
		&& sudo apt install gnupg2 ca-certificates -y \
		&& wget -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor > pgsql.gpg \
		&& sudo mv pgsql.gpg /etc/apt/trusted.gpg.d/pgsql.gpg \
		&& sudo apt update; then
				log "PostgreSQL başarılı bir şekilde eklendi!" 0
		else
				log "PostgreSQL eklenirken bir sorun oluştu." 1
		fi
}

function install_liman() {
		log "Ubuntu'ya Liman kurulmak üzere indiriliyor..."

		# Downloads the latest version package and installs it directly without saving it to disk
		if wget -O- https://github.com/limanmys/core/releases/download/release.feature-new-ui.860/liman-2.0-RC2-860.deb | sudo apt install -y; then
				log "Liman debian paketi hazırlanıyor..."
		else
				log "Liman debian paketi kurulumu sırasında bir hata oluştu" 1
				exit 1
		fi

		echo "deb [arch=amd64] http://depo.aciklab.org/ $ubuntu_version_name main" | sudo tee /etc/apt/sources.list.d/acikdepo.list
		wget -O- http://depo.aciklab.org/public.key  | gpg --dearmor > aciklab.gpg
		sudo mv aciklab.gpg /etc/apt/trusted.gpg.d/aciklab.gpg

		# Install liman
		if sudo apt update \
		&& sudo apt install liman; then
				log "Liman başarıyla yüklendi!" 0
		else
				log "Liman yüklenirken bir sorun oluştu." 1
				exit 1
		fi

		# Check service status
		health

		# IP adress
		hostname -I

		# Create an administrator password
		sudo limanctl administrator
}

function uninstall_liman() {

		# Removes Liman and its dependencies
		if sudo apt remove liman -y \
		&& sudo apt-get remove nginx nginx-common nginx-core* -y \
		&& sudo apt-get autoremove -y \
		&& sudo rm -rf /liman \
		&& sudo rm -rf /etc/apt/keyrings/nodesource.gpg \
		&& sudo apt-get install nginx -y; then
				log "Liman başarıyla kaldırıldı!" 0
		else
				log "Liman kaldırılırken bir hata oluştu." 1
				exit 1
		fi
}

function reset_administrator() {

		# Reset Liman administrator password
		sudo limanctl reset administrator@liman.dev
}

function reset_mail() {

		# Ensure argument is not null
		if [ -z "$param_two" ]; then
				log "E-posta bilgisi boş geçilemez." 1
				echo "Kullanım: ./liman.sh reset <e-posta>"
				exit 1
		fi

		# Reset Liman user password by mail
		sudo limanctl reset "$param_two"
}

function health() {

		# Status of Liman services
		if sudo limanctl service &>/dev/null; then
				sudo limanctl service
				sudo supervisorctl status all
		else
				log "Liman kurulu değil, servisler bulunamadı." 1
				exit 1
		fi
}

function display_help() {
		echo "
Liman Kurulum Sihirbazı

Kullanım: ./liman.sh [komut]

Komutlar:
 ./liman.sh kur               -> Limanı kurar. (Son sürüm)
 ./liman.sh kaldır            -> Limanı kaldırır.
 ./liman.sh sağlık            -> Liman servislerinin durumlarını gösterir.
 ./liman.sh adminyenile       -> Liman yönetici parolasını sıfırlar.
 ./liman.sh reset <e-posta>   -> Yazılan e-posta adreslerine göre parolayı sıfırlar.
 ./liman.sh yardım            -> Komutların nasıl kullanıldığını görüntüler."
}

# Calls the corresponding function by comparing the arguments entered by the user
case "$param_one" in
	"kur" | "yükle" | "install")
		create_log_file
		check_version
		add_php
		add_nodejs
		add_postgresql
		install_liman
		;;
	"kaldır" | "uninstall")
		uninstall_liman
		;;
	"adminyenile")
		reset_administrator
		;;
	"reset")
		reset_mail
		;;
	"yardım" | "help")
		display_help
		;;
	"sağlık" | "health")
		health
		;;
	*)
		display_help
		exit 1
		;;
esac
exit 0
