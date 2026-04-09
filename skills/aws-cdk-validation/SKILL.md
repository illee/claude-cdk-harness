---
name: aws-cdk-validation
description: "AWS CDK 코드 및 배포 가능성 검증 절차"
---

# 목적

이 skill은 생성된 CDK 코드가 실제로 배포 가능한지 단계적으로 검증한다.

# 검증 순서

1. **dependency install** - `npm ci`
2. **TypeScript build** - `npm run build`
3. **lint** - `npm run lint`
4. **unit test** - `npm test`
5. **cdk synth** - `npx cdk synth`
6. **cdk-nag** - 보안/컴플라이언스 규칙 검사
7. **cfn-guard** - 정책 규칙 검증
8. **cdk diff** - 배포 변경사항 확인
9. **deploy preflight** - 환경 준비 상태 정리

# 필수 명령

```bash
# 1. 의존성 설치
npm ci

# 2. TypeScript 빌드
npm run build

# 3. ESLint 검사
npm run lint

# 4. 단위 테스트
npm test

# 5. CDK 합성
npx cdk synth

# 6. CDK diff (환경 준비된 경우)
npx cdk diff

# 7. cfn-guard 검증 (guard 파일이 있는 경우)
cfn-guard validate --data cdk.out/*.template.json --rules ${CLAUDE_PLUGIN_ROOT}/policies/guard/
```

# 판정 기준

## synth-valid
- `cdk synth` 성공
- unresolved token 또는 context blocker 없음
- CloudFormation 템플릿이 정상 생성됨

## policy-valid
- cdk-nag critical 실패 없음
- cdk-nag high 실패 없음
- cfn-guard rule 실패 없음

## env-ready
- account/region 확인됨
- CDK bootstrap 상태 확인됨 (`cdk bootstrap` 완료)
- 필요한 context 값 확보됨
- IAM 권한 확인됨 (`aws sts get-caller-identity`)

## deploy-likely
- `cdk diff` 실행 가능
- 알려진 blocker 없음
- 리소스 이름 충돌 가능성 낮음
- destructive change 식별 완료

# 실패 처리 원칙

## 실패 분류
실패 원인을 아래 카테고리로 구분한다:

| Category | Examples |
|----------|----------|
| **code** | TypeScript 컴파일 오류, 테스트 실패, lint 오류 |
| **environment** | missing context, bootstrap 미완료, region 미설정 |
| **policy** | cdk-nag 위반, cfn-guard 규칙 실패 |
| **permission** | IAM 권한 부족, STS assume role 실패 |
| **network** | VPC lookup 실패, subnet 조회 실패 |

## 자동 수정 가능 항목
- lint 오류 (auto-fix 가능한 경우)
- missing import 추가
- 타입 오류 수정
- 누락된 태그 추가

## suppress 규칙
- suppress는 최후 수단이다.
- suppress 시 반드시 아래를 기록한다:
  - 어떤 규칙을 suppress 하는가
  - 왜 suppress 하는가
  - 언제까지 유효한가 (해당하는 경우)
- 예시:
  ```typescript
  NagSuppressions.addResourceSuppressions(resource, [
    {
      id: 'AwsSolutions-IAM4',
      reason: 'AWSLambdaBasicExecutionRole is acceptable for this use case',
    },
  ]);
  ```

# 출력 형식

검증 결과는 `docs/validation-report.md`에 아래 구조로 작성한다:

```markdown
# Validation Report

## Toolchain
- aws-cdk-lib: <version>
- TypeScript: <version>
- Node.js: <version>

## Results
| Step | Status | Details |
|------|--------|---------|
| Build | PASS/FAIL | |
| Lint | PASS/FAIL | |
| Test | PASS/FAIL | |
| Synth | PASS/FAIL | |
| cdk-nag | PASS/FAIL/SKIP | |
| cfn-guard | PASS/FAIL/SKIP | |
| Diff | PASS/FAIL/SKIP | |

## Findings
<검증 중 발견된 특이사항>

## Blockers
<배포를 막는 문제 목록>

## Remediation
<수정 제안>

## Final Status
- synth-valid: yes/no
- policy-valid: yes/no
- env-ready: yes/no/partial
- deploy-likely: yes/no/partial
```
