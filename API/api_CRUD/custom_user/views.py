from django.contrib.admin.utils import model_ngettext
from rest_framework import viewsets, permissions
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .models import User
from .serializers import UserSerializer, UserCreateSerializer


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all().order_by('-date_joined')

    def get_serializer_class(self):
        if self.action == 'create':
            return UserCreateSerializer
        return UserSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        else:
            # 🔥 Imprime el error detallado en la consola
            print("Errores de validación:", serializer.errors)

            # Devuelve el error detallado
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserProfileViewSet(viewsets.ModelViewSet):
    # Usa ModelViewSet para manejar el CRUD completo
    permission_classes = [IsAuthenticated]

    queryset = User.objects.all()

    def get_serializer_class(self):
        return UserSerializer  # O el que necesites para mostrar el perfil

    def list(self, request, *args, **kwargs):
        user = request.user
        return Response({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'avatar': user.avatar,
            'description': user.description,
        })

    def create(self, request, *args, **kwargs):
        user = request.user
        data = request.data

        # Obtener los datos enviados en la solicitud
        username = data.get('username', user.username)  # Si no se pasa 'username', se mantiene el actual
        email = data.get('email', user.email)  # Si no se pasa 'email', se mantiene el actual
        description = data.get('description', user.description)  # Si no se pasa 'description', se mantiene el actual
        avatar = data.get('avatar', user.avatar)  # Si no se pasa 'avatar', se mantiene el actual

        # Validación de unicidad del username y email
        if User.objects.filter(username=username).exclude(id=user.id).exists():
            return Response({'error': 'El nombre de usuario ya está en uso'}, status=status.HTTP_400_BAD_REQUEST)

        if User.objects.filter(email=email).exclude(id=user.id).exists():
            return Response({'error': 'El correo electrónico ya está en uso'}, status=status.HTTP_400_BAD_REQUEST)

        # Actualizar los campos del usuario
        user.username = username
        user.email = email
        user.description = description
        user.avatar = avatar

        # Guardar los cambios
        user.save()

        return Response({
            'id': user.id,
            'username': user.username,
            'email': user.email,
            'avatar': user.avatar if user.avatar else None,
            'description': user.description,
        }, status=status.HTTP_200_OK)

class IsAdminUser(permissions.BasePermission):
    """
    Permite acceso solo a administradores.
    """
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_superuser


class AdminViewSet(viewsets.ModelViewSet):
    queryset = User.objects.filter(is_superuser=False)  # Solo usuarios normales
    permission_classes = [IsAuthenticated, IsAdminUser]
    serializer_class = UserSerializer

    def get_queryset(self):
        """
        Solo lista usuarios normales
        """
        return User.objects.filter(is_superuser=False)