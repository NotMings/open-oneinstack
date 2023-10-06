#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Upgrade_Memcached() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -e "${memcached_install_dir}/bin/memcached" ] && echo "${CWARNING}Memcached is not installed on your system! ${CEND}" && exit 1
  OLD_memcached_ver=`${memcached_install_dir}/bin/memcached -V | awk '{print $2}'`
  Latest_memcached_ver=`curl --connect-timeout 2 -m 3 -s https://github.com/memcached/memcached/wiki/ReleaseNotes | grep 'internal present.*ReleaseNotes' |  grep -oE "[0-9]\.[0-9]\.[0-9]+" | head -1`
  Latest_memcached_ver=${Latest_memcached_ver:-1.5.12}
  echo "Current Memcached Version: ${CMSG}${OLD_memcached_ver}${CEND}"
  while :; do echo
    [ "${memcached_flag}" != 'y' ] && read -e -p "Please input upgrade Memcached Version(default: ${Latest_memcached_ver}): " NEW_memcached_ver
    NEW_memcached_ver=${NEW_memcached_ver:-${Latest_memcached_ver}}
    if [ "${NEW_memcached_ver}" != "${OLD_memcached_ver}" ]; then
      [ "${OUTIP_STATE}"x == "China"x ] && DOWN_ADDR=${mirror_link}/oneinstack/src || DOWN_ADDR=http://www.memcached.org/files
      [ ! -e "memcached-${NEW_memcached_ver}.tar.gz" ] && wget --no-check-certificate -c ${DOWN_ADDR}/memcached-${NEW_memcached_ver}.tar.gz > /dev/null 2>&1
      if [ -e "memcached-${NEW_memcached_ver}.tar.gz" ]; then
        echo "Download [${CMSG}memcached-${NEW_memcached_ver}.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Memcached version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Memcached version is the same as the old version${CEND}"
      exit
    fi
  done

  if [ -e "memcached-${NEW_memcached_ver}.tar.gz" ]; then
    echo "[${CMSG}memcached-${NEW_memcached_ver}.tar.gz${CEND}] found"
    if [ "${memcached_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf memcached-${NEW_memcached_ver}.tar.gz
    pushd memcached-${NEW_memcached_ver}
    make clean
    ./configure --prefix=${memcached_install_dir}
    make -j ${THREAD}

    if [ -e "memcached" ]; then
      echo "Restarting Memcached..."
      service memcached stop
      make install
      service memcached start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}${OLD_memcached_ver}${CEND} to ${CWARNING}${NEW_memcached_ver}${CEND}"
      rm -rf memcached-${NEW_memcached_ver}
    else
      echo "${CFAILURE}Upgrade Memcached failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
