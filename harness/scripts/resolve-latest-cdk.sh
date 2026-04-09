#!/usr/bin/env bash
# resolve-latest-cdk.sh
# npm registry에서 aws-cdk-lib 최신 안정 버전을 조회한다.
# 출력: 버전 문자열 (예: 2.175.1)

set -euo pipefail

CDK_PACKAGE="aws-cdk-lib"
CONSTRUCTS_PACKAGE="constructs"

echo "=== Resolving latest stable CDK versions ==="

# aws-cdk-lib 최신 버전
CDK_VERSION=$(npm view "${CDK_PACKAGE}" version 2>/dev/null)
if [[ -z "${CDK_VERSION}" ]]; then
  echo "ERROR: Failed to resolve ${CDK_PACKAGE} version" >&2
  exit 1
fi
echo "aws-cdk-lib: ${CDK_VERSION}"

# constructs 호환 버전
CONSTRUCTS_VERSION=$(npm view "${CONSTRUCTS_PACKAGE}" version 2>/dev/null)
if [[ -z "${CONSTRUCTS_VERSION}" ]]; then
  echo "ERROR: Failed to resolve ${CONSTRUCTS_PACKAGE} version" >&2
  exit 1
fi
echo "constructs: ${CONSTRUCTS_VERSION}"

# aws-cdk CLI (devDependency) - aws-cdk-lib과 동일 버전 사용
echo "aws-cdk (cli): ${CDK_VERSION}"

# JSON 출력 (다른 스크립트에서 파싱 가능)
echo ""
echo "=== JSON ==="
cat <<EOF
{
  "aws-cdk-lib": "${CDK_VERSION}",
  "constructs": "${CONSTRUCTS_VERSION}",
  "aws-cdk": "${CDK_VERSION}"
}
EOF
