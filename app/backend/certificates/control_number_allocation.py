"""Thread-safe allocation of unique control numbers per certificate type (server only)."""

from django.db import transaction

from .models import CertificateCounter

# Must match mobile app prefixes and Certificate.CERTIFICATE_TYPE_CHOICES keys.
PREFIX_BY_TYPE = {
  'builders_form': 'BF',
  'motorized_certification': 'MC',
  'marine_certification': 'MR',
  'exclusive_fish_privilege': 'EFP',
}


def allocate_control_number(certificate_type: str) -> str:
  """
  Return next control number like MC-042 for the given certificate_type.
  Safe under concurrent inspectors: uses select_for_update on the counter row.
  """
  prefix = PREFIX_BY_TYPE.get(certificate_type)
  if not prefix:
    raise ValueError(f'Unknown certificate_type: {certificate_type!r}')

  with transaction.atomic():
    counter, _created = CertificateCounter.objects.select_for_update().get_or_create(
      certificate_type=certificate_type,
      defaults={'last_seq': 0},
    )
    counter.last_seq += 1
    counter.save(update_fields=['last_seq'])
    seq = counter.last_seq

  return f'{prefix}-{seq:03d}'
