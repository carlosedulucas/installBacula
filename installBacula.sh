#!/bin/bash

########################## Informações #######################################
# Autor: Carlosedulucas	/ Carlos Eduardo Lucas                               #
# Data: 02/10/2016                                                           #
# Descrição: instalação do servidor ou cliente de backup bacula              #
# Versão: 1.1                                                                #
# OS: Testado e homologado Oracle Linux 7.1, CentOS 7                        #
#                                                                            #
# Reporte os erros que encontrar para o email abaixo                         #
# Não retire os devidos créditos                                             #
# Site:                                                                      #
# Email: carlosedulucas9@gmail.com                                           #
##############################################################################

# Variaveis
ipserver=$(hostname -I | cut -d' ' -f1)
dateVersion="07 de Outubro de  2016"

TITULO="installBacula.sh - v.1.0"
BANNER="https://github.com/carlosedulucas"

contato=carlosedulucas9@gmail.com	


clear


reqsToUse ()
{
	# Testa se o usuário é o root
	if [ $UID -ne 0 ]
	then
		whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "Passo 01 - É necessário estar logado com usuário root." --fb 10 50
		kill $$
	fi
}
menuPrincipal ()
{
 
	menuPrincipal=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --menu "Escolha uma opção na lista abaixo" --fb 23 60 7\
	"1" "Instalação do Servidor Bacula " \
	"2" "Instalação Apenas do Cliente " \
	"3" "Instalação do Webmin" \
	"4" "Instalação do Webacula" \
	"5" "Instalação Bacula-Web" \
	"6" "Limpar cache de Downloads" \
	"7" "Exit" 3>&1 1>&2 2>&3)
	 
	status=$?

	if [ $status != 0 ]; then
		echo "
	Obrigado...
	"
		exit;
	fi

}

verificaPostgresql ()
{
	clear
	#!/bin/bash
	if (rpm -qa | grep postgresql-server) ;then
		   echo "instalado"
		   sleep 5
	else
		   killall -9 yum
		   yum install -y postgresql postgresql-server
		   postgresql-setup initdb
		   sleep 5
	fi
	
	#Habilitar e inicializar o posgresql com o sistema
	systemctl start postgresql.service
	systemctl enable postgresql.service

}

verificaDown()
{
	
	if [ -e $1 ] ; then
		echo "Download $1 Realizado com sucesso"
		sleep 5
	else
		whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
			Ocorreu algum problema e o download do $1 não foi realizado
		" --fb 15 70
		kill $$
	fi
}
#
# Garante que o usuário tenha o whiptail instalado no computador

installWhiptail () 
{

	clear

	[ ! -e /usr/bin/whiptail ] && { echo -e "

	 ###########################################################
	#                       WARNING!!!                          #
	 -----------------------------------------------------------
	#                                                           #
	#                                                           #
	# Não foi possível encontrar o pacotes Whiptail.            #
	#                                                           #
	# O pacote whiptail é requerido 			    #
	# Por Favor Contate: $contato                               #
	#                                                           #
	#                                                           #
	 ----------------------------------------------------------
		 https://github.com/carlosedulucas 
	 ----------------------------------------------------------"; 

		exit 1; }

}

limparCacheDownloads()
{
	rm -fr /usr/src/webmin*
	rm -fr /usr/src/bacula-7.4.4*
	rm -fr /usr/src/epel*
	rm -fr /usr/src/master*
	rm -fr /usr/src/webacula-master*
	rm -fr /usr/src/usr/src/bacula-web-latest*

	echo "Cache limpo ..."
	sleep 5
}


installDependencias ()
{

	clear 

	echo "Realizando Download  Repositório Epel"
	sleep 1

	wget -P /usr/src http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-8.noarch.rpm
	verificaDown /usr/src/epel-release-7-8.noarch.rpm
	rpm -ivh /usr/src/epel-release*
	clear

	echo "Instalando Pacotes ..."
	sleep 1
	killall -9 yum
	yum -y install openssl-devel gcc-c++ readline readline-devel lzo
	yum -y install libpqxx-devel
	yum -y install qt4  qt4-devel  qwt qwt-devel
	verificaPostgresql

}


DBTables()
{
	senhaPostgres=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Informe senha do usuário Postgres " --fb 10 50 3>&1 1>&2 2>&3) 
	# baixar a segurança do postgres será elevada posteriormente
	sed  -i '/local/ s/peer/trust/g' /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql.service

	#criando uma senha para o usuário postgres
	psql -U postgres -c "alter user postgres with encrypted password '$senhaPostgres';"

	#elevando a segurança do postgres
	sed  -i '/local/ s/trust/md5/g' /var/lib/pgsql/data/pg_hba.conf
	sed  -i '/host/ s/ident/md5/g' /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql.service
}

