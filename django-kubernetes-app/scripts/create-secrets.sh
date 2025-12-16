#!/bin/bash
# Скрипт для создания Kubernetes секретов

echo "Создание Kubernetes секретов для Django приложения..."

kubectl create secret generic django-secrets \
  --namespace django-app \
  --from-literal=db_user="django_user" \
  --from-literal=db_password="SuperSecret123!" \
  --from-literal=secret_key="django-insecure-your-secret-key-here-change-in-production" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Секреты успешно созданы!"
kubectl get secrets -n django-app

