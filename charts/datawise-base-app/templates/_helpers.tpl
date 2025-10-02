{{/*
Expand the name of the chart.
*/}}
{{- define "datawise-base-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "datawise-base-app.validations" -}}
{{ required "project required!" .Values.deploy.project }}-{{ required "app required!" .Values.deploy.app }}-{{ required "service required!" .Values.deploy.service }}-{{ required "instance required!" .Values.deploy.instance }}-{{ required "version required!" .Values.deploy.version }}
{{- end }}


{{- define "datawise-base-app.appId" -}}
{{ required "project required!" .Values.deploy.project }}-{{ required "app required!" .Values.deploy.app }}-{{ required "service required!" .Values.deploy.service }}-{{ required "instance required!" .Values.deploy.instance }}
{{- end }}

{{- define "datawise-base-app.appId_underscore" -}}
{{ required "project required!" .Values.deploy.project }}_{{ required "app required!" .Values.deploy.app }}_{{ required "service required!" .Values.deploy.service }}_{{ required "instance required!" .Values.deploy.instance }}
{{- end }}

{{- define "datawise-base-app.namespace" -}}
{{- default .Values.deploy.project .Values.deploy.namespace }}
{{- end }}

{{- define "datawise-base-app.hostname" -}}
{{- if .Values.deploy.url }}
{{- .Values.deploy.url }}
{{- else }}
{{- if eq .Values.deploy.service "app" }}
{{- .Values.deploy.project }}-{{ .Values.deploy.app }}-{{ .Values.deploy.instance }}.{{ .Values.deploy.baseUrl }}
{{- else }}
{{- .Values.deploy.project }}-{{ .Values.deploy.app }}-{{ .Values.deploy.service }}-{{ .Values.deploy.instance }}.{{ .Values.deploy.baseUrl }}
{{- end }}
{{- end }}
{{- end }}

{{- define "datawise-base-app.image_registry" -}}
{{- if .Values.image.registry }}
{{- .Values.image.registry }}
{{- else }}
{{- .Values.deploy.project }}-pull.{{ .Values.image.registry_base }}
{{- end }}
{{- end }}

{{- define "datawise-base-app.image_repository" -}}
{{- if .Values.image.repository }}
{{- .Values.image.repository }}
{{- else }}
{{- .Values.deploy.app }}-{{ .Values.deploy.service }}-{{ .Values.deploy.instance }}
{{- end }}
{{- end }}


{{- define "datawise-base-app.db_connection.user" -}}
{{- default (include "datawise-base-app.appId_underscore" .) .Values.db.connection.user }}
{{- end }}

{{- define "datawise-base-app.db_connection.catalog" -}}
{{- default (include "datawise-base-app.appId_underscore" .) .Values.db.connection.catalog }}
{{- end }}

{{- define "datawise-base-app.db_connection.name" -}}
{{- default (include "datawise-base-app.appId_underscore" .) .Values.db.connection.catalog }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datawise-base-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- (include "datawise-base-app.appId" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "datawise-base-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "datawise-base-app.labels" -}}
helm.sh/chart: {{ include "datawise-base-app.chart" . }}
{{ include "datawise-base-app.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/app-project: {{ .Values.deploy.project  }}
app.kubernetes.io/app-name: {{ .Values.deploy.app  }}
app.kubernetes.io/app-instance: {{ .Values.deploy.instance  }}
app.kubernetes.io/app-version: {{ .Values.deploy.version | quote }}
app.kubernetes.io/app-service: {{ .Values.deploy.service | quote }}
app.kubernetes.io/app-infra: {{ .Values.infraName | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "datawise-base-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "datawise-base-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "datawise-base-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "datawise-base-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* toggle: otel injection enabled? */}}
{{- define "datawise-base-app.injectOtel" -}}
{{- if or .Values.otel.inject (index .Values "inject-otel") -}}true{{- end -}}
{{- end -}}

{{/* OTEL service name */}}
{{- define "datawise-base-app.otelServiceName" -}}
{{- if .Values.otel.serviceName -}}
{{ .Values.otel.serviceName }}
{{- else -}}
{{- printf "%s-%s" .Values.deploy.app .Values.deploy.service -}}
{{- end -}}
{{- end -}}

{{/* OTEL resource attributes */}}
{{- define "datawise-base-app.otelResourceAttributes" -}}
  {{- $ns := .Values.deploy.project -}}
  {{- $ver := (default .Values.deploy.version .Values.image.tag) -}}
  {{- $inf := .Values.infraName -}}

  {{/* Build env = project-app-service-instance (lowercased, no leading/trailing or duplicate dashes) */}}
  {{- $p := default "" .Values.deploy.project -}}
  {{- $a := default "" .Values.deploy.app -}}
  {{- $s := default "" .Values.deploy.service -}}
  {{- $i := default "" .Values.deploy.instance -}}
  {{- $env := printf "%s-%s-%s-%s" $p $a $s $i | regexReplaceAll "-+" "-" | trimAll "-" | lower -}}

  {{- if .Values.otel.resourceAttributes -}}
    {{ .Values.otel.resourceAttributes }}
  {{- else -}}
    {{- printf "service.namespace=%s,service.version=%s,deployment.environment.name=%s,service.name=%s" $ns $ver $inf $env -}}
  {{- end -}}
{{- end -}}