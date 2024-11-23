{{- define "commonLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ regexReplaceAll "[+].*$" .Chart.Version "" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Values.global.additionalLabels }}
{{ toYaml .Values.global.additionalLabels }}
{{- end }}
{{- end -}}