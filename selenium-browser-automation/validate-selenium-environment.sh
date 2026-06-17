#!/usr/bin/env bash

set -euo pipefail

echo "===== CONTAINER CHECK ====="
docker ps --filter name=selenium-chrome

echo
echo "===== SELENIUM STATUS ====="
curl -s http://localhost:4444/wd/hub/status | python3 -m json.tool

echo
echo "===== PYTHON TEST EXECUTION ====="
source venv/bin/activate
python selenium_test.py

echo
echo "===== REPORT CHECK ====="
python generate_report.py

echo
echo "===== REQUIRED FILE CHECK ====="

required_files=(
  "selenium_test.py"
  "generate_report.py"
  "browser-screenshot.py"
  "browser-capabilities.py"
  "selenium-health-audit.sh"
  "selenium-results.json"
  "test-report.json"
  "test-report.html"
)

for file in "${required_files[@]}"
do
  if [ -f "$file" ]; then
    echo "PASS: $file"
  else
    echo "FAIL: $file missing"
    exit 1
  fi
done

echo
echo "===== VALIDATION COMPLETE ====="
