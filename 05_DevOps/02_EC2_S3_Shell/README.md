Overview
This is an exploration on how to use AWS S3 buckets, IAW

This repo houses 2 scripts, and 1 output file.

Scripts (2)
provision.sh
This script is an automation process with starting/stopping an nginx "engine X" webserver.

Initialization sequence a. update all system packages b. install nginx c. config nginx to autostart on reboot d. copy index.html from s3 to directory e. start nginx service
Closing sequence a. Stop nginx service b. delete nginx root directory files c. uninstall nginx
Display version
Display the command help
instancedata.sh
This script pulls metadata from aws and writes it to output file metadata.txt.

append hostname to txt
append identity and access management to txt
append security-groups to txt