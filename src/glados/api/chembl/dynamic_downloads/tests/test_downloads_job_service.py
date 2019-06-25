from django.test import TestCase, override_settings
from glados.api.chembl.dynamic_downloads.models import DownloadJob
import json
import os
from django.conf import settings
from glados.api.chembl.dynamic_downloads import download_job_service
import glados.es.ws2es.es_util as es_util
from glados.settings import RunEnvs


class DownloadJobsServiceTester(TestCase):
    CONFIG_TEST_FILE = os.path.join(settings.GLADOS_ROOT, 'api/chembl/dynamic_downloads/tests/data/test_override.yml')
    GROUPS_TEST_FILE = os.path.join(settings.GLADOS_ROOT, 'api/chembl/dynamic_downloads/tests/data/test_groups.yml')

    def setUp(self):
        DownloadJob.objects.all().delete()
        if settings.RUN_ENV == RunEnvs.TRAVIS:
            es_util.setup_connection_from_full_url(settings.ELASTICSEARCH_EXTERNAL_URL)
        else:
            es_util.setup_connection_from_full_url(settings.ELASTICSEARCH_HOST)

    def tearDown(self):
        DownloadJob.objects.all().delete()

    @override_settings(PROPERTIES_GROUPS_FILE=GROUPS_TEST_FILE, PROPERTIES_CONFIG_OVERRIDE_FILE=CONFIG_TEST_FILE)
    def test_queues_simple_download_job(self):
        print('TEST QUEUES SIMPLE DOWNLOAD JOB')

        test_search_context_path = os.path.join(settings.SSSEARCH_RESULTS_DIR, 'test_search_context.json')
        test_raw_context = [{
            'molecule_chembl_id': 'CHEMBL59',
            'similarity': 100.0
        }]

        with open(test_search_context_path, 'wt') as test_search_file:
            test_search_file.write(json.dumps(test_raw_context))

        index_name = 'chembl_molecule'
        raw_query = '{"query_string": {"query": "molecule_chembl_id:(CHEMBL59)"}}'
        desired_format = 'csv'
        context_id = 'test_search_context'

        job_id = download_job_service.queue_download_job(index_name, raw_query, desired_format, context_id)
        download_job_got = DownloadJob.objects.get(job_id=job_id)

        id_property_must_be = 'molecule_chembl_id'
        id_property_got = download_job_got.id_property
        self.assertEqual(id_property_must_be, id_property_got, msg='The id property was not set correctly!')

        columns_to_download_must_be = [
            {'label_mini': 'ChEMBL ID', 'type': 'string', 'aggregatable': True, 'sortable': True,
             'prop_id': 'molecule_chembl_id', 'index_name': 'chembl_molecule', 'label': 'ChEMBL ID'},
            {'label_mini': 'Name', 'type': 'string', 'aggregatable': True, 'sortable': True, 'prop_id': 'pref_name',
             'index_name': 'chembl_molecule', 'label': 'Name'},
            {'aggregatable': False, 'label_mini': 'Similarity', 'type': 'double', 'index_name': 'chembl_molecule',
             'sortable': True, 'prop_id': 'similarity', 'is_virtual': True, 'label': 'Similarity'}]

        raw_columns_to_download_must_be = json.dumps(columns_to_download_must_be)
        raw_columns_to_download_got = download_job_got.raw_columns_to_download
        columns_to_download_got = json.loads(raw_columns_to_download_got)


        self.assertEqual(columns_to_download_must_be, columns_to_download_got,
                          msg='The columns to download were not set correctly')

        # TODO: a job must exist in queued state
        # TODO: the job id reported must be the one generated by the job id model

        # TODO: test fails when format is not valid
