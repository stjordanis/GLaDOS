"""
Django settings for mysite project.

Generated by 'django-admin startproject' using Django 1.9.2.

For more information on this file, see
https://docs.djangoproject.com/en/1.9/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.9/ref/settings/
"""

import os
import glados
from django.utils.translation import ugettext_lazy as _
import logging
import yaml
from pymongo.read_preferences import ReadPreference


class GladosSettingsError(Exception):
    """Base class for exceptions in GLaDOS configuration."""
    pass


class RunEnvs(object):
    DEV = 'DEV'
    TRAVIS = 'TRAVIS'
    TEST = 'TEST'
    PROD = 'PROD'


# ----------------------------------------------------------------------------------------------------------------------
# External Resources Defaults (will be overwritten by .yml file)
# ----------------------------------------------------------------------------------------------------------------------
WS_URL = 'https://www.ebi.ac.uk/chembl/api/data'
BEAKER_URL = 'https://www.ebi.ac.uk/chembl/api/utils'
ELASTICSEARCH_HOST = '<INTERNAL_URL_CAN NOT BE PUBLISHED>'
ELASTICSEARCH_EXTERNAL_URL = 'https://www.ebi.ac.uk/chembl/glados-es'

# ----------------------------------------------------------------------------------------------------------------------
# Read config file
# ----------------------------------------------------------------------------------------------------------------------

custom_config_file_path = os.getenv('CONFIG_FILE_PATH')
if custom_config_file_path is not None:
    CONFIG_FILE_PATH = custom_config_file_path
else:
    CONFIG_FILE_PATH = os.getenv("HOME") + '/.chembl-glados/config.yml'
print('CONFIG_FILE_PATH: ', CONFIG_FILE_PATH)
run_config = yaml.load(open(CONFIG_FILE_PATH, 'r'))

RUN_ENV = run_config['run_env']

if RUN_ENV == RunEnvs.DEV:
    print('run_config: ', run_config)

if RUN_ENV not in [RunEnvs.DEV, RunEnvs.TRAVIS, RunEnvs.TEST, RunEnvs.PROD]:
    raise GladosSettingsError("Run environment {} is not supported.".format(RUN_ENV))

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = RUN_ENV in [RunEnvs.DEV, RunEnvs.TRAVIS]
print('DEBUG: ', DEBUG)

# Build paths inside the project like this: os.path.join(GLADOS_ROOT, ...)
GLADOS_ROOT = os.path.dirname(os.path.abspath(glados.__file__))
VUE_ROOT = os.path.join(GLADOS_ROOT, 'v')
DYNAMIC_DOWNLOADS_DIR = os.path.join(GLADOS_ROOT, 'dynamic-downloads')
print('DYNAMIC_DOWNLOADS_DIR: ', DYNAMIC_DOWNLOADS_DIR)
SSSEARCH_RESULTS_DIR = os.path.join(GLADOS_ROOT, 'sssearch-results')
print('SSSEARCH_RESULTS_DIR: ', SSSEARCH_RESULTS_DIR)

FILTER_QUERY_MAX_CLAUSES = run_config.get('filter_query_max_clauses')
if FILTER_QUERY_MAX_CLAUSES is None:
    raise GladosSettingsError("You must tell me the filter_query_max_clauses")
print('FILTER_QUERY_MAX_CLAUSES: ', FILTER_QUERY_MAX_CLAUSES)

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.9/howto/deployment/checklist/

BASE_DIR = os.path.dirname(os.path.dirname(__file__))

OLD_INTERFACE_URL = run_config.get('old_interface_url')
if OLD_INTERFACE_URL is None:
    raise GladosSettingsError("You must provide the url for the old interface")

# ----------------------------------------------------------------------------------------------------------------------
# SERVER BASE PATH
# ----------------------------------------------------------------------------------------------------------------------
# For usage behind proxies eg: 'chembl/beta/', you don't need to care about this in DEV mode
SERVER_BASE_PATH = '' if os.getenv('SERVER_BASE_PATH') is None else os.getenv('SERVER_BASE_PATH') + '/'
print('SERVER_BASE_PATH: ', SERVER_BASE_PATH)

