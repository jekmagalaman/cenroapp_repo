from django.contrib import admin
from django.urls import include, path
from rest_framework.authtoken.views import obtain_auth_token

from certificates.views_admin import admin_dashboard

urlpatterns = [
  path('panel/', include('certificates.portal_urls')),
  path('admin/dashboard/', admin_dashboard, name='admin_dashboard'),
  path('admin/', admin.site.urls),
  path('api/auth/login/', obtain_auth_token, name='api-login'),
  path('api/', include('certificates.urls')),
]

