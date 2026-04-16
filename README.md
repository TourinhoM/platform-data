# deploy-prostgresql

Manifests GitOps do PostgreSQL para sincronizacao via Argo CD.

## Estrutura

- `k8s/base`: manifests base (Service + StatefulSet + secret placeholder)
- `k8s/overlays/dev`: overlay para desenvolvimento
- `k8s/overlays/prod`: placeholder para producao

## ArgoCD

No `deploy-argocd`, o `Application` deve apontar para:

- `repoURL`: `https://github.com/TourinhoM/deploy-prostgresql.git`
- `path`: `k8s/overlays/dev`
- `targetRevision`: `main`

## Seguranca

- Nao commitar senha em texto puro.
- O Secret `postgresql-auth` deve ser criado no cluster com `kubectl`.

## Secret nativo do Kubernetes (recomendado para agora)

Este repo ja esta preparado para usar `Secret` nativo sem versionar credenciais.

### 1) Gerar/aplicar o secret no cluster

Use o script:

```bash
./scripts/apply-k8s-secret.sh
```

Ou informando valores:

```bash
NAMESPACE=infra POSTGRES_USER=postgres POSTGRES_PASSWORD='troque-essa-senha' POSTGRES_DB=app ./scripts/apply-k8s-secret.sh
```

### 2) Conferir se o secret existe

```bash
kubectl -n infra get secret postgresql-auth
```

### 3) Sincronizar no ArgoCD

Depois do secret existir, sincronize o app `infra-postgresql-dev` no ArgoCD.

## Execucao rapida (copiar e colar)

```bash
cd /home/lab/deploy-prostgresql
POSTGRES_PASSWORD='troque-essa-senha' ./scripts/apply-k8s-secret.sh
kubectl -n infra get secret postgresql-auth
```

Se o seu namespace nao for `infra`:

```bash
cd /home/lab/deploy-prostgresql
NAMESPACE=database POSTGRES_PASSWORD='troque-essa-senha' ./scripts/apply-k8s-secret.sh
kubectl -n database get secret postgresql-auth
```

## Variaveis suportadas no script

- `NAMESPACE` (default: `infra`)
- `SECRET_NAME` (default: `postgresql-auth`)
- `POSTGRES_USER` (default: `postgres`)
- `POSTGRES_PASSWORD` (**obrigatoria**, sem default)
- `POSTGRES_DB` (default: `app`)

## Arquivos de suporte

- `k8s/base/secret.example.yaml`: apenas referencia de estrutura, nao aplicado pelo kustomize.
- `scripts/apply-k8s-secret.sh`: cria/aplica o Secret no namespace escolhido.
