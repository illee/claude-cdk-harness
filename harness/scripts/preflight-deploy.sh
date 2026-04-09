#!/usr/bin/env bash
# preflight-deploy.sh
# 배포 전 최종 점검 스크립트
# Usage: ./preflight-deploy.sh <project-dir>

set -euo pipefail

PROJECT_DIR="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

CHECKS_PASSED=0
CHECKS_FAILED=0
CHECKS_WARNED=0

pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((CHECKS_PASSED++)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; ((CHECKS_FAILED++)); }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; ((CHECKS_WARNED++)); }

echo "=== Pre-flight Deploy Check ==="
echo "Project: ${PROJECT_DIR}"
echo ""

cd "${PROJECT_DIR}"

# 1. Package lock exists
echo "--- Dependencies ---"
if [[ -f "package-lock.json" ]]; then
  pass "package-lock.json exists"
else
  fail "package-lock.json missing"
fi

# 2. node_modules exists
if [[ -d "node_modules" ]]; then
  pass "node_modules installed"
else
  fail "node_modules not found (run: npm ci)"
fi

# 3. Build output
echo ""
echo "--- Build ---"
if [[ -d "dist" ]] || [[ -d "build" ]] || find . -name "*.js" -path "*/lib/*" -newer tsconfig.json 2>/dev/null | head -1 | grep -q .; then
  pass "Build output exists"
else
  warn "Build output may be stale (run: npm run build)"
fi

# 4. CDK output
echo ""
echo "--- CDK Synth ---"
if [[ -d "cdk.out" ]]; then
  TEMPLATE_COUNT=$(find cdk.out -name "*.template.json" 2>/dev/null | wc -l | tr -d ' ')
  if [[ "${TEMPLATE_COUNT}" -gt 0 ]]; then
    pass "cdk.out has ${TEMPLATE_COUNT} template(s)"
  else
    fail "cdk.out exists but no templates found"
  fi
else
  fail "cdk.out not found (run: npx cdk synth)"
fi

# 5. Tests pass
echo ""
echo "--- Tests ---"
if npm test --silent 2>/dev/null; then
  pass "Tests pass"
else
  fail "Tests failing"
fi

# 6. AWS Identity
echo ""
echo "--- AWS Environment ---"
if aws sts get-caller-identity &>/dev/null; then
  ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
  REGION=$(aws configure get region 2>/dev/null || echo "not set")
  pass "AWS Account: ${ACCOUNT}"
  pass "AWS Region: ${REGION}"
else
  fail "AWS credentials not valid"
fi

# 7. Bootstrap
BOOTSTRAP_STATUS=$(aws cloudformation describe-stacks --stack-name CDKToolkit --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "${BOOTSTRAP_STATUS}" == *"COMPLETE"* ]]; then
  pass "CDK Bootstrap: ${BOOTSTRAP_STATUS}"
elif [[ "${BOOTSTRAP_STATUS}" == "NOT_FOUND" ]]; then
  fail "CDK Bootstrap: not found (run: npx cdk bootstrap)"
else
  warn "CDK Bootstrap: ${BOOTSTRAP_STATUS}"
fi

# 8. Validation report
echo ""
echo "--- Documentation ---"
if [[ -f "docs/validation-report.md" ]]; then
  pass "Validation report exists"
else
  warn "docs/validation-report.md not found"
fi

if [[ -f "docs/spec.md" ]]; then
  pass "Spec document exists"
else
  warn "docs/spec.md not found"
fi

# Summary
echo ""
echo "==========================================="
echo "=== Preflight Summary ==="
echo -e "${GREEN}PASS: ${CHECKS_PASSED}${NC}"
echo -e "${RED}FAIL: ${CHECKS_FAILED}${NC}"
echo -e "${YELLOW}WARN: ${CHECKS_WARNED}${NC}"
echo "==========================================="

if [[ "${CHECKS_FAILED}" -gt 0 ]]; then
  echo ""
  echo -e "${RED}Preflight FAILED. Resolve issues before deploying.${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}Preflight PASSED. Ready to deploy.${NC}"
  echo ""
  echo "Recommended deploy command:"
  echo "  npx cdk deploy --all --require-approval broadening"
  echo ""
  echo "For production:"
  echo "  npx cdk deploy --all --require-approval any-change"
fi
