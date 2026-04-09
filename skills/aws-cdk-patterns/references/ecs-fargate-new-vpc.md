# Example: ECS Fargate + ALB (New VPC)

## 시나리오
- 신규 VPC 생성
- ECS Fargate 서비스를 프라이빗 서브넷에 배치
- Public ALB를 통해 서비스 노출
- 2 AZ, NAT Gateway 1개 (비용 절약)

## 주요 결정
- 신규 VPC: 2 AZ, 1 NAT
- ALB: Public (internet-facing)
- ECS: Private subnet with egress
- Container: ECR 이미지

## 스택 구조
- `NetworkStack`: VPC, Subnet, NAT, SG
- `AppStack`: ECS Cluster, Fargate Service, ALB

## 필수 입력
- Account ID
- Region
- Container image URI
- 환경 (dev/prod)