installBacula ()
{
	clear 

	echo "Desabilitando SELinux"
	sleep 1

	#desabilitar o selinux
	sed -i 's/^SELINUX=enforcing.*/SELINUX=disabled/' /etc/selinux/config
	setenforce 0

	echo "Efetuando Download Bacula"
	sleep 1

	# Efetuar o download do source do bacula e preparar para instalação
	wget -P /usr/src https://sourceforge.net/projects/bacula/files/bacula/7.4.4/bacula-7.4.4.tar.gz
	verificaDown /usr/src/bacula-7.4.4.tar.gz
	tar -xvzf /usr/src/bacula-7.4.4.tar.gz -C /usr/src/
	cd /usr/src/bacula-7.4.4/

	# setar variaveis de ambiente para o Bat (Bacula Administration tool)
	export PATH=/usr/lib64/qt4/bin/:$PATH

	clear 
	echo "Configurando o Bacula"
	sleep 1
	#configurar, compilar, instalar e habilitar na inicialização
	./configure --enable-bat --with-readline=/usr/include/readline --disable-conio --with-logdir=/var/log/bacula --enable-smartalloc --with-postgresql --with-archivedir=/backup --with-hostname=$ipserver --with-db-user=postgres --with-db-password=$senhaPostgres --with-openssl
	
	clear 
	echo "Compilando o Bacula"
	sleep 1
	make 

	clear 
	echo "Instalando o Bacula"
	sleep 1	
	make install

	clear 
	echo "Configurando o Bacula para inicializar junto com o Sistema"
	sleep 1
	make install-autostart

	#preparando DB, Tables e Privilegios
	DBTables
	
	sed  -i '/local/ s/md5/trust/g' /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql.service

	#criar o BD e popular suas informações
	chmod 775 -R /etc/bacula
	clear 
	echo "criando DataBase Bacula"
	sleep 1	
	/etc/bacula/./create_bacula_database
	clear 
	echo "criando Tabelas Bacula"
	sleep 1	
	/etc/bacula/./make_bacula_tables
	clear 
	echo "Permissões DB"
	sleep 1	
	/etc/bacula/./grant_bacula_privileges	
	
	sed  -i '/local/ s/trust/md5/g' /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql.service

	#Liberando o uso do bacula no firewall
	firewall-cmd --permanent --zone=public --add-service=bacula-client
	firewall-cmd --permanent --zone=public --add-service=bacula

	#reiniciando todos os serviços
	systemctl restart firewalld.service

	#Iniciando os serviços de bacula
	systemctl start bacula-dir.service
	systemctl start bacula-sd.service
	systemctl start bacula-fd.service

	#habilitando na inicialização do sistema os serviços do bacula
	systemctl enable bacula-dir.service
	systemctl enable bacula-sd.service
	systemctl enable bacula-fd.service

	if whiptail --title "Webmin" --yesno "Deseja instalar o Webmin." 10 50
	then
	  installWebmin
	fi


	if whiptail --title "WEBACULA" --yesno "Deseja instalar o Webacula." 10 50
	then
	   installWebacula
	fi

	if whiptail --title "Bacula-Web" --yesno "Deseja instalar o Bacula-Web." 10 50
	then
	   installBaculaWeb
	fi

}

installWebmin()
{
	clear
	echo "Instalando Webmin"
	sleep 2
	
	wget -P /usr/src http://prdownloads.sourceforge.net/webadmin/webmin-1.810-1.noarch.rpm
	verificaDown /usr/src/webmin-1.810-1.noarch.rpm
	killall -9 yum
	yum install -y perl-DBD-Pg  perl perl-Net-SSLeay openssl perl-IO-Tty
	rpm -ivh /usr/src/webmin-1.810-1.noarch.rpm
	systemctl start webmin
	firewall-cmd --permanent --zone=public --add-service=wbem-https
	firewall-cmd --permanent --zone=public --add-service=https
	firewall-cmd --permanent --zone=public --add-port=10000/tcp
	firewall-cmd --permanent --zone=public --add-port=10000/udp
	systemctl restart firewalld.service

	whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
   Webmin foi instalado com sucesso!		
   Para acessá-lo utilize no navegador 
   url: https://$ipserver:10000

	"  --fb 15 50
}

installHttp()
{
	killall -9 yum	
	clear
	echo "Instalando Http e PHP"
	sleep 2
	
	yum install -y httpd php php-pgsql php-gd php-pear php-gettext php-pdo
	yum --enablerepo=ol7_optional_latest install -y php-mbstring php-bcmath
	systemctl start httpd.service
	systemctl enable httpd.service
	firewall-cmd --permanent --zone=public --add-service=http
	systemctl restart firewalld.service
}

