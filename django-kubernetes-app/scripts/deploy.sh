#!/bin/bash
# Скрипт для деплоя приложения

set -e

NAMESPACE="django-app"

echo "Начало деплоя Django приложения..."

# Создаем namespace если не существует
echo "Создание namespace..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Применяем манифесты
echo "Применение манифестов Kubernetes..."
kubectl apply -f k8s-manifests/ -n $NAMESPACE

# Ждем готовности подов
echo "Ожидание готовности подов..."
kubectl wait --for=condition=ready pod -l app=django-app -n $NAMESPACE --timeout=300s || true
kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=300s || true

# Показываем статус
echo ""
echo "Статус деплоя:"
kubectl get all -n $NAMESPACE

echo ""
echo "Деплой завершен!"

