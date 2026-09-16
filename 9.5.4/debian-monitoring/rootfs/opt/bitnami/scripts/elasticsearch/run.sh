#!/bin/bash
# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
#set -o xtrace

# Load libraries
. /opt/bitnami/scripts/libelasticsearch.sh
. /opt/bitnami/scripts/libos.sh

# Load environment
. /opt/bitnami/scripts/elasticsearch-env.sh

# Constants
EXEC=$(command -v elasticsearch)
ARGS=("-p" "$DB_PID_FILE")
[[ -z "${DB_EXTRA_FLAGS:-}" ]] || ARGS=("${ARGS[@]}" "${DB_EXTRA_FLAGS[@]}")
# JAVA_HOME to be deprecated, see warning:
#   warning: usage of JAVA_HOME is deprecated, use ES_JAVA_HOME
#
# Upstream Bitnami hardcodes /opt/bitnami/java here, since their build
# fetches a separate Bitnami "java" component. This 9.5.4 image instead
# keeps the official Elasticsearch tarball's own bundled JDK (26.0.2) -
# see the Dockerfile's JDK note - so this must point there instead, or
# elasticsearch fails to start with "could not find java in ES_JAVA_HOME
# at /opt/bitnami/java/bin/java" (confirmed the hard way).
export JAVA_HOME=/opt/bitnami/elasticsearch/jdk
export ES_JAVA_HOME=/opt/bitnami/elasticsearch/jdk

ARGS+=("$@")

info "** Starting Elasticsearch **"
if am_i_root; then
    exec_as_user "$DB_DAEMON_USER" "$EXEC" "${ARGS[@]}"
else
    exec "$EXEC" "${ARGS[@]}"
fi
