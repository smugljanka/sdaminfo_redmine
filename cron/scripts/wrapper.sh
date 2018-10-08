#!/usr/bin/env sh
set -e

# Initialize variables
cmdname=$(basename $0)

usage()
{
    cat << USAGE >&2
Usage:
    $cmdname -stack STACK_NAME --service NAME [-- command ]
    --stack STACK      stack name
    --service SERVICE  service name
    -- command         Execute command with args after the test finishes
USAGE
    exit 1
}

# process arguments
while [[ $# -gt 0 ]]
do
    case "$1" in
        --stack )
                STACK=$2
                shift 2
                ;;
        --service)
                SERVICE=$2
                shift 2
                ;;
        --)
                shift
                CLI="$@"
                break
                ;;
        --help)
                usage
                ;;
        *)
                echo "Unknown argument: $1"
                usage
                ;;
    esac
done

if [[ "$STACK" == "" || "$SERVICE" == "" ]]; then
    echo "Error: you need to provide a stack and related service."
    usage
fi

# Get container IDs related to the given STACK and SERVICE
ids=$(docker ps --format "{{.ID}} {{.Names}}" | grep "${STACK}_${SERVICE}" | cut -d " " -f1)
for i in $ids; do
    docker exec ${i} sh -c "${CLI}"
done

