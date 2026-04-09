---
name: cdk-deploy-plan
description: 배포 전 점검과 안전한 배포 계획을 생성
argument-hint: "[프로젝트 디렉터리 경로]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
  - AskUserQuestion
---

# 배포 전 점검 및 배포 계획 생성

실제 배포 전에 환경, 권한, 변경사항을 점검하고 안전한 배포 계획을 만듭니다.

## 실행 순서

### Step 1: Preflight Check (deployment-agent)
1. `aws sts get-caller-identity` - 현재 인증 확인
2. region 확인 - 의도한 region과 일치 여부
3. CDK bootstrap 상태 확인
4. context 값 확보 여부 확인

### Step 2: Diff Analysis
5. `npx cdk diff` 실행
6. 변경사항 분류:
   - 새로 생성되는 리소스
   - 수정되는 리소스
   - **삭제되는 리소스 (위험)**
   - **교체되는 리소스 (위험)**

### Step 3: Risk Assessment
7. destructive change 분석
8. Security Group / IAM 변경 영향 분석
9. 비용 영향 리소스 식별

### Step 4: Deploy Plan
10. 배포 명령어 생성
11. 위험 요소 정리
12. 승인 체크리스트 생성
13. 롤백 가이드 작성

## 안전 규칙

- `--force` 플래그 사용 금지
- prod: `--require-approval any-change` 필수
- dev/stage: `--require-approval broadening` 권장
- destructive change가 있으면 반드시 경고
- human approval 없이 prod 배포 강행 금지

## 대상 프로젝트

배포 대상: $ARGUMENTS

위 프로젝트에 대해 deployment-agent를 실행하고, deploy plan을 생성하세요.
반드시 cdk diff 결과를 사용자에게 보여주고, 승인을 받은 후에만 배포 명령을 안내하세요.
