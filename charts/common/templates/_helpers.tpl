{{- define "common.domain_name" -}}
{{- $domain_name := default "chart.local" .domain -}}
{{- $name := .name -}}
{{- $path := default false .path -}}
{{- $env := default "" .env -}}

{{- if $path -}}
  {{- if $env -}}
    {{ printf "%s/%s/%s" $domain_name $env $name }}
  {{- else -}}
    {{ printf "%s/%s" $domain_name $name }}
  {{- end -}}
{{- else -}}
  {{- if $env -}}
    {{ printf "%s.%s.%s" $name $env $domain_name }}
  {{- else -}}
    {{ printf "%s.%s" $name $domain_name }}
  {{- end -}}
{{- end -}}
{{- end }}
