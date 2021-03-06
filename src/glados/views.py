import datetime
import re

import requests
import timeago
from apiclient.discovery import build
from django.conf import settings
from django.core.cache import cache
from django.http import JsonResponse, HttpResponse
from django.shortcuts import render
from elasticsearch_dsl import Search
from glados.api.chembl.url_shortening import url_shortener
from glados.utils import *
from twitter import *

from glados.usage_statistics import glados_server_statistics
from . import heatmap_helper
from . import og_tags_generator
from . import schema_tags_generator
from django.http import Http404
from django.views.decorators.csrf import csrf_exempt
from glados.es_connection import DATA_CONNECTION, MONITORING_CONNECTION
import json


def visualise(request):
    context = {
        'hide_breadcrumbs': True
    }

    return render(request, 'glados/visualise.html', context)


def play(request):

    context = {
        'hide_breadcrumbs': True
    }

    return render(request, 'glados/play.html', context)


def get_latest_tweets(page_number=1, count=15):
    """
    Returns the latest tweets from chembl, It tries to find them in the cache first to avoid hammering twitter
    :return: The structure returned by the twitter api. If there is an error getting the tweets, it returns an
    empty list.
    """
    default_empty_response = ([], {}, 0)
    if not settings.TWITTER_ENABLED:
        return default_empty_response
    cache_key = str(page_number) + "-" + str(count)
    cache_time = 1800  # time to live in seconds

    t_cached_response = cache.get(cache_key)

    # If they are found in the cache, just return them
    if t_cached_response and isinstance(t_cached_response, tuple) and len(t_cached_response) == 3:
        print('Tweets are in cache')
        return t_cached_response

    print('tweets not found in cache!')

    try:
        access_token = settings.TWITTER_ACCESS_TOKEN
        access_token_secret = settings.TWITTER_ACCESS_TOKEN_SECRET
        consumer_key = settings.TWITTER_CONSUMER_KEY
        consumer_secret = settings.TWITTER_CONSUMER_SECRET
        t = Twitter(auth=OAuth(access_token, access_token_secret, consumer_key, consumer_secret))
        tweets = t.statuses.user_timeline(screen_name="chembl", count=count, page=page_number)
        users = t.users.lookup(screen_name="chembl")
        user_data = users[0]
        t_response = (tweets, user_data, user_data['statuses_count'])
        cache.set(cache_key, t_response, cache_time)

        return t_response
    except Exception as e:
        print_server_error(e)
        return default_empty_response


def get_latest_tweets_json(request):
    try:
        count = request.GET.get('limit', 15)
        offset = request.GET.get('offset', 0)
        page_number = str((int(offset) / int(count)) + 1)
        tweets_content, user_data, total_count = get_latest_tweets(page_number, count)
    except Exception as e:
        print_server_error(e)
        return JsonResponse({
            'tweets': [],
            'page_meta': {
                "limit": 0,
                "offset": 0,
                "total_count": 0
            },
            'ERROR': 'Unexpected error while processing your request!'
        })

    for tweet_i in tweets_content:
        tweet_i['id'] = str(tweet_i['id'])

    tweets = {
        'tweets': tweets_content,
        'page_meta': {
            "limit": int(count),
            "offset": int(offset),
            "total_count": total_count
        }
    }

    return JsonResponse(tweets)


def get_latest_blog_entries(request, pageToken):

    if not settings.BLOGGER_ENABLED:
        default_empty_response = {
            'entries': [],
            'totalCount': 0
        }
        return JsonResponse(default_empty_response)

    blogId = '2546008714740235720'
    key = settings.BLOGGER_KEY
    fetchBodies = True
    fetchImages = False
    maxResults = 15
    orderBy = 'PUBLISHED'

    cache_key = str(pageToken)
    cache_time = 1800

    # tries to get entries from cache
    cache_response = cache.get(cache_key)

    if cache_response != None:
        print('blog entries are in cache')
        return JsonResponse(cache_response)

    print('Blog entries not found in cache!')

    # gets blog entries from blogger api
    service = build('blogger', 'v3', developerKey=key)
    response = service.posts().list(blogId=blogId, orderBy=orderBy, pageToken=pageToken,
                                    fetchBodies=fetchBodies, fetchImages=fetchImages, maxResults=maxResults).execute()
    blog_response = service.blogs().get(blogId=blogId).execute()

    total_count = blog_response['posts']['totalItems']
    latest_entries_items = response['items']
    next_page_token = response['nextPageToken']

    blog_entries = []

    for blog_entry in latest_entries_items:
        date = blog_entry['published'].split('T')[0]
        content = blog_entry['content']

        html_comment = re.compile(r'<!--(.*?)-->')
        html = re.compile(r'<[^>]+>')
        url = re.compile(r'(http|ftp|https)://([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?')

        content = content.replace('\n', ' ')
        content = re.sub(html_comment, ' ', content)
        content = re.sub(html, ' ', content)
        content = re.sub(url, ' ', content)
        content = ' '.join(content.split())
        content = content[:100] + (content[100:] and '...')

        blog_entries.append({
            'title': blog_entry['title'],
            'url': blog_entry['url'],
            'author': blog_entry['author']['displayName'],
            'author_url': blog_entry['author']['url'],
            'date': date,
            'content': content

        })

    entries = {
        'entries': blog_entries,
        'nextPageToken': next_page_token,
        'totalCount': total_count
    }
    cache.set(cache_key, entries, cache_time)

    return JsonResponse(entries)


