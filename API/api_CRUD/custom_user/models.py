from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    description = models.TextField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    avatar = models.TextField(null=True, blank=True)

    # Asegúrate de que email sea único
    email = models.EmailField(unique=True)

    # Establecer 'email' como el campo de autenticación
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']  # Si lo necesitas para crear el usuario, puedes mantenerlo aquí