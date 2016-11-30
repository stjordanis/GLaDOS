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


class RunEnvs(object):
    DEV = 'DEV'
    TEST = 'TEST'
    PROD = 'PROD'

RUN_ENV = RunEnvs.PROD

# Build paths inside the project like this: os.path.join(GLADOS_ROOT, ...)
GLADOS_ROOT = os.path.dirname(os.path.abspath(glados.__file__))

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.9/howto/deployment/checklist/

# ----------------------------------------------------------------------------------------------------------------------
# SECURITY WARNING: keep the secret key used in production secret!
# ----------------------------------------------------------------------------------------------------------------------
SECRET_KEY = 'Cake, and grief counseling, will be available at the conclusion of the test.'

# ----------------------------------------------------------------------------------------------------------------------
# Twitter
# ----------------------------------------------------------------------------------------------------------------------

TWITTER_ENABLED = RUN_ENV == RunEnvs.PROD

TWITTER_ACCESS_TOKEN = '732582863107981312-dZ8OEZZdNCsltXtN2pTp3xShPMYHxkE'
TWITTER_ACCESS_TOKEN_SECRET = 'NeyIr4Qol3iOYUMhXQlYbrY7MTpZAjYTiXa2aMjjxPFPP'
TWITTER_CONSUMER_KEY = 'BQFmlwCsCc2Amai4ELLDSe8DY'
TWITTER_CONSUMER_SECRET ='Gn8ZuoI6yBl1BEACPBQvgtQP7ZmTe0pseh9RiwSEjnpdHZyvwO'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = RUN_ENV == RunEnvs.DEV

ALLOWED_HOSTS = ['*']

# Application definition

INSTALLED_APPS = [
  'django.contrib.admin',
  'django.contrib.auth',
  'django.contrib.contenttypes',
  'django.contrib.sessions',
  'django.contrib.messages',
  'django.contrib.staticfiles',
  'glados',
  'compressor',
  'twitter'
]

MIDDLEWARE_CLASSES = [
  'django.middleware.security.SecurityMiddleware',
  'django.contrib.sessions.middleware.SessionMiddleware',
  'django.middleware.common.CommonMiddleware',
  'django.middleware.csrf.CsrfViewMiddleware',
  'django.contrib.auth.middleware.AuthenticationMiddleware',
  'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
  'django.contrib.messages.middleware.MessageMiddleware',
  'django.middleware.clickjacking.XFrameOptionsMiddleware',
  'whitenoise.middleware.WhiteNoiseMiddleware'
]

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
      ],
      'debug': DEBUG,
    },
  },
]

# ----------------------------------------------------------------------------------------------------------------------
# Database
# https://docs.djangoproject.com/en/1.9/ref/settings/#databases
# ----------------------------------------------------------------------------------------------------------------------

DATABASES = {
  'default': {
    'ENGINE': 'django.db.backends.sqlite3',
    'NAME': os.path.join(GLADOS_ROOT, 'db/db.sqlite3'),
  }
}

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

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_L10N = True

USE_TZ = True

# ----------------------------------------------------------------------------------------------------------------------
# STATIC FILES (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

STATIC_URL = '/static/'

STATICFILES_DIRS = (
  os.path.join(GLADOS_ROOT, 'static/'),
)

STATIC_ROOT = os.path.join(GLADOS_ROOT, 'static_root')

STATICFILES_FINDERS = (
    'django.contrib.staticfiles.finders.FileSystemFinder',
    'django.contrib.staticfiles.finders.AppDirectoriesFinder',
    # other finders..
    'compressor.finders.CompressorFinder',
)

STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# ----------------------------------------------------------------------------------------------------------------------
# File Compression (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.9/howto/static-files/
# ----------------------------------------------------------------------------------------------------------------------

COMPRESS_ENABLED = RUN_ENV == RunEnvs.PROD

if COMPRESS_ENABLED:
    COMPRESS_OFFLINE = True
    COMPRESS_CSS_FILTERS = ['compressor.filters.css_default.CssAbsoluteFilter', 'compressor.filters.cssmin.CSSMinFilter']
    COMPRESS_JS_FILTERS = ['compressor.filters.jsmin.JSMinFilter']
    COMPRESS_URL = STATIC_URL
    COMPRESS_ROOT = STATIC_ROOT
    #COMPRESS_CLOSURE_COMPILER_BINARY = 'java -jar '+ os.path.join(BASE_DIR, 'tools/google_closure_compiler/compiler.jar')

# ----------------------------------------------------------------------------------------------------------------------
# Cache
# ----------------------------------------------------------------------------------------------------------------------

CACHES = {
  'default': {
      'BACKEND': 'django.core.cache.backends.db.DatabaseCache',
      'LOCATION': 'cache',
  }
}
