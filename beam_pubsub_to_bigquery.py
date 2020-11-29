from __future__ import absolute_import
import json
import apache_beam as beam
from apache_beam.transforms import window
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.io.gcp.bigquery_tools import parse_table_schema_from_json


def make_schema():
    schema_str = '{"fields": ' + json.dumps(json.load(open("table_schema.json"))) + '}'
    table_schema = parse_table_schema_from_json(schema_str)
    return table_schema


additional_bq_parameters = {'timePartitioning': {'type': 'DAY', 'field': 'timestamp'}}


class ParseTweets(beam.DoFn):
    def process(self, element):
        tweet = json.loads(element.decode('utf-8'))
        yield tweet


def run(argv=None):
    class MyOptions(PipelineOptions):
        @classmethod
        def _add_argparse_args(cls, parser):
            parser.add_argument(
                '--subscription',
                dest='subscription',
                help='Pub/Sub pull subscription',
                required=True,
                type=str
            )

            parser.add_argument(
                '--projectId',
                dest='projectId',
                help='project ID',
                required=True,
                type=str
            )

            parser.add_argument(
                '--datasetId',
                dest='datasetId',
                help='bigquery dataset name',
                required=True,
                type=str
            )

            parser.add_argument(
                '--tableId',
                dest='tableId',
                help='bigquery table name',
                required=True,
                type=str
            )

    options = MyOptions(flags=argv)
    with beam.Pipeline(options=options) as p:
        (p | "Read input from PubSub" >>
         beam.io.gcp.pubsub.ReadFromPubSub(subscription=options.subscription) |
         "Parse tweet" >> beam.ParDo(ParseTweets()) |
         "Windowing for writes" >> beam.WindowInto(
                    window.FixedWindows(size=60)
                ) |
         "File load to BigQuery" >> beam.io.gcp.bigquery.WriteToBigQuery(
                    project=options.projectId,
                    dataset=options.datasetId,
                    table=options.tableId,
                    schema=make_schema(),
                    additional_bq_parameters=additional_bq_parameters,
                    method="FILE_LOADS",
                    triggering_frequency=60,
                    write_disposition=beam.io.gcp.bigquery.BigQueryDisposition.WRITE_APPEND,
                    create_disposition=beam.io.gcp.bigquery.BigQueryDisposition.CREATE_NEVER)
        )


if __name__ == '__main__':
    run()
