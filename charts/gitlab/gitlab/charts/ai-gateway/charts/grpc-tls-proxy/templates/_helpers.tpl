{{- define "grpc-tls-proxy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "grpc-tls-proxy.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "grpc-tls-proxy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "grpc-tls-proxy.labels" -}}
helm.sh/chart: {{ include "grpc-tls-proxy.chart" . }}
{{ include "grpc-tls-proxy.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "grpc-tls-proxy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grpc-tls-proxy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
