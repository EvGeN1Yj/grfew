from django.shortcuts import render
from django.http import JsonResponse
import socket
import os
from datetime import datetime


def get_hostname():
    return socket.gethostname()


def get_pod_ip():
    return socket.gethostbyname(socket.gethostname())


def home(request):
    """Главная страница с красивым интерфейсом"""
    hostname = get_hostname()
    pod_ip = get_pod_ip()
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    context = {
        'hostname': hostname,
        'pod_ip': pod_ip,
        'timestamp': timestamp,
        'db_host': os.getenv('DB_HOST', 'N/A'),
        'db_name': os.getenv('DB_NAME', 'N/A'),
    }

    return render(request, 'home.html', context)


def health(request):
    """Health check endpoint"""
    return JsonResponse({
        'status': 'healthy',
        'hostname': get_hostname(),
        'timestamp': datetime.now().isoformat()
    })


def api_info(request):
    """API endpoint для JSON ответа"""
    return JsonResponse({
        'message': 'Django Kubernetes App',
        'hostname': get_hostname(),
        'status': 'running',
        'pod_ip': get_pod_ip(),
        'timestamp': datetime.now().isoformat()
    })

