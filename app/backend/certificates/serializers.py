from rest_framework import serializers

from .models import Certificate


class CertificateSerializer(serializers.ModelSerializer):
  class Meta:
    model = Certificate
    fields = [
      'id',
      'control_number',
      'applicant_name',
      'applicant_address',
      'license_type',
      'nature_of_business',
      'business_name',
      'business_address',
      'contact_number',
      'issued_date',
      'inspector_name',
      'created_at',
    ]
    read_only_fields = ['id', 'created_at']

  def create(self, validated_data):
    request = self.context.get('request')
    user = getattr(request, 'user', None)
    return Certificate.objects.create(created_by=user, **validated_data)

