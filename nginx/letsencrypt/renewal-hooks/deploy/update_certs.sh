#!/bin/sh

set -e

for domain in $RENEWED_DOMAINS; do
        case $domain in
        *)
                daemon_cert_root=/certs

                # Make sure the certificate and private key files are
                # never world readable, even just for an instant while
                # we're copying them into daemon_cert_root.
                umask 077

                #cp "$RENEWED_LINEAGE/fullchain.pem" "$daemon_cert_root/$domain.cert"
                #cp "$RENEWED_LINEAGE/privkey.pem" "$daemon_cert_root/$domain.key"

                cp --force -H "$RENEWED_LINEAGE/fullchain.pem" "$daemon_cert_root/fullchain.pem"
                cp --force -H "$RENEWED_LINEAGE/privkey.pem" "$daemon_cert_root/privkey.pem"

                # Apply the proper file ownership and permissions for
                # the daemon to read its certificate and key.
                #chown some-daemon "$daemon_cert_root/$domain.cert" \
                #        "$daemon_cert_root/$domain.key"
                #chmod 400 "$daemon_cert_root/$domain.cert" \
                #        "$daemon_cert_root/$domain.key"

                #service some-daemon restart >/dev/null
                ;;
        esac
done

echo "DEPLOY-HOOK FINISHED  $(date +"%F %H:%M")" >> /certs/renewal_status.txt || true