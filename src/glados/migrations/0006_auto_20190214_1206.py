# -*- coding: utf-8 -*-
# Generated by Django 1.9.13 on 2019-02-14 12:06
from __future__ import unicode_literals

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('glados', '0005_auto_20190213_1629'),
    ]

    operations = [
        migrations.AddField(
            model_name='sssearchjob',
            name='raw_search_params',
            field=models.TextField(null=True),
        ),
        migrations.AlterField(
            model_name='sssearchjob',
            name='status',
            field=models.CharField(choices=[('SEARCH_QUEUED', 'SEARCH_QUEUED'), ('SEARCHING', 'SEARCHING'), ('FINISHED', 'FINISHED'), ('ERROR', 'ERROR')], default='SEARCH_QUEUED', max_length=20),
        ),
    ]
