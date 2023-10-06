#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Upgrade_phpMyAdmin() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${wwwroot_dir}/default/phpMyAdmin" ] && echo "${CWARNING}phpMyAdmin is not installed on your system! ${CEND}" && exit 1
  OLD_phpmyadmin_ver=`grep Version ${wwwroot_dir}/default/phpMyAdmin/README | awk '{print $2}'`
  Latest_phpmyadmin_ver=`curl --connect-timeout 2 -m 3 -s https://www.phpmyadmin.net/files/ | awk -F'>|<' '/\/files\/[0-9]/{print $5}' | head -1`
  Latest_phpmyadmin_ver=${Latest_phpmyadmin_ver:-5.0.4}
  echo "Current phpMyAdmin Version: ${CMSG}${OLD_phpmyadmin_ver}${CEND}"
  while :; do echo
    [ "${phpmyadmin_flag}" != 'y' ] && read -e -p "Please input upgrade phpMyAdmin Version(default: ${Latest_phpmyadmin_ver}): " NEW_phpmyadmin_ver
    NEW_phpmyadmin_ver=${NEW_phpmyadmin_ver:-${Latest_phpmyadmin_ver}}
    if [ "${NEW_phpmyadmin_ver}" != "${OLD_phpmyadmin_ver}" ]; then
      [ ! -e "phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz" ] && wget --no-check-certificate -c https://files.phpmyadmin.net/phpMyAdmin/${NEW_phpmyadmin_ver}/phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz > /dev/null 2>&1
      if [ -e "phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz" ]; then
        echo "Download [${CMSG}phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}phpMyAdmin version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade phpMyAdmin version is the same as the old version${CEND}"
      exit
    fi
  done

  if [ -e "phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz" ]; then
    echo "[${CMSG}phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz${CEND}] found"
    if [ "${phpmyadmin_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages.tar.gz
    rm -rf ${wwwroot_dir}/default/phpMyAdmin
    /bin/mv phpMyAdmin-${NEW_phpmyadmin_ver}-all-languages ${wwwroot_dir}/default/phpMyAdmin
    /bin/cp ${wwwroot_dir}/default/phpMyAdmin/{config.sample.inc.php,config.inc.php}
    mkdir ${wwwroot_dir}/default/phpMyAdmin/{upload,save}
    sed -i "s@UploadDir.*@UploadDir'\] = 'upload';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    sed -i "s@SaveDir.*@SaveDir'\] = 'save';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    sed -i "s@host'\].*@host'\] = '127.0.0.1';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    sed -i "s@blowfish_secret.*;@blowfish_secret\'\] = \'$(cat /dev/urandom | head -1 | base64 | head -c 45)\';@" ${wwwroot_dir}/default/phpMyAdmin/config.inc.php
    chown -R ${run_user}:${run_group} ${wwwroot_dir}/default/phpMyAdmin
    echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_phpmyadmin_ver${CEND} to ${CWARNING}$NEW_phpmyadmin_ver${CEND}"
  fi
  popd > /dev/null
}
