#!/bin/bash

set -e -o pipefail

PACKAGE_LOCATION="${1}"
PACKAGECLOUD_REPO="${2}"
PACKAGECLOUD_TOKEN="${3}"

git_tmp_dir=$(mktemp -d /tmp/distro-info-data-XXXXX)

function packagecloud_upload {
    linux_version=$1
    pkg_filename=$2

    echo "==== Uploading packages to ${linux_version} ==="

    package_cloud push "${PACKAGECLOUD_REPO}/${linux_version}" ${pkg_filename} < /dev/null || true
}

gem install --no-document package_cloud
cat << EOF > ~/.packagecloud
{
  "url": "https://packagecloud.io",
  "token": "${PACKAGECLOUD_TOKEN}"
}
EOF

# Fetch current debian/ubuntu versions
git clone --depth 1 https://salsa.debian.org/debian/distro-info-data "${git_tmp_dir}"

# Loop over all directories
while IFS= read -r -d '' path
do
    if [ "$(basename "${path}")" == "all" ]; then
        # Upload these debs to all current debian/ubuntu versions

        for release in $(awk -F ',' -v today="$(date --utc "+%F")" \
            'BEGIN {OFS=","} NR>1 { if (($6 == "" || $6 >= today) && ($5 != "" && $5 <= today)) print $3 }' \
            "${git_tmp_dir}/ubuntu.csv"); do
            packagecloud_upload "ubuntu/${release}" "${path}/*.deb"
        done

        for release in $(awk -F ',' -v today="$(date --utc "+%F")" \
            'BEGIN {OFS=","} NR>1 { if (($6 == "" || $6 >= today) && ($4 != "" && $4 <= today)) print $3 }' \
            "${git_tmp_dir}/debian.csv" | grep -v -E "(buster|sid|experimental)"); do
            packagecloud_upload "debian/${release}" "${path}/*.deb"
            packagecloud_upload "raspbian/${release}" "${path}/*.deb"
        done
    else
        # Upload just this specific version of debian or ubuntu
        IFS=_ read -r distro release <<< "$(basename "${path}")"

        packagecloud_upload "${distro}/${release}" "${path}/*.deb"
    fi
done <   <(find "${PACKAGE_LOCATION}" -mindepth 1 -maxdepth 1 -type d -print0)

rm -rf "${git_tmp_dir}"
