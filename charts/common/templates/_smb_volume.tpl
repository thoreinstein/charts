{{- define "common.smb-volume.tpl" }}
{{- $name := .name }}
{{- $server := .server }}
{{- $share := .share }}
{{- $policy := default "Retain" .policy }}
{{- $storage := default "1Gi" .storage }}
{{- $accessModes := default "ReadWriteOnce" .accessModes }}
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
    volumeHandle: {{ printf "%s-%s" (include "karakeep.fullname" .) (sha1sum .Release.Name | trunc 8) }}
    volumeId: {{ $name }}-pv
    volumeAttributes:
      source: //{{ $server }}/{{ $share }}
      options: "dir_mode=0777,file_mode=0777,vers=3.0"
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
