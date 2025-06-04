{{- define "common.storage-volume.tpl" }}
{{- $name := .name }}
{{- $storage := default "1Gi" .storage }}
{{- $accessModes := default "ReadWriteOnce" .accessModes }}
{{- $policy := default "Retain" .policy }}
{{- $protocol := default "nfs" .protocol }}

{{- if eq $protocol "smb" }}
{{- $server := .server }}
{{- $share := .share }}
{{- $secretName := .secretName }}
{{- $secretNamespace := default .namespace .secretNamespace }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $name }}-pv
spec:
  capacity:
    storage: {{ $storage }}
  accessModes: [{{ $accessModes }}]
  csi:
    driver: smb.csi.k8s.io
    readOnly: false
    volumeId: {{ $name }}-pv
    volumeAttributes:
      source: //{{ $server }}/{{ $share }}
    nodeStageSecretRef:
      name: {{ $secretName }}
      namespace: {{ $secretNamespace }}
  persistentVolumeReclaimPolicy: {{ $policy }}
{{- else }}
{{- /* Default to NFS */ -}}
{{- $server := .server }}
{{- $path := .path }}
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: {{ $name }}-pv
spec:
  capacity:
    storage: {{ $storage }}
  accessModes: [{{ $accessModes }}]
  nfs:
    server: {{ $server }}
    path: {{ $path }}
  persistentVolumeReclaimPolicy: {{ $policy }}
{{- end }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ $name }}-pvc
spec:
  accessModes: [{{ $accessModes }}]
  volumeName: {{ $name }}-pv
  storageClassName: ''
  resources:
    requests:
      storage: {{ $storage }}
{{- end }}