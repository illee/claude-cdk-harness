---
name: aws-cdk-output-contract
description: Claude Code가 생성해야 하는 CDK 프로젝트 산출물 계약
version: 1.0.0
---

# 목적

이 skill은 생성 결과가 항상 같은 구조와 문서 포맷을 따르도록 한다.

# 필수 산출물

모든 CDK 프로젝트는 반드시 아래 파일을 포함해야 한다:

```
<project-root>/
├── package.json
├── tsconfig.json
├── cdk.json
├── jest.config.js
├── .eslintrc.json 또는 eslint.config.mjs
├── bin/app.ts
├── lib/stacks/*.ts          (최소 1개)
├── test/*.test.ts            (최소 1개)
├── docs/spec.md
├── docs/adr.md
├── docs/validation-report.md
└── README.md
```

# package.json 규칙

- `aws-cdk-lib`: 정확 버전 pin (예: `"2.175.1"`, `^` 금지)
- `constructs`: 호환 버전 pin
- 필수 scripts:
  ```json
  {
    "scripts": {
      "build": "tsc",
      "lint": "eslint .",
      "test": "jest",
      "synth": "cdk synth",
      "diff": "cdk diff",
      "deploy": "cdk deploy"
    }
  }
  ```
- devDependencies에 `@types/jest`, `jest`, `ts-jest`, `typescript`, `eslint`, `aws-cdk` 포함

# tsconfig.json 규칙

- `strict: true` 필수
- `noImplicitAny: true`
- `target`: `"ES2020"` 이상
- `module`: `"commonjs"`
- `outDir`: `"./dist"` 또는 `"./build"`

# cdk.json 규칙

- `app` 필드에 빌드된 진입점 경로 지정
- context에 환경 설정 또는 feature flag 포함
- 예시:
  ```json
  {
    "app": "npx ts-node --prefer-ts-exts bin/app.ts",
    "context": {
      "@aws-cdk/aws-lambda:recognizeLayerVersion": true,
      "@aws-cdk/core:stackRelativeExports": true
    }
  }
  ```

# README.md 규칙

README는 반드시 아래 섹션을 포함한다:

1. **프로젝트 요약** - 무엇을 배포하는가
2. **아키텍처 개요** - 주요 리소스와 관계
3. **전제조건** - 필요한 도구, 권한, 환경
4. **설치 방법** - `npm ci`
5. **빌드 및 테스트** - `npm run build && npm test`
6. **배포 명령** - `npx cdk synth`, `npx cdk diff`, `npx cdk deploy`
7. **환경 변수 및 context** - 필요한 입력값 설명
8. **알려진 제한 사항** - 현재 제약이나 미구현 사항

# docs/spec.md 규칙

```markdown
# Specification

## Confirmed
<사용자가 확정한 정보>

## Assumed
<사용자가 승인한 가정>

## Missing
<아직 없는 필수 정보>

## Architecture Summary
<아키텍처 요약>
```

# docs/adr.md 규칙

```markdown
# ADR-NNN <제목>

## Context
<결정이 필요한 배경>

## Decision
<결정 내용>

## Alternatives
<검토한 대안과 기각 이유>

## Consequences
<결정으로 인한 영향>
```

# docs/validation-report.md 규칙

```markdown
# Validation Report

## Toolchain
<사용된 도구 버전>

## Results
<build/lint/test/synth/nag/guard/diff 결과>

## Findings
<발견 사항>

## Final Status
<synth-valid / policy-valid / env-ready / deploy-likely 판정>
```

# 출력 품질 기준

- 사용자가 `npm ci && npm run build && npx cdk synth`를 바로 실행 가능한 수준
- **TODO, placeholder 금지** - 완성된 코드만 출력
- 미확정 정보는 문서(`docs/spec.md`)와 코드 주석에 `// UNCONFIRMED:` 접두사로 분명히 표시
- 모든 파일은 정상적인 인코딩(UTF-8)과 개행(LF)으로 작성
- import 순서: Node.js built-in → aws-cdk-lib → constructs → local modules
