# cloudflare-dns01-ssl
Uses [acme.sh](https://acme.sh) and the [Cloudflare API](https://developers.cloudflare.com/api/dns) in order to generate an SSL certificate. Add the following to your homeassistant configuration:
```yaml
http:
    ssl_certificate: /ssl/fullchain.pem
    ssl_key: /ssl/privkey.pem
```
Fill out all the fields for this addon's config. By default, the plugin only `echo`s the arguments that would be passed to acme.sh.
Change `dry` to `false` to run acme.sh. Testing against a staging enviornment (e.g. `letsencrypt_test` instead of `letsencrypt`, see [supported servers](https://github.com/acmesh-official/acme.sh/wiki/Server)) is recommended.

## Cloudflare API token
Your Cloudflare API token should be generated [here](https://dash.cloudflare.com/profile/api-tokens) with the following permissions:

| | | |
|------|------|------|
| Zone | DNS  | Edit |
| Zone | Zone | Read |
