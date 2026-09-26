{{/* Everything secret that used to live in ConfigMaps: the env keys reach the container
     through envFrom exactly as before and the PHP session config as a file, but from Secrets, so
     they are no longer readable by anyone with ConfigMap read in the namespace. */}}
{{- define "nextcloud.secrets" -}}
{{- $redisHost := .Values.redis.creds.plainhost | trimAll "\"" -}}
{{- $redisPass := .Values.redis.password | trimAll "\"" -}}
nextcloud-secrets:
  enabled: true
  data:
    {{/* Database */}}
    POSTGRES_PASSWORD: {{ .Values.cnpg.main.password | trimAll "\"" }}
    NX_POSTGRES_PASSWORD: {{ .Values.cnpg.main.password | trimAll "\"" }}

    {{/* Redis */}}
    NX_REDIS_PASS: {{ $redisPass }}

    {{/* Nextcloud INITIAL credentials. Emitted only when set, so a user who leaves the value
         empty can supply NEXTCLOUD_ADMIN_PASSWORD as an env secretKeyRef instead. */}}
    {{- if .Values.nextcloud.credentials.initialAdminPassword }}
    NEXTCLOUD_ADMIN_PASSWORD: {{ .Values.nextcloud.credentials.initialAdminPassword | quote }}
    {{- end }}

    {{/* Only Office. Same rule: an empty jwt leaves the key to an env secretKeyRef. */}}
    {{- if and .Values.nextcloud.onlyoffice.enabled .Values.nextcloud.onlyoffice.jwt }}
    NX_ONLYOFFICE_JWT: {{ .Values.nextcloud.onlyoffice.jwt | quote }}
    {{- end }}

{{/* The PHP session handler config embeds the Redis password, so it is a Secret too */}}
redis-session:
  enabled: true
  data:
    redis-session.ini: |
      session.save_handler = redis
      session.save_path = {{ printf "tcp://%v:6379?auth=%v" $redisHost $redisPass | quote }}
      redis.session.locking_enabled = 1
      redis.session.lock_retries = -1
      redis.session.lock_wait_time = 10000
{{ end -}}
