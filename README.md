Script de Instalação do Bacula e Ferramentas Auxiliares
==============================================

Pré-requisitos
--------------
 Instalação básica do OS com GUI(opcional) para utilização do BAT (bacula administration tools)    
 Partição primaria /backup com espaço suficiente para armazenamento dos volumes de backup
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

1. Instalação do Servidor Bacula
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


2. Instalação Apenas do Cliente
---------------------------------------------------------------
Esta opção deverá ser utilizada apenas para instalação do cliente não executá-la na servidor de backup bacula(Director)


3. Instalação do Webmin
--------------------------------
Webmin é uma interface web para administração do seu servidor ,por exemplo: Você pode configurar contas de usuário, configurar um Servidor Apache, um Servidor de DNS, compartilhamento de arquivos com Samba, entres outros serviços. O Webmin remove a necessidade de editar manualmente arquivos de configuração.
Neste caso o Webmin ira ser utilizado para configurar graficamente o Bacula

- Realiza o Download do pacote webmin
- Instala dependências para integração do webmin e bacula
- Instala o webmin
- Libera execução do webmin no Firewall


4. Instalação do Webacula
----------------------------------
Webacula  Web + Bacula - web interface para o sistema de backup Bacula.

- Instala um Fork do Webacula(Wnaderlei Huttel)
- Realiza o Download do Webacula
- Instala ambiente web e dependências
- Realiza configurações nos arquivos db.conf e config.ini
- Prepara o serviço httpd para inicializar junto ao OS
- Libera execução do httpd no Firewall

5. Instalação do Bacula-Web
----------------------------------
Bacula-Web é uma ferramenta baseada na Web de relatórios e monitoramento que fornece informações úteis sobre a sua infraestrutura Bacula como jobs, pools, volumes, logs de tarefas, clientes e relatórios de jobs de backup e muito mais ...
Bacula-Web é livre (como um pássaro) e liberado sob o termo da licença GPL v 2.0.

- Realiza o Download do Bacula-Web
- Instala ambiente web e dependências
- Realiza configurações nos arquivos 
- Prepara o serviço httpd para inicializar junto ao OS
- Libera execução do httpd no Firewall

6. Instalação do Baculum(Bacula-GUI)
----------------------------------
Baculum é uma interface Bacula baseada na Web, que permite várias funções de administração Bacula.

Esses incluem:

      Execução de trabalhos Bacula (backup, restore, verify ...)
      Monitor Bacula serviços
      Console Bacula disponível via interface web
      Suporte para consoles personalizados e restritos (funcionalidade ACL da console)
      Gestão de volumes incluindo a rotulagem de novos volumes
      Gráficos de fácil utilização Operações básicas do daemon de armazenamento em volumes (montagem, desmontagem, ações de liberação)
      Assistente de configuração e restauração fácil de usar


- Realiza o Download do Baculum(Bacula-GUI)
- Instala ambiente web e dependências
- Realiza configurações nos arquivos em sudoers, php.ini e host do Apache
- Prepara o serviço httpd para inicializar junto ao OS
- Libera execução do httpd no Firewall



7. Limpar cache de Downloads
----------------------------------------
Remove todos os downloads efetuados.
