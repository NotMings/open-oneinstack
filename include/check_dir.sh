#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

# check MySQL dir
[ -d "${mysql_install_dir}/support-files" ] && { db_install_dir=${mysql_install_dir}; db_data_dir=${mysql_data_dir}; }
[ -d "${mariadb_install_dir}/support-files" ] && { db_install_dir=${mariadb_install_dir}; db_data_dir=${mariadb_data_dir}; }
[ -d "${percona_install_dir}/support-files" ] && { db_install_dir=${percona_install_dir}; db_data_dir=${percona_data_dir}; }

# check Nginx dir
[ -e "${nginx_install_dir}/sbin/nginx" ] && web_install_dir=${nginx_install_dir}
[ -e "${tengine_install_dir}/sbin/nginx" ] && web_install_dir=${tengine_install_dir}
[ -e "${openresty_install_dir}/nginx/sbin/nginx" ] && web_install_dir=${openresty_install_dir}/nginx
