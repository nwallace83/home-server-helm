{{/*
Ensure a external database is configured
*/}}
{{- define "gitlab.checkConfig.postgresql" -}}
{{- with $.Values.global -}}
{{-   if not .psql.host }}
postgresql:
    You must configure an PostgreSQL connetion. Please set `global.psql.host`. Since chart v10.0.0,
    external PostgreSQL became required. If you were using the bundled PostgreSQL chart refer to
    https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/.
{{    end -}}
{{-   if not .psql.password.secret }}
postgresql:
    You must configure an PostgreSQL connetion. Please set `global.psql.password.secret`. Since chart v10.0.0,
    external PostgreSQL became required. If you were using the bundled PostgreSQL chart refer to
    https://docs.gitlab.com/charts/installation/migration/bundled_chart_migration/.
{{   end -}}
{{- end -}}
{{- end -}}

{{/*
Ensure that if `psql.password.useSecret` is set to false, a path to the password file is provided
*/}}
{{- define "gitlab.checkConfig.postgresql.noPasswordFile" -}}
{{- $errorMsg := list -}}
{{- $subcharts := pick .Values.gitlab "geo-logcursor" "gitlab-exporter" "migrations" "sidekiq" "toolbox" "webservice" -}}
{{- range $name, $sub := $subcharts -}}
{{-   $useSecret := include "gitlab.boolean.local" (dict "local" (pluck "useSecret" (index $sub "psql" "password") | first) "global" $.Values.global.psql.password.useSecret "default" true) -}}
{{-   if and (not $useSecret) (not (pluck "file" (index $sub "psql" "password") ($.Values.global.psql.password) | first)) -}}
{{-      $errorMsg = append $errorMsg (printf "%s: If `psql.password.useSecret` is set to false, you must specify a value for `psql.password.file`." $name) -}}
{{-   end -}}
{{- end -}}
{{- if not (empty $errorMsg) }}
postgresql:
{{- range $msg := $errorMsg }}
    {{ $msg }}
{{- end }}
    This configuration is not supported.
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.postgresql.noPasswordFile */}}

{{/*
Ensure that `global.psql.load_balancing` is properly configured
*/}}
{{- define "gitlab.checkConfig.database.externalLoadBalancing" -}}
{{- if hasKey .Values.global.psql "load_balancing" -}}
{{-   with .Values.global.psql.load_balancing -}}
{{-     if not (kindIs "map" .) }}
postgresql:
    It appears database load balancing is desired, but the current configuration is not supported.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
{{-     end -}}
{{-     if and (not (hasKey . "discover") ) (not (hasKey . "hosts") ) }}
postgresql:
    It appears database load balancing is desired, but the current configuration is not supported.
    You must specify `load_balancing.hosts` or `load_balancing.discover`.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
{{-     end -}}
{{-     if and (hasKey . "hosts") (not (kindIs "slice" .hosts) ) }}
postgresql:
    Database load balancing using `hosts` is configured, but does not appear to be a list.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
    Current format: {{ kindOf .hosts }}
{{-     end -}}
{{-     if and (hasKey . "discover") (not (kindIs "map" .discover)) }}
postgresql:
    Database load balancing using `discover` is configured, but does not appear to be a map.
    See https://docs.gitlab.com/charts/charts/globals#configure-postgresql-settings
    Current format: {{ kindOf .discover }}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{- end -}}
{{/* END gitlab.checkConfig.database.externalLoadBalancing */}}
