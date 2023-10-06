#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Upgrade_Redis() {
  pushd ${oneinstack_dir}/src > /dev/null
  [ ! -d "$redis_install_dir" ] && echo "${CWARNING}Redis is not installed on your system! ${CEND}" && exit 1
  OLD_redis_ver=`$redis_install_dir/bin/redis-cli --version | awk '{print $2}'`
  Latest_redis_ver=`curl --connect-timeout 2 -m 3 -s http://download.redis.io/redis-stable/00-RELEASENOTES | awk '/Released/{print $2}' | head -1`
  Latest_redis_ver=${Latest_redis_ver:-6.0.4}
  echo "Current Redis Version: ${CMSG}$OLD_redis_ver${CEND}"
  while :; do echo
    [ "${redis_flag}" != 'y' ] && read -e -p "Please input upgrade Redis Version(default: ${Latest_redis_ver}): " NEW_redis_ver
    NEW_redis_ver=${NEW_redis_ver:-${Latest_redis_ver}}
    if [ "$NEW_redis_ver" != "$OLD_redis_ver" ]; then
      [ ! -e "redis-$NEW_redis_ver.tar.gz" ] && wget --no-check-certificate -c http://download.redis.io/releases/redis-$NEW_redis_ver.tar.gz > /dev/null 2>&1
      if [ -e "redis-$NEW_redis_ver.tar.gz" ]; then
        echo "Download [${CMSG}redis-$NEW_redis_ver.tar.gz${CEND}] successfully! "
        break
      else
        echo "${CWARNING}Redis version does not exist! ${CEND}"
      fi
    else
      echo "${CWARNING}input error! Upgrade Redis version is the same as the old version${CEND}"
      exit
    fi
  done

  if [ -e "redis-$NEW_redis_ver.tar.gz" ]; then
    echo "[${CMSG}redis-$NEW_redis_ver.tar.gz${CEND}] found"
    if [ "${redis_flag}" != 'y' ]; then
      echo "Press Ctrl+c to cancel or Press any key to continue..."
      char=`get_char`
    fi
    tar xzf redis-$NEW_redis_ver.tar.gz
    pushd redis-$NEW_redis_ver
    make clean
    make -j ${THREAD}

    if [ -f "src/redis-server" ]; then
      echo "Restarting Redis..."
      service redis-server stop
      /bin/cp src/{redis-benchmark,redis-check-aof,redis-check-rdb,redis-cli,redis-sentinel,redis-server} $redis_install_dir/bin/
      service redis-server start
      popd > /dev/null
      echo "You have ${CMSG}successfully${CEND} upgrade from ${CWARNING}$OLD_redis_ver${CEND} to ${CWARNING}$NEW_redis_ver${CEND}"
      rm -rf redis-$NEW_redis_ver
    else
      echo "${CFAILURE}Upgrade Redis failed! ${CEND}"
    fi
  fi
  popd > /dev/null
}
