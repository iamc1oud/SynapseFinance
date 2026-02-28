from django.db import connection, migrations

RLS_TABLES = [
    'financial_accounts',
    'categories',
    'tags',
    'transactions',
]


def enable_rls(apps, schema_editor):
    if connection.vendor != 'postgresql':
        return

    for table in RLS_TABLES:
        schema_editor.execute(f"ALTER TABLE {table} ENABLE ROW LEVEL SECURITY")
        schema_editor.execute(f"ALTER TABLE {table} FORCE ROW LEVEL SECURITY")
        schema_editor.execute(f"""
            CREATE POLICY user_isolation_policy ON {table}
                USING (user_id = current_setting('app.current_user_id', true)::int);
        """)


def disable_rls(apps, schema_editor):
    if connection.vendor != 'postgresql':
        return

    for table in RLS_TABLES:
        schema_editor.execute(f"DROP POLICY IF EXISTS user_isolation_policy ON {table}")
        schema_editor.execute(f"ALTER TABLE {table} DISABLE ROW LEVEL SECURITY")


class Migration(migrations.Migration):

    dependencies = [
        ('ledger', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(enable_rls, reverse_code=disable_rls),
    ]
