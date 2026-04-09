# Handoff: cdk-generator → validator-agent

## Context
cdk-generator가 CDK TypeScript 프로젝트를 생성했습니다.

## 전달 파일
- 생성된 CDK 프로젝트 디렉터리 전체 (`workspaces/<app-name>/`)
- `docs/spec.md` (갱신됨)
- `docs/adr.md` (갱신됨)

## validator-agent에게 요청

1. 프로젝트 디렉터리로 이동하세요.
2. `aws-cdk-validation` skill에 정의된 검증 순서를 따라 실행하세요:
   - npm ci → build → lint → test → synth → cdk-nag → cfn-guard → diff
3. 각 단계의 결과를 기록하세요.
4. 실패 항목은 category(code/environment/policy/permission/network)로 분류하세요.
5. 자동 수정 가능한 항목은 수정을 시도하세요.
6. `docs/validation-report.md`를 생성하세요.

## 주의사항
- 앞 단계(build)가 실패하면 뒷 단계(synth)를 생략할 수 있습니다.
- suppress는 최후 수단이며, 적용 시 이유를 문서화하세요.
- cfn-guard는 `${CLAUDE_PLUGIN_ROOT}/policies/guard/` 디렉터리에 규칙이 있을 때만 실행하세요.
- diff는 AWS credentials가 있을 때만 실행하세요.
