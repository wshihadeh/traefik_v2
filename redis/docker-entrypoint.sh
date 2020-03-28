#!/bin/bash -e

wait_for_redis(){
  until redis-cli ping > /dev/null; do
    >&2 echo "server is unavailable - sleeping"
    sleep 2
  done
}

add_bootstrap_keys(){
  awk -F ',' '{print "set " $1" "$2}' /data/bootstrap_keys |  redis-cli --pipe || true
}

rm_old_keys(){
  for key in  $(comm -23 <( redis-cli --scan 'traefik*' | sort -u ) <( cat /data/bootstrap_keys | cut -d ',' -f 1 | sort -u ))
  do
    redis-cli DEL $key;
  done || true
}

bootstrap_data(){
  if [ -f /data/bootstrap_keys ]; then
    wait_for_redis
    add_bootstrap_keys
    rm_old_keys
    watch_configs
  fi
}

configs_sig(){
 sig=`cat /data/bootstrap_keys  | base64 | tr '\n' 'x'`;
 echo $sig;
}

watch_configs(){
  CONFIG_SIG=`configs_sig`
  while true
  do
    if [ "$CONFIG_SIG" != `configs_sig` ]; then
      add_bootstrap_keys
      rm_old_keys
      CONFIG_SIG=`configs_sig`
    fi
  done
}

case $1 in

  server)
    bootstrap_data &
    redis-server /usr/local/etc/redis/redis.conf
  ;;

  *)
    exec "$@"
  ;;

esac

exit 0
