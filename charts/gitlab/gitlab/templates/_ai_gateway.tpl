{{/*
Override ai-gateway.gitlab.url helper
In production mode the AIGW requires the gitlab url to be https for the key exachange to work
Other it will fail for security reason
*/}}
{{- define "ai-gateway.gitlab.url" -}}
{{- include "gitlab.gitlab.url" . }}
{{- end -}}
{{/*
Override ai-gateway.gitlab.apiUrl helper
*/}}
{{- define "ai-gateway.gitlab.apiUrl" -}}
{{- include "ai-gateway.gitlab.url" . -}}/api/v4
{{- end -}}

{{/*
Override Duo Workflow key secret helpers
*/}}
{{- define "ai-gateway.duoWorkflowSigningKey.secret" -}}
{{- default (printf "%s-ai-gateway-duo-workflow-signing-secret" .Release.Name) -}}
{{- end -}}

{{- define "ai-gateway.duoWorkflowSigningKey.key" -}}
duoWorkflowSigningKey
{{- end -}}

{{- define "ai-gateway.duoWorkflowValidationKey.secret" -}}
{{- default (printf "%s-ai-gateway-duo-workflow-validation-secret" .Release.Name) -}}
{{- end -}}

{{- define "ai-gateway.duoWorkflowValidationKey.key" -}}
duoWorkflowValidationKey
{{- end -}}

{{/*
Override AI Gateway key secret helpers
*/}}
{{- define "ai-gateway.aigwSigningKey.secret" -}}
{{- default (printf "%s-ai-gateway-aigw-signing-secret" .Release.Name) -}}
{{- end -}}

{{- define "ai-gateway.aigwSigningKey.key" -}}
aigwSigningKey
{{- end -}}

{{- define "ai-gateway.aigwValidationKey.secret" -}}
{{- default (printf "%s-ai-gateway-aigw-validation-secret" .Release.Name) -}}
{{- end -}}

{{- define "ai-gateway.aigwValidationKey.key" -}}
aigwValidationKey
{{- end -}}
