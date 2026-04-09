#!/usr/bin/env bash
# validate-env.sh
# CDK 배포 환경 사전 점검 스크립트
# 필요 도구: aws cli, node, npm, cdk

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

pass() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

echo "=== Environment Validation ==="
echo ""

# 1. Node.js
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  pass "Node.js: ${NODE_VER}"
  # Node 18+ 확인
  MAJOR=$(echo "${NODE_VER}" | sed 's/v//' | cut -d. -f1)
  if [[ "${MAJOR}" -lt 18 ]]; then
    warn "Node.js 18+ recommended (current: ${NODE_VER})"
  fi
else
  fail "Node.js not found"
fi

# 2. npm
if command -v npm &>/dev/null; then
  pass "npm: $(npm --version)"
else
  fail "npm not found"
fi

# 3. AWS CLI
if command -v aws &>/dev/null; then
  pass "AWS CLI: $(aws --version 2>&1 | head -1)"
else
  fail "AWS CLI not found"
fi

# 4. AWS credentials
echo ""
echo "--- AWS Identity ---"
if aws sts get-caller-identity &>/dev/null; then
  IDENTITY=$(aws sts get-caller-identity --output json)
  ACCOUNT=$(echo "${IDENTITY}" | grep -o '"Account": "[^"]*"' | cut -d'"' -f4)
  ARN=$(echo "${IDENTITY}" | grep -o '"Arn": "[^"]*"' | cut -d'"' -f4)
  pass "Account: ${ACCOUNT}"
  pass "Identity: ${ARN}"
else
  fail "AWS credentials not configured or expired"
fi

# 5. AWS Region
echo ""
echo "--- AWS Region ---"
REGION=$(aws configure get region 2>/dev/null || echo "")
if [[ -n "${REGION}" ]]; then
  pass "Region: ${REGION}"
else
  warn "Default region not set (use AWS_DEFAULT_REGION or aws configure)"
fi

# 6. CDK CLI
echo ""
echo "--- CDK CLI ---"
if command -v cdk &>/dev/null; then
  pass "CDK CLI: $(cdk --version)"
else
  if npx cdk --version &>/dev/null; then
    pass "CDK CLI (via npx): $(npx cdk --version)"
  else
    fail "CDK CLI not found (install: npm install -g aws-cdk)"
  fi
fi

# 7. CDK Bootstrap
echo ""
echo "--- CDK Bootstrap ---"
BOOTSTRAP_STACK=$(aws cloudformation describe-stacks --stack-name CDKToolkit --query 'Stacks[0].StackStatus' --output text 2>/dev/null || echo "NOT_FOUND")
if [[ "${BOOTSTRAP_STACK}" == "NOT_FOUND" ]]; then
  warn "CDKToolkit stack not found. Run: npx cdk bootstrap"
elif [[ "${BOOTSTRAP_STACK}" == *"COMPLETE"* ]]; then
  pass "CDKToolkit: ${BOOTSTRAP_STACK}"
else
  warn "CDKToolkit status: ${BOOTSTRAP_STACK}"
fi

# 8. TypeScript
echo ""
echo "--- TypeScript ---"
if command -v tsc &>/dev/null; then
  pass "TypeScript: $(tsc --version)"
elif npx tsc --version &>/dev/null; then
  pass "TypeScript (via npx): $(npx tsc --version)"
else
  warn "TypeScript not found globally (will use project-local)"
fi

echo ""
echo "=== Validation Complete ==="
