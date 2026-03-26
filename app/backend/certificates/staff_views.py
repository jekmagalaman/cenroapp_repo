from django.contrib import messages
from django.contrib.auth import login, logout
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib.auth.models import User
from django.db.models import Count, Q
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.http import require_http_methods

from .models import Certificate


def is_staff_user(user):
  return user.is_authenticated and user.is_staff


@require_http_methods(['GET', 'POST'])
def staff_login(request):
  if request.user.is_authenticated and request.user.is_staff:
    return redirect('staff_dashboard')
  if request.method == 'POST':
    username = request.POST.get('username', '').strip()
    password = request.POST.get('password', '')
    from django.contrib.auth import authenticate

    user = authenticate(request, username=username, password=password)
    if user is not None and user.is_staff:
      login(request, user)
      next_url = request.GET.get('next') or 'staff_dashboard'
      return redirect(next_url)
    messages.error(request, 'Invalid credentials or account is not staff.')
  return render(request, 'staff/login.html')


@login_required(login_url='staff_login')
@user_passes_test(is_staff_user, login_url='staff_login')
def staff_logout_view(request):
  logout(request)
  messages.info(request, 'You have been signed out.')
  return redirect('staff_login')


@login_required(login_url='staff_login')
@user_passes_test(is_staff_user, login_url='staff_login')
def staff_dashboard(request):
  total = Certificate.objects.count()
  today = Certificate.objects.filter(
    created_at__date=request.user.last_login.date() if request.user.last_login else None
  ).count()
  # Simpler: last 7 days
  from django.utils import timezone
  from datetime import timedelta

  week_ago = timezone.now() - timedelta(days=7)
  recent_week = Certificate.objects.filter(created_at__gte=week_ago).count()
  latest = Certificate.objects.select_related('created_by')[:8]
  by_user = (
    User.objects.filter(certificates__isnull=False)
    .annotate(c=Count('certificates'))
    .order_by('-c')[:5]
  )
  return render(
    request,
    'staff/dashboard.html',
    {
      'total_certificates': total,
      'recent_week': recent_week,
      'latest_certificates': latest,
      'top_contributors': by_user,
    },
  )


@login_required(login_url='staff_login')
@user_passes_test(is_staff_user, login_url='staff_login')
def staff_certificate_list(request):
  q = request.GET.get('q', '').strip()
  qs = Certificate.objects.select_related('created_by').order_by('-created_at')
  if q:
    qs = qs.filter(
      Q(control_number__icontains=q)
      | Q(applicant_name__icontains=q)
      | Q(business_name__icontains=q)
      | Q(contact_number__icontains=q)
    )
  return render(
    request,
    'staff/certificate_list.html',
    {'certificates': qs, 'search_query': q},
  )


@login_required(login_url='staff_login')
@user_passes_test(is_staff_user, login_url='staff_login')
def staff_certificate_detail(request, pk):
  cert = get_object_or_404(Certificate.objects.select_related('created_by'), pk=pk)
  return render(request, 'staff/certificate_detail.html', {'certificate': cert})
