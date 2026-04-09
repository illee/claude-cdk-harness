/**
 * cdk-nag 설정 헬퍼
 *
 * 프로젝트의 bin/app.ts에서 아래와 같이 사용:
 *
 * ```typescript
 * import { Aspects } from 'aws-cdk-lib';
 * import { AwsSolutionsChecks, NagSuppressions } from 'cdk-nag';
 *
 * // 전체 app에 적용
 * Aspects.of(app).add(new AwsSolutionsChecks({ verbose: true }));
 * ```
 *
 * suppress가 필요한 경우 반드시 사유를 기록한다:
 *
 * ```typescript
 * NagSuppressions.addResourceSuppressions(resource, [
 *   {
 *     id: 'AwsSolutions-IAM4',
 *     reason: 'AWSLambdaBasicExecutionRole is acceptable for CloudWatch log access',
 *   },
 * ]);
 * ```
 */

// 자주 사용되는 suppress 패턴 (참조용)
export const COMMON_SUPPRESSIONS = {
  // Lambda basic execution role은 일반적으로 허용
  lambdaBasicRole: {
    id: 'AwsSolutions-IAM4',
    reason: 'AWSLambdaBasicExecutionRole provides minimal CloudWatch Logs permissions',
  },

  // CDK 생성 Lambda의 기본 log retention
  lambdaLogRetention: {
    id: 'AwsSolutions-L1',
    reason: 'Runtime version is managed by CDK and updated regularly',
  },

  // ECS 서비스의 read-only root filesystem (일부 컨테이너에서 불가)
  ecsReadOnlyRoot: {
    id: 'AwsSolutions-ECS4',
    reason: 'Application requires write access to /tmp for temporary file processing',
  },
} as const;

// 환경별 적용 레벨
export type NagLevel = 'strict' | 'standard' | 'relaxed';

export function getNagConfig(level: NagLevel): { verbose: boolean } {
  switch (level) {
    case 'strict':
      return { verbose: true };
    case 'standard':
      return { verbose: true };
    case 'relaxed':
      return { verbose: false };
  }
}
