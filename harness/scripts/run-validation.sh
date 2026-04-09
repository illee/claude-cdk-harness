#!/usr/bin/env bash
# run-validation.sh
# CDK 프로젝트 전체 검증 파이프라인 실행
# Usage: ./run-validation.sh <project-dir>

set -euo pipefail

PROJECT_DIR="${1:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

pass() { echo -e "${GREEN}[PASS]${NC} $1"; ((PASS_COUNT++)); }
fail() { echo -e "${RED}[FAIL]${NC} $1"; ((FAIL_COUNT++)); }
skip() { echo -e "${YELLOW}[SKIP]${NC} $1"; ((SKIP_COUNT++)); }

echo "=== CDK Validation Pipeline ==="
echo "Project: ${PROJECT_DIR}"
echo ""

cd "${PROJECT_DIR}"

# 1. npm ci
echo "--- Step 1: Install Dependencies ---"
if npm ci --silent 2>/dev/null; then
  pass "npm ci"
else
  fail "npm ci"
  echo "Attempting npm install..."
  npm install --silent 2>/dev/null || fail "npm install"
fi

# 2. Build
echo ""
echo "--- Step 2: TypeScript Build ---"
if npm run build 2>&1; then
  pass "npm run build"
else
  fail "npm run build"
  echo "Build failed. Subsequent steps may also fail."
fi

# 3. Lint
echo ""
echo "--- Step 3: Lint ---"
if npm run lint 2>&1; then
  pass "npm run lint"
else
  fail "npm run lint"
fi

# 4. Test
echo ""
echo "--- Step 4: Unit Tests ---"
if npm test 2>&1; then
  pass "npm test"
else
  fail "npm test"
fi

# 5. CDK Synth
echo ""
echo "--- Step 5: CDK Synth ---"
if npx cdk synth 2>&1; then
  pass "cdk synth"
else
  fail "cdk synth"
fi

# 6. cdk-nag (included in synth output if configured)
echo ""
echo "--- Step 6: cdk-nag ---"
if [[ -d "cdk.out" ]]; then
  # cdk-nag results are in the synth output
  NAG_ERRORS=$(grep -r "AwsSolutions-" cdk.out/ 2>/dev/null | grep -c "Error" || true)
  if [[ "${NAG_ERRORS}" -gt 0 ]]; then
    fail "cdk-nag: ${NAG_ERRORS} error(s) found"
  else
    pass "cdk-nag: no errors"
  fi
else
  skip "cdk-nag: no cdk.out directory"
fi

# 7. cfn-guard
echo ""
echo "--- Step 7: cfn-guard ---"
GUARD_DIR="${GUARD_DIR:-${CLAUDE_PLUGIN_ROOT:-../..}/policies/guard}"
if command -v cfn-guard &>/dev/null && [[ -d "${GUARD_DIR}" ]]; then
  TEMPLATES=$(find cdk.out -name "*.template.json" 2>/dev/null)
  if [[ -n "${TEMPLATES}" ]]; then
    GUARD_FAIL=0
    for tmpl in ${TEMPLATES}; do
      if ! cfn-guard validate --data "${tmpl}" --rules "${GUARD_DIR}/" 2>&1; then
        ((GUARD_FAIL++))
      fi
    done
    if [[ "${GUARD_FAIL}" -eq 0 ]]; then
      pass "cfn-guard"
    else
      fail "cfn-guard: ${GUARD_FAIL} template(s) failed"
    fi
  else
    skip "cfn-guard: no templates found"
  fi
else
  skip "cfn-guard: not installed or no guard rules"
fi

# 8. CDK Diff
echo ""
echo "--- Step 8: CDK Diff ---"
if aws sts get-caller-identity &>/dev/null; then
  if npx cdk diff 2>&1; then
    pass "cdk diff"
  else
    fail "cdk diff"
  fi
else
  skip "cdk diff: AWS credentials not available"
fi

# Summary
echo ""
echo "==========================================="
echo "=== Validation Summary ==="
echo -e "${GREEN}PASS: ${PASS_COUNT}${NC}"
echo -e "${RED}FAIL: ${FAIL_COUNT}${NC}"
echo -e "${YELLOW}SKIP: ${SKIP_COUNT}${NC}"
echo "==========================================="

if [[ "${FAIL_COUNT}" -gt 0 ]]; then
  exit 1
fi
