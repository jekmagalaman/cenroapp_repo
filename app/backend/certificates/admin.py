from django.contrib.admin import ModelAdmin, SimpleListFilter, register

from .models import Certificate, CertificateCounter, PhotoReport


class CertificateTypeListFilter(SimpleListFilter):
  """Sidebar filter: one option per form type (Builders / Motorized / Marine / Fish)."""

  title = 'Certificate type'
  parameter_name = 'certificate_type'

  def lookups(self, request, model_admin):
    return Certificate.CERTIFICATE_TYPE_CHOICES

  def queryset(self, request, queryset):
    if self.value():
      return queryset.filter(certificate_type=self.value())
    return queryset


@register(CertificateCounter)
class CertificateCounterAdmin(ModelAdmin):
  list_display = ('certificate_type', 'last_seq')
  ordering = ('certificate_type',)


@register(Certificate)
class CertificateAdmin(ModelAdmin):
  list_display = (
    'control_number',
    'certificate_type',
    'applicant_name',
    'submitted_by',
    'business_name',
    'license_type',
    'issued_date',
    'created_at',
  )
  list_filter = (
    CertificateTypeListFilter,
    'license_type',
    'created_by',
    'created_at',
  )
  search_fields = (
    'control_number',
    'applicant_name',
    'business_name',
    'applicant_address',
    'inspector_name',
    'created_by__username',
  )
  date_hierarchy = 'created_at'
  ordering = ('-created_at',)
  readonly_fields = ('created_at',)

  fieldsets = (
    (None, {
      'fields': ('certificate_type', 'control_number', 'license_type', 'issued_date', 'inspector_name'),
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

  def submitted_by(self, obj):
    if obj.created_by:
      return obj.created_by.username
    if obj.inspector_name:
      return f'{obj.inspector_name} (legacy)'
    return '—'

  submitted_by.short_description = 'Sent by'


@register(PhotoReport)
class PhotoReportAdmin(ModelAdmin):
  list_display = ('id', 'created_by', 'created_at', 'has_location', 'short_description')
  list_filter = ('created_at', 'created_by')
  search_fields = ('description', 'created_by__username')
  date_hierarchy = 'created_at'
  ordering = ('-created_at',)
  readonly_fields = ('created_at',)

  def has_location(self, obj):
    return bool(obj.latitude is not None and obj.longitude is not None)

  has_location.boolean = True
  has_location.short_description = 'Location'

  def short_description(self, obj):
    d = (obj.description or '').strip().replace('\n', ' ')
    if len(d) > 60:
      return d[:57] + '...'
    return d or '—'

  short_description.short_description = 'Description'

