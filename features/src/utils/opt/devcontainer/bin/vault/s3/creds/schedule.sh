#! /usr/bin/env bash

schedule_s3_creds_refresh() {

    set -euo pipefail;

    local now="$(date '+%s')";
    local ttl="${VAULT_S3_TTL:-"43200"}";
    ttl="${ttl%s}";

    local stamp="$(cat ~/.aws/stamp 2>/dev/null || echo "${now}")";
    local then="$((ttl - (now - stamp)))";
    then="$((then < ttl ? ttl : then))";
    then="$((((then + 59) / 60) * 60))";
    then="$((now + then))";

    crontab -u $(whoami) -r 2>/dev/null || true;

    cat <<____EOF | crontab -u $(whoami) -
SHELL=/bin/bash
BASH_ENV="${BASH_ENV:-}"
VAULT_HOST="${VAULT_HOST:-}"
GITHUB_USER="${GITHUB_USER:-}"
VAULT_S3_TTL="${VAULT_S3_TTL:-}"
SCCACHE_BUCKET="${SCCACHE_BUCKET:-}"
SCCACHE_REGION="${SCCACHE_REGION:-}"
VAULT_GITHUB_ORGS="${VAULT_GITHUB_ORGS:-}"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-}"
$(date --date="@${then}" '+%M %H %d %m %w') \
bash -lc 'devcontainer-utils-vault-s3-creds-generate && devcontainer-utils-vault-s3-creds-schedule' 2>&1 | tee -a /var/log/devcontainer-utils-vault-s3-creds-refresh.log
____EOF

    sudo /etc/init.d/cron restart >/dev/null 2>&1;
}

if test -n "${devcontainer_utils_debug:-}"; then
    PS4="+ ${BASH_SOURCE[0]}:\${LINENO} "; set -x;
fi

(schedule_s3_creds_refresh "$@");
