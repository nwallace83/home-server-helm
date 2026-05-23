{{/* vim: set filetype=mustache: */}}

{{/*
Return the URL desired by Mail_room

If global.redis.queues is present, use this. If not present, use global.redis
*/}}
{{- define "gitlab.mailroom.redis.url" -}}
{{- if $.Values.global.redis.queues -}}
{{- $_ := set $ "redisConfigName" "queues" }}
{{- end -}}
{{- include "gitlab.redis.url" $ -}}
{{- end -}}

{{- define "gitlab.mailroom.redis.sentinels" -}}
{{- if $.Values.global.redis.queues -}}
{{- $_ := set $ "redisConfigName" "queues" }}
{{- end -}}
{{- $sentinels := include "gitlab.redis.sentinels" . }}
{{- if $sentinels -}}
:{{- $sentinels | replace " port:" " :port:" | replace " host:" " :host:" | replace " ssl:" " :ssl:" | replace " ssl_params:" " :ssl_params:" -}}
{{- end -}}
{{- end -}}

{{/*
Return the mailroom Redis TLS configuration
*/}}
{{- define "gitlab.mailroom.redis.tls" -}}
{{- if $.Values.global.redis.queues -}}
{{-   $_ := set $ "redisConfigName" "queues" }}
{{- end -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- if eq (default "redis" .redisMergedConfig.scheme) "rediss" }}
{{-   $redisTLS := .redisMergedConfig.redisTLS | default (dict) -}}
{{-   if or $redisTLS.caFile $redisTLS.cert $redisTLS.key }}
:redis_ssl_params:
{{-     if $redisTLS.cert }}
  :cert: /etc/gitlab/redis/{{ $redisTLS.cert.key | default "cert" }}
{{-     end }}
{{-   if $redisTLS.key }}
  :key: /etc/gitlab/redis/{{ $redisTLS.key.key | default "key" }}
{{-     end }}
{{-     if $redisTLS.caFile }}
  :ca_file: /etc/gitlab/redis/{{ $redisTLS.caFile.key | default "ca.crt" }}
{{-     end }}
{{-   end }}
{{- end }}
{{- end -}}

{{/*
Return the mailroom Sentinel TLS configuration
*/}}
{{- define "gitlab.mailroom.sentinel.tls" -}}
{{- if $.Values.global.redis.queues -}}
{{-   $_ := set $ "redisConfigName" "queues" }}
{{- end -}}
{{- include "gitlab.redis.configMerge" . -}}
{{- $sentinelTLS := .redisMergedConfig.sentinelTLS | default (dict) -}}
{{- if and .redisMergedConfig.sentinels $sentinelTLS.enabled }}
:ssl_params:
{{-   if $sentinelTLS.cert }}
  :cert: /etc/gitlab/redis-sentinel/{{ $sentinelTLS.cert.key | default "cert" }}
{{-   end }}
{{-   if $sentinelTLS.key }}
  :key: /etc/gitlab/redis-sentinel/{{ $sentinelTLS.key.key | default "key" }}
{{-   end }}
{{-   if $sentinelTLS.caFile }}
  :ca_file: /etc/gitlab/redis-sentinel/{{ $sentinelTLS.caFile.key | default "ca.crt" }}
{{-   end }}
:ssl: true
{{- end }}
{{- end -}}
