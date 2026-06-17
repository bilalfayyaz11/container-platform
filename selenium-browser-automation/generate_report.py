#!/usr/bin/env python3

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path


def run_tests():
    result = subprocess.run(
        ["python", "selenium_test.py"],
        capture_output=True,
        text=True,
        timeout=300
    )

    return result


def build_report():
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    result = run_tests()

    report_data = {
        "timestamp": timestamp,
        "exit_code": result.returncode,
        "status": "PASSED" if result.returncode == 0 else "FAILED",
        "stdout": result.stdout,
        "stderr": result.stderr
    }

    if Path("selenium-results.json").exists():
        try:
            with open("selenium-results.json", "r", encoding="utf-8") as f:
                report_data["test_results"] = json.load(f)
        except Exception:
            report_data["test_results"] = {}

    with open("test-report.json", "w", encoding="utf-8") as f:
        json.dump(report_data, f, indent=2)

    html_report = f"""
<!DOCTYPE html>
<html>
<head>
<title>Selenium Container Test Report</title>
<style>
body {{
    font-family: Arial, sans-serif;
    margin: 40px;
}}
.header {{
    background: #f2f2f2;
    padding: 20px;
    border-radius: 8px;
}}
.passed {{
    color: green;
    font-weight: bold;
}}
.failed {{
    color: red;
    font-weight: bold;
}}
.output {{
    background: #f8f8f8;
    border: 1px solid #ddd;
    padding: 15px;
    white-space: pre-wrap;
}}
</style>
</head>
<body>

<div class="header">
<h1>Selenium Container Automation Report</h1>
<p><strong>Generated:</strong> {timestamp}</p>
<p><strong>Status:</strong>
<span class="{report_data['status'].lower()}">
{report_data['status']}
</span>
</p>
</div>

<h2>Standard Output</h2>
<div class="output">{report_data['stdout']}</div>

<h2>Error Output</h2>
<div class="output">
{report_data['stderr'] if report_data['stderr'] else 'No errors'}
</div>

</body>
</html>
"""

    with open("test-report.html", "w", encoding="utf-8") as f:
        f.write(html_report)

    print(f"Status: {report_data['status']}")
    print("Generated:")
    print("- test-report.json")
    print("- test-report.html")

    return result.returncode


if __name__ == "__main__":
    raise SystemExit(build_report())
