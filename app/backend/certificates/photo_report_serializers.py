from rest_framework import serializers

from .models import PhotoReport


class PhotoReportSerializer(serializers.ModelSerializer):
  image_url = serializers.SerializerMethodField()

  class Meta:
    model = PhotoReport
    fields = [
      'id',
      'description',
      'image',
      'image_url',
      'latitude',
      'longitude',
      'accuracy_meters',
      'created_by',
      'created_at',
    ]
    read_only_fields = ['id', 'created_by', 'created_at', 'image_url']

  def get_image_url(self, obj: PhotoReport) -> str:
    request = self.context.get('request')
    if not obj.image:
      return ''
    try:
      url = obj.image.url
    except Exception:
      return ''
    if request is None:
      return url
    return request.build_absolute_uri(url)
