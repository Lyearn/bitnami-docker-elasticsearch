#!/bin/bash
#
# Environment configuration for elasticsearch

# The values for all environment variables will be set in the below order of precedence
# 1. Custom environment variables defined below after Bitnami defaults
# 2. Constants defined in this file (environment variables with no default), i.e. BITNAMI_ROOT_DIR
# 3. Environment variables overridden via external files using *_FILE variables (see below)
# 4. Environment variables set externally (i.e. current Bash context/Dockerfile/userdata)

# Load logging library
# shellcheck disable=SC1090,SC1091
. /opt/bitnami/scripts/liblog.sh

export BITNAMI_ROOT_DIR="/opt/bitnami"
export BITNAMI_VOLUME_DIR="/bitnami"

# Logging configuration
export MODULE="${MODULE:-elasticsearch}"
export BITNAMI_DEBUG="${BITNAMI_DEBUG:-false}"

# By setting an environment variable matching *_FILE to a file path, the prefixed environment
# variable will be overridden with the value specified in that file
elasticsearch_env_vars=(
    ELASTICSEARCH_CERTS_DIR
    ELASTICSEARCH_DATA_DIR_LIST
    ELASTICSEARCH_BIND_ADDRESS
    ELASTICSEARCH_ADVERTISED_HOSTNAME
    ELASTICSEARCH_CLUSTER_HOSTS
    ELASTICSEARCH_CLUSTER_MASTER_HOSTS
    ELASTICSEARCH_CLUSTER_NAME
    ELASTICSEARCH_HEAP_SIZE
    ELASTICSEARCH_MAX_ALLOWED_MEMORY_PERCENTAGE
    ELASTICSEARCH_MAX_ALLOWED_MEMORY
    ELASTICSEARCH_MAX_TIMEOUT
    ELASTICSEARCH_LOCK_ALL_MEMORY
    ELASTICSEARCH_DISABLE_JVM_HEAP_DUMP
    ELASTICSEARCH_ACTION_DESTRUCTIVE_REQUIRES_NAME
    ELASTICSEARCH_DISABLE_GC_LOGS
    ELASTICSEARCH_IS_DEDICATED_NODE
    ELASTICSEARCH_MINIMUM_MASTER_NODES
    ELASTICSEARCH_NODE_NAME
    ELASTICSEARCH_FS_SNAPSHOT_REPO_PATH
    ELASTICSEARCH_NODE_ROLES
    ELASTICSEARCH_NODE_TYPE
    ELASTICSEARCH_PLUGINS
    ELASTICSEARCH_KEYS
    ELASTICSEARCH_TRANSPORT_PORT_NUMBER
    ELASTICSEARCH_HTTP_PORT_NUMBER
    ELASTICSEARCH_PASSWORD
    ELASTICSEARCH_ENABLE_SECURITY
    ELASTICSEARCH_ENABLE_FIPS_MODE
    ELASTICSEARCH_TLS_VERIFICATION_MODE
    ELASTICSEARCH_TLS_USE_PEM
    ELASTICSEARCH_KEYSTORE_PASSWORD
    ELASTICSEARCH_TRUSTSTORE_PASSWORD
    ELASTICSEARCH_KEY_PASSWORD
    ELASTICSEARCH_KEYSTORE_LOCATION
    ELASTICSEARCH_TRUSTSTORE_LOCATION
    ELASTICSEARCH_NODE_CERT_LOCATION
    ELASTICSEARCH_NODE_KEY_LOCATION
    ELASTICSEARCH_CA_CERT_LOCATION
    ELASTICSEARCH_SKIP_TRANSPORT_TLS
    ELASTICSEARCH_TRANSPORT_TLS_USE_PEM
    ELASTICSEARCH_TRANSPORT_TLS_KEYSTORE_PASSWORD
    ELASTICSEARCH_TRANSPORT_TLS_TRUSTSTORE_PASSWORD
    ELASTICSEARCH_TRANSPORT_TLS_KEY_PASSWORD
    ELASTICSEARCH_TRANSPORT_TLS_KEYSTORE_LOCATION
    ELASTICSEARCH_TRANSPORT_TLS_TRUSTSTORE_LOCATION
    ELASTICSEARCH_TRANSPORT_TLS_NODE_CERT_LOCATION
    ELASTICSEARCH_TRANSPORT_TLS_NODE_KEY_LOCATION
    ELASTICSEARCH_TRANSPORT_TLS_CA_CERT_LOCATION
    ELASTICSEARCH_ENABLE_REST_TLS
    ELASTICSEARCH_HTTP_TLS_USE_PEM
    ELASTICSEARCH_HTTP_TLS_KEYSTORE_PASSWORD
    ELASTICSEARCH_HTTP_TLS_TRUSTSTORE_PASSWORD
    ELASTICSEARCH_HTTP_TLS_KEY_PASSWORD
    ELASTICSEARCH_HTTP_TLS_KEYSTORE_LOCATION
    ELASTICSEARCH_HTTP_TLS_TRUSTSTORE_LOCATION
    ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION
    ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION
    ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION
)
for env_var in "${elasticsearch_env_vars[@]}"; do
    file_env_var="${env_var}_FILE"
    if [[ -n "${!file_env_var:-}" ]]; then
        if [[ -r "${!file_env_var:-}" ]]; then
            export "${env_var}=$(< "${!file_env_var}")"
            unset "${file_env_var}"
        else
            warn "Skipping export of '${env_var}'. '${!file_env_var:-}' is not readable."
        fi
    fi
