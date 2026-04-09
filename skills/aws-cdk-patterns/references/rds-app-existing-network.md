# Example: RDS Application (Existing Network)

## 시나리오
- 기존 VPC/서브넷에 RDS Aurora 클러스터 배포
- 애플리케이션(ECS)에서 RDS 접근
- Secrets Manager로 자격증명 관리

## 주요 결정
- 기존 VPC import: `Vpc.fromLookup()`
- Aurora Serverless v2 (비용 최적화)
- Secrets Manager: 자동 비밀번호 관리
- DB Subnet Group: isolated 서브넷 사용

## 스택 구조
- `DataStack`: Aurora Cluster, Secrets Manager, DB Subnet Group, SG
- `AppStack`: ECS Service (기존 VPC에 배치)

## 필수 입력
- VPC ID
- Isolated subnet IDs (DB용)
- Private subnet IDs (App용)
- 환경 (dev/prod)

## 보안 설정
- dev: `removalPolicy: DESTROY`, backup 1일
- prod: `removalPolicy: RETAIN`, `deletionProtection: true`, backup 7일