def get_database_summary(request):

    cache_key = 'deposited_datasets'
    cache_time = 604800
    q = {


        "bool": {
            "filter": {
                "term": {
                    "doc_type": "DATASET"
                }
            },
            "must": {
                "range": {
                    "_metadata.related_activities.count": {
                        "gt": 0
                    }
                }
            },
            "must_not": {
                "terms": {
                    "_metadata.source.src_id": [1, 7, 8, 9, 7, 8, 9, 11, 12, 13, 15, 18, 25, 26, 28, 31,
                                                35, 37, 38,
                                                39, 41, 42]
                }
            }
        }

    }

    # tries to get number from cache
    cache_response = cache.get(cache_key)

    if cache_response != None:
        print('datasets are in cache')
        return JsonResponse(cache_response)

    print('datasets are not in cache')

    s = Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"document").extra(track_total_hits=True).using(DATA_CONNECTION)\
        .query(q)
    response = s.execute()
    response = {'num_datasets': response.hits.total.value}
    cache.set(cache_key, response, cache_time)

    return JsonResponse(response)


def get_entities_records(request):

    cache_key = 'entities_records_v2'
    cache_time = 604800
    cache_response = cache.get(cache_key)
    print(cache_key)

    if cache_response is not None:
        print('records are in cache')
        return JsonResponse(cache_response)

    print('records are not in cache')

    drugs_query = {

        "term": {
          "_metadata.drug.is_drug": True
        }

    }

    response = {
        'Compounds':
            Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"molecule").extra(track_total_hits=True).using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Drugs': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"molecule").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .query(drugs_query).execute().hits.total.value,
        'Assays': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"assay").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Documents': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"document").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Targets': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"target").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Cells': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"cell_line").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Tissues': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"tissue").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Indications': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"drug_indication_by_parent")
            .extra(track_total_hits=True).using(DATA_CONNECTION)
            .execute().hits.total.value,
        'Mechanisms': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"mechanism_by_parent_target")
            .extra(track_total_hits=True).using(DATA_CONNECTION)
            .execute().hits.total.value
    }

    cache.set(cache_key, response, cache_time)

    return JsonResponse(response)


def get_covid_entities_records(request):

    cache_key = 'covid_entities_records'
    cache_time = 604800
    cache_response = cache.get(cache_key)
    print(cache_key)

    if cache_response is not None:
        print('records are in cache')
        return JsonResponse(cache_response)

    print('records are not in cache')

    covid_compounds_query = {
        "query_string" : {
            "query" : "_metadata.compound_records.src_id:52",
        }
    }

    covid_assays_query = {
        "query_string": {
            "query": "_metadata.source.src_id:52",
        }
    }

    covid_documents_query = {
        "query_string": {
            "query": "_metadata.source.src_id:52 AND NOT document_chembl_id:CHEMBL4303081",
        }
    }

    covid_activities_query = {
        "query_string": {
            "query": "_metadata.source.src_id:52",
        }
    }

    response = {
        'Compounds':
            Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"molecule").extra(track_total_hits=True).using(DATA_CONNECTION)
            .query(covid_compounds_query).execute().hits.total.value,
        'Assays': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"assay").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .query(covid_assays_query).execute().hits.total.value,
        'Documents': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"document").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .query(covid_documents_query).execute().hits.total.value,
        'Activities': Search(index=settings.CHEMBL_ES_INDEX_PREFIX+"activity").extra(track_total_hits=True)
            .using(DATA_CONNECTION)
            .query(covid_activities_query).execute().hits.total.value,
    }

    cache.set(cache_key, response, cache_time)

    return JsonResponse(response)


def get_github_details(request):

    cache_key = 'github_details'
    cache_time = 1800
    cache_response = cache.get(cache_key)

    if cache_response is not None:
        print('github details are in cache')
        now = datetime.datetime.now()
        raw_commit_date = cache_response['raw_commit_date']
        commit_date = datetime.datetime.strptime(raw_commit_date, '%Y-%m-%dT%H:%M:%S')
        time_ago = timeago.format(commit_date, now)
        cache_response['time_ago'] = time_ago
        return JsonResponse(cache_response)

    print('github details are not in cache')
    last_commit = requests.get('https://api.github.com/repos/chembl/GLaDOS/commits/master').json()

    now = datetime.datetime.now()
    raw_commit_date = last_commit['commit']['author']['date'][:-1]
    commit_date = datetime.datetime.strptime(raw_commit_date, '%Y-%m-%dT%H:%M:%S')
    time_ago = timeago.format(commit_date, now)

    response = {
        'url': last_commit['html_url'],
        'author': last_commit['commit']['author']['name'],
        'time_ago': time_ago,
        'raw_commit_date': raw_commit_date,
        'message': last_commit['commit']['message']
    }

    print('response: ', response)

    cache.set(cache_key, response, cache_time)

    return JsonResponse(last_commit)


