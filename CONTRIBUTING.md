# Contributing

Thanks for taking the time. ufw-cf intentionally stays small — please keep
patches focused.

## Local development

```bash
make lint     # shellcheck everything
make test     # bats tests with mocked ufw/curl
make deb      # build a .deb under dist/
```

You can run the script straight from the repo:

```bash
sudo NO_COLOR=1 \
  UFW_CF_CONFIG=$(pwd)/systemd/config.example \
  UFW_CF_STATE_DIR=/tmp/ufw-cf-state \
  ./bin/ufw-cf status
```

## Style

- Bash 4+, `set -euo pipefail`, 4-space indent.
- Pass `shellcheck` clean — no disables without a comment.
- Keep the script free of jq/python/etc. Stick to coreutils.

## Pull requests

- One logical change per PR.
- Include or update tests in `tests/`.
- Update `README.md` if the user-visible behaviour changes.
- Bump `VERSION` in `bin/ufw-cf` and `debian/DEBIAN/control` for releases —
  the maintainers will tag.

## Reporting bugs

Please include:

- Distro and version (`lsb_release -a`).
- `ufw --version`, `bash --version`, `systemctl --version`.
- The output of `sudo ufw-cf status` and the failing command with `bash -x`.
