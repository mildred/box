#!/bin/bash

# Trap processes started through box in a dBus session
# Designed to be used with systemd

dir="$(cd "`dirname "$0"`"; pwd)"

mkdir -p "$dir/units" "$dir/config" "$dir/data" "$dir/run" "$dir/plugins"

export SYSTEMD_UNIT_PATH="$dir/units"
export XDG_CONFIG_HOME="$dir/config"
export XDG_DATA_HOME="$dir/data"

for p in "$dir"/plugins/*; do
  SYSTEMD_UNIT_PATH="$SYSTEMD_UNIT_PATH:$p/units"
done

#
# util
#	

rc_shquote () {
  local HEAD TAIL="$*"
  printf "'"
  while [ -n "$TAIL" ]; do
    HEAD="${TAIL%%\'*}"
    if [ "$HEAD" = "$TAIL" ]; then
      printf "%s" "$TAIL"
      break
    fi
    printf "%s'\"'\"'" "$HEAD"
    TAIL="${TAIL#*\'}"
  done
  printf "'"
}

has-dbus(){
  [[ -z "$DBUS_SESSION_BUS_PID" ]] && return 1
  [[ ! -d "/proc/$DBUS_SESSION_BUS_PID" ]] && return 1
  return 0
}

start-dbus(){
  local info="$(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID"
  eval "$info"
  echo "$info"
}

dump-dbus(){
  echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
  echo "DBUS_SESSION_BUS_PID=$DBUS_SESSION_BUS_PID"
  echo "export DBUS_SESSION_BUS_ADDRESS"
  echo "export DBUS_SESSION_BUS_PID"
}

clear-dbus(){
  export DBUS_SESSION_BUS_ADDRESS=""
  export DBUS_SESSION_BUS_PID=""
}

#
# Box dBus
#

clear-dbus
[ -f "$dir/run/dbus.sh" ] && source "$dir/run/dbus.sh"

if [ -n "$*" ] && ! has-dbus; then
  start-dbus > "$dir/run/dbus.sh"
fi

#
# Run child
#

if [ -z "$*" ]; then
  if has-dbus; then
    echo "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS"
    echo "DBUS_SESSION_BUS_PID=$DBUS_SESSION_BUS_PID"
    exit 0
  else
    exit 1
  fi
else
  "$@"
  exit $?
fi

