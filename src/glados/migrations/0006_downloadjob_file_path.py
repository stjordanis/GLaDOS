# Generated by Django 2.2 on 2019-06-21 14:06

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('glados', '0005_auto_20190520_1108'),
    ]

    operations = [
        migrations.AddField(
            model_name='downloadjob',
            name='file_path',
            field=models.TextField(null=True),
        ),
    ]
