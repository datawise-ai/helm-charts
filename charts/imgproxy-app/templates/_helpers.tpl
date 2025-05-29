{{/*
Expand the name of the chart.
*/}}
{{- define "imgproxy-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "imgproxy-app.validations" -}}
{{ required "project required!" .Values.deploy.project }}-{{ required "app required!" .Values.deploy.app }}-{{ required "service required!" .Values.deploy.service }}-{{ required "instance required!" .Values.deploy.instance }}-{{ required "version required!" .Values.deploy.version }}
{{- end }}


{{- define "imgproxy-app.appId" -}}
{{ required "project required!" .Values.deploy.project }}-{{ required "app required!" .Values.deploy.app }}-{{ required "service required!" .Values.deploy.service }}-{{ required "instance required!" .Values.deploy.instance }}
{{- end }}

{{- define "imgproxy-app.appId_underscore" -}}
{{ required "project required!" .Values.deploy.project }}_{{ required "app required!" .Values.deploy.app }}_{{ required "service required!" .Values.deploy.service }}_{{ required "instance required!" .Values.deploy.instance }}
{{- end }}

{{- define "imgproxy-app.namespace" -}}
{{- default .Values.deploy.project .Values.deploy.namespace }}
{{- end }}

{{- define "imgproxy-app.hostname" -}}
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

{{- define "imgproxy-app.image_registry" -}}
{{- if .Values.image.registry }}
{{- .Values.image.registry }}
{{- else }}
{{- .Values.deploy.project }}-pull.{{ .Values.image.registry_base }}
{{- end }}
{{- end }}

{{- define "imgproxy-app.image_repository" -}}
{{- if .Values.image.repository }}
{{- .Values.image.repository }}
{{- else }}
{{- .Values.deploy.app }}-{{ .Values.deploy.service }}-{{ .Values.deploy.instance }}
{{- end }}
{{- end }}


{{- define "imgproxy-app.db_connection.user" -}}
{{- default (include "imgproxy-app.appId_underscore" .) .Values.db.connection.user }}
{{- end }}

{{- define "imgproxy-app.db_connection.catalog" -}}
{{- default (include "imgproxy-app.appId_underscore" .) .Values.db.connection.catalog }}
{{- end }}

{{- define "imgproxy-app.db_connection.name" -}}
{{- default (include "imgproxy-app.appId_underscore" .) .Values.db.connection.catalog }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "imgproxy-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- (include "imgproxy-app.appId" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "imgproxy-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "imgproxy-app.labels" -}}
helm.sh/chart: {{ include "imgproxy-app.chart" . }}
{{ include "imgproxy-app.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/app-project: {{ .Values.deploy.project  }}
app.kubernetes.io/app-name: {{ .Values.deploy.app  }}
app.kubernetes.io/app-instance: {{ .Values.deploy.instance  }}
app.kubernetes.io/app-version: {{ .Values.deploy.version | quote }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "imgproxy-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "imgproxy-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "imgproxy-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "imgproxy-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
