{{/*
Ensure that gitlab/toolbox is not configured with `replicas` > 1 if
persistence is enabled.
*/}}
{{- define "gitlab.toolbox.replicas" -}}
{{-   $replicas := index $.Values.gitlab "toolbox" "replicas" | int -}}
{{-   if and (gt $replicas 1) (index $.Values.gitlab "toolbox" "persistence" "enabled") -}}
toolbox: replicas is greater than 1, with persistence enabled.
    It appear that `gitlab/toolbox` has been configured with more than 1 replica, but also with a PersistentVolumeClaim. This is not supported. Please either reduce the replicas to 1, or disable persistence.
{{-   end -}}
{{- end -}}
{{/* END gitlab.toolbox.replicas */}}
