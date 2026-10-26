#!/bin/sh
# SPDX-License-Identifier: Apache-2.0
set -e

uci -q delete luci.themes.Mavxa || :
uci commit luci
