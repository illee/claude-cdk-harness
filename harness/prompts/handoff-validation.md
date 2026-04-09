# Handoff: validator-agent → deployment-agent

## Context
validator-agent가 CDK 프로젝트 검증을 완료했습니다.

## 전달 파일
- `docs/validation-report.md` - 검증 결과 보고서
- `docs/spec.md` - 요구사항 명세
- `docs/answers.json` - 구조화된 답변 데이터

## deployment-agent에게 요청

1. `docs/validation-report.md`를 읽어 현재 readiness 상태를 확인하세요.
2. synth-valid와 policy-valid가 모두 yes인 경우에만 배포 계획을 작성하세요.
3. 환경 preflight를 수행하세요 (identity, region, bootstrap).
4. `cdk diff`를 실행하고 결과를 분석하세요.
5. deploy plan을 작성하세요.

## 주의사항
- synth-valid가 no이면 배포 계획을 작성하지 마세요. 코드 수정이 먼저입니다.
- destructive change가 감지되면 반드시 경고하세요.
- prod 환경은 `--require-approval any-change`를 사용하세요.
- 사용자 승인 없이 배포를 실행하지 마세요.
