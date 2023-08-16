#!/usr/bin/with-contenv bashio

/usr/sbin/crond -f -l 8

if bashio::config.true 'dry'; then
    _ACME="echo"
else
    _ACME="/acme.sh/acme.sh --home /data/acme.sh"
fi

# track changes
mkdir -p /data/cf-dns-ssl
touch /data/cf-dns-ssl/olddomain.txt
touch /data/cf-dns-ssl/oldemail.txt

if bashio::config.has_value 'email' &&
	! bashio::config.equals 'email' "$(cat /data/cf-dns-ssl/oldemail.txt)"; then

	EMAIL="$(bashio::config 'email')"

	$_ACME --update-account --accountemail "$EMAIL" &&
		echo -n "$EMAIL" >/data/cf-dns-ssl/oldemail.txt
fi

if bashio::config.has_value 'domain' &&
	! bashio::config.equals 'domain' "$(cat /data/cf-dns-ssl/olddomain.txt)" &&
	bashio::config.has_value 'email' &&
	bashio::config.has_value 'cf.token' &&
	bashio::config.has_value 'cf.account_id' &&
	bashio::config.has_value 'cf.zone_id'; then

	export CF_Token="$(bashio::config 'cf.token')"
	export CF_Account_ID="$(bashio::config 'cf.account_id')"
	export CF_Zone_ID="$(bashio::config 'cf.zone_id')"

	DOMAIN="$(bashio::config 'domain')"
	SERVER="$(bashio::config 'server')"
	EMAIL="$(bashio::config 'email')"

	$_ACME --install-cert \
		--dns dns_cf \
		-d "$DOMAIN" \
		--key-file /ssl/privkey.pem \
		--fullchain-file /ssl/fullchain.pem \
		--server "$SERVER" \
		--email "$EMAIL" &&
		echo -n "$DOMAIN" >/data/cf-dns-ssl/olddomain.txt
fi
