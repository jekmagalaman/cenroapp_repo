from functools import wraps

from django.contrib import messages
from django.contrib.auth import authenticate, login, logout, get_user_model
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.db.models import Count, Q
from django.shortcuts import get_object_or_404, redirect, render
from django.utils import timezone
from datetime import timedelta

from .export_service import build_excel_bytes, build_pdf_bytes, build_word_bytes
from .models import Certificate, PhotoReport
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django import forms

User = get_user_model()


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

  type_labels = dict(Certificate.CERTIFICATE_TYPE_CHOICES)
  cert_type_breakdown = []
  for row in (
    Certificate.objects.values('certificate_type')
    .annotate(count=Count('id'))
    .order_by('-count')
  ):
    key = row['certificate_type']
    cert_type_breakdown.append(
      {
        'label': type_labels.get(key, key),
        'count': row['count'],
      }
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
      'cert_type_breakdown': cert_type_breakdown,
    },
  )


@portal_staff_required
def certificate_list(request):
  q = (request.GET.get('q') or '').strip()
  license_type = (request.GET.get('license_type') or '').strip()
  certificate_type = (request.GET.get('certificate_type') or '').strip()

  qs = Certificate.objects.select_related('created_by')
  if q:
    qs = qs.filter(
      Q(control_number__icontains=q)
      | Q(applicant_name__icontains=q)
      | Q(business_name__icontains=q)
      | Q(inspector_name__icontains=q)
      | Q(created_by__username__icontains=q)
    )

  if license_type:
    qs = qs.filter(license_type=license_type)

  if certificate_type:
    qs = qs.filter(certificate_type=certificate_type)

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
      'certificate_type': certificate_type,
      'certificate_type_choices': Certificate.CERTIFICATE_TYPE_CHOICES,
    },
  )


@portal_staff_required
def certificate_detail(request, pk: int):
  cert = get_object_or_404(Certificate.objects.select_related('created_by'), pk=pk)
  return render(
    request,
    'portal/certificate_detail.html',
    {'cert': cert},
  )


