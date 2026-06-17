# Containerized Browser Automation Environment

## What This Does

This implementation builds a containerized browser automation environment using Docker, Selenium Grid, Chrome, and Python.

The system runs a full Chrome browser inside a Docker container, connects to it through Selenium WebDriver, executes automated browser tests, captures structured JSON results, generates HTML reports, exports browser capabilities, collects container logs, and captures screenshot evidence.

This approach gives engineering teams a repeatable browser testing environment without installing Chrome, ChromeDriver, or Selenium directly on the host machine.

## Architecture

    +--------------------------------------------------+
    | Ubuntu Host                                      |
    | Docker Engine                                    |
    | Python Virtual Environment                       |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Selenium Chrome Container                        |
    | selenium/standalone-chrome:latest                |
    | Selenium Grid Port: 4444                         |
    | noVNC Browser Port: 7900                         |
    | Shared Memory: 2GB                               |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Python Automation Layer                          |
    | selenium_test.py                                 |
    | browser-screenshot.py                            |
    | browser-capabilities.py                          |
    | generate_report.py                               |
    +-----------------------+--------------------------+
                            |
                            v
    +--------------------------------------------------+
    | Test Evidence and Reporting                      |
    | selenium-results.json                            |
    | test-report.json                                 |
    | test-report.html                                 |
    | selenium-homepage.png                            |
    | selenium-health-report.txt                       |
    +--------------------------------------------------+

## Prerequisites

- Ubuntu 24.04
- Docker Engine
- Python 3
- Python virtual environments
- pip
- curl
- tree
- Internet access for pulling Selenium Docker images
- Access to ports 4444 and 7900 on the host

## Setup & Installation

sudo apt update

sudo apt install -y docker.io docker-compose-v2 python3 python3-pip python3-venv curl tree

sudo systemctl enable --now docker

sudo usermod -aG docker ubuntu

newgrp docker

docker --version

python3 --version

## How to Reproduce

Create the working directory:

mkdir -p ~/selenium-browser-automation

cd ~/selenium-browser-automation

Pull the Selenium Chrome image:

docker pull selenium/standalone-chrome:latest

Start Selenium Chrome:

docker rm -f selenium-chrome >/dev/null 2>&1 || true

docker run -d \
  --name selenium-chrome \
  --shm-size=2g \
  -p 4444:4444 \
  -p 7900:7900 \
  selenium/standalone-chrome:latest

Verify Selenium readiness:

curl -s http://localhost:4444/wd/hub/status | python3 -m json.tool

Create a Python virtual environment:

python3 -m venv venv

source venv/bin/activate

python -m pip install --upgrade pip

pip install selenium requests

pip freeze > requirements.txt

Run the Selenium tests:

python selenium_test.py

Generate reports:

python generate_report.py

Capture screenshot evidence:

python browser-screenshot.py

Export browser capabilities:

python browser-capabilities.py

Run the health audit:

./selenium-health-audit.sh | tee selenium-health-report.txt

Run final validation:

./validate-selenium-environment.sh | tee final-validation-report.txt

Clean up the container:

./cleanup-selenium-environment.sh

## Tools Used

- Docker
- Selenium Grid
- Selenium Standalone Chrome
- Chrome Browser
- ChromeDriver
- Python 3
- Selenium WebDriver Python library
- requests
- Bash
- curl
- JSON
- HTML reporting
- noVNC
- Git
- Ubuntu 24.04

## Key Skills Demonstrated

- Containerized browser testing
- Selenium Grid deployment with Docker
- Remote WebDriver automation
- Chrome browser automation
- Python test framework scripting
- Structured JSON test reporting
- HTML report generation
- Browser screenshot capture
- Runtime capability discovery
- Container log collection
- Docker resource cleanup
- Test infrastructure validation
- QA automation and DevOps workflow design

## Real-World Use Case

A QA automation, DevOps, or platform engineering team can use this setup to run browser tests consistently across local machines, CI/CD runners, and cloud environments. Instead of manually installing browser versions and drivers on every host, the entire browser runtime is containerized. This reduces environment drift, improves test repeatability, and makes UI regression testing easier to integrate into delivery pipelines.

## Lessons Learned

- Selenium containers provide a clean way to standardize browser automation environments.
- Chrome requires sufficient shared memory inside Docker, so --shm-size=2g is important for stability.
- Public sites such as Google can be flaky automation targets due to consent pages, bot detection, and changing selectors.
- Python virtual environments are safer than global pip installs on Ubuntu 24.04.
- Test evidence is more useful when it includes structured JSON, HTML reports, screenshots, browser capabilities, and container logs.

## Troubleshooting Log

Issue:
Docker failed with permission denied while connecting to /var/run/docker.sock.

Resolution:
Added the ubuntu user to the docker group and refreshed group membership with newgrp docker.

Issue:
The original instructions used global pip installation.

Resolution:
Created a Python virtual environment and installed Selenium dependencies inside it.

Issue:
The original test targeted Google Search, which is unreliable for automation.

Resolution:
Used selenium.dev and httpbin.org because they are more stable browser automation targets.

Issue:
The original form selector only used input[type='submit'].

Resolution:
Used a broader selector that supports both button and submit input elements.

Issue:
The original report generator ignored structured Selenium result data.

Resolution:
Integrated selenium-results.json into the generated JSON and HTML reports.

Issue:
The original cleanup suggested removing the Selenium image.

Resolution:
Kept the image by default to avoid unnecessary large re-downloads and only removed unused Docker resources.

Issue:
The original workflow did not capture browser evidence.

Resolution:
Added screenshot capture, browser capabilities export, Selenium health audit, container logs, final validation report, and Docker evidence files.
