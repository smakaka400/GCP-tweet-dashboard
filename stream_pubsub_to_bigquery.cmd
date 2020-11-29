@ECHO OFF
set GCS_BUCKET=tweets_dashboard_data
set PROJECT=tweets-dashboard-297018
set TOPIC_ID=live_tweets
set TOPIC=projects/%PROJECT%/topics/%TOPIC_ID%
set SUBSCRIPTION=projects/%PROJECT%/subscriptions/%TOPIC_ID%
set DATASET=tweets_data
set TABLE=tweets
set GOOGLE_APPLICATION_CREDENTIALS=GCP_creds.json

python beam_pubsub_to_bigquery.py --streaming --runner=DirectRunner --temp_location=gs://%GCS_BUCKET% --subscription=%SUBSCRIPTION% --projectId=%PROJECT% --datasetId=%DATASET% --tableId=%TABLE%