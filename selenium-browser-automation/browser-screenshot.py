#!/usr/bin/env python3

from selenium import webdriver
from selenium.webdriver.chrome.options import Options

chrome_options = Options()
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

driver = webdriver.Remote(
    command_executor="http://localhost:4444/wd/hub",
    options=chrome_options
)

driver.get("https://www.selenium.dev")

driver.save_screenshot("selenium-homepage.png")

print("Screenshot saved: selenium-homepage.png")

driver.quit()
