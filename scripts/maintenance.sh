#!/usr/bin/env bash
#title          :maintenance.sh
#description    :This script will manage maintenance mode on wordpress pod.
#author		    :Jeremy REISSER
#date           :2020.06.10
#version        :0.1
#usage		      :bash maintenance.sh (on|off)
#==============================================================================

set -o errexit          # Exit on most errors
set -o errtrace         # Make sure any error trap is inherited
set -o nounset          # Disallow expansion of unset variables
set -o pipefail         # Use last non-zero exit code in a pipeline

INGRESS_NAME=$(kubectl -n wordpress get ing/wordpress-ingress -o jsonpath='{.spec.rules[].http.paths[].backend.serviceName}')

function on() {
  if [[ $INGRESS_NAME != 'maintenance-svc' ]]; then
    kubectl -n wordpress get ing/wordpress-ingress -o json \
    | jq '(.spec.rules[].http.paths[].backend.serviceName | select(. == "varnish-svc")) |= "maintenance-svc"' \
    | kubectl apply -f -
    printf 'Maintenance Mode Enabled'
  else
    printf 'Already in maintenance'
  fi
}

function off() {
  if [[ $INGRESS_NAME == 'maintenance-svc' ]]; then
    kubectl -n wordpress get ing/wordpress-ingress -o json \
    | jq '(.spec.rules[].http.paths[].backend.serviceName | select(. == "maintenance-svc")) |= "varnish-svc"' \
    | kubectl apply -f -
    printf 'Maintenance Mode Disabled'
  else
    printf 'Not in maintenance'
  fi
}

"$@"
