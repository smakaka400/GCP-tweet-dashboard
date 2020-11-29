@ECHO OFF
set GCS_BUCKET=tweets_dashboard_data
set PROJECT=tweets-dashboard-297018
set TOPIC_ID=live_tweets
set TOPIC=projects/%PROJECT%/topics/%TOPIC_ID%
set SUBSCRIPTION=projects/%PROJECT%/subscriptions/%TOPIC_ID%
set DATASET=tweets_data
set TABLE=tweets
set GOOGLE_APPLICATION_CREDENTIALS=../GCP_creds.json

ECHO ========================================
ECHO DELETING PUBSUB RESOURCES
ECHO ========================================
cmd /c gcloud pubsub subscriptions delete %SUBSCRIPTION%
cmd /c gcloud pubsub topics delete %TOPIC%

ECHO ========================================
ECHO DELETING GCS BUCKET
ECHO ========================================
cmd /c gsutil -m rm -r gs://%GCS_BUCKET%

ECHO ========================================
ECHO DELETING BIGQUERY DATASET
ECHO ========================================
cmd /c bq rm -r -f %PROJECT%:%DATASET%