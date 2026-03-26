from django.db import models
from django.contrib.auth.models import User


class Certificate(models.Model):
  control_number = models.CharField(max_length=50, unique=True)
  applicant_name = models.CharField(max_length=255)
  applicant_address = models.TextField()
  license_type = models.CharField(max_length=20)
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

