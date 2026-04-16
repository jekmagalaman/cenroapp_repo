# Fix rows that defaulted to marine_certification; infer from control number prefix.

from django.db import migrations


def forwards(apps, schema_editor):
  Certificate = apps.get_model('certificates', 'Certificate')
  mapping = (
    ('BF-', 'builders_form'),
    ('MC-', 'motorized_certification'),
    ('MR-', 'marine_certification'),
    ('EFP-', 'exclusive_fish_privilege'),
  )
  for prefix, ctype in mapping:
    Certificate.objects.filter(control_number__startswith=prefix).update(
      certificate_type=ctype,
    )


def backwards(apps, schema_editor):
  pass


class Migration(migrations.Migration):

  dependencies = [
    ('certificates', '0002_certificate_certificate_type'),
  ]

  operations = [
    migrations.RunPython(forwards, backwards),
  ]
