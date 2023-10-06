#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_Tengine() {
  pushd ${oneinstack_dir}/src > /dev/null
  id -g ${run_group} >/dev/null 2>&1
  [ $? -ne 0 ] && groupadd ${run_group}
  id -u ${run_user} >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -g ${run_group} -M -s /sbin/nologin ${run_user}

  tar xzf pcre-${pcre_ver}.tar.gz
  tar xzf tengine-${tengine_ver}.tar.gz
  tar xzf openssl-${openssl11_ver}.tar.gz
  pushd tengine-${tengine_ver} > /dev/null
  # Modify Tengine version
  #sed -i 's@TENGINE "/" TENGINE_VERSION@"Tengine/unknown"@' src/core/nginx.h

  [ ! -d "${tengine_install_dir}" ] && mkdir -p ${tengine_install_dir}
  ./configure --prefix=${tengine_install_dir} --user=${run_user} --group=${run_group} --with-http_v2_module --with-http_ssl_module --with-stream --with-stream_ssl_preread_module --with-stream_ssl_module --with-http_gzip_static_module --with-http_realip_module --with-http_flv_module --with-http_mp4_module --with-openssl=../openssl-${openssl11_ver} --with-pcre=../pcre-${pcre_ver} --with-pcre-jit --with-jemalloc ${nginx_modules_options}
  make && make install
  if [ -e "${tengine_install_dir}/conf/nginx.conf" ]; then
    popd > /dev/null
    rm -rf pcre-${pcre_ver} openssl-${openssl11_ver} tengine-${tengine_ver}
    echo "${CSUCCESS}Tengine installed successfully! ${CEND}"
  else
    rm -rf ${tengine_install_dir}
    echo "${CFAILURE}Tengine install failed, Please Contact the author! ${CEND}"
    kill -9 $$; exit 1;
  fi

  [ -z "`grep ^'export PATH=' /etc/profile`" ] && echo "export PATH=${tengine_install_dir}/sbin:\$PATH" >> /etc/profile
  [ -n "`grep ^'export PATH=' /etc/profile`" -a -z "`grep ${tengine_install_dir} /etc/profile`" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${tengine_install_dir}/sbin:\1@" /etc/profile
  . /etc/profile

  /bin/cp ../init.d/nginx.service /lib/systemd/system/
  sed -i "s@/usr/local/nginx@${tengine_install_dir}@g" /lib/systemd/system/nginx.service
  systemctl enable nginx

  mv ${tengine_install_dir}/conf/nginx.conf{,_bk}
  if [ "${apache_flag}" == 'y' ] || [ -e "${apache_install_dir}/bin/httpd" ]; then
    /bin/cp ../config/nginx_apache.conf ${tengine_install_dir}/conf/nginx.conf
  elif { [[ ${tomcat_option} =~ ^[1-4]$ ]] || [ -e "${tomcat_install_dir}/conf/server.xml" ]; } && { [[ ! ${php_option} =~ ^[1-9]$|^1[0-1]$ ]] && [ ! -e "${php_install_dir}/bin/php" ]; }; then
    /bin/cp ../config/nginx_tomcat.conf ${tengine_install_dir}/conf/nginx.conf
  else
    /bin/cp ../config/nginx.conf ${tengine_install_dir}/conf/nginx.conf
    [[ "${php_option}" =~ ^[1-9]$|^1[0-1]$ ]] && [ -z "`grep '/php-fpm_status' ${tengine_install_dir}/conf/nginx.conf`" ] &&  sed -i "s@index index.html index.php;@index index.html index.php;\n    location ~ /php-fpm_status {\n        #fastcgi_pass remote_php_ip:9000;\n        fastcgi_pass unix:/dev/shm/php-cgi.sock;\n        fastcgi_index index.php;\n        include fastcgi.conf;\n        allow 127.0.0.1;\n        deny all;\n        }@" ${tengine_install_dir}/conf/nginx.conf
  fi
  cat > ${tengine_install_dir}/conf/proxy.conf << EOF
proxy_connect_timeout 300s;
proxy_send_timeout 900;
proxy_read_timeout 900;
proxy_buffer_size 32k;
proxy_buffers 4 64k;
proxy_busy_buffers_size 128k;
proxy_redirect off;
proxy_hide_header Vary;
proxy_set_header Accept-Encoding '';
proxy_set_header Referer \$http_referer;
proxy_set_header Cookie \$http_cookie;
proxy_set_header Host \$host;
proxy_set_header X-Real-IP \$remote_addr;
proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto \$scheme;
EOF
  sed -i "s@/data/wwwroot/default@${wwwroot_dir}/default@" ${tengine_install_dir}/conf/nginx.conf
  sed -i "s@/data/wwwlogs@${wwwlogs_dir}@g" ${tengine_install_dir}/conf/nginx.conf
  sed -i "s@^user www www@user ${run_user} ${run_group}@" ${tengine_install_dir}/conf/nginx.conf

  # logrotate nginx log
  cat > /etc/logrotate.d/nginx << EOF
${wwwlogs_dir}/*nginx.log {
  daily
  rotate 5
  missingok
  dateext
  compress
  notifempty
  sharedscripts
  postrotate
    [ -e /var/run/nginx.pid ] && kill -USR1 \`cat /var/run/nginx.pid\`
  endscript
}
EOF
  popd > /dev/null
  ldconfig
  systemctl start nginx
}
