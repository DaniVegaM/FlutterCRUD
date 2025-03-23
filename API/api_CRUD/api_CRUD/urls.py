from django.contrib import admin
from django.urls import path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt import views as jwt_views
from custom_user.views import UserProfileViewSet

from custom_user.urls import router as user_router

router = DefaultRouter()
router.register(r'api/user/profile', UserProfileViewSet, basename='user-profile')

router.registry.extend(user_router.registry)

urlpatterns = router.urls + [
    # URL para obtener el token de acceso (login)
    path('api/token/', jwt_views.TokenObtainPairView.as_view(), name='token_obtain_pair'),
    # URL para obtener el token de refresco (si necesitas refrescar el token)
    path('api/token/refresh/', jwt_views.TokenRefreshView.as_view(), name='token_refresh'),
]
