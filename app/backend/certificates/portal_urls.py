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
  path(
    'certificates/<int:pk>/export/<str:filetype>/',
    portal_views.certificate_export,
    name='portal_cert_export',
  ),
  path('inspectors/', portal_views.inspectors_list, name='portal_inspectors'),
  path('inspectors/create/', portal_views.user_create, name='user_create'),
  path('inspectors/<int:pk>/update/', portal_views.user_update, name='user_update'),
  path('inspectors/<int:pk>/delete/', portal_views.user_delete, name='user_delete'),
  path('photo-reports/', portal_views.photo_reports_list, name='portal_photo_reports'),
  path('reports/', portal_views.reports, name='portal_reports'),
]
