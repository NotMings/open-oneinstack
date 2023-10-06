#!/bin/bash
# Author:  yeho <lj2007331 AT gmail.com>
# BLOG:  https://linuxeye.com
#
# Notes: OneinStack for CentOS/RedHat 7+ Debian 9+ and Ubuntu 16+
#
# Project home page:
#       https://oneinstack.com
#       https://github.com/oneinstack/oneinstack

Install_PostgreSQL() {
  pushd ${oneinstack_dir}/src > /dev/null
  id -u postgres >/dev/null 2>&1
  [ $? -ne 0 ] && useradd -d ${pgsql_install_dir} -s /bin/bash postgres
  mkdir -p ${pgsql_data_dir};chown postgres.postgres -R ${pgsql_data_dir}
  tar xzf postgresql-${pgsql_ver}.tar.gz
  pushd postgresql-${pgsql_ver}
  ./configure --prefix=$pgsql_install_dir
  make -j ${THREAD}
  make install
  chmod 755 ${pgsql_install_dir}
  chown -R postgres.postgres ${pgsql_install_dir}
  /bin/cp ${oneinstack_dir}/init.d/postgresql.service /lib/systemd/system/
  sed -i "s@=/usr/local/pgsql@=${pgsql_install_dir}@g" /lib/systemd/system/postgresql.service
  sed -i "s@PGDATA=.*@PGDATA=${pgsql_data_dir}@" /lib/systemd/system/postgresql.service
  systemctl enable postgresql
  popd
  su - postgres -c "${pgsql_install_dir}/bin/initdb -D ${pgsql_data_dir}"
  systemctl start postgresql
  sleep 5
  su - postgres -c "${pgsql_install_dir}/bin/psql -c \"alter user postgres with password '$dbpostgrespwd';\""
  sed -i 's@^host.*@#&@g' ${pgsql_data_dir}/pg_hba.conf
  sed -i 's@^local.*@#&@g' ${pgsql_data_dir}/pg_hba.conf
  echo 'local   all             all                                     md5' >> ${pgsql_data_dir}/pg_hba.conf
  echo 'host    all             all             0.0.0.0/0               md5' >> ${pgsql_data_dir}/pg_hba.conf
  sed -i "s@^#listen_addresses.*@listen_addresses = '*'@" ${pgsql_data_dir}/postgresql.conf
  systemctl reload postgresql

  if [ -e "${pgsql_install_dir}/bin/psql" ]; then
    sed -i "s+^dbpostgrespwd.*+dbpostgrespwd='$dbpostgrespwd'+" ../options.conf
    echo "${CSUCCESS}PostgreSQL installed successfully! ${CEND}"
  else
    rm -rf ${pgsql_install_dir} ${pgsql_data_dir}
    echo "${CFAILURE}PostgreSQL install failed, Please contact the author! ${CEND}" && grep -Ew 'NAME|ID|ID_LIKE|VERSION_ID|PRETTY_NAME' /etc/os-release
    kill -9 $$; exit 1;
  fi
  popd
  [ -z "$(grep ^'export PATH=' /etc/profile)" ] && echo "export PATH=${pgsql_install_dir}/bin:\$PATH" >> /etc/profile
  [ -n "$(grep ^'export PATH=' /etc/profile)" -a -z "$(grep ${pgsql_install_dir} /etc/profile)" ] && sed -i "s@^export PATH=\(.*\)@export PATH=${pgsql_install_dir}/bin:\1@" /etc/profile
  . /etc/profile
}
