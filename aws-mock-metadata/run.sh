#!/usr/bin/env bash
set -eo pipefail

APP_HOST=169.254.169.254
APP_PORT=42000

AVAILABILITY_ZONE="ap-southeast-2a"
INSTANCE_ID="i-01e0f26d68ca3ab48"
AWS_SESSION_TOKEN=""
HOSTNAME="ip-172-17-0-1.ap-southeast-2.compute.internal"
PRIVATE_IP="10.0.0.10"
ROLE_ARN=""
ROLE_NAME=""
VPC_ID="vpc-abcdef99"

if [[-r "/.dockerenv" ]]; then
  source /.dockerenv
fi

if [[-r "/.env" ]]; then
  source /.env
fi

echo "Adding loopback alias ${APP_HOST}"
ifconfig lo:0 ${APP_HOST} netmask 255.255.255.0 up

echo "Redirecting ${APP_HOST} port 80 => ${APP_PORT}"
iptables -t nat -A OUTPUT -p tcp -d ${APP_HOST}/32 --dport 80  -j DNAT --to-destination ${APP_HOST}:${APP_PORT}

echo "Running AWS mock metadata service"
$(dirname $0)/aws-mock-metadata --app-port=${APP_PORT} \
  --availability-zone=$AVAILABILITY_ZONE \
  --instance-id=$INSTANCE_ID \
  --hostname=$HOSTNAME \
  --role-name=$ROLE_NAME \
  --role-arn=$ROLE_ARN \
  --vpc-id=$VPC_ID \
  --private-ip=$PRIVATE_IP \
  "${@}"
