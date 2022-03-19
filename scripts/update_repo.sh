#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu

update_dev_build() {
  set -eu
  echo "Updating dev build"

  latestVersionCode=$(ls repo/io.gitjournal.gitjournal.dev_*.apk | sed -e 's/^repo\/io.gitjournal.gitjournal.dev_//' | sed -e 's/.apk//' | sort | tail -n 1)
  echo "Latest Version Code: $latestVersionCode"

  versionCode=$(grep CurrentVersionCode metadata/io.gitjournal.gitjournal.dev.yml | awk '{ print $2 }')
  echo "Current Version Code: $versionCode"

  if [ "$latestVersionCode" == "$versionCode" ]; then
    echo "Nothing to do"
    return
  fi

  sed -i "s#CurrentVersionCode: .*#CurrentVersionCode: ${latestVersionCode}\n#" metadata/io.gitjournal.gitjournal.dev.yml
}

update_build() {
  wget https://github.com/GitJournal/apb/releases/download/v0.1/apb-linux-x64 -O ./apb
  chmod +x ./apb
  echo "Updating build"

  latestVersionCode=$(./apb -p io.gitjournal.gitjournal trackInfo p | jq -r '.versionCodes | .[0]')
  echo "Latest Version Code: $latestVersionCode"

  versionCode=$(grep CurrentVersionCode metadata/io.gitjournal.gitjournal.yml | awk '{ print $2 }')
  echo "Current Version Code: $versionCode"

  if [ "$latestVersionCode" == "$versionCode" ]; then
    echo "Nothing to do"
    return
  fi

  sed -i "s#CurrentVersionCode: .*#CurrentVersionCode: ${latestVersionCode}\n#" metadata/io.gitjournal.gitjournal.yml
}

if [[ $(git diff --stat) != '' ]]; then
  echo 'Git Dirty'
else
  echo 'Git Clean'
fi

update_build
update_dev_build

fdroid gpgsign
fdroid rewritemeta

fdroid update --pretty --delete-unknown --rename-apks --use-date-from-apk