done
unset elasticsearch_env_vars

# Paths
export ELASTICSEARCH_VOLUME_DIR="/bitnami/elasticsearch"
export ELASTICSEARCH_BASE_DIR="/opt/bitnami/elasticsearch"
export ELASTICSEARCH_CONF_DIR="${ELASTICSEARCH_BASE_DIR}/config"
export ELASTICSEARCH_CERTS_DIR="${ELASTICSEARCH_CERTS_DIR:-${ELASTICSEARCH_CONF_DIR}/certs}"
export ELASTICSEARCH_LOGS_DIR="${ELASTICSEARCH_BASE_DIR}/logs"
export ELASTICSEARCH_PLUGINS_DIR="${ELASTICSEARCH_BASE_DIR}/plugins"
export ELASTICSEARCH_DATA_DIR="${ELASTICSEARCH_VOLUME_DIR}/data"
export ELASTICSEARCH_DATA_DIR_LIST="${ELASTICSEARCH_DATA_DIR_LIST:-}"
export ELASTICSEARCH_TMP_DIR="${ELASTICSEARCH_BASE_DIR}/tmp"
export ELASTICSEARCH_BIN_DIR="${ELASTICSEARCH_BASE_DIR}/bin"
export ELASTICSEARCH_MOUNTED_PLUGINS_DIR="${ELASTICSEARCH_VOLUME_DIR}/plugins"
export ELASTICSEARCH_CONF_FILE="${ELASTICSEARCH_CONF_DIR}/elasticsearch.yml"
export ELASTICSEARCH_LOG_FILE="${ELASTICSEARCH_LOGS_DIR}/elasticsearch.log"
export ELASTICSEARCH_INITSCRIPTS_DIR="/docker-entrypoint-initdb.d"
export PATH="${ELASTICSEARCH_BIN_DIR}:${BITNAMI_ROOT_DIR}/common/bin:$PATH"

# System users (when running with a privileged user)
export ELASTICSEARCH_DAEMON_USER="elasticsearch"
export ELASTICSEARCH_DAEMON_GROUP="elasticsearch"

