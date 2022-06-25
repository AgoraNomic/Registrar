 
from sys import argv
from csv import reader
from datetime import datetime, timezone 

isTest = "-t" in argv
isReport = "-r" in argv

# Determine timestamp
now = datetime.now(timezone.utc)

if isTest:
    print("Running test generation.")
    report_name = "test"
elif isReport:
    report_name = str(now.year) + "-" + str(now.month).zfill(2) + "-" + str(now.day).zfill(2)
    print("Generating report: " + report_name)

time_str = now.strftime('%B %d, %Y')

fancy_time = time_str

print(fancy_time)
