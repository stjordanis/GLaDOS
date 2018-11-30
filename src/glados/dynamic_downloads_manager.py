# this handles the creation of dynamically generated downloads
import time
from django_rq import job
import hashlib
import base64
from glados.models import DownloadJob
import json

class DownloadError(Exception):
    """Base class for exceptions in this file."""
    pass

@job
def generate_download_file(download_id):

    print('generate_download_file: ', download_id)
    download_job = DownloadJob.objects.get(job_id=download_id)
    download_job.status = DownloadJob.PROCESSING
    download_job.save()

    num = 100
    for i in range(num):
        print('i: ', i)
        download_job.progress = i
        download_job.save()
        time.sleep(1)


def get_download_id(index_name, raw_query, desired_format):

    # make sure the string generated is stable
    stable_raw_query = json.dumps(json.loads(raw_query), sort_keys=True)
    print('stable_raw_query:', stable_raw_query)

    parsed_desired_format = desired_format.lower()
    if parsed_desired_format not in ['csv', 'tsv', 'csv']:
        raise DownloadError("Format {} not supported".format(desired_format))

    latest_release_full = 'chembl_24_1'
    query_digest = hashlib.sha256(stable_raw_query.encode('utf-8')).digest()
    base64_query_digest = base64.b64encode(query_digest).decode('utf-8').replace('/', '_').replace('+', '-')

    download_id = "{}-{}-{}.{}".format(latest_release_full, index_name, base64_query_digest, parsed_desired_format)
    return download_id


def generate_download(index_name, raw_query, desired_format):
    response = {}
    download_id = get_download_id(index_name, raw_query, desired_format)
    print('download_id: ', download_id)

    try:
        DownloadJob.objects.get(job_id=download_id)
        print('job already in queue')
    except DownloadJob.DoesNotExist:
        download_job = DownloadJob(job_id=download_id)
        download_job.save()
        generate_download_file.delay(download_id)
        print('new job created')

    response['download_id'] = download_id
    return response

def get_download_status(download_id):

    try:
        download_job = DownloadJob.objects.get(job_id=download_id)
        response = {
            'percentage': download_job.progress,
            'status': download_job.status

        }
        return response

    except DownloadJob.DoesNotExist:
        print('does not exist!')
        response = {
            'error': 'download does not exist!'
        }
        return response