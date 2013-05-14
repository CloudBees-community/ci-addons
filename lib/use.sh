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

function get_distribution_url {
  local NAME=$1
  echo "https://repository-cloudbees.forge.cloudbees.com/distributions/ci-addons/${NAME}"
}

function addon_architecture {
  uname -m
}

function addon_platform {
  issue=$(cat /etc/issue | head -n 1)

  fedora_regex="Fedora release 17*"
  if [[ $issue == $fedora_regex ]]; then
      echo fc17
      return
  fi

  arch_regex="Arch Linux*"
  if [[ $issue == $arch_regex ]]; then
      echo arch
      return
  fi
  log_debug "Unknown platform: /etc/issue: $issue"
  exit 1
}

# PACKAGE: <package>
# NAME: <package>-<version>.tar.bz2
function addon_download {
  local PACKAGE=$1
  local NAME=$2
  local FQNAME="$PACKAGE/$(addon_platform)/$NAME.tar.bz2"

  if [ ! -f "/tmp/${NAME}.tar.bz2" ]; then
    wget -nv -P /tmp $(get_distribution_url "${FQNAME}")
  fi
}

# PACKAGE: <package>
# NAME: <package>-<version>.tar.bz2
# TEST: bin/php (for example)
function addon_extract {
  local PACKAGE=$1
  local NAME=$2
  local TEST=$3
  local FILE="/tmp/${NAME}.tar.bz2"
  local TARGET="/scratch/jenkins/${PACKAGE}/${NAME}"

  if [ ! -f "${TARGET}/${TEST}" ]; then
    mkdir -p ${TARGET}
    tar xjf ${FILE} -C ${TARGET} --strip-components 1
  fi
}

