# PostgreSQL Integration Guide

## Local Development with docker-compose

Run PostgreSQL and the app together locally:

```bash
docker-compose up -d
```

This starts:
- PostgreSQL 16 on `localhost:5432` (credentials: `postgres:postgres`)
- Tasklist app on `http://localhost:8080`

Check logs:
```bash
docker-compose logs -f app
docker-compose logs -f postgres
```

Stop:
```bash
docker-compose down
```

To restart with a fresh database:
```bash
docker-compose down -v
docker-compose up -d
```

## Environment Variables

Configure PostgreSQL connection via environment variables:
- `DB_HOST` — PostgreSQL hostname (default: localhost)
- `DB_PORT` — PostgreSQL port (default: 5432)
- `DB_NAME` — Database name (default: tasklist_db)
- `DB_USER` — Database user (default: postgres)
- `DB_PASSWORD` — Database password (default: postgres)

Example:
```bash
export DB_HOST=prod-db.example.com
export DB_USER=appuser
export DB_PASSWORD=secret
java -jar target/Tasklist-0.0.1-SNAPSHOT.jar
```

## Kubernetes Deployment

For Kubernetes, create a Secret with PostgreSQL credentials:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: postgres-secret
type: Opaque
stringData:
  DB_HOST: postgres.default.svc.cluster.local
  DB_PORT: "5432"
  DB_NAME: tasklist_db
  DB_USER: postgres
  DB_PASSWORD: your-secure-password
```

Reference in `deploy/k8s/deployment.yaml`:
```yaml
env:
  - name: DB_HOST
    valueFrom:
      secretKeyRef:
        name: postgres-secret
        key: DB_HOST
  # ... repeat for other keys
```

## Production PostgreSQL

For production, use a managed database service (Azure Database for PostgreSQL, AWS RDS, etc.) and store credentials in your secret store (Kubernetes Secrets, Ansible Vault, Azure Key Vault, etc.).

Never commit database credentials to git.
