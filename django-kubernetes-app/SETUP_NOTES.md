# Заметки по настройке проекта

## ⚠️ Важные настройки перед использованием

### 1. Обновление пути к Docker образу

В файле `k8s-manifests/deployment.yaml` замените:

```yaml
image: ghcr.io/your-username/django-kubernetes-app:latest
```

на ваш реальный путь к образу, например:

```yaml
image: ghcr.io/evgeniy/django-kubernetes-app:latest
```

### 2. Настройка Ingress

В файле `k8s-manifests/ingress.yaml` замените:

```yaml
host: "your-domain.com"
```

на IP вашего сервера или домен:

```yaml
host: "192.168.1.100"  # или ваш домен
```

Или для тестирования можно использовать:

```yaml
host: "localhost"
```

### 3. Настройка GitHub репозитория

1. Создайте репозиторий на GitHub
2. Обновите путь к образу в `deployment.yaml` (см. пункт 1)
3. Добавьте секрет `KUBE_CONFIG` в GitHub:
   - Settings → Secrets and variables → Actions → New secret
   - Имя: `KUBE_CONFIG`
   - Значение: содержимое `~/.kube/config` с вашего сервера

### 4. Изменение секретов

**ВАЖНО**: Измените все секреты на свои собственные!

- В скриптах `scripts/setup-vault.sh` и `scripts/create-secrets.sh`
- В Vault (если используете)
- В Kubernetes секретах

### 5. Настройка базы данных

Убедитесь, что в `k8s-manifests/configmap.yaml` указаны правильные параметры подключения к БД.

## Порядок выполнения

1. Настройте пути к образам и хостам (пункты 1-2)
2. Создайте репозиторий на GitHub
3. Настройте секреты (пункт 4)
4. Запушьте код в репозиторий
5. Настройте GitHub Actions секреты (пункт 3)
6. Выполните деплой согласно инструкции

