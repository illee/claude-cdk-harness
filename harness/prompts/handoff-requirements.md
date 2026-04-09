# Handoff: requirements-agent → solution-architect

## Context
requirements-agent가 사용자로부터 배포 정보를 수집하여 아래 파일을 생성했습니다.

## 전달 파일
- `docs/spec.md` - 요구사항 명세 (confirmed / assumed / missing)
- `docs/answers.json` - 구조화된 답변 데이터

## solution-architect에게 요청

1. `docs/spec.md`와 `docs/answers.json`을 읽어주세요.
2. confirmed 정보를 기반으로 적합한 아키텍처 패턴을 선택하세요.
3. assumed 항목이 아키텍처에 영향을 주면 명시적으로 표시하세요.
4. missing 항목이 있다면 생성 단계에 blocking인지 판단하세요.
5. `docs/adr.md`와 `architecture-contract.json`을 생성하세요.

## 주의사항
- 네트워크 모드(new-vpc / existing-vpc)를 반드시 확인하세요.
- 기존 VPC 사용이 명시되어 있으면 신규 VPC를 설계하지 마세요.
- L2 construct 우선 원칙을 적용하세요.