# ----------------------------------------------------------------------------------------------------------------------
# ChEMBL API
# ----------------------------------------------------------------------------------------------------------------------
chembl_api_config = run_config.get('chembl_api')
if chembl_api_config is None:
    raise GladosSettingsError("You must provide the chembl_api configuration")
else:
    WS_URL = chembl_api_config.get('ws_url')
    BEAKER_URL = chembl_api_config.get('beaker_url')
    if WS_URL is None or BEAKER_URL is None:
        raise GladosSettingsError("You must provide both the web services (data) URL and beaker (utils) URL")


# ----------------------------------------------------------------------------------------------------------------------
# Admin user
# ----------------------------------------------------------------------------------------------------------------------
ADMIN_USER_CONFIG = run_config.get('admin_user')

# ----------------------------------------------------------------------------------------------------------------------
# SECURITY WARNING: keep the secret key used in production secret!
# ----------------------------------------------------------------------------------------------------------------------
SECRET_KEY = run_config.get('server_secret_key',
                            'Cake and grief counseling will be available at the conclusion of the test.')

# ----------------------------------------------------------------------------------------------------------------------
# Twitter
# ----------------------------------------------------------------------------------------------------------------------
TWITTER_ENABLED = run_config.get('enable_twitter', False)

if TWITTER_ENABLED:

    twitter_secrets = run_config.get('twitter_secrets')
    if twitter_secrets is None:
        raise GladosSettingsError("You must provide the twitter secrets ")

    TWITTER_ACCESS_TOKEN = twitter_secrets.get('twitter_access_token', '')
    TWITTER_ACCESS_TOKEN_SECRET = twitter_secrets.get('twitter_access_token_secret', '')
    TWITTER_CONSUMER_KEY = twitter_secrets.get('twitter_access_consumer_key', '')
    TWITTER_CONSUMER_SECRET = twitter_secrets.get('twitter_access_consumer_secret', '')

# ----------------------------------------------------------------------------------------------------------------------
# Blogger
# ----------------------------------------------------------------------------------------------------------------------
BLOGGER_ENABLED = run_config.get('enable_blogger', False)
if BLOGGER_ENABLED:
    blogger_secrets = run_config.get('blogger_secrets')
    if blogger_secrets is None:
        raise GladosSettingsError("You must provide the blogger secrets ")

    BLOGGER_KEY = blogger_secrets.get('blogger_key', '')


# ----------------------------------------------------------------------------------------------------------------------
# ElasticSearch
# ----------------------------------------------------------------------------------------------------------------------
elasticsearch_config = run_config.get('elasticsearch')
if elasticsearch_config is None:
    raise GladosSettingsError("You must provide the elasticsearch configuration")
else:
    ELASTICSEARCH_HOST = elasticsearch_config.get('host')

    if RUN_ENV == RunEnvs.TRAVIS:
        ELASTICSEARCH_USERNAME = os.getenv('ELASTICSEARCH_USERNAME')
        ELASTICSEARCH_PASSWORD = os.getenv('ELASTICSEARCH_PASSWORD')
    else:
        ELASTICSEARCH_USERNAME = elasticsearch_config.get('username')
        ELASTICSEARCH_PASSWORD = elasticsearch_config.get('password')

    ELASTICSEARCH_EXTERNAL_URL = elasticsearch_config.get('public_host')
    if ELASTICSEARCH_EXTERNAL_URL is None:
        raise GladosSettingsError("You must provide the elasticsearch public URL that will be accessible from the js "
                                  "code in the browser")

ALLOWED_HOSTS = ['*']

# Application definition

INSTALLED_APPS = [
  'django.contrib.admin',
  'django.contrib.auth',
  'django.contrib.contenttypes',
  'django.contrib.sessions',
  'django.contrib.messages',
  'django.contrib.staticfiles',
  'corsheaders',
  'glados',
  'compressor',
  'twitter',
  'django_rq',
  'unichem'
]

MIDDLEWARE = [
  'corsheaders.middleware.CorsMiddleware',    
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  'django.middleware.locale.LocaleMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.contrib.auth.middleware.AuthenticationMiddleware',
  'django.contrib.messages.middleware.MessageMiddleware',
  'django.middleware.clickjacking.XFrameOptionsMiddleware',
  'whitenoise.middleware.WhiteNoiseMiddleware'
]

