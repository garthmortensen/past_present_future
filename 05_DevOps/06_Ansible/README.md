# AWS Ansible

2019.11.10
Garth Mortensen

## Background

This is about the configuration of applications, servers and server configurations on things like EC2 instances. You can automate an entire fleet of servers with tools like Ansible. We can also manage the automation scripts with version control. 

Taking this route, remember that there's always a trade-off between _deployment speed_ and _risk_.

 [Ansible](https://www.ansible.com/) is a free software tool, now acquired by Red Hat. It's a push-based tool. It uses YAML to describe the server configuration, using a script called a _playbook_. The control application must run on UNIX/Linux system. Ansible will shell into a server and run all commands to configure the hardware. 

<img src="https://cdn2.hubspot.net/hubfs/4682592/Logo-Red_Hat-Ansible-A-Reverse-SVG.svg" alt="Ansible Logo" style="zoom:33%;" />

Playbooks are a set of tasks you want Ansible to perform. A set of tasks pertain to a certain goal, such as install and configure a webserver on a server. You create a play to go about installing and configuring the nginx webserver. 

* Playbooks contain Plays

* Plays contain 1+ Tasks

* Each Task calls a Module. 

* Modules start/stop server, etc. These are like shell commands.

### Example Playbook

```yaml
--- # YAML files start with 3 dash
- hosts: webservers # this is a play in an array/list (starts with -)
  vars:
    http_port: 80
    max_clients: 200
  remote_user: root
  tasks: # each task starts with a name, and calls a module
  - name: ensure apache is at the latest version # names are useful for debugging
    yum: # yum module installs httpd, using latest version
      name: httpd
      state: latest
  - name: write the apache config file
    template:
      src: /srv/httpd.j2
      dest: /etc/httpd.conf
    notify: # After above runs, it triggers the handler
    - restart apache
  - name: ensure apache is running
    service:
      name: httpd
      state: started
  handlers: # Notify triggers this
    - name: restart apache
      service:
        name: httpd
        state: restarted
... # Optional: YAML files end with elipses
```

## Begin

Here, I use a predefined Amazon CloudFormation **AnsibleSystems.json** template to define the desired infrastructure. CloudFormation will automatically install and configure Ansible on the management server.

It’s very common to use a small script to bootstrap configuration management software on a new system. Ansible can then be used to install and configure other software packages.

#### Launch Stack

In us-east-1a, AWS Cloudformation -> Create Stack -> reference AnsibleSystems URL. **Note:** Uploading the file does not work. It results in a stack rollback.

<img src="C:\Users\grm\Google Drive\aStThomas\08DevOps\Assignments\09_hw5\template1-designer.png" alt="Stack" style="zoom:50%;" />

##### Input parameters

Stack name =  ansiblestack2

KeyName = dropdown list

YourIp =  24.245.43.210 /32 (variable)

Create Stack

#### Test Ansible

SSH into EC2 mgmt1

Make directory

``` shell
mkdir assignment5
```

Enter dir

```shell
cd assignment5/
```

Create repo

```shell
git init
```

Jump to root dir

```shell
cd ../../../
```

Cd to ansible

```shell
cd etc/ansible/
```

Check folder content

```shell
ls -la
```

Look at hosts file content

```shell
cat hosts
```

Return:

>web1 ansible_host=10.0.0.159 ansible_user=ec2-user ansible_ssh_private_key_file=/home/ec2-user/.ssh/web1-key.pem
>database1 ansible_host=10.0.0.198 ansible_user=ec2-user ansible_ssh_private_key_file=/home/ec2-user/.ssh/database1-key.pem

Check that Ansible can access all hosts.

```shell
ansible all -m ping
```

Return:

> web1 | SUCCESS => {
>     "changed": false,
>     "ping": "pong"
> }
> database1 | SUCCESS => {
>     "changed": false,
>     "ping": "pong"
> }

Pong = good!

#### Configure Servers

Look at the facts that Ansible can collect from a remote host

```shell
ansible web1 -m setup
```

Much text returns. Return to your user directory.

```shell
cd ~/assignment5
```

Create the playbook.

```shell
touch playbook.yml
nano playbook.yml
```

#### Create Playbook Code

Write code to perform the on **all hosts**,

- [x] Update all the current software packages on the system.
- [x] Create a variable called administrator_name with a value of corpadmin in the play.
- [x] **Create a user with the value of the administrator_name variable on each system with a password of your choosing.**

On **web1**, perform the following,

- [x] Install the Nginx server package.

- [x] Copy the following default.conf.j2 template to the system
  directory /etc/nginx/conf.d/default.conf substituting the text example.com with the fully-qualified domain name (fqdn) of the webserver (using a fact variable). Note, the fqdn of the server isn’t web1. AWS automatically generates a domain address based on the private IP address of the instance.

- [x] Ensure the nginx service is running and will automatically start during the system boot.

On **database1**, perform the following,

- [x] Install the mysql server package.
- [x] Configure the system to ensure mysql is running and will automatically start during the system boot.
- [x] **Use a loop to create 5 directories called:**
  o /var/data/client1
  o /var/data/client2
  o /var/data/client3
  o /var/data/client4
  o /var/data/client5

The final code is as follows:

```yaml
---
# this can be run using Ansible on a linux/unix ec2
- name: all server setup
  hosts: all
  become: yes
  vars: 
    administrator_name: corpadmin
  tasks:
    - name: Update all current software packages
      yum: name='*' state=latest
    - name: Create user administrator_name variable on each system with a custom password
      user: 
        name: "{{administrator_name}}"
        password: 'ilovecats'
- name: install nginx
  hosts: web1
  become: yes
  tasks:
    - name: install nginx
      yum: name=nginx state=present
    - name: ensure nginx is up and running
      service: name=nginx enabled=yes
    - name: create directory
      file: path=/etc/ngingx/conf.d/default.conf state=directory
    - name: copy j2 template
      template: src=default.conf.js dest=/etc/ngingx/conf.d/default.conf
- name: db1 server setup
  hosts: database1
  become: yes
  tasks: 
    - name: install mysql-server
      yum: name=mysql-server state=present
    - name: ensure mysql is up and running
      service: name=mysqld enabled=yes  
    - name: use a loop to create 5 directories
      file:
        dest: "/var/data/client{{ item }}"
        state: directory
      with_sequence: start=1 end=5 stride=1
```

#### Create config

default.conf.j2

```mark
server {
	listen 80;
	server_name {{ansible_fqdn}};
	location / {
		root /var/www/{{ansible_fqdn}}/public_html/;
		index index.html index.htm;
	}
}
```

Run playbook with -v for verbose, so that you can see the output.

```shell 
ansible-playbook -v playbook.yml
```

## Upload to Existing Repo

``` bash
git status
git add .
git status
git commit -m "adding all"
git remote add origin https://github.com/UST-SEIS665/hw05-gmort01.git
git push -u origin master
git status
git exit
exit
history
exit
```

The instance is now shut down. Delete the entire stack from AWS. You may need to delete the S3 bucket file before you can delete the stack, however.

## History

Enable timestamp for history using [this]( https://askubuntu.com/questions/391082/how-to-see-time-stamps-in-bash-history ) guide:

``` bash
HISTTIMEFORMAT="%d/%m/%y %T "
history
```

Which displays the following:

``` bash
    1  16/11/19 14:57:21 mkdir assignment5
    2  16/11/19 14:57:21 cd assignment5/
    3  16/11/19 14:57:21 git init
    4  16/11/19 14:57:21 cd ../../../
    5  16/11/19 14:57:21 pwd
    6  16/11/19 14:57:21 cd etc/ansible/hosts
    7  16/11/19 14:57:21 cd etc/ansible/
    8  16/11/19 14:57:21 ls -la
    9  16/11/19 14:57:21 cat hosts
   10  16/11/19 14:57:21 ansible all -m ping
   11  16/11/19 14:57:21 ansible web1 -m setup
   12  16/11/19 14:57:21 cd ~
   13  16/11/19 14:57:21 cd ../
   14  16/11/19 14:57:21 cd ~/assignment5/
   15  16/11/19 14:57:21 ansible playbook playbook.yml -v
   16  16/11/19 14:57:21 ls -la
   17  16/11/19 14:57:21 pws
   18  16/11/19 14:57:21 pwd
   19  16/11/19 14:57:21 cd ~
   20  16/11/19 14:57:21 pwd
   21  16/11/19 14:57:21 ls -la
   22  16/11/19 14:57:21 cd assignment5/
   23  16/11/19 14:57:21 ls -la
   24  16/11/19 14:57:21 touch playbook.yml
   25  16/11/19 14:57:21 nano playbook.yml
   26  16/11/19 14:57:21 cat playbook.yml
   27  16/11/19 14:57:21 ansible playbook playbook.yml -v
   28  16/11/19 14:57:21 nano ass
   29  16/11/19 14:57:21 nano playbook.yml
   30  16/11/19 14:57:21 ansible playbook playbook.yml -v
   31  16/11/19 14:57:21 nano
   32  16/11/19 14:57:21 nano playbook.yml
   33  16/11/19 14:57:21 ansible playbook playbook.yml -v
   34  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   35  16/11/19 14:57:21 nano playbook.yml
   36  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   37  16/11/19 14:57:21 nano playbook.yml
   38  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   39  16/11/19 14:57:21 nano playbook.yml
   40  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   41  16/11/19 14:57:21 nano playbook.yml
   42  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   43  16/11/19 14:57:21 nano playbook.yml
   44  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   45  16/11/19 14:57:21 nano playbook.yml
   46  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   47  16/11/19 14:57:21 nano playbook.yml
   48  16/11/19 14:57:21 nano playbook.yml
   49  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   50  16/11/19 14:57:21 nano playbook.yml
   51  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   52  16/11/19 14:57:21 nano playbook.yml
   53  16/11/19 14:57:21 ansible-playbook playbook.yml -v
   54  16/11/19 14:57:21 nano playbook.yml
   55  16/11/19 14:57:21 ansible web1 -m setup
   56  16/11/19 14:57:21 ansible database1 -m setup
   57  16/11/19 14:57:21 nano playbook.yml
   58  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   59  16/11/19 14:57:21 nano playbook.yml
   60  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   61  16/11/19 14:57:21 nano playbook.yml
   62  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   63  16/11/19 14:57:21 nano playbook.yml
   64  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   65  16/11/19 14:57:21 nano playbook.yml
   66  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   67  16/11/19 14:57:21 nano playbook.yml
   68  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   69  16/11/19 14:57:21 nano playbook.yml
   70  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   71  16/11/19 14:57:21 nano playbook.yml
   72  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   73  16/11/19 14:57:21 nano playbook.yml
   74  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   75  16/11/19 14:57:21 nano playbook.yml
   76  16/11/19 14:57:21 rm playbook.
   77  16/11/19 14:57:21 rm playbook.yml
   78  16/11/19 14:57:21 touch playbook.yml
   79  16/11/19 14:57:21 nano playbook.
   80  16/11/19 14:57:21 nano playbook.yml
   81  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   82  16/11/19 14:57:21 nano playbook.yml
   83  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   84  16/11/19 14:57:21 nano playbook.yml
   85  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   86  16/11/19 14:57:21 nano playbook.yml
   87  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   88  16/11/19 14:57:21 nano playbook.yml
   89  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   90  16/11/19 14:57:21 ls -la
   91  16/11/19 14:57:21 touch default.conf.js
   92  16/11/19 14:57:21 nano default.conf.js
   93  16/11/19 14:57:21 ansible-playbook -v playbook.yml
   94  16/11/19 14:57:21 nano default.conf.js
   95  16/11/19 14:57:21 nano playbook.y
   96  16/11/19 14:57:21 nano playbook.yml
   97  16/11/19 14:57:21 cd /etc
   98  16/11/19 14:57:21 cd ../
   99  16/11/19 14:57:21 ls -l
  100  16/11/19 14:57:21 cd ~/assignment5/
  101  16/11/19 14:57:21 nano playbook.yml
  102  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  103  16/11/19 14:57:21 cd /etc
  104  16/11/19 14:57:21 ls =la
  105  16/11/19 14:57:21 ls -l
  106  16/11/19 14:57:21 cd ~/assignment5/
  107  16/11/19 14:57:21 nano playbook.yml
  108  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  109  16/11/19 14:57:21 nano playbook.yml
  110  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  111  16/11/19 14:57:21 ls -l
  112  16/11/19 14:57:21 cd ../../../../
  113  16/11/19 14:57:21 ls
  114  16/11/19 14:57:21 cd etc/
  115  16/11/19 14:57:21 ls -l
  116  16/11/19 14:57:21 cd ~/assignment5/
  117  16/11/19 14:57:21 nano playbook.yml
  118  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  119  16/11/19 14:57:21 nano playbook.yml
  120  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  121  16/11/19 14:57:21 nano playbook.yml
  122  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  123  16/11/19 14:57:21 nano playbook.yml
  124  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  125  16/11/19 14:57:21 nano playbook.yml
  126  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  127  16/11/19 14:57:21 nano playbook.yml
  128  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  129  16/11/19 14:57:21 nano playbook.yml
  130  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  131  16/11/19 14:57:21 nano playbook.yml
  132  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  133  16/11/19 14:57:21 nano playbook.yml
  134  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  135  16/11/19 14:57:21 nano playbook.yml
  136  16/11/19 14:57:21 nano aaa.yml
  137  16/11/19 14:57:21 ansible-playbook -v aaa.yml
  138  16/11/19 14:57:21 nano playbook.yml
  139  16/11/19 14:57:21 ansible-playbook -v aaa.yml
  140  16/11/19 14:57:21 nano playbook.yml
  141  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  142  16/11/19 14:57:21 nano playbook.yml
  143  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  144  16/11/19 14:57:21 nano playbook.yml
  145  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  146  16/11/19 14:57:21 nano playbook.yml
  147  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  148  16/11/19 14:57:21 nano playbook.yml
  149  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  150  16/11/19 14:57:21 nano playbook.yml
  151  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  152  16/11/19 14:57:21 nano playbook.yml
  153  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  154  16/11/19 14:57:21 nano playbook.yml
  155  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  156  16/11/19 14:57:21 nano playbook.yml
  157  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  158  16/11/19 14:57:21 nano playbook.yml
  159  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  160  16/11/19 14:57:21 nano playbook.yml
  161  16/11/19 14:57:21 ansible-playbook -v playbook.yml
  162  16/11/19 14:57:21 exit
  163  16/11/19 14:57:21 pwd
  164  16/11/19 14:57:21 ls -la
  165  16/11/19 14:57:21 cd assignment5/
  166  16/11/19 14:57:21 ls -la
  167  16/11/19 14:57:21 rm aaa.yml
  168  16/11/19 14:57:21 rm ilovecats
  169  16/11/19 14:57:21 rm playbook.retry
  170  16/11/19 14:57:21 ls -la
  171  16/11/19 14:57:21 cat default.conf.js
  172  16/11/19 14:57:21 cat playbook.yml
  173  16/11/19 14:57:21 clear
  174  16/11/19 14:57:21 git status
  175  16/11/19 14:57:21 git add .
  176  16/11/19 14:57:21 git status
  177  16/11/19 14:57:21 git commit -m "adding all"
  178  16/11/19 14:57:21 git remote add origin https://github.com/UST-SEIS665/hw05-gmort01.git
  179  16/11/19 14:57:21 git push -u origin master
  180  16/11/19 14:57:21 git status
  181  16/11/19 14:57:21 git exit
  182  16/11/19 14:57:21 exit
  183  16/11/19 14:57:21 history
  184  16/11/19 14:57:21 exit
  185  16/11/19 14:57:26 ls -la
  186  16/11/19 14:57:29 cd assignment5/
  187  16/11/19 14:57:33 ls -l
  188  16/11/19 14:57:38 cat playbook.yml
  189  16/11/19 15:03:30 cd ~
  190  16/11/19 15:03:47 HISTTIMEFORMAT="%d/%m/%y %T "
  191  16/11/19 15:03:53 history
[ec2-user@ip-10-0-0-43 ~]$
```

