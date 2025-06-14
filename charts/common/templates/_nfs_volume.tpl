{{- define "common.nfs-volume.tpl" }}
{{- $name := .name }}
{{- $server := .server }}
{{- $path := .path }}
{{- $policy := default "Retain" .policy }}
{{- $storage := default "1Gi" .storage }}
{{- $accessModes := default "ReadWriteOnce" .accessModes }}
{{- $storageClassName := default "" .storageClassName }}
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
  mountOptions:
    - hard
    - nfsvers=4.1
    - timeo=600
    - retrans=2
    - noatime
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
