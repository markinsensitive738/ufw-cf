# Common helpers for ufw-cf bats tests.

setup_mocks() {
    export TEST_TMP="$(mktemp -d)"
    export MOCK_BIN="$TEST_TMP/bin"
    export MOCK_LOG="$TEST_TMP/calls.log"
    export UFW_CF_CONFIG="$TEST_TMP/config"
    export UFW_CF_STATE_DIR="$TEST_TMP/state"
    export UFW_CF_V4_URL="file://$TEST_TMP/v4.txt"
    export UFW_CF_V6_URL="file://$TEST_TMP/v6.txt"
    export NO_COLOR=1
    mkdir -p "$MOCK_BIN" "$UFW_CF_STATE_DIR"
    : > "$MOCK_LOG"

    cat > "$TEST_TMP/v4.txt" <<EOF
1.2.3.0/24
5.6.7.0/24
EOF
    cat > "$TEST_TMP/v6.txt" <<EOF
2400:cb00::/32
EOF

    # Make tests run as "root" by short-circuiting id.
    cat > "$MOCK_BIN/id" <<'EOF'
#!/usr/bin/env bash
echo 0
EOF

    cat > "$MOCK_BIN/ufw" <<'EOF'
#!/usr/bin/env bash
printf 'ufw %s\n' "$*" >> "$MOCK_LOG"
case "$1" in
    status)
        echo "Status: active"
        echo
        echo "     To                         Action      From"
        echo "     --                         ------      ----"
        ;;
esac
exit 0
EOF

    cat > "$MOCK_BIN/systemctl" <<'EOF'
#!/usr/bin/env bash
printf 'systemctl %s\n' "$*" >> "$MOCK_LOG"
case "$1" in
    is-active|is-enabled) exit 1 ;;
    list-unit-files) exit 0 ;;
esac
exit 0
EOF

    chmod +x "$MOCK_BIN"/*
    export PATH="$MOCK_BIN:$PATH"
}

teardown_mocks() {
    [ -n "${TEST_TMP:-}" ] && rm -rf "$TEST_TMP"
}

ufw_cf() {
    "$BATS_TEST_DIRNAME/../bin/ufw-cf" "$@"
}
