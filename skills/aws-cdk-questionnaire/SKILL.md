---
name: aws-cdk-questionnaire
description: "CDK 코드 생성 전 필수 배포 정보를 수집하는 질문 규칙"
---

# 목적

이 skill은 코드 생성 전에 배포를 좌우하는 필수 정보를 수집하도록 한다.

# 질문 우선순위

1. AWS account / region
2. 신규 VPC 또는 기존 VPC
3. subnet 유형 및 인터넷 연결 요구
4. 배포 대상 서비스 유형 (Lambda, ECS, EKS 등)
5. 보안/암호화/로그 요구
6. 운영 환경 구분 (dev/stage/prod)

# 필수 확인 항목

## 기본 인프라
- AWS account ID
- 대상 region
- 신규 네트워크 생성 여부
- 기존 VPC 사용 시 VPC ID 또는 조회 기준 (태그, 이름 등)

## 네트워크
- subnet 사용 대상 (public / private-with-egress / private-isolated)
- 최소 AZ 수
- 인터넷 inbound 필요 여부
- 인터넷 outbound 필요 여부
- NAT Gateway 필요 여부
- 퍼블릭 엔드포인트 노출 여부

## 워크로드
- 서비스 유형 (Lambda, ECS Fargate, EKS, EC2 등)
- 데이터 저장소 필요 여부 (RDS, DynamoDB, S3 등)
- 기존 리소스 연동 여부

## 운영
- 운영 환경 구분 (단일 환경 / 다중 환경)
- 환경별 account 분리 여부
- 배포 방식 (수동 / CI-CD)

# 질문 규칙

- 정보가 배포 blocker이면 반드시 질문한다.
- 한 번에 너무 많은 질문을 던지지 말고, 가장 영향이 큰 항목부터 묻는다.
- 최대 3-5개 질문을 한 라운드에 제시한다.
- 사용자가 답하지 않은 항목은 "미확정"으로 표시한다.
- 미확정 항목이 있으면 생성 단계로 넘기지 않는다.
  - 예외: synth만 가능한 초안 생성이 목적일 때는 명시적으로 예외를 표기한다.
- 추정값과 확정값을 명확히 구분한다.

# 기존 환경 Discovery 규칙

사용자가 허용하면 읽기 전용 조회를 제안할 수 있다:

```bash
# VPC 목록 조회
aws ec2 describe-vpcs --query 'Vpcs[*].{VpcId:VpcId,Name:Tags[?Key==`Name`].Value|[0],CidrBlock:CidrBlock}' --output table

# Subnet 목록 조회
aws ec2 describe-subnets --filters "Name=vpc-id,Values=<vpc-id>" --query 'Subnets[*].{SubnetId:SubnetId,AZ:AvailabilityZone,CidrBlock:CidrBlock,Type:MapPublicIpOnLaunch}' --output table

# Security Group 목록 조회
aws ec2 describe-security-groups --filters "Name=vpc-id,Values=<vpc-id>" --query 'SecurityGroups[*].{GroupId:GroupId,GroupName:GroupName,Description:Description}' --output table
```

- Discovery 결과는 선택지 형태로 요약해 사용자에게 확인받는다.
- Discovery 실패 시 수동 입력을 안내한다.

# 출력 형식

반드시 아래 구조를 만들어 `docs/answers.json`에 저장한다:

```json
{
  "confirmed": {
    "accountId": "",
    "region": "",
    "networkMode": "new-vpc | existing-vpc",
    "vpcId": "",
    "subnetType": "",
    "workloadType": ""
  },
  "assumed": {},
  "missing": [],
  "nextQuestion": ""
}
```

## confirmed
사용자가 명시적으로 확정한 정보

## assumed
사용자가 승인한 가정 (반드시 승인 표시)

## missing
아직 없는 필수 정보 목록

## nextQuestion
지금 가장 먼저 물어야 할 단일 질문
