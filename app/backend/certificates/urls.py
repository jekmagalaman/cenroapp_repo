from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CertificateViewSet, PhotoReportViewSet, UserViewSet


router = DefaultRouter()
router.register('certificates', CertificateViewSet, basename='certificate')
router.register('photo-reports', PhotoReportViewSet, basename='photo-report')
router.register('users', UserViewSet, basename='user')


urlpatterns = [
  path('', include(router.urls)),
]

