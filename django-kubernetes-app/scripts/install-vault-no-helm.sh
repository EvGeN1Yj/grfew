#!/bin/bash
# Скрипт для установки Vault без Helm (обход блокировки CloudFront)

set -e

echo "Установка Vault без Helm..."

# Создаем namespace если не существует
kubectl create namespace vault --dry-run=client -o yaml | kubectl apply -f -

# Устанавливаем Vault через манифесты
echo "Создание Deployment и Service для Vault..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vault
  namespace: vault
  labels:
    app: vault
spec:
  replicas: 1
  selector:
    matchLabels:
      app: vault
  template:
    metadata:
      labels:
        app: vault
    spec:
      containers:
      - name: vault
        image: hashicorp/vault:latest
        args:
        - server
        - -dev
        - -dev-root-token-id=root
        - -dev-listen-address=0.0.0.0:8200
        ports:
        - name: http
          containerPort: 8200
          protocol: TCP
        env:
        - name: VAULT_ADDR
          value: "http://0.0.0.0:8200"
        - name: VAULT_DEV_ROOT_TOKEN_ID
          value: "root"
        - name: VAULT_DEV_LISTEN_ADDRESS
          value: "0.0.0.0:8200"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /v1/sys/health
            port: 8200
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /v1/sys/health
            port: 8200
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: vault
  namespace: vault
  labels:
    app: vault
spec:
  type: ClusterIP
  ports:
  - name: http
    port: 8200
    targetPort: 8200
    protocol: TCP
  selector:
    app: vault
EOF

echo "Ожидание готовности Vault..."
kubectl wait --namespace vault \
  --for=condition=ready pod \
  --selector=app=vault \
  --timeout=120s || true

echo "Проверка статуса..."
kubectl get pods -n vault
kubectl get svc -n vault

echo ""
echo "Vault установлен!"
echo ""
echo "Для настройки секретов выполните:"
echo "  kubectl exec -it deployment/vault -n vault -- /bin/sh"
echo ""
echo "Затем внутри pod:"
echo "  export VAULT_ADDR='http://127.0.0.1:8200'"
echo "  export VAULT_TOKEN='root'"
echo "  vault secrets enable -path=secret kv-v2"
echo "  vault kv put secret/django-app/database \\"
echo "    db_name=\"django_prod\" \\"
echo "    db_user=\"django_user\" \\"
echo "    db_password=\"SuperSecret123!\" \\"
echo "    secret_key=\"django-insecure-your-secret-key-here\""

