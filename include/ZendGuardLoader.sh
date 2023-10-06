#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_ZendGuardLoader() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    phpExtensionDir=`${php_install_dir}/bin/php-config --extension-dir`
    [ ! -d "${phpExtensionDir}" ] && mkdir -p ${phpExtensionDir}
    if [ -n "`echo $phpExtensionDir | grep 'non-zts'`" ] && [ "${armplatform}" != 'y' ]; then
      case "${PHP_main_ver}" in
        5.6)
          tar xzf zend-loader-php5.6-linux-x86_64.tar.gz
          /bin/mv zend-loader-php5.6-linux-x86_64/ZendGuardLoader.so ${phpExtensionDir}
          rm -rf zend-loader-php5.6-linux-x86_64
          ;;
        5.5)
          tar xzf zend-loader-php5.5-linux-x86_64.tar.gz
          /bin/mv zend-loader-php5.5-linux-x86_64/ZendGuardLoader.so ${phpExtensionDir}
          rm -rf zend-loader-php5.5-linux-x86_64
          ;;
        5.4)
          tar xzf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz
          /bin/mv ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64/php-5.4.x/ZendGuardLoader.so ${phpExtensionDir}
          rm -rf ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64
          ;;
        5.3)
          tar xzf ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz
          /bin/mv ZendGuardLoader-php-5.3-linux-glibc23-x86_64/php-5.3.x/ZendGuardLoader.so ${phpExtensionDir}
          rm -rf ZendGuardLoader-php-5.3-linux-glibc23-x86_64
          ;;
        *)
          echo "${CWARNING}Your php ${PHP_detail_ver} does not support ZendGuardLoader! ${CEND}";
          ;;
      esac

      if [ -f "${phpExtensionDir}/ZendGuardLoader.so" ]; then
        chmod 644 ${phpExtensionDir}/ZendGuardLoader.so
        cat > ${php_install_dir}/etc/php.d/01-ZendGuardLoader.ini<< EOF
[Zend Guard Loader]
zend_extension=${phpExtensionDir}/ZendGuardLoader.so
zend_loader.enable=1
zend_loader.disable_licensing=0
zend_loader.obfuscation_level_support=3
EOF
        echo "${CSUCCESS}PHP ZendGuardLoader module installed successfully! ${CEND}"
      fi
    else
      echo "Error! Your Apache's prefork or PHP already enable thread safety or platform ${TARGET_ARCH} does not support ZendGuardLoader! "
    fi
    popd > /dev/null
  fi
}

Uninstall_ZendGuardLoader() {
  if [ -e "${php_install_dir}/etc/php.d/01-ZendGuardLoader.ini" ]; then
    rm -f ${php_install_dir}/etc/php.d/01-ZendGuardLoader.ini
    echo; echo "${CMSG}PHP ZendGuardLoader module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP ZendGuardLoader module does not exist! ${CEND}"
  fi
}
