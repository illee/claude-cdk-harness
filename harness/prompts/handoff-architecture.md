# Handoff: solution-architect → cdk-generator

## Context
solution-architect가 아키텍처를 설계하고 생성 계약을 만들었습니다.

## 전달 파일
- `docs/adr.md` - 아키텍처 결정 기록
- `docs/spec.md` - 요구사항 명세
- `docs/answers.json` - 구조화된 답변 데이터
- `architecture-contract.json` - 생성 계약 (스택, construct, 보안, 네트워크)

## cdk-generator에게 요청

1. `architecture-contract.json`을 읽어주세요. 이것이 구현의 기준입니다.
2. `${CLAUDE_PLUGIN_ROOT}/harness/scripts/resolve-latest-cdk.sh`를 실행하여 최신 CDK 버전을 확인하세요.
3. contract에 정의된 스택과 construct를 그대로 구현하세요.
4. `${CLAUDE_PLUGIN_ROOT}/harness/templates/` 아래의 템플릿을 참조하여 boilerplate를 구성하세요.
5. 모든 필수 산출물(`aws-cdk-output-contract` skill 참조)을 생성하세요.

## 주의사항
- 기존 VPC 사용이 contract에 명시되어 있으면 **절대** 신규 VPC를 만들지 마세요.
- subnet 정보가 불충분하면 임의 결정하지 말고 `// UNCONFIRMED:` 주석을 남기세요.
- package.json에 정확 버전을 pin하세요 (^ 금지).
- cdk-nag를 app.ts에 기본 포함하세요.
