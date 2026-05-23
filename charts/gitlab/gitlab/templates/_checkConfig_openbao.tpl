{{/*
Ensure a database is configured when OpenBao is installed.

The database must be configured explicitly via global.openbao.psql or
openbao.config.storage.postgresql.connection with host, database, username, and password.
Password is required and is not inherited from the main DB.

NOTE: We intentionally check global.openbao.psql and openbao.config.storage.postgresql.connection
directly rather than the merged openbao.postgresql.configuration template. The merged template
falls back to global.psql (the main Rails DB), which would cause this check to silently pass
even when no dedicated OpenBao database is configured.
*/}}
{{- define "gitlab.checkConfig.openbao.database" -}}
{{- if .Values.openbao.install -}}
{{-   $openbaoConfig := coalesce ((.Values.openbao).config) .Values.config | default dict -}}
{{-   $conn := ((($openbaoConfig.storage).postgresql).connection | default dict) -}}
{{-   $globalObaPsql := ((.Values.global).openbao).psql | default dict -}}
{{-   $host := coalesce $conn.host $globalObaPsql.host "" -}}
{{-   if not $host }}
openbao: no database configured
    It appears OpenBao is enabled but no database was configured. Configure `global.openbao.psql` with host, database, username, and password. See https://docs.gitlab.com/charts/charts/openbao/#database-configuration
{{-   end }}
{{-   $password := coalesce $conn.password $globalObaPsql.password (dict) -}}
{{-   if not (hasKey $password "secret") }}
openbao: no database password configured
    OpenBao requires an explicit database password. Configure `global.openbao.psql.password` with secret/key. Password is not inherited from the main DB. See https://docs.gitlab.com/charts/charts/openbao/#database-configuration
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.openbao.database */}}
