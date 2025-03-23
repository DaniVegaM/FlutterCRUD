from os.path import basename

from rest_framework.routers import DefaultRouter

from custom_user.views import UserViewSet, AdminViewSet

router = DefaultRouter(trailing_slash=False)

router.register(r'api/user', UserViewSet, basename='api/user')
router.register(r'api/admin', AdminViewSet, basename='api/admin')

urlpatterns = router.urls