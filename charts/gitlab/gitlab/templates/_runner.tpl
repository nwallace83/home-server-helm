{{/*
Return the gitlab-runner registration token secret name
*/}}
{{- define "gitlab.gitlab-runner.registrationToken.secret" -}}
{{- default (printf "%s-gitlab-runner-secret" .Release.Name) .Values.global.runner.registrationToken.secret | quote -}}
{{- end -}}

{{/*
Override the runner charts secret name containing the tokens so everything matches
*/}}
{{- define "gitlab-runner.secret" -}}
{{ include "gitlab.gitlab-runner.registrationToken.secret" . }}
{{- end -}}

{{/*
Override gitlab external URL
*/}}
{{- define "gitlab-runner.gitlabUrl" -}}
{{- if .Values.gitlabUrl -}}
{{-   .Values.gitlabUrl -}}
{{- else -}}
{{-   template "gitlab.gitlab.url" . -}}
{{- end -}}
{{- end -}}
