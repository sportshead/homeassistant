#!/usr/bin/with-contenv bashio
set -e

/usr/sbin/crond -f -l 8

bashio::config.suggest.false 'dry' 'acme.sh will not be called until `dry` is disabled.'
bashio::config.require 'email' 'The email will be used for notifications about the domain.'
bashio::config.require 'domain'
bashio::config.require 'cf.token'
bashio::config.require 'cf.account_id'
bashio::config.suggest 'cf.zone_id' 'Not setting the zone_id requires all zones to be enabled in the token permissions'

if bashio::config.true 'dry'; then
    _ACME="echo"
else
    _ACME="/acme.sh/acme.sh --home /data/acme.sh"
fi

mkdir -p /data/cf-dns-ssl
touch /data/cf-dns-ssl/olddomain.txt
touch /data/cf-dns-ssl/oldemail.txt

if ! bashio::config.equals 'email' "$(cat /data/cf-dns-ssl/oldemail.txt)"; then
    EMAIL="$(bashio::config 'email')"

    $_ACME --update-account --accountemail "$EMAIL"
    echo -n "$EMAIL" >/data/cf-dns-ssl/oldemail.txt
fi

if ! bashio::config.equals 'domain' "$(cat /data/cf-dns-ssl/olddomain.txt)"; then
    export CF_Token="$(bashio::config 'cf.token')"
    export CF_Account_ID="$(bashio::config 'cf.account_id')"
    export CF_Zone_ID="$(bashio::config 'cf.zone_id')"

    DOMAIN="$(bashio::config 'domain')"
    SERVER="$(bashio::config 'server')"
    EMAIL="$(bashio::config 'email')"

    if bashio::var.has_value $(cat /data/cf-dns-ssl/olddomain.txt); then
        $_ACME --remove -d "$(cat /data/cf-dns-ssl/olddomain.txt)"
    fi

    $_ACME --install-cert \
        --dns dns_cf \
        -d "$DOMAIN" \
        --key-file /ssl/privkey.pem \
        --fullchain-file /ssl/fullchain.pem \
        --server "$SERVER" \
        --email "$EMAIL"

    echo -n "$DOMAIN" >/data/cf-dns-ssl/olddomain.txt
fi
