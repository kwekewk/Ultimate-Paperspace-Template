#!/bin/bash
# Don't exit on error

function source_env_file() {
  if [[ -e ".env" ]]; then
    source ".env"
  fi
}

function check_required_env_vars() {
  local required_vars=($(echo "$REQUIRED_ENV" | tr ',' '\n'))
  local missing_vars=()
  for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
      missing_vars+=("$var")
    fi
  done
  if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo "The following required environment variables are missing: ${missing_vars[*]}"
    return 1
  fi
  return 0
}

export SCRIPT_ROOT_DIR=$(dirname "$(realpath "$0")")
cd $SCRIPT_ROOT_DIR

# Read the RUN_SCRIPT environment variable
run_script="$RUN_SCRIPT"

# Separate the variable by commas
IFS=',' read -ra scripts <<< "$run_script"

echo "Starting script(s)"
apt-get update -qq
apt-get install -qq curl git-lfs zip python3.10 python3.10-venv python3.10-dev -y > /dev/null

# Prepare required path
mkdir -p /notebooks/outputs

# Loop through each script and execute the corresponding case
for script in "${scripts[@]}"
do
  cd $SCRIPT_ROOT_DIR
  if [[ ! -d $script ]]; then
    echo "Script folder $script not found, skipping..."
    continue
  fi
  cd $script
  source_env_file
  if ! check_required_env_vars; then
    echo "One or more required environment variables are missing."
    continue
  fi
  bash main.sh $@
done