# Elasticsearch configuration
export ELASTICSEARCH_BIND_ADDRESS="${ELASTICSEARCH_BIND_ADDRESS:-}"
export ELASTICSEARCH_ADVERTISED_HOSTNAME="${ELASTICSEARCH_ADVERTISED_HOSTNAME:-}"
export ELASTICSEARCH_CLUSTER_HOSTS="${ELASTICSEARCH_CLUSTER_HOSTS:-}"
export ELASTICSEARCH_CLUSTER_MASTER_HOSTS="${ELASTICSEARCH_CLUSTER_MASTER_HOSTS:-}"
export ELASTICSEARCH_CLUSTER_NAME="${ELASTICSEARCH_CLUSTER_NAME:-}"
export ELASTICSEARCH_HEAP_SIZE="${ELASTICSEARCH_HEAP_SIZE:-1024m}"
export ELASTICSEARCH_MAX_ALLOWED_MEMORY_PERCENTAGE="${ELASTICSEARCH_MAX_ALLOWED_MEMORY_PERCENTAGE:-100}"
export ELASTICSEARCH_MAX_ALLOWED_MEMORY="${ELASTICSEARCH_MAX_ALLOWED_MEMORY:-}"
export ELASTICSEARCH_MAX_TIMEOUT="${ELASTICSEARCH_MAX_TIMEOUT:-60}"
export ELASTICSEARCH_LOCK_ALL_MEMORY="${ELASTICSEARCH_LOCK_ALL_MEMORY:-no}"
export ELASTICSEARCH_DISABLE_JVM_HEAP_DUMP="${ELASTICSEARCH_DISABLE_JVM_HEAP_DUMP:-no}"
export ELASTICSEARCH_ACTION_DESTRUCTIVE_REQUIRES_NAME="${ELASTICSEARCH_ACTION_DESTRUCTIVE_REQUIRES_NAME:-}"
export ELASTICSEARCH_DISABLE_GC_LOGS="${ELASTICSEARCH_DISABLE_GC_LOGS:-no}"
export ELASTICSEARCH_IS_DEDICATED_NODE="${ELASTICSEARCH_IS_DEDICATED_NODE:-no}"
export ELASTICSEARCH_MINIMUM_MASTER_NODES="${ELASTICSEARCH_MINIMUM_MASTER_NODES:-}"
export ELASTICSEARCH_NODE_NAME="${ELASTICSEARCH_NODE_NAME:-}"
export ELASTICSEARCH_FS_SNAPSHOT_REPO_PATH="${ELASTICSEARCH_FS_SNAPSHOT_REPO_PATH:-}"
export ELASTICSEARCH_NODE_ROLES="${ELASTICSEARCH_NODE_ROLES:-}"
export ELASTICSEARCH_NODE_TYPE="${ELASTICSEARCH_NODE_TYPE:-}"
export ELASTICSEARCH_PLUGINS="${ELASTICSEARCH_PLUGINS:-}"
export ELASTICSEARCH_KEYS="${ELASTICSEARCH_KEYS:-}"
export ELASTICSEARCH_TRANSPORT_PORT_NUMBER="${ELASTICSEARCH_TRANSPORT_PORT_NUMBER:-9300}"
export ELASTICSEARCH_HTTP_PORT_NUMBER="${ELASTICSEARCH_HTTP_PORT_NUMBER:-9200}"

