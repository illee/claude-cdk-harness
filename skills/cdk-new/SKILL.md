---
name: cdk-new
description: "새 AWS CDK v2 TypeScript 프로젝트를 생성하는 전체 파이프라인. 요구수집→설계→생성→검증 파이프라인으로 CDK 프로젝트를 만듭니다."
---

# 새 AWS CDK 프로젝트 시작

새 AWS CDK v2 TypeScript 프로젝트를 질문 → 설계 → 생성 → 검증 파이프라인으로 만듭니다.

## 실행 순서

### Phase 1: Requirements (requirements-agent)
1. 사용자 요구사항 분석
2. 필수 배포 정보 확인 (account, region, VPC, subnet 등)
3. 부족한 정보가 있으면 질문
4. `docs/spec.md`, `docs/answers.json` 생성

### Phase 2: Architecture (solution-architect)
5. 요구사항을 아키텍처 패턴으로 변환
6. 스택 분리 전략 결정
7. `docs/adr.md`, `architecture-contract.json` 생성

### Phase 3: Generation (cdk-generator)
8. 최신 안정 aws-cdk-lib v2 버전 조회
9. CDK TypeScript 프로젝트 코드 생성
10. 단위 테스트, README 포함

### Phase 4: Validation (validator-agent)
11. build / lint / test / synth 실행
12. cdk-nag / cfn-guard 검사
13. `docs/validation-report.md` 생성

## 기본 규칙

- VPC / subnet / account / region이 불분명하면 **질문 먼저**
- 최신 안정 aws-cdk-lib v2 사용 후 정확 버전 pin
- validation report 생성 필수
- TODO, placeholder 금지
- 기존 VPC 사용이 명시되면 신규 VPC 생성 금지

## 사용자 입력

사용자가 제공한 원래 요구사항: $ARGUMENTS

위 요구사항을 기반으로 Phase 1부터 순서대로 실행하세요.
부족한 정보가 있으면 반드시 사용자에게 질문하고, 추정과 확정을 구분하세요.
