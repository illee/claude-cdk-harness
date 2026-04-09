# claude-cdk-harness

Claude Code 플러그인 - AWS CDK v2 TypeScript 프로젝트를 **요구수집 → 설계 → 생성 → 검증 → 배포** 파이프라인으로 만들어줍니다.

## Installation

### GitHub
```bash
/plugin install github:OWNER/claude-cdk-harness
```

### Local (개발용)
```bash
claude --plugin-dir /path/to/claude-cdk-harness
```

## Usage

### 새 CDK 프로젝트 생성
```
/claude-cdk-harness:cdk-new ECS Fargate 서비스를 기존 VPC에 배포
```

파이프라인이 순서대로 실행됩니다:
1. **requirements-agent**: 필수 배포 정보 수집 (account, region, VPC 등)
2. **solution-architect**: 아키텍처 패턴 선택, contract 생성
3. **cdk-generator**: CDK TypeScript 코드 생성
4. **validator-agent**: build/synth/test/nag/guard 검증

### 기존 프로젝트 검증
```
/claude-cdk-harness:cdk-validate workspaces/my-app
```

### 배포 계획 생성
```
/claude-cdk-harness:cdk-deploy-plan workspaces/my-app
```

## What's Included

### Skills (8)
| Skill | Type | Description |
|-------|------|-------------|
| `aws-cdk-authoring` | auto | CDK 코드 작성 표준, 구조, 네이밍 |
| `aws-cdk-questionnaire` | auto | 배포 전 필수 정보 수집 규칙 |
| `aws-cdk-patterns` | auto | 아키텍처 패턴 선택 기준 |
| `aws-cdk-validation` | auto | 코드/배포 가능성 검증 절차 |
| `aws-cdk-output-contract` | auto | 산출물 구조 및 포맷 계약 |
| `cdk-new` | slash command | 새 프로젝트 생성 파이프라인 |
| `cdk-validate` | slash command | 프로젝트 검증 |
| `cdk-deploy-plan` | slash command | 배포 계획 생성 |

### Agents (5)
| Agent | Role |
|-------|------|
| `requirements-agent` | 필수 배포 정보 수집 |
| `solution-architect` | 아키텍처 설계, contract 생성 |
| `cdk-generator` | CDK TypeScript 코드 생성 |
| `validator-agent` | build/synth/test/nag/guard 검증 |
| `deployment-agent` | preflight 점검, 배포 계획 |

### Harness
- **templates/**: CDK 프로젝트 boilerplate (package.json, tsconfig, app.ts 등)
- **schemas/**: Agent 간 데이터 계약 (JSON Schema)
- **scripts/**: 검증/배포 자동화 (resolve-latest-cdk, run-validation 등)
- **prompts/**: Agent 간 handoff 프롬프트

### Policies
- **cdk-nag**: AwsSolutions 규칙 기본 활성화
- **cfn-guard**: S3, IAM, Networking 정책 규칙

## Consuming Project Setup

1. Plugin 설치 후 프로젝트 루트에 `CLAUDE.md` 생성:
```bash
cp $(npm root -g)/claude-cdk-harness/CLAUDE.md.template ./CLAUDE.md
```

2. 프로젝트별 context 추가 (account, region 등)

3. `/claude-cdk-harness:cdk-new` 실행

## Key Principles

- VPC/subnet 정보가 없으면 **질문 먼저**, 추정하지 않음
- 기존 VPC 명시 시 **신규 VPC 생성 금지**
- aws-cdk-lib **최신 안정 버전 사용 + 정확 버전 pin**
- cdk-nag critical/high **실패 금지**
- prod 환경 **사람 승인 없이 배포 금지**

## License

MIT
