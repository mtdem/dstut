# Export the module function if it exists
[[ $(type -t module) == "function" ]] && export -f module

# Find available port to run server on
port=$(find_port ${host})

ntype="classc"
imgtyp="cpu"
ml_lib=""
nv=""
if [ "$ntype" = "gpu" ] || [ "$ntype" = "class" ]; then
    imgtyp="gpu"
    nv="--nv"
    ml_lib="-tf"
fi

/home/rxf131/ondemand/share/config/run.sh \
  ${nv} /home/rxf131/ondemand/share/build_link/rserver_${imgtyp}${ml_lib}.sif \
  /usr/lib/rstudio-server/bin/rserver --www-port ${port} \
  --auth-stay-signed-in-days=30 --auth-none=1 --server-user ${USER}

# Wait for the RStudio Server to start
echo "Waiting for RStudio Server to open port ${port}..."
if wait_until_port_used "${host}:${port}" 300; then
  echo "Discovered RStudio Server listening on port ${port}!"
else
  echo "Timed out waiting for RStudio Server to open port ${port}!"
  clean_up 1
fi
sleep 2

module purge
cd /home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37

# Export useful connection variables
export host
export port

# Generate a connection yaml file with given parameters
create_yml () {
  echo "Generating connection YAML file..."
  (
    umask 077
    echo -e "host: $host\nport: $port\npassword: $password" > "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/connection.yml"
  )
}

# Cleanliness is next to Godliness
clean_up () {
  echo "Cleaning up..."
  [[ -e "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/clean.sh" ]] && source "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/clean.sh"
  [[ ${SCRIPT_PID} ]] && pkill -P ${SCRIPT_PID} || :
  pkill -P $$
  exit ${1:-0}
}

# Source in all the helper functions
source_helpers () {
  # Generate random integer in range [$1..$2]
  random_number () {
    shuf -i ${1}-${2} -n 1
  }
  export -f random_number

  port_used_python() {
    python -c "import socket; socket.socket().connect(('$1',$2))" >/dev/null 2>&1
  }

  port_used_python3() {
    python3 -c "import socket; socket.socket().connect(('$1',$2))" >/dev/null 2>&1
  }

  port_used_nc(){
    nc -w 2 "$1" "$2" < /dev/null > /dev/null 2>&1
  }

  port_used_lsof(){
    lsof -i :"$2" >/dev/null 2>&1
  }

  port_used_bash(){
    local bash_supported=$(strings /bin/bash 2>/dev/null | grep tcp)
    if [ "$bash_supported" == "/dev/tcp/*/*" ]; then
      (: < /dev/tcp/$1/$2) >/dev/null 2>&1
    else
      return 127
    fi
  }

  # Check if port $1 is in use
  port_used () {
    local port="${1#*:}"
    local host=$((expr "${1}" : '\(.*\):' || echo "localhost") | awk 'END{print $NF}')
    local port_strategies=(port_used_nc port_used_lsof port_used_bash port_used_python port_used_python3)

    for strategy in ${port_strategies[@]};
    do
      $strategy $host $port
      status=$?
      if [[ "$status" == "0" ]] || [[ "$status" == "1" ]]; then
        return $status
      fi
    done

    return 127
  }
  export -f port_used

  # Find available port in range [$2..$3] for host $1
  # Default: [2000..65535]
  find_port () {
    local host="${1:-localhost}"
    local port=$(random_number "${2:-2000}" "${3:-65535}")
    while port_used "${host}:${port}"; do
      port=$(random_number "${2:-2000}" "${3:-65535}")
    done
    echo "${port}"
  }
  export -f find_port

  # Wait $2 seconds until port $1 is in use
  # Default: wait 30 seconds
  wait_until_port_used () {
    local port="${1}"
    local time="${2:-30}"
    for ((i=1; i<=time*2; i++)); do
      port_used "${port}"
      port_status=$?
      if [ "$port_status" == "0" ]; then
        return 0
      elif [ "$port_status" == "127" ]; then
         echo "commands to find port were either not found or inaccessible."
         echo "command options are lsof, nc, bash's /dev/tcp, or python (or python3) with socket lib."
         return 127
      fi
      sleep 0.5
    done
    return 1
  }
  export -f wait_until_port_used

  # Generate random alphanumeric password with $1 (default: 8) characters
  create_passwd () {
    tr -cd 'a-zA-Z0-9' < /dev/urandom 2> /dev/null | head -c${1:-8}
  }
  export -f create_passwd
}
export -f source_helpers

source_helpers

# Set host of current machine
host=$(hostname)

[[ -e "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/before.sh" ]] && source "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/before.sh"

echo "Script starting..."
"/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/script.sh" &
SCRIPT_PID=$!

[[ -e "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/after.sh" ]] && source "/home/mxd601/ondemand/data/sys/dashboard/batch_connect/usr/rxf131/rserver/output/d15a3b25-ece1-4d27-9dd1-5c5debda4c37/after.sh"

# Create the connection yaml file
create_yml

# Wait for script process to finish
wait ${SCRIPT_PID} || clean_up 1

# Exit cleanly
clean_up

