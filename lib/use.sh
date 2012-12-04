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
  #exit 1
}
