#!/usr/bin/env bash

set -eo pipefail

usage() { 
    echo "Usage: $0 [-a <AWS Version String>] [-t <Terraform Version String>]" 1>&2
    exit 1
}

while getopts ":a:t:" o; do
    case "${o}" in
        a)
            aws_cli_version=${OPTARG}
            ;;
        t)
            terraform_version=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${aws_cli_version}" ] || [ -z "${terraform_version}" ] ; then
    usage
fi

echo -n "Generating test configuration with AWS_CLI_VERSION=${aws_cli_version} "
echo "and TERRAFORM_VERSION=${terraform_version}"

export TERRAFORM_VERSION=${terraform_version} && export AWS_CLI_VERSION=${aws_cli_version}

for template_file in $(find tests -name "*.template.yaml" -type f); do
    echo "Generating ${template_file%.template}"
    envsubst '${AWS_CLI_VERSION},${TERRAFORM_VERSION}' < "${template_file}" > "tests/test.yaml"
done

exit 0