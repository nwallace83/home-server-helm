{{/*
Renders all listeners to be bound by the Webservice HTTPRoute.
*/}}
{{- define "webservice.gatewayApi.gatewayRefs" }}
{{-   include "gitlab.gatewayApi.gatewayRef" . }}
{{-   if .Values.global.geo.gatewayApi.additionalHostname }}
{{     include "webservice.gatewayApi.gatewayRef.geo" . }}
{{    end }}
{{-   if .Values.global.appConfig.smartcard.enabled }}
{{     include "webservice.gatewayApi.gatewayRef.smartcard" . }}
{{    end }}
{{- end }}

{{/*
Renders optional Geo Gateway+Listener reference.
*/}}
{{- define "webservice.gatewayApi.gatewayRef.geo" }}
{{-   $ref := (include "gitlab.gatewayApi.gatewayRef" . ) | fromYamlArray }}
{{-   $_ := set ($ref | first) "sectionName" .Values.gatewayRoute.geoSectionName }}
{{-   slice $ref | toYaml }}
{{- end }}

{{/*
Renders optional Smartcard Gateway+Listener reference.
*/}}
{{- define "webservice.gatewayApi.gatewayRef.smartcard" }}
{{-   $ref := (include "gitlab.gatewayApi.gatewayRef" . ) | fromYamlArray }}
{{-   $_ := set ($ref | first) "sectionName" .Values.gatewayRoute.smartcardSectionName }}
{{-   slice $ref | toYaml }}
{{- end }}

{{/*
Returns "true" when the section-scoped ClientTrafficPolicy targeting the
gitlab-web listener should be rendered.

Conditions:
- Gateway API is enabled and Envoy Gateway is the implementation.
- HTTPS is enabled either globally (global.hosts.https) or for the gitlab
  service specifically (global.hosts.gitlab.https). In HTTP-only mode all
  listeners share port 80, so Envoy Gateway rejects section-scoped CTPs
  due to port overlap; the gateway-wide CTP
  (gatewayApiResources.envoy.clientTrafficPolicySpec) covers that case.
*/}}
{{- define "webservice.gatewayApi.sectionCtp.enabled" -}}
{{- $envoy := and .Values.global.gatewayApi.enabled .Values.global.gatewayApi.installEnvoy -}}
{{- $https := or .Values.global.hosts.https .Values.global.hosts.gitlab.https -}}
{{- if and $envoy $https -}}
true
{{- end -}}
{{- end -}}

{{/*
Renders all hostnames webservice accepts traffic for.
*/}}
{{- define "webservice.gatewayApi.hostnames" }}
- {{ include "gitlab.gitlab.hostname" . | quote }}
{{-   with .Values.global.geo.gatewayApi.additionalHostname }}
- {{ . | quote }}
{{-   end }}
{{-   if $.Values.global.appConfig.smartcard.enabled }}
- {{ include "gitlab.smartcard.hostname" . | quote }}
{{-   end }}
{{- end }}