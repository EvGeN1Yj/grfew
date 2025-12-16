"""
URL configuration for django_app project.
"""
from django.contrib import admin
from django.urls import path
from django_app import views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('health/', views.health, name='health'),
    path('api/', views.api_info, name='api'),
    path('', views.home, name='home'),
]
