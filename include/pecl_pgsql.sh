#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_pecl_pgsql() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    tar xzf php-${PHP_detail_ver}.tar.gz
    pushd php-${PHP_detail_ver}/ext/pgsql > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-pgsql=${pgsql_install_dir} --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    pushd php-${PHP_detail_ver}/ext/pdo_pgsql > /dev/null
    ${php_install_dir}/bin/phpize
    ./configure --with-pdo-pgsql=${pgsql_install_dir} --with-php-config=${php_install_dir}/bin/php-config
    make -j ${THREAD} && make install
    popd > /dev/null
    if [ -f "${phpExtensionDir}/pgsql.so" -a -f "${phpExtensionDir}/pdo_pgsql.so" ]; then
      echo 'extension=pgsql.so' > ${php_install_dir}/etc/php.d/07-pgsql.ini
      echo 'extension=pdo_pgsql.so' >> ${php_install_dir}/etc/php.d/07-pgsql.ini
      echo "${CSUCCESS}PHP pgsql module installed successfully! ${CEND}"
      rm -rf php-${PHP_detail_ver}
    else
      echo "${CFAILURE}PHP pgsql module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    fi
    popd > /dev/null
  fi
}

Uninstall_pecl_pgsql() {
  if [ -e "${php_install_dir}/etc/php.d/07-pgsql.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/07-pgsql.ini
    echo; echo "${CMSG}PHP pgsql module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP pgsql module does not exist! ${CEND}"
  fi
}
