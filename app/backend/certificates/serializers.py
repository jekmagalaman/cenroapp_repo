from rest_framework import serializers



from django.contrib.auth import get_user_model
from .control_number_allocation import allocate_control_number

from .models import Certificate
User = get_user_model()







class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_staff', 'is_superuser', 'date_joined', 'last_login', 'cert_count']
        read_only_fields = ['id', 'date_joined', 'last_login', 'cert_count', 'username']
    
    def create(self, validated_data):
        password = validated_data.pop('password')
        user = User.objects.create_user(**validated_data)
        user.set_password(password)
        user.save()
        return user


class CertificateSerializer(serializers.ModelSerializer):


  class Meta:

    model = Certificate

    fields = [

      'id',

      'certificate_type',

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

    extra_kwargs = {

      # Server assigns on create; client may omit or send __LOCAL__ placeholder.

      'control_number': {

        'validators': [],

        'required': False,

        'allow_blank': True,

      },

      'certificate_type': {'required': True},

    }



  def create(self, validated_data):

    request = self.context.get('request')

    user = getattr(request, 'user', None)



    cn_in = (validated_data.pop('control_number', None) or '').strip()

    if cn_in.startswith('__LOCAL__'):

      cn_in = ''



    cert_type = validated_data.get('certificate_type')

    if not cert_type:

      raise serializers.ValidationError(

        {

          'certificate_type': (

            'This field is required. Send the certificate form type (e.g. motorized_certification).'

          ),

        },

      )



    if cn_in and Certificate.objects.filter(control_number=cn_in).exists():

      control_number = cn_in

    else:

      if validated_data.get('license_type') == 'Renew':

        if cn_in:

          raise serializers.ValidationError(

            {

              'control_number': (

                'No certificate with this control number exists on the server; '

                'cannot renew. Check the number or ensure the original was synced.'

              ),

            }

          )

        raise serializers.ValidationError(

          {'control_number': 'Control number is required for renewal.'},

        )

      control_number = allocate_control_number(cert_type)



    defaults = {**validated_data}

    if user is not None:

      defaults['created_by'] = user

    obj, _created = Certificate.objects.update_or_create(

      control_number=control_number,

      defaults=defaults,

    )

    return obj


