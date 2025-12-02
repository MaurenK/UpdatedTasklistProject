# Ansible deployment for Tasklist

This folder contains a simple Ansible role and playbook to deploy the `tasklist` Spring Boot jar to one or more Linux servers and manage it as a `systemd` service.

Quickstart
1. Edit `inventory.ini` and replace `app1` / `your.server.ip` / `youruser` with your host(s) and SSH user.
2. Update `deploy/ansible/roles/app/vars/main.yml` to match the `jar_name` and any other defaults you want.
3. Build the project locally (from repo root):

```powershell
.\mvnw clean package
```

4. Run the playbook from the `deploy/ansible` folder:

```powershell
cd deploy/ansible
ansible-playbook playbook.yml
```

Notes
- The playbook uses the `app` role under `roles/app`.
- `ansible.cfg` sets the inventory and turns off host key checking for convenience — adjust for production.
- The role will upload the JAR from the controller machine's `local_build_path` (default `../target/<jar>`). Run the playbook from the repo root or adjust `local_build_path` when invoking.
- To pass different values per host, add `host_vars/<hostname>.yml` or use `group_vars`.

Security
- Use Ansible Vault for secrets (DB passwords, agent keys). Do NOT commit sensitive credentials.
