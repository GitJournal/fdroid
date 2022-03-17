#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2019-2021 Vishesh Handa <me@vhanda.in>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

set -eu pipefail

echo "$GITCRYPT_KEY" | base64 -d > /tmp/secret
sha1sum /tmp/secret

echo 'Unlocking ...'
git-crypt unlock /tmp/secret
rm /tmp/secret
