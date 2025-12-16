#!/bin/bash
# Скрипт для настройки Vault секретов

echo "Настройка Vault секретов для Django приложения..."

# Определяем имя пода Vault (может быть vault-0 для Helm или deployment/vault для установки без Helm)
VAULT_POD=$(kubectl get pod -n vault -l app=vault -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$VAULT_POD" ]; then
    # Пробуем найти pod с другим селектором (для Helm установки)
    VAULT_POD=$(kubectl get pod -n vault -l app.kubernetes.io/name=vault -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
fi

if [ -z "$VAULT_POD" ]; then
    echo "Ошибка: Pod Vault не найден!"
    echo "Убедитесь, что Vault установлен и запущен:"
    echo "  kubectl get pods -n vault"
    exit 1
fi

echo "Используется pod: $VAULT_POD"

# Подключаемся к pod Vault
kubectl exec -it $VAULT_POD -n vault -- /bin/sh <<EOF
export VAULT_ADDR='http://127.0.0.1:8200'
export VAULT_TOKEN='root'

# Включаем KV v2 секреты
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV v2 уже включен"

# Записываем секреты для БД
vault kv put secret/django-app/database \
  db_name="django_prod" \
  db_user="django_user" \
  db_password="SuperSecret123!" \
  secret_key="django-insecure-your-secret-key-here-change-in-production"

# Создаем политику доступа
vault policy write django-app - <<POLICY
path "secret/data/django-app/*" {
  capabilities = ["read"]
}
POLICY

echo "Секреты успешно настроены в Vault!"
vault kv get secret/django-app/database
EOF

