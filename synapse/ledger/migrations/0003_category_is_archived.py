from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('ledger', '0002_enable_rls_policies'),
    ]

    operations = [
        migrations.AddField(
            model_name='category',
            name='is_archived',
            field=models.BooleanField(default=False),
        ),
    ]
