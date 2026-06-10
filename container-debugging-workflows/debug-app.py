import time
import random

def problematic_function():
    issue = random.choice(['memory', 'exception', 'slow', 'success'])

    if issue == 'memory':
        print("WARNING: High memory usage detected", flush=True)
        data = [0] * 1000000
        time.sleep(2)
    elif issue == 'exception':
        print("ERROR: About to raise an exception", flush=True)
        raise Exception("Simulated application error")
    elif issue == 'slow':
        print("INFO: Processing slow operation", flush=True)
        time.sleep(10)
    else:
        print("INFO: Operation completed successfully", flush=True)

if __name__ == "__main__":
    print("Starting problematic application...", flush=True)
    while True:
        try:
            problematic_function()
            time.sleep(3)
        except Exception as e:
            print(f"EXCEPTION: {e}", flush=True)
            time.sleep(5)
