name: Front CI

on:
  push:
    branches:
      - main
      - develop
      - "feature-*"
      - "feature/**"
    paths:
      - "front/**"
      - ".github/workflows/front-ci.yml"
  pull_request:
    paths:
      - "front/**"

jobs:
  build:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: front
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: "20"
          cache: npm
          cache-dependency-path: front/package-lock.json
      - name: Install
        run: npm ci
      - name: Typecheck
        run: npm run typecheck
      - name: Test
        run: npm test
      - name: Build
        run: npm run build
