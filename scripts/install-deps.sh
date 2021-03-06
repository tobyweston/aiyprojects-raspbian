#!/bin/bash
# Copyright 2017 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit

scripts_dir="$(dirname "${BASH_SOURCE[0]}")"

# make sure we're running as the owner of the checkout directory
RUN_AS="$(ls -ld "$scripts_dir" | awk 'NR==1 {print $3}')"
if [ "$USER" != "$RUN_AS" ]
then
    echo "This script must run as $RUN_AS, trying to change user..."
    exec sudo -u $RUN_AS $0
fi

# fresh Raspbian may not have pip3 install and we install requirements for the checkpoint dependencies
sudo apt-get -y install python3-all-dev python3-pip virtualenv
sudo pip3 install --upgrade pip virtualenv
pip3 install -r requirements.txt

# virtualenv is required to resolve dependencies against src/aiy for checkpoint scripts etc
cd "${scripts_dir}/.."
virtualenv --system-site-packages -p python3 env
echo "/home/pi/AIY-projects-python/src" > /home/pi/AIY-projects-python/env/lib/python3.5/site-packages/aiy.pth

# The google-assistant-library is only available on some platforms.
if [[ "$(uname -m)" == "armv7l" || "$(uname -m)" == "x86_64" || "$(uname -m)" == "armv6l" ]] ; then
  pip3 install google-assistant-library==0.1.0
fi
