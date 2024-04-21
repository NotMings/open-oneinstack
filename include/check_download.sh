#!/bin/bash
# Author:  Alpha Eva <kaneawk AT gmail.com>
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

checkDownload() {
  pushd ${oneinstack_dir}/src > /dev/null
  # icu
  if ! command -v icu-config >/dev/null 2>&1 || icu-config --version | grep '^3.' || [ "${Ubuntu_ver}" == "20" ]; then
    echo "Download icu..."
    src_url=${mirror_link}/oneinstack/src/icu4c-${icu4c_ver}-src.tgz && Download_src
  fi

  # General system utils
  if [ "${with_old_openssl_flag}" == 'y' ]; then
    echo "Download openSSL..."
    src_url=${mirror_link}/oneinstack/src/openssl-${openssl_ver}.tar.gz && Download_src
    echo "Download cacert.pem..."
    src_url=${mirror_link}/oneinstack/src/cacert.pem && Download_src
  fi

  # openssl1.1
  if [[ ${nginx_option} =~ ^[1-3]$ ]]; then
      echo "Download openSSL1.1..."
      src_url=${mirror_link}/oneinstack/src/openssl-${openssl11_ver}.tar.gz && Download_src
  fi

  # jemalloc
  if [[ ${nginx_option} =~ ^[1-3]$ ]] || [[ "${db_option}" =~ ^[1-9]$|^1[0-2]$ ]]; then
    echo "Download jemalloc..."
    src_url=${mirror_link}/oneinstack/src/jemalloc-${jemalloc_ver}.tar.bz2 && Download_src
  fi

  # pcre
  if [[ "${nginx_option}" =~ ^[1-3]$ ]] || [ "${apache_flag}" == 'y' ]; then
    echo "Download pcre..."
    src_url=${mirror_link}/oneinstack/src/pcre-${pcre_ver}.tar.gz && Download_src
  fi

  # nginx/tengine/openresty
  case "${nginx_option}" in
    1)
      echo "Download nginx..."
      src_url=${mirror_link}/oneinstack/src/nginx-${nginx_ver}.tar.gz && Download_src
      ;;
    2)
      echo "Download tengine..."
      src_url=${mirror_link}/oneinstack/src/tengine-${tengine_ver}.tar.gz && Download_src
      ;;
    3)
      echo "Download openresty..."
      src_url=${mirror_link}/oneinstack/src/openresty-${openresty_ver}.tar.gz && Download_src
      ;;
  esac

  # if nginx_option=4 download caddy
  if [ "${nginx_option}" == '4' ]; then
    echo "Download caddy ${caddy_ver}"
    src_url=${mirror_link}/caddy/v${caddy_ver}/caddy-${caddy_ver}.tar.gz  && Download_src
  fi

  # caddy
  if [ "${caddy_flag}" == 'y' ]; then
    echo "Download caddy ${caddy_ver}"
    src_url=${mirror_link}/caddy/v${caddy_ver}/caddy-${caddy_ver}.tar.gz  && Download_src
  fi

  # apache
  if [ "${apache_flag}" == 'y' ]; then
    echo "Download apache 2.4..."
    src_url=${mirror_link}/oneinstack/src/httpd-${apache_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/apr-${apr_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/apr-util-${apr_util_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/nghttp2-${nghttp2_ver}.tar.gz && Download_src
  fi

  # tomcat
  case "${tomcat_option}" in
    1)
      echo "Download tomcat 10..."
      src_url=${mirror_link}/apache/tomcat/v${tomcat10_ver}/apache-tomcat-${tomcat10_ver}.tar.gz && Download_src
      ;;
    2)
      echo "Download tomcat 9..."
      src_url=${mirror_link}/apache/tomcat/v${tomcat9_ver}/apache-tomcat-${tomcat9_ver}.tar.gz && Download_src
      ;;
    3)
      echo "Download tomcat 8..."
      src_url=${mirror_link}/apache/tomcat/v${tomcat8_ver}/apache-tomcat-${tomcat8_ver}.tar.gz && Download_src
      ;;
    4)
      echo "Download tomcat 7..."
      src_url=${mirror_link}/apache/tomcat/v${tomcat7_ver}/apache-tomcat-${tomcat7_ver}.tar.gz && Download_src
      src_url=${mirror_link}/apache/tomcat/v${tomcat7_ver}/catalina-jmx-remote.jar && Download_src
      ;;
  esac

  # jdk apr
  if [[ "${jdk_option}"  =~ ^[1-2]$ ]]; then
    echo "Download apr..."
    src_url=${mirror_link}/oneinstack/src/apr-${apr_ver}.tar.gz && Download_src
  fi

  if [[ "${db_option}" =~ ^[1-9]$|^1[0-4]$ ]]; then
    if [[ "${db_option}" =~ ^[1,2,5,6,7,9]$|^10$ ]] && [ "${dbinstallmethod}" == "2" ]; then
      [[ "${db_option}" =~ ^[2,5,6,7]$|^10$ ]] && boost_ver=${boost_oldver}
      [[ "${db_option}" =~ ^9$ ]] && boost_ver=${boost_percona_ver}
      echo "Download boost..."
      DOWN_ADDR_BOOST=${mirror_link}/oneinstack/src
      boostVersion2=$(echo ${boost_ver} | awk -F. '{print $1"_"$2"_"$3}')
      src_url=${DOWN_ADDR_BOOST}/boost_${boostVersion2}.tar.gz && Download_src
    fi

    case "${db_option}" in
      1)
        # MySQL 8.0
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 8.0 binary package..."
          DOWN_ADDR_MYSQL=${mirror_link}/oneinstack/src
          FILE_NAME=mysql-${mysql80_ver}-linux-glibc2.12-x86_64.tar.xz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 8.0 source package..."
          DOWN_ADDR_MYSQL=https://cdn.mysql.com/Downloads/MySQL-8.0
          FILE_NAME=mysql-${mysql80_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        ;;
      2)
        # MySQL 5.7
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.7 binary package..."
          DOWN_ADDR_MYSQL=${mirror_link}/oneinstack/src
          FILE_NAME=mysql-${mysql57_ver}-linux-glibc2.12-x86_64.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.7 source package..."
          DOWN_ADDR_MYSQL=https://cdn.mysql.com/Downloads/MySQL-5.7
          FILE_NAME=mysql-${mysql57_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        ;;
      3)
        # MySQL 5.6
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.6 binary package..."
          DOWN_ADDR_MYSQL=${mirror_link}/oneinstack/src
          FILE_NAME=mysql-${mysql56_ver}-linux-glibc2.12-x86_64.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.6 source package..."
          DOWN_ADDR_MYSQL=https://cdn.mysql.com/Downloads/MySQL-5.6
          FILE_NAME=mysql-${mysql56_ver}.tar.gz
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        ;;
      4)
        # MySQL 5.5
        DOWN_ADDR_MYSQL=${mirror_link}/oneinstack/src
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download MySQL 5.5 binary package..."
          FILE_NAME=mysql-${mysql55_ver}-linux-glibc2.12-x86_64.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download MySQL 5.5 source package..."
          FILE_NAME=mysql-${mysql55_ver}.tar.gz
          src_url=${mirror_link}/oneinstack/src/mysql-5.5-fix-arm-client_plugin.patch && Download_src
        fi
        # start download
        src_url=${DOWN_ADDR_MYSQL}/${FILE_NAME} && Download_src
        ;;
      [5-8])
	case "${db_option}" in
          5)
            mariadb_ver=${mariadb1011_ver}
	    ;;
          6)
            mariadb_ver=${mariadb105_ver}
	    ;;
          7)
            mariadb_ver=${mariadb104_ver}
	    ;;
          8)
            mariadb_ver=${mariadb55_ver}
	    ;;
        esac

        if [ "${dbinstallmethod}" == '1' ]; then
          FILE_NAME=mariadb-${mariadb_ver}-linux-systemd-x86_64.tar.gz
        elif [ "${dbinstallmethod}" == '2' ]; then
          FILE_NAME=mariadb-${mariadb_ver}.tar.gz
        fi

        DOWN_ADDR_MARIADB=${mirror_link}/oneinstack/src
        echo "Download MariaDB ${FILE_NAME} package..."
        src_url=${DOWN_ADDR_MARIADB}/${FILE_NAME} && Download_src
        ;;
      9)
        # Percona 8.0
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 8.0 binary package..."
          FILE_NAME=Percona-Server-${percona80_ver}-Linux.x86_64.glibc2.28.tar.gz
          DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-8.0/Percona-Server-${percona80_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 8.0 source package..."
          FILE_NAME=percona-server-${percona80_ver}.tar.gz
          if [ "${OUTIP_STATE}"x == "China"x ]; then
            DOWN_ADDR_PERCONA=${mirror_link}/oneinstack/src
          else
            DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-8.0/Percona-Server-${percona80_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        ;;
      10)
        # Precona 5.7
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 5.7 binary package..."
          FILE_NAME=Percona-Server-${percona57_ver}-Linux.x86_64.glibc2.17.tar.gz
          DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 5.7 source package..."
          FILE_NAME=percona-server-${percona57_ver}.tar.gz
          if [ "${OUTIP_STATE}"x == "China"x ]; then
            DOWN_ADDR_PERCONA=${mirror_link}/oneinstack/src
          else
            DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-5.7/Percona-Server-${percona57_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        ;;
      11)
        # Precona 5.6
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 5.6 binary package..."
          perconaVerStr1=$(echo ${percona56_ver} | sed "s@-@-rel@")
          FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.x86_64.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 5.6 source package..."
          FILE_NAME=percona-server-${percona56_ver}.tar.gz
          if [ "${OUTIP_STATE}"x == "China"x ]; then
            DOWN_ADDR_PERCONA=${mirror_link}/oneinstack/src
          else
            DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-5.6/Percona-Server-${percona56_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        ;;
      12)
        # Percona 5.5
        if [ "${dbinstallmethod}" == '1' ]; then
          echo "Download Percona 5.5 binary package..."
          perconaVerStr1=$(echo ${percona55_ver} | sed "s@-@-rel@")
          FILE_NAME=Percona-Server-${perconaVerStr1}-Linux.x86_64.${sslLibVer}.tar.gz
          DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_ver}/binary/tarball
        elif [ "${dbinstallmethod}" == '2' ]; then
          echo "Download Percona 5.5 source package..."
          FILE_NAME=percona-server-${percona55_ver}.tar.gz
          if [ "${OUTIP_STATE}"x == "China"x ]; then
            DOWN_ADDR_PERCONA=${mirror_link}/oneinstack/src
          else
            DOWN_ADDR_PERCONA=https://downloads.percona.com/downloads/Percona-Server-5.5/Percona-Server-${percona55_ver}/source/tarball
          fi
        fi
        # start download
        src_url=${DOWN_ADDR_PERCONA}/${FILE_NAME} && Download_src
        ;;
      13)
        FILE_NAME=postgresql-${pgsql_ver}.tar.gz
        DOWN_ADDR_PGSQL_BK=${mirror_link}/oneinstack/src
        src_url=${DOWN_ADDR_PGSQL}/${FILE_NAME} && Download_src
        ;;
      14)
        # MongoDB
        echo "Download MongoDB binary package..."
        FILE_NAME=mongodb-linux-x86_64-${mongodb_ver}.tgz
        DOWN_ADDR_MongoDB=${mirror_link}/oneinstack/src
        src_url=${DOWN_ADDR_MongoDB}/${FILE_NAME} && Download_src
        ;;
    esac
  fi

  # PHP
  if [[ "${php_option}" =~ ^[1-9]$|^1[0-3]$ ]] || [[ "${mphp_ver}" =~ ^5[3-6]$|^7[0-4]$|^8[0-3]$ ]]; then
    echo "PHP common..."
    src_url=${mirror_link}/oneinstack/src/libiconv-${libiconv_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/curl-${curl_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/mhash-${mhash_ver}.tar.bz2 && Download_src
    src_url=${mirror_link}/oneinstack/src/libmcrypt-${libmcrypt_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/mcrypt-${mcrypt_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/freetype-${freetype_ver}.tar.gz && Download_src
  fi

  if [ "${php_option}" == '1' ] || [ "${mphp_ver}" == '53' ]; then
    src_url=${mirror_link}/oneinstack/src/debian_patches_disable_SSLv2_for_openssl_1_0_0.patch && Download_src
    src_url=${mirror_link}/oneinstack/src/php5.3patch && Download_src
    src_url=https://secure.php.net/distributions/php-${php53_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/fpm-race-condition.patch && Download_src
  elif [ "${php_option}" == '2' ] || [ "${mphp_ver}" == '54' ]; then
    src_url=https://secure.php.net/distributions/php-${php54_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/fpm-race-condition.patch && Download_src
  elif [ "${php_option}" == '3' ] || [ "${mphp_ver}" == '55' ]; then
    src_url=https://secure.php.net/distributions/php-${php55_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/fpm-race-condition.patch && Download_src
  elif [ "${php_option}" == '4' ] || [ "${mphp_ver}" == '56' ]; then
    src_url=https://secure.php.net/distributions/php-${php56_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '5' ] || [ "${mphp_ver}" == '70' ]; then
    src_url=https://secure.php.net/distributions/php-${php70_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '6' ] || [ "${mphp_ver}" == '71' ]; then
    src_url=https://secure.php.net/distributions/php-${php71_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '7' ] || [ "${mphp_ver}" == '72' ]; then
    src_url=https://secure.php.net/distributions/php-${php72_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '8' ] || [ "${mphp_ver}" == '73' ]; then
    src_url=https://secure.php.net/distributions/php-${php73_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '9' ] || [ "${mphp_ver}" == '74' ]; then
    src_url=https://secure.php.net/distributions/php-${php74_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libzip-${libzip_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '10' ] || [ "${mphp_ver}" == '80' ]; then
    src_url=https://secure.php.net/distributions/php-${php80_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libzip-${libzip_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '11' ] || [ "${mphp_ver}" == '81' ]; then
    src_url=https://secure.php.net/distributions/php-${php81_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libzip-${libzip_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '12' ] || [ "${mphp_ver}" == '82' ]; then
    src_url=https://secure.php.net/distributions/php-${php82_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_up_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libzip-${libzip_ver}.tar.gz && Download_src
  elif [ "${php_option}" == '13' ] || [ "${mphp_ver}" == '83' ]; then
    src_url=https://secure.php.net/distributions/php-${php83_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/phc-winner-argon2-${argon2_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libsodium-${libsodium_up_ver}.tar.gz && Download_src
    src_url=${mirror_link}/oneinstack/src/libzip-${libzip_ver}.tar.gz && Download_src
  fi

  # PHP OPCache
  case "${phpcache_option}" in
    1)
      if [[ "${php_option}" =~ ^[1-2]$ ]]; then
        # php 5.3 5.4
        echo "Download Zend OPCache..."
        src_url=https://pecl.php.net/get/zendopcache-${zendopcache_ver}.tgz && Download_src
      fi
      ;;
    2)
      echo "Download apcu..."
      if [[ "${php_option}" =~ ^[1-4]$ ]]; then
        src_url=https://pecl.php.net/get/apcu-${apcu_oldver}.tgz && Download_src
      else
        src_url=https://pecl.php.net/get/apcu-${apcu_ver}.tgz && Download_src
      fi
      ;;
    3)
      if [[ "${php_option}" =~ ^[1-4]$ ]]; then
        # php 5.3 5.4 5.5 5.6
        # TODO need delete
        echo "Download xcache..."
        src_url=http://xcache.lighttpd.net/pub/Releases/${xcache_ver}/xcache-${xcache_ver}.tar.gz && Download_src 
      fi
      ;;
    4)
      # php 5.3 5.4
      if [ "${php_option}" == '1' ]; then
        echo "Download eaccelerator 0.9..."
        src_url=https://github.com/downloads/eaccelerator/eaccelerator/eaccelerator-${eaccelerator_ver}.tar.bz2 && Download_src
      elif [ "${php_option}" == '2' ]; then
        echo "Download eaccelerator 1.0 dev..."
        src_url=https://github.com/eaccelerator/eaccelerator/tarball/master && Download_src
      fi
      ;;
  esac

  # Zend Guard Loader
  if [ "${pecl_zendguardloader}" == '1' -a "${armplatform}" != 'y' ]; then
    case "${php_option}" in
      4)
        echo "Download zend loader for php 5.6..."
        src_url=${mirror_link}/oneinstack/src/zend-loader-php5.6-linux-x86_64.tar.gz && Download_src
        ;;
      3)
        echo "Download zend loader for php 5.5..."
        src_url=${mirror_link}/oneinstack/src/zend-loader-php5.5-linux-x86_64.tar.gz && Download_src
        ;;
      2)
        echo "Download zend loader for php 5.4..."
        src_url=${mirror_link}/oneinstack/src/ZendGuardLoader-70429-PHP-5.4-linux-glibc23-x86_64.tar.gz && Download_src
        ;;
      1)
        echo "Download zend loader for php 5.3..."
        src_url=${mirror_link}/oneinstack/src/ZendGuardLoader-php-5.3-linux-glibc23-x86_64.tar.gz && Download_src
        ;;
    esac
  fi

  # ioncube
  if [ "${pecl_ioncube}" == '1' ]; then
    echo "Download ioncube..."
    src_url=${mirror_link}/oneinstack/src/ioncube_loaders_lin_${SYS_ARCH_i}.tar.gz && Download_src
  fi

  # SourceGuardian
  if [ "${pecl_sourceguardian}" == '1' ]; then
    echo "Download SourceGuardian..."
    src_url=${mirror_link}/oneinstack/src/loaders.linux-${ARCH}.tar.gz && Download_src
  fi

  # imageMagick
  if [ "${pecl_imagick}" == '1' ]; then
    echo "Download ImageMagick..."
    src_url=${mirror_link}/oneinstack/src/ImageMagick-${imagemagick_ver}.tar.gz && Download_src
    echo "Download imagick..."
    if [[ "${php_option}" =~ ^1$ ]]; then
      src_url=https://pecl.php.net/get/imagick-${imagick_oldver}.tgz && Download_src
    else
      src_url=https://pecl.php.net/get/imagick-${imagick_ver}.tgz && Download_src
    fi
  fi

  # graphicsmagick
  if [ "${pecl_gmagick}" == '1' ]; then
    echo "Download graphicsmagick..."
    # TODO need check
    src_url=https://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/${graphicsmagick_ver}/GraphicsMagick-${graphicsmagick_ver}.tar.gz && Download_src
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download gmagick for php..."
      src_url=https://pecl.php.net/get/gmagick-${gmagick_oldver}.tgz && Download_src
    else
      echo "Download gmagick for php 7.x..."
      src_url=https://pecl.php.net/get/gmagick-${gmagick_ver}.tgz && Download_src
    fi
  fi

  # redis-server
  if [ "${redis_flag}" == 'y' ]; then
    echo "Download redis-server..."
    src_url=${mirror_link}/oneinstack/src/redis-${redis_ver}.tar.gz && Download_src
  fi

  # pecl_redis
  if [ "${pecl_redis}" == '1' ]; then
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download pecl_redis for php 5.x..."
      src_url=https://pecl.php.net/get/redis-4.3.0.tgz && Download_src
    elif [[ "${php_option}" =~ ^[5-6]$ ]]; then
      echo "Download pecl_redis for php 7.0~7.1..."
      src_url=https://pecl.php.net/get/redis-5.3.7.tgz && Download_src
    else
      echo "Download pecl_redis for php 7.2+..."
      src_url=https://pecl.php.net/get/redis-${pecl_redis_ver}.tgz && Download_src
    fi
  fi

  # memcached-server
  if [ "${memcached_flag}" == 'y' ]; then
    echo "Download memcached-server..."
    DOWN_ADDR=${mirror_link}/oneinstack/src
    src_url=${DOWN_ADDR}/memcached-${memcached_ver}.tar.gz && Download_src
  fi

  # pecl_memcached
  if [ "${pecl_memcached}" == '1' ]; then
    echo "Download libmemcached..."
    src_url=${mirror_link}/oneinstack/src/libmemcached-${libmemcached_ver}.tar.gz && Download_src
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download pecl_memcached for php..."
      src_url=https://pecl.php.net/get/memcached-${pecl_memcached_oldver}.tgz && Download_src
    else
      echo "Download pecl_memcached for php 7.x..."
      src_url=https://pecl.php.net/get/memcached-${pecl_memcached_ver}.tgz && Download_src
    fi
  fi

  # memcached-server pecl_memcached pecl_memcache
  if [ "${pecl_memcache}" == '1' ]; then
    if [[ "${php_option}" =~ ^[1-4]$ ]]; then
      echo "Download pecl_memcache for php 5.x..."
      src_url=https://pecl.php.net/get/memcache-3.0.8.tgz && Download_src
    elif [[ "${php_option}" =~ ^[5-9]$ ]]; then
      echo "Download pecl_memcache for php 7.x..."
      src_url=https://pecl.php.net/get/memcache-${pecl_memcache_oldver}.tgz && Download_src
    else
      echo "Download pecl_memcache for php 8.x..."
      src_url=https://pecl.php.net/get/memcache-${pecl_memcache_ver}.tgz && Download_src
    fi
  fi

  # pecl_mongodb
  if [ "${pecl_mongodb}" == '1' ]; then
    echo "Download pecl mongo for php..."
    src_url=https://pecl.php.net/get/mongo-${pecl_mongo_ver}.tgz && Download_src
    echo "Download pecl mongodb for php..."
    src_url=https://pecl.php.net/get/mongodb-${pecl_mongodb_ver}.tgz && Download_src
  fi

  # nodejs
  if [ "${nodejs_flag}" == 'y' ]; then
    echo "Download Nodejs..."
    [ "${OUTIP_STATE}"x == "China"x ] && DOWN_ADDR_NODE=https://mirrors.tuna.tsinghua.edu.cn/nodejs-release || DOWN_ADDR_NODE=https://nodejs.org/dist
    src_url=${DOWN_ADDR_NODE}/v${nodejs_ver}/node-v${nodejs_ver}-linux-${SYS_ARCH_n}.tar.gz && Download_src
  fi

  # pureftpd
  if [ "${pureftpd_flag}" == 'y' ]; then
    echo "Download pureftpd..."
    src_url=https://download.pureftpd.org/pub/pure-ftpd/releases/pure-ftpd-${pureftpd_ver}.tar.gz && Download_src
  fi

  # phpMyAdmin
  if [ "${phpmyadmin_flag}" == 'y' ]; then
    echo "Download phpMyAdmin..."
    if [[ "${php_option}" =~ ^[1-5]$ ]] || [[ "${mphp_ver}" =~ ^5[3-6]$|^70$ ]]; then
      src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_oldver}/phpMyAdmin-${phpmyadmin_oldver}-all-languages.tar.gz && Download_src
    else
      src_url=https://files.phpmyadmin.net/phpMyAdmin/${phpmyadmin_ver}/phpMyAdmin-${phpmyadmin_ver}-all-languages.tar.gz && Download_src
    fi
  fi

  popd > /dev/null
}