# Elasticsearch Security configuration
export ELASTICSEARCH_PASSWORD="${ELASTICSEARCH_PASSWORD:-bitnami}"
export ELASTICSEARCH_ENABLE_SECURITY="${ELASTICSEARCH_ENABLE_SECURITY:-false}"
export ELASTICSEARCH_ENABLE_FIPS_MODE="${ELASTICSEARCH_ENABLE_FIPS_MODE:-false}"
export ELASTICSEARCH_TLS_VERIFICATION_MODE="${ELASTICSEARCH_TLS_VERIFICATION_MODE:-full}"
export ELASTICSEARCH_TLS_USE_PEM="${ELASTICSEARCH_TLS_USE_PEM:-false}"
export ELASTICSEARCH_KEYSTORE_PASSWORD="${ELASTICSEARCH_KEYSTORE_PASSWORD:-}"
export ELASTICSEARCH_TRUSTSTORE_PASSWORD="${ELASTICSEARCH_TRUSTSTORE_PASSWORD:-}"
export ELASTICSEARCH_KEY_PASSWORD="${ELASTICSEARCH_KEY_PASSWORD:-}"
export ELASTICSEARCH_KEYSTORE_LOCATION="${ELASTICSEARCH_KEYSTORE_LOCATION:-${ELASTICSEARCH_CERTS_DIR}/elasticsearch.keystore.jks}"
export ELASTICSEARCH_TRUSTSTORE_LOCATION="${ELASTICSEARCH_TRUSTSTORE_LOCATION:-${ELASTICSEARCH_CERTS_DIR}/elasticsearch.truststore.jks}"
export ELASTICSEARCH_NODE_CERT_LOCATION="${ELASTICSEARCH_NODE_CERT_LOCATION:-${ELASTICSEARCH_CERTS_DIR}/tls.crt}"
export ELASTICSEARCH_NODE_KEY_LOCATION="${ELASTICSEARCH_NODE_KEY_LOCATION:-${ELASTICSEARCH_CERTS_DIR}/tls.key}"
export ELASTICSEARCH_CA_CERT_LOCATION="${ELASTICSEARCH_CA_CERT_LOCATION:-${ELASTICSEARCH_CERTS_DIR}/ca.crt}"
export ELASTICSEARCH_SKIP_TRANSPORT_TLS="${ELASTICSEARCH_SKIP_TRANSPORT_TLS:-false}"
export ELASTICSEARCH_TRANSPORT_TLS_USE_PEM="${ELASTICSEARCH_TRANSPORT_TLS_USE_PEM:-$ELASTICSEARCH_TLS_USE_PEM}"
export ELASTICSEARCH_TRANSPORT_TLS_KEYSTORE_PASSWORD="${ELASTICSEARCH_TRANSPORT_TLS_KEYSTORE_PASSWORD:-$ELASTICSEARCH_KEYSTORE_PASSWORD}"
export ELASTICSEARCH_TRANSPORT_TLS_TRUSTSTORE_PASSWORD="${ELASTICSEARCH_TRANSPORT_TLS_TRUSTSTORE_PASSWORD:-$ELASTICSEARCH_TRUSTSTORE_PASSWORD}"
export ELASTICSEARCH_TRANSPORT_TLS_KEY_PASSWORD="${ELASTICSEARCH_TRANSPORT_TLS_KEY_PASSWORD:-$ELASTICSEARCH_KEY_PASSWORD}"
export ELASTICSEARCH_TRANSPORT_TLS_KEYSTORE_LOCATION="${ELASTICSEARCH_TRANSPORT_TLS_KEYSTORE_LOCATION:-$ELASTICSEARCH_KEYSTORE_LOCATION}"
export ELASTICSEARCH_TRANSPORT_TLS_TRUSTSTORE_LOCATION="${ELASTICSEARCH_TRANSPORT_TLS_TRUSTSTORE_LOCATION:-$ELASTICSEARCH_TRUSTSTORE_LOCATION}"
export ELASTICSEARCH_TRANSPORT_TLS_NODE_CERT_LOCATION="${ELASTICSEARCH_TRANSPORT_TLS_NODE_CERT_LOCATION:-$ELASTICSEARCH_NODE_CERT_LOCATION}"
export ELASTICSEARCH_TRANSPORT_TLS_NODE_KEY_LOCATION="${ELASTICSEARCH_TRANSPORT_TLS_NODE_KEY_LOCATION:-$ELASTICSEARCH_NODE_KEY_LOCATION}"
export ELASTICSEARCH_TRANSPORT_TLS_CA_CERT_LOCATION="${ELASTICSEARCH_TRANSPORT_TLS_CA_CERT_LOCATION:-$ELASTICSEARCH_CA_CERT_LOCATION}"
export ELASTICSEARCH_ENABLE_REST_TLS="${ELASTICSEARCH_ENABLE_REST_TLS:-false}"
export ELASTICSEARCH_HTTP_TLS_USE_PEM="${ELASTICSEARCH_HTTP_TLS_USE_PEM:-$ELASTICSEARCH_TLS_USE_PEM}"
export ELASTICSEARCH_HTTP_TLS_KEYSTORE_PASSWORD="${ELASTICSEARCH_HTTP_TLS_KEYSTORE_PASSWORD:-$ELASTICSEARCH_KEYSTORE_PASSWORD}"
export ELASTICSEARCH_HTTP_TLS_TRUSTSTORE_PASSWORD="${ELASTICSEARCH_HTTP_TLS_TRUSTSTORE_PASSWORD:-$ELASTICSEARCH_TRUSTSTORE_PASSWORD}"
export ELASTICSEARCH_HTTP_TLS_KEY_PASSWORD="${ELASTICSEARCH_HTTP_TLS_KEY_PASSWORD:-$ELASTICSEARCH_KEY_PASSWORD}"
export ELASTICSEARCH_HTTP_TLS_KEYSTORE_LOCATION="${ELASTICSEARCH_HTTP_TLS_KEYSTORE_LOCATION:-$ELASTICSEARCH_KEYSTORE_LOCATION}"
export ELASTICSEARCH_HTTP_TLS_TRUSTSTORE_LOCATION="${ELASTICSEARCH_HTTP_TLS_TRUSTSTORE_LOCATION:-$ELASTICSEARCH_TRUSTSTORE_LOCATION}"
export ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION="${ELASTICSEARCH_HTTP_TLS_NODE_CERT_LOCATION:-$ELASTICSEARCH_NODE_CERT_LOCATION}"
export ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION="${ELASTICSEARCH_HTTP_TLS_NODE_KEY_LOCATION:-$ELASTICSEARCH_NODE_KEY_LOCATION}"
export ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION="${ELASTICSEARCH_HTTP_TLS_CA_CERT_LOCATION:-$ELASTICSEARCH_CA_CERT_LOCATION}"

# Custom environment variables may be defined below
