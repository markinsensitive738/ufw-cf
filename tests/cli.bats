#!/usr/bin/env bats

load helpers

setup()    { setup_mocks; }
teardown() { teardown_mocks; }

@test "version prints expected format" {
    run ufw_cf --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ ^ufw-cf\ v[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "help mentions all subcommands" {
    run ufw_cf --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"sync"* ]]
    [[ "$output" == *"status"* ]]
    [[ "$output" == *"enable"* ]]
    [[ "$output" == *"disable"* ]]
    [[ "$output" == *"clean"* ]]
}

@test "unknown command exits non-zero" {
    run ufw_cf wat
    [ "$status" -ne 0 ]
}

@test "sync calls ufw allow once per ip per port" {
    run ufw_cf sync
    [ "$status" -eq 0 ]
    # 2 v4 + 1 v6 = 3 ips, 2 ports = 6 allow calls
    allow_calls="$(grep -c 'ufw allow' "$MOCK_LOG" || true)"
    [ "$allow_calls" -eq 6 ]
}

@test "sync writes state files and timestamp" {
    run ufw_cf sync
    [ "$status" -eq 0 ]
    [ -s "$UFW_CF_STATE_DIR/ips-v4" ]
    [ -s "$UFW_CF_STATE_DIR/ips-v6" ]
    [ -s "$UFW_CF_STATE_DIR/last-sync" ]
}

@test "sync skips ipv6 when IPV6=false" {
    cat > "$UFW_CF_CONFIG" <<EOF
PORTS="80,443"
IPV6=false
EOF
    run ufw_cf sync
    [ "$status" -eq 0 ]
    # 2 v4 ips, 2 ports = 4 allow calls
    allow_calls="$(grep -c 'ufw allow' "$MOCK_LOG" || true)"
    [ "$allow_calls" -eq 4 ]
}

@test "sync respects custom PORTS" {
    cat > "$UFW_CF_CONFIG" <<EOF
PORTS="443"
IPV6=true
EOF
    run ufw_cf sync
    [ "$status" -eq 0 ]
    # 3 ips, 1 port = 3 allow calls
    allow_calls="$(grep -c 'ufw allow' "$MOCK_LOG" || true)"
    [ "$allow_calls" -eq 3 ]
    grep -q 'port 443' "$MOCK_LOG"
    ! grep -q 'port 80 ' "$MOCK_LOG"
}

@test "sync rejects garbage from cloudflare endpoint" {
    echo "this is not a cidr range" > "$TEST_TMP/v4.txt"
    run ufw_cf sync
    [ "$status" -ne 0 ]
    [[ "$output" == *"could not fetch"* ]]
}

@test "sync rejects empty response" {
    : > "$TEST_TMP/v4.txt"
    run ufw_cf sync
    [ "$status" -ne 0 ]
}

@test "sync rejects invalid PORTS in config" {
    cat > "$UFW_CF_CONFIG" <<EOF
PORTS="80,abc"
IPV6=false
EOF
    run ufw_cf sync
    [ "$status" -ne 0 ]
    [[ "$output" == *"invalid port"* ]]
}

@test "sync rejects out-of-range port" {
    cat > "$UFW_CF_CONFIG" <<EOF
PORTS="99999"
IPV6=false
EOF
    run ufw_cf sync
    [ "$status" -ne 0 ]
    [[ "$output" == *"out of range"* ]]
}

@test "status reports never when no sync has run" {
    run ufw_cf status
    [ "$status" -eq 0 ]
    [[ "$output" == *"never"* ]]
}

@test "status reports last-sync timestamp" {
    echo "2025-01-01T00:00:00Z" > "$UFW_CF_STATE_DIR/last-sync"
    run ufw_cf status
    [ "$status" -eq 0 ]
    [[ "$output" == *"2025-01-01T00:00:00Z"* ]]
}

@test "clean removes state files" {
    echo dummy > "$UFW_CF_STATE_DIR/ips-v4"
    echo dummy > "$UFW_CF_STATE_DIR/ips-v6"
    echo "2025-01-01T00:00:00Z" > "$UFW_CF_STATE_DIR/last-sync"
    run ufw_cf clean
    [ "$status" -eq 0 ]
    [ ! -e "$UFW_CF_STATE_DIR/ips-v4" ]
    [ ! -e "$UFW_CF_STATE_DIR/ips-v6" ]
    [ ! -e "$UFW_CF_STATE_DIR/last-sync" ]
}

@test "enable invokes systemctl on the timer" {
    run ufw_cf enable
    [ "$status" -eq 0 ]
    grep -q 'systemctl enable --now ufw-cf.timer' "$MOCK_LOG"
}

@test "disable invokes systemctl on the timer" {
    run ufw_cf disable
    [ "$status" -eq 0 ]
    grep -q 'systemctl disable --now ufw-cf.timer' "$MOCK_LOG"
}
