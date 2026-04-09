---
name: aws-cdk-patterns
description: 자주 쓰는 AWS CDK 아키텍처 패턴과 선택 기준
version: 1.0.0
---

# 목적

이 skill은 요구사항에 맞는 CDK 패턴을 선택하도록 돕는다.

# 우선 지원 패턴

1. Lambda + API Gateway
2. ECS Fargate + ALB
3. RDS/Aurora 연계 애플리케이션
4. S3 + CloudFront 정적 배포
5. EKS 연계 보조 리소스

# 참조 아키텍처

패턴별 상세 예시는 `references/` 디렉터리를 참조하세요:
- [Lambda + API Gateway (기존 VPC)](references/lambda-apigw-existing-vpc.md)
- [ECS Fargate + ALB (신규 VPC)](references/ecs-fargate-new-vpc.md)
- [RDS Application (기존 네트워크)](references/rds-app-existing-network.md)

# 패턴 선택 기준

## Lambda + API Gateway

**적합한 경우:**
- 이벤트 기반 또는 경량 API
- 운영 단순성 우선
- 짧은 실행 시간 (15분 이내)
- 비용 최적화 우선

**네트워크 결정:**
- VPC 연결이 꼭 필요하지 않으면 non-VPC 우선 검토
- RDS 등 VPC 내 리소스 접근 필요 시에만 VPC Lambda 사용

**주요 construct:**
- `aws_lambda.Function` 또는 `aws_lambda_nodejs.NodejsFunction`
- `aws_apigateway.RestApi` 또는 `aws_apigatewayv2.HttpApi`
- `aws_logs.LogGroup` (보존 기간 명시)

## ECS Fargate + ALB

**적합한 경우:**
- 컨테이너 기반 서비스
- 안정적 네트워크와 장시간 실행 워크로드
- 수평 확장 필요

**네트워크 결정:**
- private subnet에 서비스 배치
- ALB는 public/internal 여부를 명확히 구분
- 서비스 SG → ALB SG 참조 기반 허용

**주요 construct:**
- `aws_ecs.Cluster`
- `aws_ecs_patterns.ApplicationLoadBalancedFargateService`
- `aws_ecr_assets.DockerImageAsset` 또는 `aws_ecr.Repository`

## RDS/Aurora 연계

**적합한 경우:**
- 관계형 데이터베이스 필요
- 트랜잭션 무결성 필요

**핵심 규칙:**
- DB subnet group 명시
- SG 참조 기반 허용 (IP 기반 허용 최소화)
- 비밀번호는 `aws_secretsmanager.Secret` 우선
- 백업/삭제보호는 환경에 따라 다르게:
  - dev: `removalPolicy: DESTROY`, backup 최소
  - prod: `removalPolicy: RETAIN`, `deletionProtection: true`

**주요 construct:**
- `aws_rds.DatabaseInstance` 또는 `aws_rds.DatabaseCluster`
- `aws_secretsmanager.Secret`
- `aws_ec2.SubnetGroup`

## S3 + CloudFront 정적 배포

**적합한 경우:**
- SPA, 정적 웹사이트
- 글로벌 CDN 배포

**핵심 규칙:**
- S3 버킷 퍼블릭 접근 차단
- CloudFront OAC(Origin Access Control) 사용
- HTTPS 강제

**주요 construct:**
- `aws_s3.Bucket`
- `aws_cloudfront.Distribution`
- `aws_s3_deployment.BucketDeployment`

## EKS 연계 보조 리소스

**적합한 경우:**
- 기존 EKS 클러스터에 보조 AWS 리소스 추가
- IRSA(IAM Roles for Service Accounts) 설정

**핵심 규칙:**
- EKS 클러스터 자체를 CDK로 생성하는 것은 복잡성이 높으므로 신중 검토
- 보조 리소스(SQS, S3, DynamoDB, Secrets Manager 등)에 집중
- IRSA를 위한 OIDC provider와 IAM role 설정

# 네트워크 패턴

## 신규 VPC
- AZ, NAT, subnet group을 명시적으로 정의
- `maxAzs`, `natGateways`, `subnetConfiguration` 필수 명시
- 비용 고려: dev는 NAT 1개 또는 0개

## 기존 VPC
- `Vpc.fromLookup()` 또는 명시적 attribute import 사용
- subnet selection은 목적 중심:
  - 앱 서비스: `SubnetType.PRIVATE_WITH_EGRESS`
  - ALB(public): `SubnetType.PUBLIC`
  - DB: `SubnetType.PRIVATE_ISOLATED` 또는 전용 subnet group

# 보안 기본값

- 저장 데이터 암호화 기본 활성화 (`encryption: true`)
- 공개 SG 인바운드 최소화 (필요한 포트만 허용)
- IAM wildcard 최소화 (`Resource: '*'` 피하기)
- CloudWatch Logs 보존 기간 설정 (무제한 금지)
- S3 공개 접근 차단 기본 활성화 (`blockPublicAccess: BlockPublicAccess.BLOCK_ALL`)
- KMS CMK vs AWS managed key 선택 근거 문서화

# 출력 형식

패턴 선택 결과는 아래 구조로 정리한다:

```markdown
## 선택한 패턴
<패턴명>

## 선택 이유
<근거>

## 대안과 기각 이유
- <대안 1>: <기각 이유>
- <대안 2>: <기각 이유>

## 필수 입력값
- <항목 목록>

## 생성해야 할 주요 construct 목록
- <construct 1>
- <construct 2>
```
