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

function addon_platform {
  uname=$(uname -a)
  osx_regex="Darwin *"
  if [[ $uname == $osx_regex ]]; then
    echo osx
    return
  fi

  if [ -f /etc/redhat-release ]; then
      if grep -q "Fedora release 25 (Twenty Five)" /etc/redhat-release; then
          echo fc25
          return
      fi
      echo fc17
      return
  fi

  issue=$(cat /etc/issue | head -n 1)
  arch_regex="Arch Linux*"
  if [[ $issue == $arch_regex ]]; then
      echo archer
      return
  fi

  log_debug "Unknown platform: /etc/issue: $issue"
  #exit 1
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
  else
    log_debug "${NAME} does not exist"
    echo "0"
    return
  fi

  # Now we check for a "rebuild" file which tells us to rebuild the package
  wget --spider -q $URL.rebuild
  if [ $? == 0 ]; then
    log_debug "${NAME} rebuild file exists"
    echo "0"
  else
    log_debug "${NAME} does not exist"
    echo "1"
  fi
}

function addon_package {
  local ROOT=$1
  local NAME=$(basename $ROOT)

  log_debug "Packaging"
  log_debug "  From: ${ROOT}"
  log_debug "  To: ${NAME}.tar.bz2"

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

  addon_remove_rebuild_file ${NAME}
}

function addon_remove_rebuild_file {
  local NAME=$1
  local URL=$(get_distribution_url $NAME).rebuild

  log_debug "Removing: ${URL}"

  #XXX would be better if this wasn't hardcoded to a specific account
  cp -f /private/cbruby/cloudbees_deployer_netrc ~/.netrc
  # For now, we'll ignore errors (e.g. a 404)
  curl -n -q -X DELETE ${URL}
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
