# AppDynamics Java Agent integration

This document explains how to attach the AppDynamics Java agent to your Spring Boot application.

Prerequisites
- An AppDynamics account / controller and an agent download (access key)
- The Java agent .zip you download will contain `javaagent.jar` and config files

Installation (example)
1. Download the AppDynamics Java agent and extract to `/opt/appdynamics/javaagent` (or a path of your choice).
2. Add the following JVM argument to the service or container that starts your app:

```
-javaagent:/opt/appdynamics/javaagent/javaagent.jar
-Dappdynamics.controller.hostName=<CONTROLLER_HOST>
-Dappdynamics.controller.port=8090
-Dappdynamics.controller.ssl.enabled=false
-Dappdynamics.agent.applicationName=Tasklist
-Dappdynamics.agent.tierName=Tasklist-Tier
-Dappdynamics.agent.nodeName=Tasklist-Node-1
```

3. If using Kubernetes, mount the agent files into the container and add `JAVA_OPTS` env var or update the container `command`/`args` to include the `-javaagent` flag.

4. Restart the app. The agent should register with the controller and start reporting metrics.

Security: never commit controller credentials to git. Use Secrets (Kubernetes Secrets, Ansible Vault, or your CI secret manager).
