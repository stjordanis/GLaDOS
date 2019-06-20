from elasticsearch_dsl.connections import connections
from elasticsearch.helpers import scan
from glados.utils.dot_notation_getter import DotNotationGetter
from glados.es.es_properties_configuration import columns_parser
from enum import Enum
import os
from django.conf import settings
import gzip


class OutputFormats(Enum):
    CSV = 'CSV'
    TSV = 'TSV'


class FileWriterError(Exception):
    """Base class for exceptions in the file writer."""
    pass


def get_search_source(columns_to_download):
    return [col['property_name'] for col in columns_to_download]


def format_cell(original_value):
    value = original_value
    if isinstance(value, str):
        value = value.replace('"', "'")

    return '"{}"'.format(value)


def write_separated_values_file(desired_format, index_name, query, columns_to_download, base_file_name='result',
                                output_dir=settings.DYNAMIC_DOWNLOADS_DIR, context=None, id_property=None,
                                contextual_columns=None,
                                progress_function=(lambda progress: progress)):

    if desired_format not in OutputFormats:
        raise FileWriterError('The format {} is not supported'.format(desired_format))

    if index_name is None:
        raise FileWriterError('You must provide an index name')

    using_context = False
    if context is not None:
        if id_property is None:
            raise FileWriterError('When providing context, an id property must be given in order to join the rows')
        if contextual_columns is None:
            raise FileWriterError('When providing context, an contextual column description must be given')
        using_context = True

    if desired_format is OutputFormats.CSV:
        separator = ';'
        file_path = os.path.join(output_dir, base_file_name + '.csv.gz')
    elif desired_format is OutputFormats.TSV:
        separator = '\t'
        file_path = os.path.join(output_dir, base_file_name + '.tsv.gz')

    with gzip.open(file_path, 'wt', encoding='utf-16-le') as out_file:

        if using_context:
            all_columns = contextual_columns + columns_to_download
        else:
            all_columns = columns_to_download

        header_line = separator.join([format_cell(col['label']) for col in all_columns])
        out_file.write(header_line + '\n')

        es_conn = connections.get_connection()
        source = get_search_source(columns_to_download)

        scanner = scan(es_conn, index=index_name, scroll=u'1m', size=1000, request_timeout=60, query={
            "_source": source,
            "query": query
        })

        i = 0
        previous_percentage = 0
        total_items = es_conn.search(index=index_name, body={'query': query})['hits']['total']
        for doc_i in scanner:
            i += 1
            doc_source = doc_i['_source']

            dot_notation_getter = DotNotationGetter(doc_source)
            own_properties_to_get = [col['property_name'] for col in columns_to_download]

            own_values = [columns_parser.parse(dot_notation_getter.get_from_string(prop_name), index_name, prop_name)
                          for prop_name in own_properties_to_get]

            contextual_values = []
            if using_context:
                context_item = context.get(doc_i['_id'])
                if context_item is not None:
                    contextual_values = [str(context_item[col['property_name']]) for col in contextual_columns]
                else:
                    contextual_values = ['' for i in range(0, len(contextual_columns))]

            all_values = contextual_values + own_values
            item_line = separator.join([format_cell(v) for v in all_values])
            out_file.write(item_line + '\n')

            percentage = int((i / total_items) * 100)
            if percentage != previous_percentage:
                previous_percentage = percentage
                progress_function(percentage)

    return file_path, total_items


def write_sdf_file(query, base_file_name='compounds', output_dir=settings.DYNAMIC_DOWNLOADS_DIR):

    file_path = os.path.join(output_dir, base_file_name + '.sdf.gz')
    index_name = 'chembl_molecule'
    es_conn = connections.get_connection()
    count_query = query
    total_items = es_conn.search(index=index_name, body={'query': count_query})['hits']['total']

    with gzip.open(file_path, 'wt') as out_file:
        es_conn = connections.get_connection()
        scanner = scan(es_conn, index=index_name, scroll=u'1m', size=1000, request_timeout=60, query={
            "_source": ['_metadata.compound_generated.sdf_data'],
            "query": query
        })

        for doc_i in scanner:

            doc_source = doc_i['_source']
            dot_notation_getter = DotNotationGetter(doc_source)
            sdf_value = dot_notation_getter.get_from_string('_metadata.compound_generated.sdf_data')

            out_file.write(sdf_value)
            out_file.write('$$$$\n')

    return file_path, total_items

