
{{/*
Ensure that `global.redis.host` is present when not using redis.yml override
*/}}
{{- define "gitlab.checkConfig.redis" -}}
{{-   if and (empty .Values.global.redis.host) (empty .Values.global.redis.redisYmlOverride) }}
redis:
  You must configure an Redis connetion. Please set `global.redis.host`. Since chart v10.0.0,
  external Redis became required. If you were using the bundled Redis chart refer to
  https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/.
{{-   end -}}
{{- end -}}
