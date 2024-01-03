#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Upgrade_OneinStack() {
  pushd ${oneinstack_dir} > /dev/null
  Latest_OneinStack_MD5=$(curl --connect-timeout 3 -m 5 -s ${mirror_link}/md5sum.txt | grep oneinstack.tar.gz | awk '{print $1}')
  [ ! -e README.md ] && ois_flag=n
  if [ "${oneinstack_md5}" != "${Latest_OneinStack_MD5}" ]; then
    /bin/mv options.conf /tmp
    sed -i '/oneinstack_dir=/d' /tmp/options.conf
    [ -e /tmp/oneinstack.tar.gz ] && rm -rf /tmp/oneinstack.tar.gz
    wget --no-check-certificate -qc ${mirror_link}/oneinstack.tar.gz -O /tmp/oneinstack.tar.gz
    if [ -n "`echo ${oneinstack_dir} | grep lnmp`" ]; then
      tar xzf /tmp/oneinstack.tar.gz -C /tmp
      /bin/cp -R /tmp/oneinstack/* ${oneinstack_dir}/
      /bin/rm -rf /tmp/oneinstack
    else
      tar xzf /tmp/oneinstack.tar.gz -C ../
    fi
    IFS=$'\n'
    for L in `grep -vE '^#|^$' /tmp/options.conf`
    do
      IFS=$IFS_old
      Key="`echo ${L%%=*}`"
      Value="`echo ${L#*=}`"
      sed -i "s|^${Key}=.*|${Key}=${Value}|" ./options.conf
    done
    rm -rf /tmp/{oneinstack.tar.gz,options.conf}
    [ "${ois_flag}" == "n" ] && rm -f ss.sh LICENSE README.md
    sed -i "s@^oneinstack_md5=.*@oneinstack_md5=${Latest_OneinStack_MD5}@" ./options.conf
    if [ -e "change_jdk_version.sh" ]; then
      rm -f change_jdk_version.sh
      wget -qc ${mirror_link}/scripts/change_jdk_version.sh
      chmod +x change_jdk_version.sh
    fi
    if [ -e "${php_install_dir}/sbin/php-fpm" ]; then
      [ -n "`grep ^cgi.fix_pathinfo=0 ${php_install_dir}/etc/php.ini`" ] && sed -i 's@^cgi.fix_pathinfo.*@;&@' ${php_install_dir}/etc/php.ini
      [ -e "/usr/local/php53/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php53/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php54/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php54/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php55/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php55/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php56/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php56/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php70/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php70/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php71/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php71/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php72/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php72/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php73/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php73/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php74/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php74/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php80/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php80/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php81/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php81/etc/php.ini 2>/dev/null
      [ -e "/usr/local/php82/etc/php.ini" ] && sed -i 's@^cgi.fix_pathinfo=0@;&@' /usr/local/php82/etc/php.ini 2>/dev/null
    fi
    [ -e "/lib/systemd/system/php-fpm.service" ] && { sed -i 's@^PrivateTmp.*@#&@g' /lib/systemd/system/php-fpm.service; systemctl daemon-reload; }
    echo
    echo "${CSUCCESS}Congratulations! OneinStack upgrade successful! ${CEND}"
    echo
  else
    echo "${CWARNING}Your OneinStack already has the latest version or does not need to be upgraded! ${CEND}"
  fi
  [ ! -e "${oneinstack_dir}/options.conf" ] && [ -e "/tmp/options.conf" ] && /bin/cp /tmp/options.conf ${oneinstack_dir}/options.conf
  popd > /dev/null
}
