#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-infra}"
SECRET_NAME="${SECRET_NAME:-postgresql-auth}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-}"
POSTGRES_DB="${POSTGRES_DB:-app}"

if [[ -z "${POSTGRES_PASSWORD}" ]]; then
  echo "Erro: defina POSTGRES_PASSWORD no ambiente."
  echo "Exemplo:"
  echo "POSTGRES_PASSWORD='minha-senha-forte' ./scripts/apply-k8s-secret.sh"
  exit 1
fi

echo "Aplicando Secret '${SECRET_NAME}' no namespace '${NAMESPACE}'..."

k3s kubectl get namespace "${NAMESPACE}" >/dev/null 2>&1 || k3s kubectl create namespace "${NAMESPACE}"

k3s kubectl -n "${NAMESPACE}" create secret generic "${SECRET_NAME}" \
  --from-literal=POSTGRES_USER="${POSTGRES_USER}" \
  --from-literal=POSTGRES_PASSWORD="${POSTGRES_PASSWORD}" \
  --from-literal=POSTGRES_DB="${POSTGRES_DB}" \
  --dry-run=client -o yaml | k3s kubectl apply -f -

echo "Secret aplicado com sucesso."
k3s kubectl -n "${NAMESPACE}" get secret "${SECRET_NAME}" -o name
