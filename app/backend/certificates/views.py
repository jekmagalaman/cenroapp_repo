from rest_framework import permissions, viewsets
from rest_framework.parsers import FormParser, MultiPartParser

from .models import Certificate
from .serializers import CertificateSerializer
from .models import PhotoReport
from .photo_report_serializers import PhotoReportSerializer
from .serializers import UserSerializer
from django.db.models import Count
from django.contrib.auth import get_user_model
User = get_user_model()
from rest_framework import permissions


class CertificateViewSet(viewsets.ModelViewSet):
  queryset = Certificate.objects.all()
  serializer_class = CertificateSerializer
  permission_classes = [permissions.IsAuthenticated]



class PhotoReportViewSet(viewsets.ModelViewSet):
  queryset = PhotoReport.objects.select_related('created_by').all()
  serializer_class = PhotoReportSerializer
  permission_classes = [permissions.IsAuthenticated]
  parser_classes = [MultiPartParser, FormParser]

  def perform_create(self, serializer):
    serializer.save(created_by=self.request.user)


class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.annotate(cert_count=Count('certificates')).all()
    serializer_class = UserSerializer
    permission_classes = [permissions.IsAuthenticated, permissions.IsAdminUser]

