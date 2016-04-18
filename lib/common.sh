set -u

keysdir="${mydir}/private"
certsdir="${mydir}/public"
cadir="${mydir}/authority"
etcdir="${mydir}/etc"
opensslconfig="${etcdir}/openssl.cnf"

echoerr() {
    echo "[$$]" "$@" >&2
}

echolog() {
    echo "[$$]" "$@"
}

main() {
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
            # Note: domains.list allows only domainnames without spaces, thus
            # don't use quotes around $line here
            FQDNS=($line)
            [[ "${#FQDNS[@]}" -gt 0 ]] && { # ignore empty array
                process_fqdns
            }
        done <"${etcdir}/domains.list"
    else
        # Note: FQDNS already set by process_cmdline
        [[ "${#FQDNS[@]}" -gt 0 ]] && { # ignore empty array
            process_fqdns
        }
    fi
}
