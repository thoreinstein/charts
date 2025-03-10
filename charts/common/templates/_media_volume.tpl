{{- define "common.media-volume.tpl" }}
{{- $name := .name }}
{{- $server := .server }}
{{- $path := .path }}
{{- $policy := default "Retain" .policy }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $name }}-media-pv
spec:
  capacity:
    storage: 50Gi
  accessModes: [ReadWriteMany]
  nfs:
    server: {{ $server }}
    path: {{ $path }}
  persistentVolumeReclaimPolicy: {{ $policy }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $name }}-media-pvc
spec:
  accessModes: [ReadWriteMany]
  volumeName: {{ $name }}-media-pv
  storageClassName: ''
  resources:
    requests:
      storage: 50Gi
{{- end }}
