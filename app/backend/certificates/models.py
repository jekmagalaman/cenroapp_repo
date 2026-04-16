from django.db import models
from django.contrib.auth.models import User


def infer_certificate_type_from_control_number(control_number: str) -> str:
  """Map control number prefix (BF-, MC-, MR-, EFP-) to certificate_type. Fallback: marine."""
  cn = (control_number or '').strip().upper()
  if cn.startswith('BF-'):
    return 'builders_form'
  if cn.startswith('MC-'):
    return 'motorized_certification'
  if cn.startswith('MR-'):
    return 'marine_certification'
  if cn.startswith('EFP-'):
    return 'exclusive_fish_privilege'
  return 'marine_certification'


class Certificate(models.Model):
  """Form category (Builders, Motorized, Marine, Exclusive Fish). Distinct from license_type (New/Renew)."""

  CERTIFICATE_TYPE_CHOICES = [
    ('builders_form', 'Builders Form'),
    ('motorized_certification', 'Motorized Certification'),
    ('marine_certification', 'Marine Certification'),
    ('exclusive_fish_privilege', 'Exclusive Fish Privilege'),
  ]

  certificate_type = models.CharField(
    max_length=32,
    choices=CERTIFICATE_TYPE_CHOICES,
    default='marine_certification',
    verbose_name='Certificate type',
    help_text='Form category: Builders, Motorized, Marine, or Exclusive Fish.',
  )
  control_number = models.CharField(max_length=50, unique=True)
  applicant_name = models.CharField(max_length=255)
  applicant_address = models.TextField()
  license_type = models.CharField(
    max_length=20,
    verbose_name='License (New / Renew)',
  )
  nature_of_business = models.CharField(max_length=255)
  business_name = models.CharField(max_length=255)
  business_address = models.TextField()
  contact_number = models.CharField(max_length=50)
  issued_date = models.CharField(max_length=100)
  inspector_name = models.CharField(max_length=255)
  created_by = models.ForeignKey(
    User,
    on_delete=models.SET_NULL,
    null=True,
    blank=True,
    related_name='certificates',
  )
  created_at = models.DateTimeField(auto_now_add=True)

  class Meta:
    ordering = ['-created_at']

  def __str__(self) -> str:
    return self.control_number


class CertificateCounter(models.Model):
  """Atomic sequence per certificate_type for server-generated control numbers."""

  certificate_type = models.CharField(max_length=32, primary_key=True)
  last_seq = models.PositiveIntegerField(default=0)

  class Meta:
    verbose_name = 'Certificate number sequence'
    verbose_name_plural = 'Certificate number sequences'

  def __str__(self) -> str:
    return f'{self.certificate_type}: {self.last_seq}'


class PhotoReport(models.Model):
  """Inspector-submitted photo report (image + description) from mobile app."""

  description = models.TextField(blank=True, default='')
  image = models.ImageField(upload_to='photo_reports/%Y/%m/%d/')
  latitude = models.FloatField(null=True, blank=True)
  longitude = models.FloatField(null=True, blank=True)
  accuracy_meters = models.FloatField(null=True, blank=True)
  created_by = models.ForeignKey(
    User,
    on_delete=models.SET_NULL,
    null=True,
    blank=True,
    related_name='photo_reports',
  )
  created_at = models.DateTimeField(auto_now_add=True)

  class Meta:
    ordering = ['-created_at']

  def __str__(self) -> str:
    return f'PhotoReport {self.pk}'