installWebacula()
{
	
	clear
	echo "instalado webacula"
	sleep 2

	installHttp
	
	wget -P /usr/src https://github.com/wanderleihuttel/webacula/archive/master.zip
	verificaDown /usr/src/master.zip
	unzip /usr/src/master.zip -d /usr/src
	cp -r /usr/src/webacula-master/ /var/www/html/webacula
	chown apache:apache -R /var/www/html/
	cd /var/www/html/webacula/install/
	sleep 5
	
	senhaPostgres=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Informe senha do usuário Postgres " --fb 10 50 3>&1 1>&2 2>&3) 
	
	sed  -i "/db_pwd=/ s/''/'$senhaPostgres'/g" /var/www/html/webacula/install/db.conf
	sed  -i "/db_user=/ s/root/postgres/g"	/var/www/html/webacula/install/db.conf
	
	
	sed  -i '/local/ s/md5/trust/g' /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql.service



	cd /var/www/html/webacula/install/PostgreSql/

	sed -i '/./ s/..\/db.conf/\/var\/www\/html\/webacula\/install\/db.conf/g'  /var/www/html/webacula/install/PostgreSql/10_make_tables.sh
	sed -i '/./ s/..\/db.conf/\/var\/www\/html\/webacula\/install\/db.conf/g'  /var/www/html/webacula/install/PostgreSql/20_acl_make_tables.sh
	su -c "./10_make_tables.sh" postgres 
	su -c "./20_acl_make_tables.sh" postgres 
	
	sed  -i '/local/ s/trust/md5/g' /var/lib/pgsql/data/pg_hba.conf
	systemctl restart postgresql.service
	
	sed -i '/db.adapter/ s/PDO_MYSQL/PDO_PGSQL/g' /var/www/html/webacula/application/config.ini
	sed -i '/db.config.username/ s/bacula/postgres/g' /var/www/html/webacula/application/config.ini
	sed -i "/db.config.password/ s/bacula/$senhaPostgres/g" /var/www/html/webacula/application/config.ini
	sed -i '/bacula.sudo/ s/"\/usr\/bin\/sudo"/""/g' /var/www/html/webacula/application/config.ini
	sed -i '/bacula.bconsole/ s/"\/opt\/bacula\/sbin\/bconsole"/"\/sbin\/bconsole"/g' /var/www/html/webacula/application/config.ini

	cd /etc/bacula/
	chown apache /sbin/bconsole
	chown apache /etc/bacula/bconsole.conf
	chmod 775 /etc/bacula/

	cp /var/www/html/webacula/install/apache/webacula.conf /etc/httpd/conf.d/
	sed -i 's/\/var\/www\/webacula/\/var\/www\/html\/webacula/g' /etc/httpd/conf.d/webacula.conf

	mask=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --inputbox  "Informe sua mascara de rede " --fb 10 50 3>&1 1>&2 2>&3)	
	sed -i "/Allow from localhost/a Allow from $ipserver\/$mask" /etc/httpd/conf.d/webacula.conf

  	systemctl restart httpd.service
	chown -R apache:apache /var/www/html/
		
	
	
	whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
  Webacula foi instalado com sucesso!
  Para acessá-lo utilize o navegador 
  url: http://$ipserver/webacula
  Dados Iniciais
  Usuário: root
  Senha: bacula

	"  --fb 20 50	
	
}


installBaculaWeb()
{

	clear
	echo "instalado Bacula-Web"
	sleep 2

	installHttp
	
	
	wget -P /usr/src http://www.bacula-web.org/files/bacula-web.org/downloads/bacula-web-latest.tgz
	verificaDown /usr/src/bacula-web-latest.tgz
	mkdir -v /var/www/html/bacula-web
	tar -xzf /usr/src/bacula-web-latest.tgz -C /var/www/html/bacula-web
	chown -Rv apache: /var/www/html/bacula-web
	sleep 5
	

	cd /var/www/html/bacula-web/application/config/
	cp -v config.php.sample config.php
	chown -v apache: config.php

	senhaPostgres=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --passwordbox "Informe senha do usuário Postgres " --fb 10 50 3>&1 1>&2 2>&3) 
	labelServer=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --inputbox "Informe o nome da Configuração " --fb 10 50 3>&1 1>&2 2>&3) 
	sed -i  '/config\[0\]/d' /var/www/html/bacula-web/application/config/config.php
	sed  -i "/language/ s/en_US/pt_BR/g" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['label'] = '$labelServer';" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['host'] = 'localhost';" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['login'] = 'postgres';" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['password'] = '$senhaPostgres';" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['db_name'] = 'bacula';" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['db_type'] = 'pgsql';" /var/www/html/bacula-web/application/config/config.php
	sed -i "/PostgreSQL bacula catalog/a \$config[0]['db_port'] = '5432';" /var/www/html/bacula-web/application/config/config.php

	
	echo "
	<Directory /var/www/html/bacula-web>
	  AllowOverride All
	</Directory>
	" >> /etc/httpd/conf.d/bacula-web.conf

	systemctl restart httpd.service


	
	whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "
  Bacula-Web foi instalado com sucesso!
  Para acessá-lo utilize o navegador 
  url: http://$ipserver/bacula-Web

	"  --fb 20 50	
	
}






