from django.contrib import admin

from .models import Certificate


@admin.register(Certificate)
class CertificateAdmin(admin.ModelAdmin):
  list_display = (
    'control_number',
    'applicant_name',
    'business_name',
    'license_type',
    'issued_date',
    'created_by',
    'created_at',
  )
  list_filter = ('license_type', 'created_at')
  search_fields = (
    'control_number',
    'applicant_name',
    'business_name',
    'applicant_address',
    'inspector_name',
  )
  date_hierarchy = 'created_at'
  ordering = ('-created_at',)
  readonly_fields = ('created_at',)

  fieldsets = (
    (None, {
      'fields': ('control_number', 'license_type', 'issued_date', 'inspector_name'),
    }),
    ('Applicant', {
      'fields': ('applicant_name', 'applicant_address', 'contact_number'),
    }),
    ('Business', {
      'fields': ('nature_of_business', 'business_name', 'business_address'),
    }),
    ('Meta', {
      'fields': ('created_by', 'created_at'),
      'classes': ('collapse',),
    }),
  )

