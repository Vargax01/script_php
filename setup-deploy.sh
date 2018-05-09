#!/bin/bash
git_url=$1
cont=`echo $git_url | grep -o / | wc -l`
cont=$(($cont+1))
carpeta_proyecto=`echo $git_url | cut -d"/" -f$cont`
if [ -d /var/www/$carpeta_proyecto ];
then
	sudo rm -r /var/www/$carpeta_proyecto
fi
git clone $git_url /var/www/$carpeta_proyecto
sudo chmod -R 777 /var/www/$carpeta_proyecto
project_name=$carpeta_proyecto
dns=`/home/ubuntu/script_php/json-bash.sh DNS $project_name | cut -d" " -f2`
site_apache=`/home/ubuntu/script_php/json-bash.sh SITE_APACHE $project_name | cut -d" " -f2`
cp /home/ubuntu/script_php/template-site.conf /home/ubuntu/script_php/template-site.conf.tmp
sed -i 's/$PROJECT_NAME/'$project_name'/g' /home/ubuntu/script_php/template-site.conf.tmp
sed -i 's/$SERVER_NAME/'$dns'/g' /home/ubuntu/script_php/template-site.conf.tmp
sed -i 's/$ERROR_LOG/'$project_name'_error.log/g' /home/ubuntu/script_php/template-site.conf.tmp
sed -i 's/$ACCESS_LOG/'$project_name'_access.log/g' /home/ubuntu/script_php/template-site.conf.tmp
if [ ! -f /etc/apache2/sites-enabled/$site_apache ];
then
	sudo cp /home/ubuntu/script_php/template-site.conf.tmp /etc/apache2/sites-enabled/$site_apache
fi
sudo a2ensite $site_apache
sudo systemctl restart apache2
