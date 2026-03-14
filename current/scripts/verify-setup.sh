#!/usr/bin/env bash
# verify-setup.sh - Smoke test script for Malicious Kubernetes Workshop lab setup
# Run this after completing lab setup to verify all tools and services are working.

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

pass() {
    echo -e "  ${GREEN}[PASS]${NC} $1"
    ((PASS++))
}

fail() {
    echo -e "  ${RED}[FAIL]${NC} $1"
    ((FAIL++))
}

warn() {
    echo -e "  ${YELLOW}[WARN]${NC} $1"
    ((WARN++))
}

check_command() {
    local cmd=$1
    local expected_version=${2:-""}
    if command -v "$cmd" &> /dev/null; then
        local version
        version=$("$cmd" version 2>/dev/null | head -1 || "$cmd" --version 2>/dev/null | head -1 || echo "installed")
        if [ -n "$expected_version" ]; then
            if echo "$version" | grep -q "$expected_version"; then
                pass "$cmd ($version)"
            else
                warn "$cmd installed but version mismatch (got: $version, expected: $expected_version)"
            fi
        else
            pass "$cmd ($version)"
        fi
    else
        fail "$cmd not found in PATH"
    fi
}

echo "=========================================="
echo " Malicious Kubernetes Workshop"
echo " Setup Verification"
echo "=========================================="
echo ""

# --- Section 1: Core Tools ---
echo "--- Core Tools ---"
check_command docker
check_command kubectl "v1.31"
check_command kind "v0.27"
check_command helm "v3.16"
check_command ansible
check_command jq
check_command ngrok

# --- Section 2: Supply Chain Tools ---
echo ""
echo "--- Supply Chain Tools ---"
check_command cosign
check_command crane
check_command syft
check_command grype

# --- Section 3: Docker ---
echo ""
echo "--- Docker ---"
if docker info &> /dev/null; then
    pass "Docker daemon is running"
else
    fail "Docker daemon is not running (try: sudo systemctl start docker)"
fi

if groups | grep -q docker; then
    pass "Current user is in docker group"
else
    warn "Current user is NOT in docker group (you may need sudo for docker commands)"
fi

# --- Section 4: Kind Cluster ---
echo ""
echo "--- Kind Cluster ---"
if kind get clusters 2>/dev/null | grep -q "lab"; then
    pass "Kind cluster 'lab' exists"
else
    warn "Kind cluster 'lab' not found (run: kind create cluster --config=kind-lab-config.yaml)"
fi

if kubectl cluster-info --context kind-lab &> /dev/null; then
    pass "kubectl can reach kind-lab cluster"

    # Check nodes
    NODE_COUNT=$(kubectl get nodes --no-headers 2>/dev/null | wc -l)
    if [ "$NODE_COUNT" -ge 3 ]; then
        pass "Cluster has $NODE_COUNT nodes (expected 3: 1 control-plane + 2 workers)"
    else
        warn "Cluster has $NODE_COUNT nodes (expected 3)"
    fi

    # --- Section 5: K8s Resources ---
    echo ""
    echo "--- K8s Resources ---"
    if kubectl get namespace pls-dont-hack-me &> /dev/null; then
        pass "Namespace 'pls-dont-hack-me' exists"
    else
        warn "Namespace 'pls-dont-hack-me' not found (run: ansible-playbook k8s-ansible-setup.yaml)"
    fi

    if kubectl get namespace monitoring &> /dev/null; then
        pass "Namespace 'monitoring' exists"
    else
        warn "Namespace 'monitoring' not found"
    fi

    if kubectl get namespace tracee-system &> /dev/null; then
        pass "Namespace 'tracee-system' exists"
    else
        warn "Namespace 'tracee-system' not found"
    fi

    # --- Section 6: Helm Releases ---
    echo ""
    echo "--- Helm Releases ---"
    for release in kind-prometheus promtail loki tracee; do
        if helm list --all-namespaces 2>/dev/null | grep -q "$release"; then
            pass "Helm release '$release' is deployed"
        else
            warn "Helm release '$release' not found"
        fi
    done

    for release in falco tetragon; do
        if helm list --all-namespaces 2>/dev/null | grep -q "$release"; then
            pass "Helm release '$release' is deployed"
        else
            warn "Helm release '$release' not found (new tool — run k8s-ansible-setup if not yet deployed)"
        fi
    done

    # --- Section 7: Key Pods ---
    echo ""
    echo "--- Key Pods ---"
    if kubectl get pods -n monitoring --no-headers 2>/dev/null | grep -q "Running"; then
        pass "Monitoring pods are running"
    else
        warn "No running pods in monitoring namespace"
    fi

    if kubectl get pods -n tracee-system --no-headers 2>/dev/null | grep -q "Running"; then
        pass "Tracee pods are running"
    else
        warn "Tracee pods not running"
    fi

    # --- Section 8: Developer Context ---
    echo ""
    echo "--- Contexts ---"
    if kubectl config get-contexts 2>/dev/null | grep -q "developer@kind-lab"; then
        pass "Developer context configured"
    else
        warn "Developer context not configured (set up by k8s-ansible-setup)"
    fi
else
    warn "Cannot reach kind-lab cluster (cluster may not be created yet)"
fi

# --- Section 9: Container Image Pull Test ---
echo ""
echo "--- Image Pull Test ---"
for image in "ubuntu:22.04" "alpine/curl:8.11.1" "bkimminich/juice-shop"; do
    if docker pull "$image" &> /dev/null; then
        pass "Can pull $image"
    else
        fail "Cannot pull $image"
    fi
done

# --- Section 10: ngrok ---
echo ""
echo "--- ngrok ---"
if ngrok config check &> /dev/null 2>&1; then
    pass "ngrok config is valid"
else
    if [ -f "$HOME/.config/ngrok/ngrok.yml" ] || [ -f "$HOME/.ngrok2/ngrok.yml" ]; then
        pass "ngrok config file exists"
    else
        warn "ngrok authtoken not configured (run: ngrok config add-authtoken <token>)"
    fi
fi

# --- Summary ---
echo ""
echo "=========================================="
echo " Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}, ${YELLOW}${WARN} warnings${NC}"
echo "=========================================="

if [ "$FAIL" -gt 0 ]; then
    echo -e "${RED}Some checks failed. Review the output above and fix issues before starting the workshop.${NC}"
    exit 1
elif [ "$WARN" -gt 0 ]; then
    echo -e "${YELLOW}Some warnings — the lab may still work, but review the output above.${NC}"
    exit 0
else
    echo -e "${GREEN}All checks passed! Lab is ready.${NC}"
    exit 0
fi
