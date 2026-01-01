module.exports = {
  root: true,
  env: {
    node: true
  },
  'extends': [
    'plugin:vue/vue3-essential',
    'eslint:recommended'
  ],
  rules: {
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'vue/html-self-closing': 'off',
    'no-tabs': 'off',
    'vue/multi-word-component-names': 'off'
  },
  parserOptions: {
    ecmaVersion: 2020
  }
}
