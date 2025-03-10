{{- define "common.config-volume.tpl" }}
{{- $name := .name }}
{{- $server := .server }}
{{- $path := .path }}
{{- $policy := default "Retain" .policy }}
{{- $storage := default "1Gi" .storage }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $name }}-config-pv
spec:
  capacity:
    storage: {{ $storage }}
  accessModes: [ReadWriteMany]
  nfs:
    server: {{ $server }}
    path: {{ $path }}
  persistentVolumeReclaimPolicy: {{ $policy }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $name }}-config-pvc
spec:
  accessModes: [ReadWriteMany]
  volumeName: {{ $name }}-config-pv
  storageClassName: ''
  resources:
    requests:
      storage: {{ $storage }}
{{- end }}
