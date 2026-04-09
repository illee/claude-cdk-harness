# Example: Lambda + API Gateway (Existing VPC)

## 시나리오
- 기존 VPC의 프라이빗 서브넷에서 Lambda 실행
- API Gateway를 통해 외부 API 노출
- RDS 접근을 위한 VPC Lambda

## 주요 결정
- VPC Lambda: `Vpc.fromLookup()` 사용
- API Gateway: REST API (v1)
- Lambda Runtime: Node.js 20.x
- Security Group: Lambda → RDS 접근 허용

## 스택 구조
- `AppStack`: Lambda + API Gateway + SG

## 필수 입력
- VPC ID
- RDS Security Group ID
- RDS endpoint (Secrets Manager)
