################################################################################
#  Copyright 2012 CloudBees Inc.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
################################################################################

function log_debug {
  echo "DEBUG: $*" > /dev/stderr
}

function addon_architecture {
  uname -m
}

# Usage:
#   is_already_built 'ruby/ruby-1.3.2-i386.zip'
function addon_is_built {
  local NAME=$1
  local URL=$(get_distribution_url $NAME)
  log_debug "Checking if ${URL} exists"

  # We use spider as it is a simpler way to check for existence (can't remember why now though)
  set +e
  wget --spider -q $URL
  if [ $? == 0 ]; then
    log_debug "${NAME} exists"
    echo "1"
  else
    log_debug "${NAME} does not exist"
    echo "0"
  fi
}

function addon_package {
  local ROOT=$1
  local NAME=$(basename $ROOT)

  log_debug "Packaging"
  log_debug "  From: ${ROOT}"
  log_debug "  To: ${NAME}"

  rm -f ${NAME}.tar.bz2
  tar cjf ${NAME}.tar.bz2 -C "$ROOT/.." ${NAME}
}

function addon_publish {
  local NAME=$1
  local SOURCE=$2
  local URL=$(get_distribution_url $NAME)

  log_debug "Publishing ${NAME}"
  log_debug " From: ${SOURCE}"
  log_debug " To:   ${URL}"

  #XXX would be better if this wasn't hardcoded to a specific account
  cp -f /private/cbruby/cloudbees_deployer_netrc ~/.netrc
  curl -n --upload-file ${SOURCE} ${URL}
}

function get_distribution_url {
  local NAME=$1
  echo "https://repository-cloudbees.forge.cloudbees.com/distributions/ci-addons/${NAME}"
}


function addon_clean_build {
  log_debug "Checking build directory"
  if [ -d build ]; then
    log_debug "Removing build directory"
    rm -rf build
  fi

  log_debug "Creating build directory"
  mkdir build
}

function addon_platform {
  if [ -f /etc/redhat-release ]; then
      echo fc17
  else
      echo arch
  fi
}
