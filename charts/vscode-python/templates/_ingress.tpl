{{/* vim: set filetype=mustache: */}}

{{/*
Returns true if the ingressClassname field is supported
Usage:
{{ include "common.ingress.supportsIngressClassname" . }}
*/}}
{{- define "vscode-python.ingress.supportsIngressClassname" -}}
{{- if semverCompare "<1.18-0" (include "vscode-python.capabilities.kubeVersion" .) -}}
{{- print "false" -}}
{{- else -}}
{{- print "true" -}}
{{- end -}}
{{- end -}}

{{/* Ingress annotations */}}
{{- define "vscode-python.ingress.annotations" -}}
{{- with .Values.ingress.annotations }}
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- if .Values.security.allowlist.enabled }}
nginx.ingress.kubernetes.io/whitelist-source-range: {{ .Values.security.allowlist.ip }}
{{- end }}
{{- if .Values.ingress.useCertManager }}
cert-manager.io/cluster-issuer: {{ .Values.ingress.certManagerClusterIssuer }}
acme.cert-manager.io/http01-ingress-class: {{ .Values.ingress.ingressClassName }}
{{- end }}
{{- end }}

{{/* Ingress hostname */}}
{{- define "vscode-python.ingress.hostname" -}}
{{- if .Values.ingress.generate }}
{{- printf "%s" .Values.ingress.userHostname }}
{{- else }}
{{- printf "%s" .Values.ingress.hostname }}
{{- end }}
{{- end }}

{{/* Template to generate a standard Ingress */}}
{{- define "vscode-python.ingress" -}}
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.service.port -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}-ui
  labels:
    {{- include "vscode-python.labels" . | nindent 4 }}
  annotations:
    {{- include "vscode-python.ingress.annotations" . | nindent 4 }}
spec:
  {{- if and .Values.ingress.ingressClassName (eq "true" (include "vscode-python.ingress.supportsIngressClassname" .)) }}
  ingressClassName: {{ .Values.ingress.ingressClassName | quote }}
  {{- end }}
{{- if .Values.ingress.tls }}
  tls:
    - hosts:
        - {{ .Values.ingress.hostname | quote }}
        - {{ cat "3000-" .Values.ingress.hostname | quote }}
    {{- if .Values.ingress.useCertManager }}
      secretName: tls-cert-{{ include "library-chart.fullname" . }}
    {{- end }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.hostname | quote }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $fullName }}
                port: 
                  number: {{ $svcPort }}
    - host: {{ cat "3000-" .Values.ingress.hostname | quote }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: dagster-{{ $fullName }}
                port: 
                  number: 3000
{{- end }}
{{- end }}

{{/* Template to generate a custom Ingress */}}
{{- define "vscode-python.ingressUser" -}}
{{- if .Values.ingress.enabled -}}
{{- if .Values.networking.user.enabled }}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.user.port -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}-user
  labels:
    {{- include "vscode-python.labels" . | nindent 4 }}
  annotations:
    {{- include "vscode-python.ingress.annotations" . | nindent 4 }}
spec:
  {{- if and .Values.ingress.ingressClassName (eq "true" (include "vscode-python.ingress.supportsIngressClassname" .)) }}
  ingressClassName: {{ .Values.ingress.ingressClassName | quote }}
  {{- end }}
{{- if .Values.ingress.tls }}
  tls:
    - hosts:
        - {{ .Values.ingress.userHostname | quote }}
    {{- if .Values.ingress.useCertManager }}
      secretName: tls-cert-{{ include "library-chart.fullname" . }}
    {{- end }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.userHostname | quote }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $fullName }}
                port: 
                  number: {{ $svcPort }}
{{- end }}
{{- end }}
{{- end }}

{{/* Template to generate an Ingress for the Spark UI */}}
{{- define "vscode-python.ingressSpark" -}}
{{- if .Values.ingress.enabled -}}
{{- if .Values.spark.sparkui -}}
{{- $fullName := include "library-chart.fullname" . -}}
{{- $svcPort := .Values.networking.sparkui.port -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}-sparkui
  labels:
    {{- include "vscode-python.labels" . | nindent 4 }}
  annotations:
    {{- include "vscode-python.ingress.annotations" . | nindent 4 }}
spec:
  {{- if and .Values.ingress.ingressClassName (eq "true" (include "vscode-python.ingress.supportsIngressClassname" .)) }}
  ingressClassName: {{ .Values.ingress.ingressClassName | quote }}
  {{- end }}
{{- if .Values.ingress.tls }}
  tls:
    - hosts:
        - {{ .Values.ingress.sparkHostname | quote }}
    {{- if .Values.ingress.useCertManager }}
      secretName: tls-cert-{{ include "library-chart.fullname" . }}
    {{- end }}
  {{- end }}
  rules:
    - host: {{ .Values.ingress.sparkHostname | quote }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ $fullName }}
                port: 
                  number: {{ $svcPort }}
{{- end }}
{{- end }}
{{- end }}
