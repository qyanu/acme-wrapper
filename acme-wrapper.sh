#!/bin/bash
set -u

#################################
#### configuration variables ####

# re-request 3 days before expiry
# value is in seconds
RESUBMIT_BEFORE=$((3*24*60*60))

# rsa key pairs (user account and certificate private keys) should have
# that many number of bits
RSA_KEY_BITS=4096

# don't re-retrieve intermediate and ca certificates if file was modified
# as recent as these many seconds
RETRIEVE_COOLDOWN=2592000 # seconds: 30 days

# directory to write acme-challenge files into and that will be
# publicly available at http://<domain>/.well-known/acme-challenge
ACME_CHALLENGE_DIR="/var/www/acme-challenge"


######################################
#### configuration of directories ####

mydir="$(dirname "$0")"
keysdir="${mydir}/private"
certsdir="${mydir}/public"
cadir="${mydir}/authority"
accountdir="${mydir}/account"
etcdir="${mydir}/etc"
opensslconfig="${etcdir}/openssl.cnf"


###############################
#### codes from sysexits.h ####
EX_OK=0
EX_USAGE=64
EX_NOINPUT=66
EX_UNAVAILABLE=69


echoerr() {
    echo "[$$]" "$@" >&2
}

echolog() {
    echo "[$$]" "$@"
}

printhelp() {
    echoerr "$0 [COMMAND] [OPTIONS] [FQDN] [SANs]"
    echoerr ""
    echoerr "wrapper around acme-tiny intended to be automatically executed"
    echoerr "by cron et al"
    echoerr ""
    echoerr "COMMAND:"
    echoerr "  --help display this help and exit"
    echoerr "  --create-account generate a new rsa key-pair used as letsencrypt account"
    echoerr ""
    echoerr "OPTIONS:"
    echoerr "  --all select all FQDNs plus SANs from etc/domains.list"
    echoerr ""
    echoerr "FQDN:"
    echoerr "  the first non-option parameter is the fully qualified domain name"
    echoerr "  of the certificate to be processed by the command"
    echoerr ""
    echoerr "SAN(s):"
    echoerr "  all other non-option parameters are additional fqdns for the same"
    echoerr "  certificate, used as subject-alternative-name(s)"
    echoerr ""
}

parse_cmdline() {
    [[ "$#" -eq 0 ]] && {
        printhelp
        exit $EX_USAGE
    }

    OPT_ALL=0
    FQDNS=()

    while [[ $# > 0 ]]
    do
        key="$1"

        case "$key" in
            # commands
            --help)
                printhelp
                exit $EX_USAGE
                ;;
            --create-account)
                CMD="create_account"
                ;;

            # options
            --all)
                OPT_ALL=1
                ;;

            # FQDNs (including SANs)
            *)
                FQDNS+=("$key")
                ;;
        esac
        shift
    done

    [[ "$OPT_ALL" -eq 1 && "${#FQDNS[@]}" -gt 0 ]] && {
        echoerr "ERROR: option --all and specifying FQDNs are mutually exclusive"
        exit $EX_USAGE
    }

    # [[ "$OPT_ALL" -eq 0 && "${#FQDNS[@]}" -lt 1 ]] && {
    #     echoerr "ERROR: no domainnames given: ${#FQDNS[@]}"
    #     exit $EX_USAGE
    # }
}

create_account() {
    [[ "${#FQDNS[@]}" -gt 0 ]] && {
        echoerr "INFO: ignoring specified fqdns, the same account rsa-keypair"
        echoerr "is used for all remote operations"
    }

    # ask if account.key should be overwritten
    [[ -e "${accountdir}/current" ]] && {
        echoerr "WARN: private key file already exists: ${accountdir}/current"
        read -p "Overwrite? [y|n] " yesno
        [[ "$yesno" != "y" ]] && {
            echoerr "aborting."
            exit $EX_NOINPUT
        }
    }

    commit=1

    # make new directory in order to be able to roll back
    datestr="$(date +%Y-%m-%d-%H-%M-%S)"
    linkname="current"
    mkdir -p "${accountdir}/${datestr}"
    chmod go-rwx "${accountdir}/${datestr}"

    keyfile="${accountdir}/${datestr}/account_key.pem"
    pubfile="${accountdir}/${datestr}/account_pub.pem"

    echolog "INFO: Generating RSA keypair, ${RSA_KEY_BITS} bit long modulus"
    openssl genpkey -algorithm RSA \
        -pkeyopt rsa_keygen_bits:"$RSA_KEY_BITS" \
        -out "${keyfile}" -outform PEM -text 2>/dev/null
    [[ "$?" -ne 0 ]] && commit=0;
    chmod go-rwx "${keyfile}"
    [[ "$?" -ne 0 ]] && commit=0;

    openssl rsa -in "${keyfile}" -check -noout 
    [[ "$?" -ne 0 ]] && commit=0;

    openssl rsa -in "${keyfile}" -pubout -text > "${pubfile}"
    [[ "$?" -ne 0 ]] && commit=0;
    chmod go-rwx "${pubfile}"
    [[ "$?" -ne 0 ]] && commit=0;

    # commit transaction if no error
    if [[ "$commit" -eq 1 ]]; then
        ln -snf "${datestr}" "${accountdir}/${linkname}"
    else
        echoerr "ERROR: no committing work, previous state retained"
    fi
}

main() {
    # if OPT_ALL, read all lines from etc/domains.list into $FQDNS[]
    if [[ "$OPT_ALL" -eq 1 ]];
    then
        [[ -r "${etcdir}/domains.list" ]] || {
            echoerr "ERROR: cannot read ${etcdir}/domains.list"
            exit $EX_NOINPUT
        }

        while read line; do
            # skip comments
            [[ "$line" =~ ^\ *# ]] && continue;
            # skip empty lines
            [[ "$line" =~ ^\ *$ ]] && continue;
            # expand the line into fqdns
            # it's simple, because each line is a space-seperated list of
            # fqdns
            FQDNS=($line)
            # execute command
            $CMD
        done <"${etcdir}/domains.list"
    else
        # FQDNS already expanded/set by parse_cmdline
        # execute command
        $CMD
    fi
}

parse_cmdline "$@"
main
