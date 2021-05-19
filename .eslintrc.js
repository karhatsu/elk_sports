module.exports = {
  env: {
    browser: true,
    es2021: true,
  },
  extends: [
    'plugin:react/recommended',
    'standard',
  ],
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 12,
    sourceType: 'module',
  },
  plugins: [
    'react',
  ],
  rules: {
    'comma-dangle': ['error', 'always-multiline'],
    'node/no-callback-literal': 0,
    'react/prop-types': 0,
    'space-before-function-paren': ['error', 'never'],
  },
  settings: {
    react: {
      version: 'detect',
    },
  },
}
