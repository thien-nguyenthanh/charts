{{/*
Expand the name of the chart.
*/}}
{{- define "actableai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "actableai.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "actableai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "actableai.labels" -}}
helm.sh/chart: {{ include "actableai.chart" . }}
{{ include "actableai.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "actableai.selectorLabels" -}}
app.kubernetes.io/name: {{ include "actableai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/*
Worker common labels
*/}}
{{- define "actableai-worker.labels" -}}
helm.sh/chart: {{ include "actableai.chart" . }}
{{ include "actableai-worker.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Worker selector labels
*/}}
{{- define "actableai-worker.selectorLabels" -}}
app.kubernetes.io/name: {{ include "actableai.name" . }}-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "actableai.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "actableai.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- define "actableai-config" }}
import os
from cachelib.redis import RedisCache
from kombu.serialization import register
from superset.security.manager import OverfitSecurityManager
from superset.utils import CustomJSONEncoder, aai_dumps, aai_loads
from typing import Any, Callable, Dict, List, Optional, TYPE_CHECKING



def env(key, default=None):
    return os.getenv(key, default)


IP_WISHLIST = env("IP_WISHLIST", "")
ROW_LIMIT = 5000

SUPERSET_WEBSERVER_PORT = 8088

SECRET_KEY = env('SECRET_KEY')
APP_NAME = env('APP_NAME')

SQLALCHEMY_DATABASE_URI = f"postgresql://{env('SYSTEM_DB_USER')}:{env('SYSTEM_DB_PASS')}@{env('SYSTEM_DB_HOST')}:{env('SYSTEM_DB_PORT')}/{env('SYSTEM_DB_NAME')}"

SQLALCHEMY_EXAMPLES_URI = f"postgresql://{env('EXAMPLE_DB_USER')}:{env('EXAMPLE_DB_PASS')}@{env('EXAMPLE_DB_HOST')}:{env('EXAMPLE_DB_PORT')}/{env('EXAMPLE_DB_NAME')}"

SQLALCHEMY_TRACK_MODIFICATIONS = True

CACHE_CONFIG = {
      'CACHE_TYPE': 'redis',
      'CACHE_DEFAULT_TIMEOUT': 300,
      'CACHE_KEY_PREFIX': 'actable_',
      'CACHE_REDIS_HOST': env('REDIS_HOST'),
      'CACHE_REDIS_PORT': env('REDIS_PORT'),
      'CACHE_REDIS_PASSWORD': env('REDIS_PASSWORD'),
      'CACHE_REDIS_DB': env('REDIS_DB', 1),
}
DATA_CACHE_CONFIG = CACHE_CONFIG

SESSION_COOKIE_SAMESITE = None

ENABLE_CORS = True
CORS_OPTIONS: Dict[Any, Any] = {
    'supports_credentials': True,
    'headers': '*',
    'origins': '*',
}

WTF_CSRF_ENABLED = True
WTF_CSRF_EXEMPT_LIST = [
    'superset.views.nifi_proxy.proxy',
    'superset.views.nlu_proxy.proxy',
    'superset.views.core.sql_json',
    'superset.views.core.explore_json',
    'superset.datasets.api.post',
    'superset.datasets.api.delete',
    'superset.datasets.api.bulk_delete',
    'superset.datasets.api.upload_csv',
    'superset.billing.views.webhook_received',
    'superset.datasets.api.clone',
    'superset.datasets.api.download',
    'superset.charts.api.clone_chart',
    'superset.charts.api.download',
    'superset.charts.api.check_result',
    'superset.charts.api.list_datasource',
    'superset.dashboards.api.clone',
    'superset.connectors.sqla.views.edit',
    'flask_monitoringdashboard.views.auth.login',
    'flask_monitoringdashboard.views.version.multi_version',
    'flask_monitoringdashboard.views.endpoint.api_performance',
    'flask_monitoringdashboard.views.auth.user_create',
    'flask_monitoringdashboard.views.auth.user_edit',
    'flask_monitoringdashboard.views.endpoint.set_rule',
    'flask_monitoringdashboard.views.endpoint.endpoint_users',
    'flask_monitoringdashboard.views.version.version_user',
    'flask_monitoringdashboard.views.version.version_ip',
    'flask_monitoringdashboard.views.endpoint.endpoint_versions',
    'superset.dashboards.api.bulk_delete',
    'superset.views.core.log',
    'superset.charts.api.bulk_delete',
    'superset.views.custom.infer_model'
]

AVAILABLE_ANALYTICS = [
    'clean_data',
    'causal_inference',
    'intervention',
    'plotly_tsne',
    'classification_prediction',
    'regression_prediction',
    'plotly_prediction',
    'sentiment_analysis',
    'association_rules',
#    'multi_armed_bandit',
    'plotly_correlation',
    'bayesian_regression',
    'ttest_custom',
    'chi_square',
    'anova',
    'mann_whitney_wilcoxon',
    'plotly_bubble',
    'pie',
    'plotly_bar',
    'line',
    'filter_box',
    'histogram',
    'table',
    'table_one',
    'box_plot',
    'pivot_table',
    'dual_line',
    'sunburst',
    'word_cloud',
    'partition',
    'directed_force',
    'chord',
    'heatmap',
]

WIP_ANALYTICS = [
  'multi_armed_bandit',
]

# List analytics will check payment
BILLING_ANALYTICS_CHECK_PAYMENT = [
    "clean_data", "plotly_tsne", "classification_prediction",
    "regression_prediction", "plotly_prediction", "sentiment_analysis",
    "causal_inference", "bayesian_regression", "intervention"]


WTF_CSRF_TIME_LIMIT = 60 * 60 * 24 * 365

register("aai_json", aai_dumps, aai_loads,
    content_type='application/json',
    content_encoding='utf-8')

class CeleryConfig(object):
    broker_url = f"redis://{env('REDIS_HOST')}:{env('REDIS_PORT')}/0"
    imports = ("superset.sql_lab", "superset")
    result_backend = f"db+postgresql://{env('CELERY_DB_USER')}:{env('CELERY_DB_PASS')}@{env('CELERY_DB_HOST')}:{env('CELERY_DB_PORT')}/{env('CELERY_DB_NAME')}"
    task_annotations = {'tasks.add': {'rate_limit': '10/s'}}
    accept_content = ["aai_json"]
    task_serializer = "aai_json"
    result_serializer = "aai_json"

CELERY_CONFIG = CeleryConfig

SUPERSET_DOMAIN = env('SUPERSET_DOMAIN')

GOOGLE_ID = env('GOOGLE_ID')
GOOGLE_SECRET = env('GOOGLE_SECRET')

MAILGUN_ACCOUNT = env('MAILGUN_ACCOUNT')
MAILGUN_PASSWORD = env('MAILGUN_PASSWORD')
MAILGUN_FROM = env('MAILGUN_FROM')
MAILGUN_SERVER_NAME = env('MAILGUN_SERVER_NAME')
MAILGUN_PORT = env('MAILGUN_PORT')

RECAPTCHA_PUBLIC_KEY = env('RECAPTCHA_PUBLIC_KEY')
RECAPTCHA_PRIVATE_KEY = env('RECAPTCHA_PRIVATE_KEY')

CUSTOM_SECURITY_MANAGER = OverfitSecurityManager

SAP_FEATURE = env('SAP_FEATURE_ENABLED')
LINKEDIN_FEATURE = env('LINKEDIN_FEATURE_ENABLED')
USECASES_FEATURE = env('USECASES_FEATURE_ENABLED')
BILLING_FEATURE = env('BILLING_FEATURE_ENABLED')
BILLING_TRIAL= env('BILLING_TRIAL_ENABLED')
DASHBOARD_FEATURE = env('DASHBOARD_FEATURE_ENABLED')
DATACLEAN_ANALYTICS_FEATURE = env('DATACLEAN_ANALYTICS_FEATURE_ENABLED')
SENTIMENT_ANALYSIS_FEATURE = env('SENTIMENT_ANALYSIS_FEATURE')
CHAT_BOX_ENABLE = env('CHAT_BOX_ENABLED')
FULFILLMENT_ENABLE = env('FULFILLMENT_ENABLED')
GOOGLE_SIGNIN_FEATURE = env('GOOGLE_SIGNIN_ENABLED')
ALLOW_VIEW_ANOTHER_PROFILE = env('ALLOW_VIEW_ANOTHER_PROFILE')
ENTRY_TRACES_SAMPLE_RATE = env('ENTRY_TRACES_SAMPLE_RATE')
STRIPE_SECRET_KEY = env('STRIPE_SECRET_KEY')
STRIPE_PUBLISHABLE_KEY = env('STRIPE_PUBLISHABLE_KEY')
STRIPE_WEBHOOK_SECRET = env('STRIPE_WEBHOOK_SECRET')
MAX_UPLOADED_PUBLIC_DATASETS_PER_DAY = os.getenv("MAX_UPLOADED_PUBLIC_DATASETS_PER_DAY", 2)
ONLY_BETA_LOGIN = os.getenv("ONLY_BETA_LOGIN","false").lower() == 'true'

LOG_LEVEL = env('LOG_LEVEL')

{{ if .Values.configOverrides }}
# Overrides
{{- range $key, $value := .Values.configOverrides }}
# {{ $key }}
{{ tpl $value $ }}
{{- end }}
{{- end }}

{{- end }}