-- Create a non-superuser role for the application.
-- Superusers bypass RLS entirely, so the app must connect
-- with a regular role for row-level security to work.
--
-- The 'synapse' superuser role (created by POSTGRES_USER) is
-- used for migrations only.

CREATE ROLE synapse_app WITH LOGIN PASSWORD 'synapse';
GRANT CONNECT ON DATABASE synapse TO synapse_app;
GRANT USAGE ON SCHEMA public TO synapse_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO synapse_app;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO synapse_app;

-- Grant on any tables that already exist
GRANT ALL ON ALL TABLES IN SCHEMA public TO synapse_app;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO synapse_app;
