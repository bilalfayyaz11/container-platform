#!/usr/bin/env python3

import json
import sys
import time
from datetime import datetime, timezone

import requests
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait


SELENIUM_URL = "http://localhost:4444/wd/hub"


def wait_for_selenium(timeout_seconds=60):
    deadline = time.time() + timeout_seconds

    while time.time() < deadline:
        try:
            response = requests.get(f"{SELENIUM_URL}/status", timeout=5)
            response.raise_for_status()
            data = response.json()

            if data.get("value", {}).get("ready") is True:
                print("Selenium Grid is ready.")
                return True
        except Exception as error:
            print(f"Waiting for Selenium Grid: {error}")

        time.sleep(2)

    raise RuntimeError("Selenium Grid did not become ready in time.")


def create_driver():
    chrome_options = Options()
    chrome_options.add_argument("--no-sandbox")
    chrome_options.add_argument("--disable-dev-shm-usage")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--disable-extensions")
    chrome_options.add_argument("--window-size=1365,768")

    return webdriver.Remote(
        command_executor=SELENIUM_URL,
        options=chrome_options
    )


def test_selenium_homepage():
    driver = None

    try:
        driver = create_driver()
        print("Connected to Selenium container.")

        driver.get("https://www.selenium.dev/")
        print("Opened Selenium homepage.")

        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.TAG_NAME, "body"))
        )

        title = driver.title
        current_url = driver.current_url

        print(f"Page title: {title}")
        print(f"Current URL: {current_url}")

        assert "Selenium" in title, "Expected Selenium in page title."

        return {
            "name": "selenium_homepage_title_check",
            "status": "PASSED",
            "title": title,
            "url": current_url
        }

    except Exception as error:
        return {
            "name": "selenium_homepage_title_check",
            "status": "FAILED",
            "error": str(error)
        }

    finally:
        if driver:
            driver.quit()
            print("Browser session closed.")


def test_httpbin_form_page():
    driver = None

    try:
        driver = create_driver()
        print("Connected to Selenium container for form test.")

        driver.get("https://httpbin.org/forms/post")
        print("Opened httpbin form page.")

        WebDriverWait(driver, 20).until(
            EC.presence_of_element_located((By.NAME, "custname"))
        )

        driver.find_element(By.NAME, "custname").send_keys("Bilal Fayyaz")
        driver.find_element(By.NAME, "custtel").send_keys("555-1234")
        driver.find_element(By.NAME, "custemail").send_keys("bilal@example.com")

        driver.find_element(By.CSS_SELECTOR, "button, input[type='submit']").click()
        time.sleep(2)

        current_url = driver.current_url
        page_source = driver.page_source

        print(f"Form submission URL: {current_url}")

        assert "httpbin.org" in current_url, "Expected httpbin response URL."

        return {
            "name": "httpbin_form_interaction",
            "status": "PASSED",
            "url": current_url,
            "contains_customer_name": "Bilal Fayyaz" in page_source
        }

    except Exception as error:
        return {
            "name": "httpbin_form_interaction",
            "status": "FAILED",
            "error": str(error)
        }

    finally:
        if driver:
            driver.quit()
            print("Browser session closed.")


def main():
    print("Starting Selenium Docker browser automation tests.")
    print("=" * 60)

    wait_for_selenium()

    started_at = datetime.now(timezone.utc).isoformat()

    results = [
        test_selenium_homepage(),
        test_httpbin_form_page()
    ]

    finished_at = datetime.now(timezone.utc).isoformat()

    summary = {
        "started_at": started_at,
        "finished_at": finished_at,
        "selenium_url": SELENIUM_URL,
        "total_tests": len(results),
        "passed": len([test for test in results if test["status"] == "PASSED"]),
        "failed": len([test for test in results if test["status"] == "FAILED"]),
        "results": results
    }

    with open("selenium-results.json", "w", encoding="utf-8") as file:
        json.dump(summary, file, indent=2)

    print("=" * 60)
    print(json.dumps(summary, indent=2))

    if summary["failed"] > 0:
        sys.exit(1)

    sys.exit(0)


if __name__ == "__main__":
    main()
