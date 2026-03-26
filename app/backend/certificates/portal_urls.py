from django.urls import path

from . import portal_views

urlpatterns = [
  path('login/', portal_views.portal_login, name='portal_login'),
  path('logout/', portal_views.portal_logout, name='portal_logout'),
  path('', portal_views.dashboard, name='portal_dashboard'),
  path('certificates/', portal_views.certificate_list, name='portal_cert_list'),
  path(
    'certificates/<int:pk>/',
    portal_views.certificate_detail,
    name='portal_cert_detail',
  ),
]

