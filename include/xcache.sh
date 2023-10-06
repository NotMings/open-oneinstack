#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_XCache() {
  if [ -e "${php_install_dir}/bin/phpize" ]; then
    pushd ${oneinstack_dir}/src > /dev/null
    phpExtensionDir=$(${php_install_dir}/bin/php-config --extension-dir)
    PHP_detail_ver=$(${php_install_dir}/bin/php-config --version)
    PHP_main_ver=${PHP_detail_ver%.*}
    if [[ "${PHP_main_ver}" =~ ^5.[3-6]$ ]]; then
      tar xzf xcache-${xcache_ver}.tar.gz
      pushd xcache-${xcache_ver} > /dev/null
      ${php_install_dir}/bin/phpize
      ./configure --enable-xcache --enable-xcache-coverager --enable-xcache-optimizer --with-php-config=${php_install_dir}/bin/php-config
      make -j ${THREAD} && make install
      if [ -f "${phpExtensionDir}/xcache.so" ]; then
        /bin/cp -R htdocs ${wwwroot_dir}/default/xcache
        popd > /dev/null
        chown -R ${run_user}:${run_group} ${wwwroot_dir}/default/xcache
        touch /tmp/xcache;chown ${run_user}:${run_group} /tmp/xcache
        let xcacheCount="${CPU}+1"
        let xcacheSize="${Memory_limit}/2"
        cat > ${php_install_dir}/etc/php.d/04-xcache.ini << EOF
[xcache-common]
extension=xcache.so
[xcache.admin]
xcache.admin.enable_auth=On
xcache.admin.user=admin
xcache.admin.pass="${xcachepwd_md5}"

[xcache]
xcache.size=${xcacheSize}M
xcache.count=${xcacheCount}
xcache.slots=8K
xcache.ttl=3600
xcache.gc_interval=300
xcache.var_size=4M
xcache.var_count=${xcacheCount}
xcache.var_slots=8K
xcache.var_ttl=0
xcache.var_maxttl=0
xcache.var_gc_interval=300
xcache.test=Off
xcache.readonly_protection=Off
xcache.shm_scheme=mmap
xcache.mmap_path=/tmp/xcache
xcache.coredump_directory=
xcache.cacher=On
xcache.stat=On
xcache.optimizer=Off

[xcache.coverager]
; enabling this feature will impact performance
; enable only if xcache.coverager == On && xcache.coveragedump_directory == "non-empty-value"
; enable coverage data collecting and xcache_coverager_start/stop/get/clean() functions
xcache.coverager = Off
xcache.coverager_autostart = On
xcache.coveragedump_directory = ""
EOF
        echo "${CSUCCESS}PHP xcache module installed successfully! ${CEND}"
        rm -rf xcache-${xcache_ver}
      else
        echo "${CFAILURE}PHP xcache module install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
      fi
    else
      echo; echo "${CWARNING}Your php ${PHP_detail_ver} does not support XCache! ${CEND}";
    fi
    popd > /dev/null
  fi
}

Uninstall_XCache() {
  if [ -e "${php_install_dir}/etc/php.d/04-xcache.ini" ]; then
    rm -rf ${php_install_dir}/etc/php.d/04-xcache.ini ${wwwroot_dir}/default/xcache /tmp/xcache
    echo; echo "${CMSG}PHP xcache module uninstall completed${CEND}"
  else
    echo; echo "${CWARNING}PHP xcache module does not exist! ${CEND}"
  fi
}
