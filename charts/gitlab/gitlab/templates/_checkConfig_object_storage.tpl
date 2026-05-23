{{/*
Ensure Registry object store secret is configured.
*/}}
{{- define "gitlab.checkConfig.objectStorage.registry.configured" -}}
{{-   with $.Values.registry -}}
{{-     if and .enabled (not .storage.secret) }}
Registry Object Storage:
  The chart provides no longer bundled object storage solution. Please
  prepare an external object storage solution for the Registry by following 
  https://docs.gitlab.com/charts/advanced/external-object-storage/#registry-configuration
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Ensure Pages object store secret is configured.
*/}}
{{- define "gitlab.checkConfig.objectStorage.pages.configured" -}}
{{-   with $.Values.global.pages -}}
{{-     if and .enabled .objectStore.enabled (empty .objectStore.connection) }}
Pages Object Storage:
  The chart provides no longer bundled object storage solution. Please
  prepare an external object storage solution for Pages by following
  https://docs.gitlab.com/charts/advanced/external-object-storage/
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Ensure Backup/Restore object store secret is configured.

Skipped when backend is GKE workload identity is configured which needs
no backup object store secret.
*/}}
{{- define "gitlab.checkConfig.objectStorage.backup.configured" -}}
{{-   with $.Values.gitlab.toolbox -}}
{{-     $gcsWorkloadIdentity := and (eq .backups.objectStorage.backend "gcs") (empty .backups.objectStorage.config) -}}
{{-     if and .enabled (not .backups.objectStorage.config.secret) (not $gcsWorkloadIdentity) }}
Backup Object Storage:
  The chart provides no longer bundled object storage solution. Please
  prepare an external object storage solution for backup and restore by following
  https://docs.gitlab.com/charts/advanced/external-object-storage/#backups
{{-     end -}}
{{-   end -}}
{{- end -}}

{{/*
Ensure consolidate and type-specific object store configuration are not mixed.
*/}}
{{- define "gitlab.checkConfig.objectStorage.consolidatedConfig" -}}
{{-   if $.Values.global.appConfig.object_store.enabled -}}
{{-     $problematicTypes := list -}}
{{-     range $objectTypes := list "artifacts" "lfs" "uploads" "packages" "externalDiffs" "terraformState" "dependencyProxy" -}}
{{-       if hasKey $.Values.global.appConfig . -}}
{{-         $objectProps := index $.Values.global.appConfig . -}}
{{-         if (and (index $objectProps "enabled") (or (not (empty (index $objectProps "connection"))) (empty (index $objectProps "bucket")))) -}}
{{-           $problematicTypes = append $problematicTypes . -}}
{{-         end -}}
{{-       end -}}
{{-     end -}}
{{-     if not (empty $problematicTypes) }}
Object Storage:
  When consolidated object storage is enabled, for each item `bucket` must be specified and the `connection` must be empty. Check the following object storage configuration(s): {{ join "," $problematicTypes }}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.objectStorage.consolidatedConfig */}}

{{- define "gitlab.checkConfig.objectStorage.typeSpecificConfig" -}}
{{-   if not $.Values.global.appConfig.object_store.enabled -}}
{{-     $problematicTypes := list -}}
{{-     range $objectTypes := list "artifacts" "lfs" "uploads" "packages" "externalDiffs" "terraformState" "dependencyProxy" "ciSecureFiles" -}}
{{-       if hasKey $.Values.global.appConfig . -}}
{{-         $objectProps := index $.Values.global.appConfig . -}}
{{-         if and (index $objectProps "enabled") (empty (index $objectProps "connection")) -}}
{{-           $problematicTypes = append $problematicTypes . -}}
{{-         end -}}
{{-       end -}}
{{-     end -}}
{{-     if not (empty $problematicTypes) }}
Object Storage:
  When type-specific object storage is enabled the `connection` property can not be empty. Check the following object storage configuration(s): {{ join "," $problematicTypes }}
{{-     end -}}
{{-   end -}}
{{- end -}}
{{/* END gitlab.checkConfig.objectStorage.typeSpecificConfig */}}
