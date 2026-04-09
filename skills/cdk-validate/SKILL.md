---
name: cdk-validate
description: "기존 AWS CDK 프로젝트의 코드 품질과 배포 가능성을 검증합니다. build, lint, test, synth, cdk-nag, cfn-guard 전체 검증 파이프라인을 실행합니다."
---

# 기존 AWS CDK 프로젝트 검증

기존 CDK 프로젝트에 대해 전체 검증 파이프라인을 실행합니다.

## 실행 순서

### Step 1: 프로젝트 탐색
1. 프로젝트 디렉터리 확인 ($ARGUMENTS 또는 현재 디렉터리)
2. `package.json`, `cdk.json`, `tsconfig.json` 존재 확인
3. CDK 프로젝트 구조 파악

### Step 2: validator-agent 호출
4. `npm ci` - 의존성 설치
5. `npm run build` - TypeScript 빌드
6. `npm run lint` - ESLint 검사
7. `npm test` - 단위 테스트 실행
8. `npx cdk synth` - CloudFormation 합성
9. cdk-nag 결과 확인
10. cfn-guard 규칙 검증 (guard 파일 있는 경우)
11. `npx cdk diff` 실행 (환경 준비된 경우)

### Step 3: 보고서 생성
12. `docs/validation-report.md` 갱신
13. blocker 및 수정 제안 정리

## 판정 기준

- **synth-valid**: synth 성공, unresolved token 없음
- **policy-valid**: cdk-nag critical/high 통과, guard 통과
- **env-ready**: account/region 확인, bootstrap 완료
- **deploy-likely**: diff 가능, 알려진 blocker 없음

## 대상 프로젝트

검증 대상: $ARGUMENTS

위 프로젝트에 대해 validator-agent를 실행하고, 결과를 `docs/validation-report.md`에 기록하세요.
실패 항목이 있으면 원인 분류(code/environment/policy/permission/network)와 수정 제안을 포함하세요.