CORS_URLS_REGEX = r'^/glados_api/.*$'
CORS_ORIGIN_ALLOW_ALL = True

ROOT_URLCONF = 'glados.urls'

TEMPLATES = [
  {
    'BACKEND': 'django.template.backends.django.DjangoTemplates',
    'DIRS': [os.path.join(GLADOS_ROOT, 'templates/'),],
    'APP_DIRS': True,
    'OPTIONS': {
      'context_processors': [
        'django.template.context_processors.debug',
        'django.template.context_processors.request',
        'django.contrib.auth.context_processors.auth',
        'django.contrib.messages.context_processors.messages',
        'glados.settings_context.glados_settings_context_processor',
      ],
      'debug': DEBUG,
    },
  },
]

# ----------------------------------------------------------------------------------------------------------------------
# Database
# https://docs.djangoproject.com/en/1.9/ref/settings/#databases
# ----------------------------------------------------------------------------------------------------------------------
DATABASES = {}

ENABLE_MYSQL_DATABASE = run_config.get('enable_mysql_database', False)
print('ENABLE_MYSQL_DATABASE: ', ENABLE_MYSQL_DATABASE)

DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': os.path.join(GLADOS_ROOT, 'db/db.sqlite3')
  }
}
if ENABLE_MYSQL_DATABASE:

    mysql_config = run_config.get('mysql_config')
    if mysql_config is None:
        raise GladosSettingsError("You must provide the mysql configuration")
    else:
        DATABASES['default'] = {
            'ENGINE': 'mysql.connector.django',
            'NAME': mysql_config.get('schema_name'),
            'HOST': mysql_config.get('host'),
            'PORT': mysql_config.get('port'),
            'USER': mysql_config.get('user'),
            'PASSWORD': mysql_config.get('password'),
            'OPTIONS': {
                'autocommit': True,
            }

        }

else:

    print('Using sqlite database: ', os.path.join(GLADOS_ROOT, 'db/db.sqlite3'))
    DATABASES['default'] = {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(GLADOS_ROOT, 'db/db.sqlite3')
    }

ENABLE_UNICHEM_ORACLE_DB = run_config.get('enable_unichem_oracle_db', False)
print('ENABLE_UNICHEM_ORACLE_DB: ', ENABLE_UNICHEM_ORACLE_DB)
if ENABLE_UNICHEM_ORACLE_DB:

    oracle_config = run_config.get('unichem_oracle')

    DATABASES['oradb'] = {
        'ENGINE': 'django.db.backends.oracle',
        'NAME': oracle_config.get('name'),
        'USER': oracle_config.get('user'),
        'PASSWORD': oracle_config.get('password')
    }

    DATABASE_ROUTERS = ['glados.db.APIDatabaseRouter.APIDatabaseRouter']
# ----------------------------------------------------------------------------------------------------------------------
# Django RQ
# https://github.com/rq/django-rq
# ----------------------------------------------------------------------------------------------------------------------
CUSTOM_RQ_QUEUES = run_config.get('custom_rq_queues_config')

if CUSTOM_RQ_QUEUES is not None:

    RQ_QUEUES = CUSTOM_RQ_QUEUES

else:

    RQ_QUEUES = {
        'default': {
            'HOST': 'localhost',
            'PORT': 6379,
            'DB': 0,
            'DEFAULT_TIMEOUT': 86400,
        },
    }

print('RQ_QUEUES: ', RQ_QUEUES)
# ----------------------------------------------------------------------------------------------------------------------
# Password validation
# https://docs.djangoproject.com/en/1.9/ref/settings/#auth-password-validators
# ----------------------------------------------------------------------------------------------------------------------

AUTH_PASSWORD_VALIDATORS = [
  {
    'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
  },
  {
    'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
  },
]

# ----------------------------------------------------------------------------------------------------------------------
# Internationalization
# https://docs.djangoproject.com/en/1.9/topics/i18n/
# ----------------------------------------------------------------------------------------------------------------------

