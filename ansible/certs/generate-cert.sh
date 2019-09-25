#!/bin/bash
# Марко М. Костић (Marko M. Kostic)
# Requires: openssl, idn, recode-sr-latin, awk
# You need to generate root CA key annd cert before executing this script
# $ openssl genrsa -aes128 -out rootCA.key 8192
# $ openssl req -x509 -utf8 -new -nodes -key rootCA.key -sha512 -days 3650 \
# -subj "/C=RS/ST=Србија/O=Костић.дом/CN=Костић главно сертификационо тело - 2019" \
# -out rootCA.crt

function usage()
{
    printf "Usage:\n"
    printf "./generate-cert.sh\n"
    printf "\t-h --help\n"
    printf "\t-d=<domain-name OR --domain=<domain-name>\n"
}

while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    case $PARAM in
        -h | --help)
            usage
            exit 0
            ;;
        -d | --domain)
            DOMAIN=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [[ $DOMAIN == "" ]]; then
    usage;
    exit 0;
fi

# domain to lower case
DOMAIN=$(echo $DOMAIN | awk '{print tolower($0)}')

export PUNNY_DOMAIN=$(echo -n $DOMAIN | idn -a)
export LATIN_DOMAIN=$(echo $DOMAIN | recode-sr-latin)

# remove non-English chars from the $LATIN_DOMAIN
LATIN_DOMAIN=$(echo $LATIN_DOMAIN | sed 's/ć/c/g' | sed 's/č/c/g' \
| sed 's/dž/dz/g' | sed 's/đ/dj/g' | sed 's/š/s/g' | sed 's/ž/z/g')

# generate new key and cert
openssl genrsa -out $LATIN_DOMAIN.key 4096
openssl req -new -utf8 -sha512 -key $LATIN_DOMAIN.key \
-subj "/C=RS/ST=Србија/O=Костић.дом/CN=$PUNNY_DOMAIN" -out $LATIN_DOMAIN.csr

# sign the newly generated cert via our root CA
openssl x509 -req -extfile \
<(printf "subjectAltName=DNS:$PUNNY_DOMAIN,DNS:*.$PUNNY_DOMAIN") \
-days 1095 -sha512 -in $LATIN_DOMAIN.csr -CA rootCA.crt -CAkey rootCA.key \
-CAcreateserial -out $LATIN_DOMAIN.crt

# remove CSR and sort the cert into a folder
rm $LATIN_DOMAIN.csr
mkdir -p ./$LATIN_DOMAIN
mv ./$LATIN_DOMAIN.* ./$LATIN_DOMAIN/

exit 0