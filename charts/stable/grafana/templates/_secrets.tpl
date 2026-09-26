{{/* The admin credentials, so the password reaches the main container and the provisioning
     sidecars through a Secret instead of a plain env string on the Deployment. */}}
{{- define "grafana.secrets" -}}
enabled: true
data:
  user: {{ .Values.grafana.adminUser | quote }}
  password: {{ .Values.grafana.adminPassword | quote }}
{{- end -}}
