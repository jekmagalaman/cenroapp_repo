from functools import wraps

from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.db.models import Count, Q
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone

from .models import Certificate


def portal_staff_required(view_func):
  @wraps(view_func)
  @login_required(login_url='/panel/login/')
  def wrapper(request, *args, **kwargs):
    if not request.user.is_staff:
      logout(request)
      return redirect('/panel/login/')
    return view_func(request, *args, **kwargs)

  return wrapper


def portal_login(request):
  if request.method == 'POST':
    username = (request.POST.get('username') or '').strip()
    password = request.POST.get('password') or ''
    user = authenticate(request, username=username, password=password)
    if user is not None and user.is_staff:
      login(request, user)
      return redirect('/panel/')
    messages.error(request, 'Invalid credentials or not allowed.')

  return render(request, 'portal/login.html')


def portal_logout(request):
  logout(request)
  return redirect('/panel/login/')


@portal_staff_required
def dashboard(request):
  now = timezone.now()
  today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
  month_start = today_start.replace(day=1)

  total = Certificate.objects.count()
  today = Certificate.objects.filter(created_at__gte=today_start).count()
  this_month = Certificate.objects.filter(created_at__gte=month_start).count()

  recent = Certificate.objects.all()[:10]

  license_breakdown = (
    Certificate.objects.values('license_type')
    .annotate(count=Count('id'))
    .order_by('-count')
  )

  return render(
    request,
    'portal/dashboard.html',
    {
      'total_certificates': total,
      'today_count': today,
      'this_month_count': this_month,
      'recent_certificates': recent,
      'license_breakdown': license_breakdown,
    },
  )


@portal_staff_required
def certificate_list(request):
  q = (request.GET.get('q') or '').strip()
  license_type = (request.GET.get('license_type') or '').strip()

  qs = Certificate.objects.all()
  if q:
    qs = qs.filter(
      Q(control_number__icontains=q)
      | Q(applicant_name__icontains=q)
      | Q(business_name__icontains=q)
    )

  if license_type:
    qs = qs.filter(license_type=license_type)

  qs = qs.order_by('-created_at')[:500]

  license_types = (
    Certificate.objects.values_list('license_type', flat=True)
    .distinct()
    .order_by('license_type')
  )

  return render(
    request,
    'portal/certificates_list.html',
    {
      'certificates': qs,
      'q': q,
      'license_type': license_type,
      'license_types': license_types,
    },
  )


@portal_staff_required
def certificate_detail(request, pk: int):
  cert = get_object_or_404(Certificate, pk=pk)
  return render(
    request,
    'portal/certificate_detail.html',
    {'cert': cert},
  )

