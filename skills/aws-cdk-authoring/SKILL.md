---
name: aws-cdk-authoring
description: "AWS CDK v2 TypeScript 코드 작성 표준, 구조화, 네이밍, 환경 분리 규칙"
---

# 목적

이 skill은 AWS CDK 코드를 생성할 때 일관된 TypeScript 구조와 배포 가능한 기본 규칙을 적용한다.

# 기본 원칙

- 언어는 TypeScript를 기본으로 사용한다.
- CDK는 aws-cdk-lib v2를 사용한다.
- 생성 시점의 최신 안정 버전을 조회하되, 생성된 프로젝트에는 정확 버전을 pin 한다.
- L2 construct를 우선 사용하고, L1 또는 escape hatch는 반드시 이유가 있을 때만 사용한다.
- 스택은 책임 단위로 분리한다. 네트워크, 데이터, 애플리케이션 스택을 무분별하게 합치지 않는다.
- 환경별 차이는 코드 분기보다 config 파일과 context로 처리한다.
- prod 기본값은 안전 쪽으로 둔다. 예: termination protection, removal policy 보수 적용.
- 리소스 네이밍은 예측 가능해야 하며, `{app}-{env}-{purpose}` 형식을 우선 검토한다.
- 모든 주요 리소스에 tags를 적용한다.

# 구조 규칙

```
workspaces/<app-name>/
├── bin/app.ts              # App 진입점, 환경별 스택 인스턴스화
├── lib/
│   ├── stacks/             # 책임 단위 스택 정의
│   │   ├── network-stack.ts
│   │   ├── data-stack.ts
│   │   └── app-stack.ts
│   └── constructs/         # 재사용 가능한 construct
├── test/                   # assertions 기반 단위 테스트
├── docs/
│   ├── spec.md             # 요구사항 명세
│   ├── adr.md              # 아키텍처 결정 기록
│   └── validation-report.md
├── package.json
├── tsconfig.json
├── cdk.json
├── jest.config.js
└── README.md
```

# 네트워크 규칙

- 사용자가 기존 VPC를 명시하면 신규 VPC를 임의로 생성하지 않는다.
- VPC, subnet, security group, route table 등 배포 환경 정보가 없으면 먼저 질문한다.
- 기존 VPC 사용 시 `Vpc.fromLookup()` 또는 명시적 attribute import를 검토한다.
- subnet type이 불명확하면 질문한다. 추정으로 public/private를 결정하지 않는다.
- 인터넷 egress 요구가 없으면 NAT를 기본값으로 만들지 않는다.

# 코드 품질 규칙

- strict TypeScript를 사용한다 (`strict: true` in tsconfig).
- `any` 사용을 피한다.
- 하드코딩된 account/region을 피하고 env 입력으로 받는다.
- README에 배포 전제조건과 실행 방법을 반드시 기록한다.

# 환경 분리

- `cdk.json`의 context 또는 별도 config 파일로 환경별 설정을 관리한다.
- 예시:
  ```json
  {
    "context": {
      "environments": {
        "dev":  { "account": "111111111111", "region": "ap-northeast-2" },
        "prod": { "account": "222222222222", "region": "ap-northeast-2" }
      }
    }
  }
  ```
- 환경별 스택 인스턴스는 `bin/app.ts`에서 분기한다.

# 태깅 규칙

모든 스택에 최소 아래 태그를 적용한다:

```typescript
Tags.of(app).add('Project', projectName);
Tags.of(app).add('Environment', envName);
Tags.of(app).add('ManagedBy', 'cdk');
```

# 출력 기대치

- 빌드 가능한 CDK 프로젝트
- 최소 1개 이상의 테스트
- 환경 입력 방식을 문서화한 README
- `cdk synth` 성공 가능한 상태
