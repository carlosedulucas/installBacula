Script de Instalação do Bacula e Ferramentas Auxiliares
==============================================

Pré-requisitos
--------------
 Instalação básica do OS com GUI(opcional) para utilização do BAT (bacula administration tools)    
 Terminal logado como root   
 Acesso a internet no terminal de execução   
 
 Caso necessite autenticação para proxy execute no terminal:   
 export http_proxy=http://usuario:senha@proxy-xyz.com:porta  
 export https_proxy=http://usuario:senha@proxy-xyz.com:porta   
 export ftp_proxy=http://usuario:senha@proxy-xyz.com:porta   
 export no_proxy=.xyz     


Execução
--------
chmod +x installBacula.sh   
./installBacula.sh   


Sistemas Operacionais Homologados
-------------------------------------------------

 - Oracle Linux 7.1
 - CentOS 7

1. Instalação do Bacula
------------------------------

 - Instala dependências
 - Verifica Instalação do PostgreSQL
	- Instalado -> Continua
	- Não Instalado
		- Instala o PostgreSQL-Server
		- Dependências
		- Cria um novo PostgreSQL Database Cluster
		- Atribui  uma senha para o usuário postgres
 - Instalação do Bacula
 - Desabilita o SELinux
 - Versão 7.4.4
 - Compila
 - Instala
 - Cria DB bacula e atribui as permissões para o bacula no PostgreSQL
 - Prepara os serviços do bacula(Dir, FD e SD), para inicialização junto ao sistema
 - Libera a execução do bacula e bacula-client no Firewall
 - Altera parâmetro de segurança(md5) no pg_hba.conf do PostgreSQL


2. (Fase de Testes) Instalação do Cliente
---------------------------------------------------------------


3. Instalação do Webmin
--------------------------------
- Realiza o Download do pacote webmin
- Instala dependências para integração do webmin e bacula
- Instala o webmin
- Libera execução do webmin no Firewall


4. Instalação do Webacula
----------------------------------
- Instala um Fork do Webacula(Wnaderlei Huttel)
- Realiza o Download do Webacula
- Instala ambiente web e dependências
- Realiza configurações nos arquivos db.conf e config.ini
- Prepara o serviço httpd para inicializar junto ao OS
- Libera execução do httpd no Firewall

5. Limpar cache de Downloads
----------------------------------------
Remove todos os downloads efetuados.
