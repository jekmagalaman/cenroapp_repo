from django.contrib.admin.views.decorators import staff_member_required
from django.shortcuts import render
from django.utils import timezone

from .models import Certificate


@staff_member_required
def admin_dashboard(request):
    now = timezone.now()
    today_start = now.replace(hour=0, minute=0, second=0, microsecond=0)
    month_start = today_start.replace(day=1)

    total_certificates = Certificate.objects.count()
    this_month_count = Certificate.objects.filter(created_at__gte=month_start).count()
    today_count = Certificate.objects.filter(created_at__gte=today_start).count()
    recent_certificates = Certificate.objects.all()[:15]

    return render(
        request,
        'admin/dashboard.html',
        {
            'total_certificates': total_certificates,
            'this_month_count': this_month_count,
            'today_count': today_count,
            'recent_certificates': recent_certificates,
        },
    )
