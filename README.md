# deploy-prostgresql

Manifests GitOps do PostgreSQL para sincronização via Argo CD.

## Estrutura

- `k8s/base`: manifests base (Service + StatefulSet + ConfigMap + ExternalSecret)
- `k8s/overlays/dev`: overlay para desenvolvimento
- `k8s/overlays/prod`: placeholder para produção

## Argo CD

A `Application` deste deploy vive no repo central de GitOps (`deploy-argocd`).
`path` = `k8s/overlays/dev`, `targetRevision` = `main`.

## Configuração e segredos

A aplicação consome duas fontes:

- **`base/configmap-postgresql.yaml`** — config não-sensível (`POSTGRES_USER`, `POSTGRES_DB`).
- **`base/externalsecret-postgresql.yaml`** — sincroniza `POSTGRES_PASSWORD` do Bitwarden Secrets Manager via External Secrets Operator (`ClusterSecretStore: bitwarden-homelab`). Gera o Secret `postgresql-auth` com:
  - `POSTGRES_PASSWORD` ← BW secret `postgres-superuser-password`

O StatefulSet usa `envFrom` apontando pra ambos.

**Pré-requisito:** ESO + ClusterSecretStore prontos no cluster (gerenciado em `deploy-argocd`, ver a seção *Quickstart* lá — `scripts/onboarding.sh` cobre setup do Bitwarden, access token e cert TLS do SDK server).

O secret `postgres-superuser-password` no Bitwarden é a senha do superusuário do Postgres e é **compartilhado** com o Keycloak (mesma credencial).

## Validação

```bash
sudo k3s kubectl -n infra get pod,svc,sts,configmap,externalsecret
sudo k3s kubectl -n infra get externalsecret postgresql-auth \
  -o jsonpath='{.status.conditions}'   # type=Ready, status=True
```
