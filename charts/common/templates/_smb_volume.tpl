{{- define "common.smb-volume.tpl" }}
{{- $name := .name }}
{{- $server := .server }}
{{- $share := .share }}
{{- $policy := default "Retain" .policy }}
{{- $storage := default "1Gi" .storage }}
{{- $accessModes := default "ReadWriteOnce" .accessModes }}
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