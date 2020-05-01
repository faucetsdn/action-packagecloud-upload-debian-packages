# action-packagecloud-upload-debian-packages

Github action for uploading debian packages to packagecloud.

## Inputs

### `path`

**Required** Path to a directory full of packages with the following structure:

```
all/*.deb
distro_version1/*.deb
distro_version2/*.deb
distro_versionN/*.deb
```

Packages in the `all/` directory will be uploaded to all currently supported
Debian and Ubuntu versions.

Packages in the `distro_version/` directory (e.g. debian_buster) will just be
uploaded to that particular version of Debian or Ubuntu.

### `repo`

**Required** The packagecloud repository to upload to

### `token`

**Required** The packagecloud token to use for authentication

## Example usage

```
uses: faucetsdn/action-packagecloud-upload-debian-packages@v1
with:
  path: packages/
  repo: faucetsdn/faucet
  token: ${{ secrets.PACKAGECLOUD_TOKEN }}
```
