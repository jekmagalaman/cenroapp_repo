# CertificateCounter rows + seed last_seq from existing Certificate control numbers.

from django.db import migrations, models


def _max_suffix_for_prefix(apps, certificate_type: str, prefix: str) -> int:
  Certificate = apps.get_model('certificates', 'Certificate')
  max_n = 0
  needle = f'{prefix}-'
  for cn in Certificate.objects.filter(certificate_type=certificate_type).values_list(
    'control_number',
    flat=True,
  ):
    s = (cn or '').strip().upper()
    if not s.startswith(needle.upper()):
      continue
    tail = s[len(needle) :]
    n = int(''.join(c for c in tail if c.isdigit()) or '0')
    if n > max_n:
      max_n = n
  return max_n


def _max_suffix_scan(apps, prefix: str) -> int:
  Certificate = apps.get_model('certificates', 'Certificate')
  max_n = 0
  needle = f'{prefix}-'.upper()
  for cn in Certificate.objects.values_list('control_number', flat=True):
    s = (cn or '').strip().upper()
    if not s.startswith(needle):
      continue
    tail = s[len(needle) :]
    n = int(''.join(c for c in tail if c.isdigit()) or '0')
    if n > max_n:
      max_n = n
  return max_n


def forwards(apps, schema_editor):
  CertificateCounter = apps.get_model('certificates', 'CertificateCounter')
  mapping = (
    ('builders_form', 'BF'),
    ('motorized_certification', 'MC'),
    ('marine_certification', 'MR'),
    ('exclusive_fish_privilege', 'EFP'),
  )
  for ct, pfx in mapping:
    max_scan = _max_suffix_scan(apps, pfx)
    max_typed = _max_suffix_for_prefix(apps, ct, pfx)
    last = max(max_scan, max_typed)
    CertificateCounter.objects.update_or_create(
      certificate_type=ct,
      defaults={'last_seq': last},
    )


def backwards(apps, schema_editor):
  CertificateCounter = apps.get_model('certificates', 'CertificateCounter')
  CertificateCounter.objects.all().delete()


class Migration(migrations.Migration):

  dependencies = [
    ('certificates', '0003_fix_certificate_type_from_control_prefix'),
  ]

  operations = [
    migrations.CreateModel(
      name='CertificateCounter',
      fields=[
        ('certificate_type', models.CharField(max_length=32, primary_key=True, serialize=False)),
        ('last_seq', models.PositiveIntegerField(default=0)),
      ],
      options={
        'verbose_name': 'Certificate number sequence',
        'verbose_name_plural': 'Certificate number sequences',
      },
    ),
    migrations.RunPython(forwards, backwards),
  ]
