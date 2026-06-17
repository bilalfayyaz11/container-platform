#!/usr/bin/env python3

import json
from selenium import webdriver
from selenium.webdriver.chrome.options import Options

chrome_options = Options()
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")

driver = webdriver.Remote(
    command_executor="http://localhost:4444/wd/hub",
    options=chrome_options
)

with open("browser-capabilities.json", "w") as f:
    json.dump(driver.capabilities, f, indent=2)

print("Capabilities exported to browser-capabilities.json")

driver.quit()
