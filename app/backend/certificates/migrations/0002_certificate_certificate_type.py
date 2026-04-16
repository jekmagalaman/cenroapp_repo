# Generated manually for certificate type filter

from django.db import migrations, models


class Migration(migrations.Migration):

  dependencies = [
    ('certificates', '0001_initial'),
  ]

  operations = [
    migrations.AddField(
      model_name='certificate',
      name='certificate_type',
      field=models.CharField(
        choices=[
          ('builders_form', 'Builders Form'),
          ('motorized_certification', 'Motorized Certification'),
          ('marine_certification', 'Marine Certification'),
          ('exclusive_fish_privilege', 'Exclusive Fish Privilege'),
        ],
        default='marine_certification',
        max_length=32,
      ),
    ),
  ]