LANGUAGE_CODE = 'en'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True
LANGUAGES = [
    ('en', _('English')),
]
LOCALE_PATHS = [
    os.path.join(GLADOS_ROOT, 'locale'),
]

# ----------------------------------------------------------------------------------------------------------------------
# STATIC FILES (CSS, JavaScript, Images) and URL's
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

USE_X_FORWARDED_HOST = True

STATIC_URL = '/{0}static/'.format(SERVER_BASE_PATH)
VUE_STATIC_URL = '{0}v/'.format(SERVER_BASE_PATH)

print('VUE ROOT', VUE_ROOT)

STATICFILES_DIRS = (
    os.path.join(GLADOS_ROOT, 'static/'),
    VUE_ROOT
)

STATIC_ROOT = os.path.join(GLADOS_ROOT, 'static_root')

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'compressor.finders.CompressorFinder',
)

WATCH_AND_UPDATE_STATIC_COMPILED_FILES = RUN_ENV in [RunEnvs.DEV, RunEnvs.TRAVIS]
print('WATCH_AND_UPDATE_STATIC_COMPILED_FILES: ', WATCH_AND_UPDATE_STATIC_COMPILED_FILES)

# ----------------------------------------------------------------------------------------------------------------------
# File Compression (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

COMPRESS_ENABLED = RUN_ENV in [RunEnvs.TEST, RunEnvs.PROD]
print('COMPRESS_ENABLED: ', COMPRESS_ENABLED)

if COMPRESS_ENABLED:
    COMPRESS_OFFLINE = True

    COMPRESS_CSS_FILTERS = ['compressor.filters.css_default.CssAbsoluteFilter',
                            'compressor.filters.cssmin.CSSMinFilter']
    COMPRESS_JS_FILTERS = ['compressor.filters.yuglify.YUglifyJSFilter']
    COMPRESS_URL = STATIC_URL
    COMPRESS_ROOT = STATIC_ROOT
    #COMPRESS_CLOSURE_COMPILER_BINARY = 'java -jar '+ os.path.join(BASE_DIR,
    #'external_tools/closure_compiler/closure-compiler-v20180610.jar')

# ----------------------------------------------------------------------------------------------------------------------
# HTTPS SSL PROXY HEADER
# ----------------------------------------------------------------------------------------------------------------------

SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# ----------------------------------------------------------------------------------------------------------------------
# Cache
# ----------------------------------------------------------------------------------------------------------------------
ENABLE_MONGO_DB_CACHE = run_config.get('enable_mongo_db_cache', False)

if not ENABLE_MONGO_DB_CACHE:

    CACHES = {
        'default': {
            'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
            'LOCATION': '127.0.0.1:11211',
        }
    }
else:

    mongo_db_cache_config = run_config.get('mongo_db_cache_config')

    if mongo_db_cache_config is None:
        raise GladosSettingsError('You must provide a mongdo db cache configuration!')

    mongo_db_cache_config['OPTIONS']['READ_PREFERENCE'] = ReadPreference.SECONDARY_PREFERRED

    CACHES = {
        'default': mongo_db_cache_config
    }



# ----------------------------------------------------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------------------------------------------------


LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'glados': {
            'class': 'glados.logging_helper.MultiLineFormatter',
            'format': '%(asctime)s %(levelname)-8s %(message)s',
            'datefmt': '%Y-%m-%d %H:%M:%S'
        }
    },
    'handlers': {
        'console': {
            'level': logging.DEBUG,
            'class': 'glados.logging_helper.ColoredConsoleHandler',
            'formatter': 'glados',
        },
    },
    'loggers': {
        'django': {
            'handlers': ['console'],
            'level': os.getenv('DJANGO_LOG_LEVEL', 'INFO'),
        },
        'elasticsearch': {
            'level': logging.CRITICAL
        },
        'glados.static_files_compiler': {
            'handlers': ['console'],
            'level': logging.DEBUG if WATCH_AND_UPDATE_STATIC_COMPILED_FILES else logging.INFO,
            'propagate': True,
        },
        'glados.es_connection': {
            'handlers': ['console'],
            'level': logging.INFO,
            'propagate': True,
        },
    },
}