installClient ()
{

	clear 

	echo "Instalação do Cliente"
	sleep 1

	#desabilitar o selinux
	sed -i 's/^SELINUX=enforcing.*/SELINUX=disabled/' /etc/selinux/config
	setenforce 0

	# Efetuar o download do source do bacula e preparar para instalação
	wget -P /usr/src https://sourceforge.net/projects/bacula/files/bacula/7.4.4/bacula-7.4.4.tar.gz
	tar -xvzf /usr/src/bacula-7.4.4.tar.gz -C /usr/src/
	cd /usr/src/bacula-7.4.4/

	#configurar, compilar, instalar e habilitar na inicialização
	./configure --enable-client-only
	  make 
	  make install
	  make install-autostart

	nomeDirector=$(whiptail --title "${TITULO}" --backtitle "${BANNER}" --inputbox  "Informe o nome do seu director: bacula-dir? " --fb 10 50 3>&1 1>&2 2>&3)
	hostname=$(hostname)
	sed -i "s/$hostname-dir/$nomeDirector/" /root/Downloads/installBacula-master/bacula-fd.conf

	senhaClient=$(grep -m 1 "Password" /root/Downloads/installBacula-master/bacula-fd.conf)

	whiptail --title "${TITULO}" --backtitle "${BANNER}" --msgbox "Adicione este cliente ao seu arquivo /etc/bacula/bacula-dir.conf do seu Servidor de Backup Director

Client {
 Name = $hostname-fd
 Address = $ipserver 
 FDPort = 9102
 Catalog = MyCatalog
 $senhaClient # SENHA DO CLIENTE
 File Retention = 30 days # 30 days
 Job Retention = 6 months # six months
 AutoPrune = yes # Prune expired Jobs/Files
}" --fb 22 70

	#Liberando o uso do bacula no firewall
	firewall-cmd --permanent --zone=public --add-service=bacula-client
	firewall-cmd --permanent --zone=public --add-service=bacula

	#reiniciando todos os serviços
	systemctl restart firewalld.service
	systemctl enable bacula-fd.service
	systemctl restart bacula-fd.service
}


infoFinal ()
{
	clear

	whiptail --title "${TITULO}" --backtitle "${BANNER}" --scrolltext --msgbox "
  $TITULO Versão: $dateVersion

  Download:  $BANNER

  Este Script realiza a instalação:
  - Bacula-7.4.4
  - PostgreSQL
  - bconsole
  - BAT (Bacula Administration Tool) caso seu servidor possua interface gráfica
  - Fork Webacula ( Wanderlei Huttel)  - https://github.com/wanderleihuttel/webacula
  - Webmin 
  - Bacula-web
---------------------------------------------------------	
  Webacula 
	Url: http://$ipserver/webacula
	Usuário: root
	Senha: bacula
---------------------------------------------------------	
  Webmin
	Url: https://$ipserver:10000
	Usuário: root
	Senha: senha do usuário root do sistema
	Acessar -> System -> Bacula Backup System-> module configuration -> 
	User to login to database as : postgres
	Password to login with: senha do postgres
---------------------------------------------------------		
  Bacula-web
	Url: http://$ipserver/bacula=web
	
---------------------------------------------------------		

	Obrigado!

	
	"  --fb 22 70

}



# Script start

clear

[ ! -e /usr/bin/whiptail ] && { installWhiptail; }

menuPrincipal

while true
do
case $menuPrincipal in

	1)
		reqsToUse
		#limparCacheDownloads		
		installDependencias
		installBacula
		infoFinal
		menuPrincipal
		
	;;
	
	2)
		installClientE
		infoFinal
		menuPrincipal
	;;
		

	3)
		installWebmin
		infoFinal
		menuPrincipal
	;;
	
	4)
		installWebacula
		infoFinal
		menuPrincipal
	;;
	
	5)
		installBaculaWeb
		infoFinal
		menuPrincipal
	;;
	
	6)
		limparCacheDownloads		
		infoFinal
		kill $$
	;;

	7)
		infoFinal
		kill $$
	;;

esac
done