@portal_staff_required
def certificate_export(request, pk: int, filetype: str):
  cert = get_object_or_404(Certificate.objects.select_related('created_by'), pk=pk)
  safe_cn = cert.control_number.replace('/', '-').replace('\\', '-')

  if filetype == 'pdf':
    data = build_pdf_bytes(cert)
    response = HttpResponse(data, content_type='application/pdf')
    response['Content-Disposition'] = f'attachment; filename="{safe_cn}.pdf"'
    return response

  if filetype == 'excel':
    data = build_excel_bytes(cert)
    response = HttpResponse(
      data,
      content_type=(
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
      ),
    )
    response['Content-Disposition'] = f'attachment; filename="{safe_cn}.xlsx"'
    return response

  if filetype == 'word':
    data = build_word_bytes(cert)
    response = HttpResponse(
      data,
      content_type='application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    )
    response['Content-Disposition'] = f'attachment; filename="{safe_cn}.docx"'
    return response

  return HttpResponse('Unsupported export type.', status=400)




























# ===============================
# 📋 LIST USERS
# ===============================
@portal_staff_required
def inspectors_list(request):
    q = (request.GET.get('q') or '').strip()

    qs = User.objects.all()

    if q:
        qs = qs.filter(
            Q(username__icontains=q) |
            Q(first_name__icontains=q) |
            Q(last_name__icontains=q) |
            Q(email__icontains=q)
        )

    qs = qs.annotate(
        cert_count=Count('certificates')
    ).order_by('-is_staff', '-cert_count', 'username')

    return render(request, 'portal/inspectors_list.html', {
        'inspectors': qs,
        'q': q,
        'user_creation_form': UserCreationForm(),
    })


# ===============================
# ➕ CREATE USER
# ===============================
@portal_staff_required
def user_create(request):
    if not request.user.is_superuser:
        messages.error(request, 'Only superusers can create users.')
        return redirect('portal_inspectors')

    if request.method == 'POST':
        form = UserCreationForm(request.POST)

        if form.is_valid():
            user = form.save(commit=False)

            # Default role
            user.is_staff = True

            # Optional extra fields
            user.email = request.POST.get('email')
            user.first_name = request.POST.get('first_name')
            user.last_name = request.POST.get('last_name')

            user.save()

            messages.success(request, f'User {user.username} created successfully.')
        else:
            messages.error(request, 'Error creating user.')

    # 🔥 ALWAYS redirect (no render here)
    return redirect('portal_inspectors')


# ===============================
# ✏️ UPDATE USER (FIXED)
# ===============================
@portal_staff_required
def user_update(request, pk):
    user = get_object_or_404(User, pk=pk)

    # 🔐 Permission check
    if not request.user.is_superuser and user.is_superuser:
        messages.error(request, 'Permission denied.')
        return redirect('portal_inspectors')

    if request.method == 'POST':
        # ✅ MANUAL FIELD UPDATE
        user.email = request.POST.get('email')
        user.first_name = request.POST.get('first_name')
        user.last_name = request.POST.get('last_name')

        user.is_staff = 'is_staff' in request.POST
        user.is_superuser = 'is_superuser' in request.POST

        # 🔐 PASSWORD UPDATE (OPTIONAL)
        password1 = request.POST.get('password1')
        password2 = request.POST.get('password2')

        if password1 or password2:
            if password1 == password2:
                user.set_password(password1)
            else:
                messages.error(request, "Passwords do not match.")
                return redirect('user_update', pk=pk)

        user.save()

        messages.success(request, f'User {user.username} updated successfully.')
        return redirect('portal_inspectors')

    return render(request, 'portal/user_update.html', {
        'user': user
    })


# ===============================
# 🗑️ DELETE USER
# ===============================
@portal_staff_required
def user_delete(request, pk):
    if not request.user.is_superuser:
        messages.error(request, 'Only superusers can delete users.')
        return redirect('portal_inspectors')

    user = get_object_or_404(User, pk=pk)

    if user == request.user:
        messages.error(request, 'Cannot delete yourself.')
        return redirect('portal_inspectors')

    if request.method == 'POST':
        username = user.username
        user.delete()
        messages.success(request, f'User {username} deleted successfully.')

    # 🔥 ALWAYS redirect (no render)
    return redirect('portal_inspectors')

























@portal_staff_required
def photo_reports_list(request):
  q = (request.GET.get('q') or '').strip()
  qs = PhotoReport.objects.select_related('created_by').all()
  if q:
    qs = qs.filter(
      Q(description__icontains=q)
      | Q(created_by__username__icontains=q)
      | Q(created_by__first_name__icontains=q)
      | Q(created_by__last_name__icontains=q)
    )
  qs = qs.order_by('-created_at')[:500]
  return render(
    request,
    'portal/photo_reports_list.html',
    {
      'reports': qs,
      'q': q,
    },
  )


@portal_staff_required
def reports(request):
  now = timezone.now()

  # Pie chart data: Certificates by type
  type_labels = dict(Certificate.CERTIFICATE_TYPE_CHOICES)
  cert_types_qs = (
    Certificate.objects
    .values('certificate_type')
    .annotate(count=Count('id'))
    .order_by('-count')[:10]  # top 10
  )
  pie_data = [
    {
      'label': type_labels.get(row['certificate_type'], row['certificate_type']),
      'value': row['count'],
    }
    for row in cert_types_qs
  ]

  # Bar chart: Monthly certificates last 12 months
  month_start = now.replace(day=1)
  year_months = []
  counts = []
  current = month_start
  for _ in range(12):
    next_current = current.replace(day=28) + timedelta(days=4)
    next_current = next_current.replace(day=1)
    c = Certificate.objects.filter(
      created_at__gte=current,
      created_at__lt=next_current
    ).count()
    year_months.append(current.strftime('%b %Y'))
    counts.append(c)
    current = next_current
  bar_data_monthly = {
    'labels': year_months[::-1],
    'data': counts[::-1]
  }

  # Doughnut: License types
  license_data = list(
    Certificate.objects
    .values('license_type')
    .annotate(count=Count('id'))
    .order_by('-count')[:10]
  )

  # Line chart: Daily trends last 30 days
  thirty_days_ago = now - timedelta(days=30)
  dates = []
  cert_daily = []
  photo_daily = []
  current_date = thirty_days_ago.date()
  while current_date <= now.date():
    next_date = current_date + timedelta(days=1)
    c = Certificate.objects.filter(created_at__date=current_date).count()
    p = PhotoReport.objects.filter(created_at__date=current_date).count()
    dates.append(current_date.strftime('%m-%d'))
    cert_daily.append(c)
    photo_daily.append(p)
    current_date = next_date
  line_data = {
    'labels': dates,
    'certs': cert_daily,
    'photos': photo_daily
  }

  return render(
    request,
    'portal/reports.html',
    {
      'pie_data': pie_data,
      'bar_data_monthly': bar_data_monthly,
      'license_data': license_data,
      'line_data': line_data,
    },
  )