def replace_urls_from_entinies(html, urls):
    """
    :return: the html with the corresponding links from the entities
    """
    for url in urls:
        link = '<a href="%s">%s</a>' % (url['url'], url['display_url'])
        html = html.replace(url['url'], link)

    return html


def main_page(request):

    context = {
        'main_page': True,
        'hide_breadcrumbs': True,
        'metadata_str':  json.dumps(schema_tags_generator.get_main_page_schema(request), indent=2),
    }
    return render(request, 'glados/main_page.html', context)


def design_components(request):
    context = {
        'hide_breadcrumbs': True
    }
    return render(request, 'glados/base/design_components.html', context)


def main_html_base_no_bar(request):
    context = {
        'show_save_button': True
    }
    return render(request, 'glados/mainGladosNoBar.html', context)


def render_params_from_hash(request, hash):

    long_url, expiration_date_str = url_shortener.get_original_url(hash)

    if long_url is None:
        raise Http404("Shortened url does not exist")

    context = {
        'shortened_params': long_url,
        'expiration_date_str': expiration_date_str,
        'show_save_button': True
    }
    return render(request, 'glados/mainGladosNoBar.html', context)


def render_params_from_hash_when_embedded(request, hash):

    long_url, expiration_date_str = url_shortener.get_original_url(hash)
    context = {
        'shortened_params': long_url
    }
    return render(request, 'glados/Embedding/embed_base.html', context)


# ----------------------------------------------------------------------------------------------------------------------
# Heatmap Helper
# ----------------------------------------------------------------------------------------------------------------------


def request_heatmap_helper(request):
    if request.method != "POST":
        return JsonResponse({'error': 'this is only available via POST'})

    index_name = request.POST.get('index_name', '')
    raw_search_data = request.POST.get('search_data', '')
    action = request.POST.get('action')

    if action == 'GET_INITIAL_DATA':
        heatmap_helper.generate_heatmap_initial_data(index_name, raw_search_data)

    return JsonResponse({'data': 'Data'})


def extend_url(request, hash):
    resp_data = {
        'long_url': url_shortener.get_original_url(hash)
    }

    return JsonResponse(resp_data)

# ----------------------------------------------------------------------------------------------------------------------
# Tracking
# ----------------------------------------------------------------------------------------------------------------------


def register_usage(request):

    if request.method == "POST":
        try:
            view_name = request.POST.get('view_name', '')
            view_type = request.POST.get('view_type', '')
            entity_name = request.POST.get('entity_name', '')
            glados_server_statistics.record_view_usage(view_name, view_type, entity_name)
            return JsonResponse({'success': 'registration successful!'})
        except Exception as e:
            print_server_error(e)
            return HttpResponse('Internal Server Error', status=500)
    else:
        return JsonResponse({'error': 'this is only available via POST! You crazy hacker! :P'})

# ----------------------------------------------------------------------------------------------------------------------
# Report Cards
# ----------------------------------------------------------------------------------------------------------------------


def compound_report_card(request, chembl_id):

    context = {
        'og_tags': og_tags_generator.get_og_tags_for_compound(chembl_id),
        'schema_helper_obj': schema_tags_generator.get_schema_obj_for_compound(chembl_id, request),
        'link_to_rdf': "http://rdf.ebi.ac.uk/resource/chembl/molecule/{}".format(chembl_id)
    }

    return render(request, 'glados/compoundReportCard.html', context)


def assay_report_card(request, chembl_id):

    context = {
        'og_tags': og_tags_generator.get_og_tags_for_assay(chembl_id)
    }

    return render(request, 'glados/assayReportCard.html', context)


def cell_line_report_card(request, chembl_id):

    context = {
        'og_tags': og_tags_generator.get_og_tags_for_cell_line(chembl_id)
    }

    return render(request, 'glados/cellLineReportCard.html', context)


def tissue_report_card(request, chembl_id):

    context = {
        'og_tags': og_tags_generator.get_og_tags_for_tissue(chembl_id)
    }

    return render(request, 'glados/tissueReportCard.html', context)


def target_report_card(request, chembl_id):

    context = {
        'og_tags': og_tags_generator.get_og_tags_for_target(chembl_id)
    }

    return render(request, 'glados/targetReportCard.html', context)


def document_report_card(request, chembl_id):

    context = {
        'og_tags': og_tags_generator.get_og_tags_for_document(chembl_id)
    }

    return render(request, 'glados/documentReportCard.html', context)
