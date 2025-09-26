// jest.config.mjs
import { createDefaultPreset } from 'ts-jest';

/** @type {import('jest').Config} */
const tsJestTransformCfg = createDefaultPreset().transform;

export default {
  testEnvironment: 'node',
  transform: {
    ...tsJestTransformCfg,
  },
  moduleFileExtensions: ['ts', 'js', 'json'],
  testMatch: ['**/tests/**/*.test.ts'],
};
