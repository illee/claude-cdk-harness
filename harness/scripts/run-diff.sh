#!/usr/bin/env bash
# run-diff.sh
# CDK diff를 실행하고 결과를 요약한다.
# Usage: ./run-diff.sh <project-dir> [stack-name]

set -euo pipefail

PROJECT_DIR="${1:-.}"
STACK_NAME="${2:-}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== CDK Diff ==="
echo "Project: ${PROJECT_DIR}"
echo ""

cd "${PROJECT_DIR}"

# Identity check
echo "--- Identity ---"
if ! aws sts get-caller-identity --output json 2>/dev/null; then
  echo -e "${RED}ERROR: AWS credentials not configured${NC}"
  exit 1
fi

echo ""
echo "--- Running diff ---"

DIFF_CMD="npx cdk diff"
if [[ -n "${STACK_NAME}" ]]; then
  DIFF_CMD="${DIFF_CMD} ${STACK_NAME}"
else
  DIFF_CMD="${DIFF_CMD} --all"
fi

DIFF_OUTPUT=$(${DIFF_CMD} 2>&1) || true
echo "${DIFF_OUTPUT}"

# Analyze diff output for destructive changes
echo ""
echo "--- Analysis ---"

CREATES=$(echo "${DIFF_OUTPUT}" | grep -c "^\[+\]" || true)
UPDATES=$(echo "${DIFF_OUTPUT}" | grep -c "^\[~\]" || true)
DELETES=$(echo "${DIFF_OUTPUT}" | grep -c "^\[-\]" || true)
REPLACES=$(echo "${DIFF_OUTPUT}" | grep -ci "replacement" || true)

echo "Create: ${CREATES}"
echo "Update: ${UPDATES}"

if [[ "${DELETES}" -gt 0 ]]; then
  echo -e "${YELLOW}Delete: ${DELETES}${NC} (review carefully)"
fi

if [[ "${REPLACES}" -gt 0 ]]; then
  echo -e "${RED}Replace: ${REPLACES}${NC} (DANGER: resource replacement may cause data loss)"
fi

# Security changes
SG_CHANGES=$(echo "${DIFF_OUTPUT}" | grep -ci "SecurityGroup\|security.group" || true)
IAM_CHANGES=$(echo "${DIFF_OUTPUT}" | grep -ci "IAM\|Policy\|Role" || true)

if [[ "${SG_CHANGES}" -gt 0 ]]; then
  echo -e "${YELLOW}Security Group changes detected: ${SG_CHANGES}${NC}"
fi

if [[ "${IAM_CHANGES}" -gt 0 ]]; then
  echo -e "${YELLOW}IAM/Policy changes detected: ${IAM_CHANGES}${NC}"
fi

if [[ "${DELETES}" -eq 0 && "${REPLACES}" -eq 0 ]]; then
  echo -e "${GREEN}No destructive changes detected.${NC}"
fi
