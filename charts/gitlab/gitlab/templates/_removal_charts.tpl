{{/*
Check if user explictly enabled bundled MinIO.
Can be removed in 19.3 when 19.2 upgrade stops ensures global.minio.enabled is not set anymore.
*/}}
{{- define "gitlab.removal.chart.minio" -}}
{{-   if ((.Values.global).minio).enabled }}
global.minio:
    The bundled MinIO chart has been removed, and thus `global.minio.enabled` does not have any effect.
    Please migrate to external object storage by following https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/,
    and remove `global.minio` from your values.
    See the deprecation announcement at https://docs.gitlab.com/update/deprecations/#support-for-bundled-postgresql-redis-and-minio-in-gitlab-helm-chart
    for details.
{{-   end -}}
{{- end -}}

{{/*
Check if user explictly enabled bundled PostgreSQL.
Can be removed in 19.3 when 19.2 upgrade stops ensures postgresql.install is not set anymore.
*/}}
{{- define "gitlab.removal.chart.postgresql" -}}
{{-   if (.Values.postgresql).install }}
postgresql:
    The bundled PostgreSQL chart has been removed, and thus `postgresql.install` does not have any effect.
    Please migrate to an external PostgreSQL by following https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/,
    and remove the `postgresql` configuration from your values.
    See the deprecation announcement at https://docs.gitlab.com/update/deprecations/#support-for-bundled-postgresql-redis-and-minio-in-gitlab-helm-chart
    for details.
{{-   end -}}
{{- end -}}

{{/*
Check if user explictly enabled bundled Redis.
Can be removed in 19.3 when 19.2 upgrade stops ensures redis.install is not set anymore.
*/}}
{{- define "gitlab.removal.chart.redis" -}}
{{-   if (.Values.redis).install }}
redis:
    The bundled Redis chart has been removed, and thus `redis.install` does not have any effect.
    Please migrate to an external Redis by following https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/,
    and remove the `redis` configuration from your values.
    See the deprecation announcement at https://docs.gitlab.com/update/deprecations/#support-for-bundled-postgresql-redis-and-minio-in-gitlab-helm-chart
    for details.
{{-   end -}}
{{- end -}}
