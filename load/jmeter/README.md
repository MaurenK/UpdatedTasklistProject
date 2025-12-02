# JMeter load testing for Tasklist

This folder contains a starter JMeter test plan and instructions to run it locally or in CI.

Prerequisites
- Install JMeter (https://jmeter.apache.org/) or use a Docker image: `justb4/jmeter` or `jmeter:5.6.2`

Run non-GUI local test:
```powershell
# From repository root
cd load/jmeter
# Run (replace URL with your app endpoint)
jmeter -n -t testplan.jmx -l results.jtl -Jhost=http://localhost:8080
```

CI: Use `jmeter` Docker image and run the same CLI command mounting the repo.

Customize `testplan.jmx` to add samplers/assertions/listeners as required.
