{{- define "common.host-volume.tpl" }}
{{- $name := .name }}
{{- $accessModes := default "ReadWriteOnce" .accessModes }}
{{- $storage := default "1Gi" .storage }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $name }}-pvc
spec:
  storageClassName: ''
  accessModes: [{{ $accessModes }}]
  resources:
    requests:
      storage: {{ $storage }}
{{- end }}
