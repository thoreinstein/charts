{{- define "common.config-volume.tpl" }}
{{- $name := .name }}
{{- $capacity := default "1Gi" .capacity }}
{{- $accessModes := default "ReadWriteOnce" .accessModes }}
{{- $server := .server }}
{{- $share := default "appdata" .share }}
---
{{- include "common.storage-volume.tpl" (dict
"name" .name
"capacity" .capacity
"accessModes" .accessModes
"server" .server
"share" (printf "%s/%s" .share .name)
"policy" .policy) }}
{{- end }}
