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
ECHO CREATING GCP RESOURCES...
ECHO ========================================

ECHO ========================================
ECHO CREATING PUBSUB RESOURCES
ECHO ========================================
cmd /c gcloud pubsub topics create %TOPIC_ID% --message-storage-policy-allowed-regions=us-west1
cmd /c gcloud pubsub subscriptions create %TOPIC_ID% --topic=%TOPIC% --expiration-period=7d

ECHO ========================================
ECHO CREATING GCS BUCKET
ECHO ========================================
cmd /c gsutil mb -p %PROJECT% -l us-west1 gs://%GCS_BUCKET%

ECHO ========================================
ECHO CREATING BIGQUERY DATASET AND TABLE
ECHO ========================================
cmd /c bq --location=us-west1 mk --dataset %PROJECT%:%DATASET%
cmd /c bq mk --table --schema table_schema.json --time_partitioning_field timestamp --time_partitioning_type DAY %PROJECT%:%DATASET%.%TABLE%

ECHO ========================================
ECHO GCP RESOURCES CREATED.
ECHO ========================================

ECHO ========================================
ECHO DEPLOYING PIPELINE...
ECHO ========================================
START python ../python_scripts/tweets_to_pubsub.py --projectId=%PROJECT% --topicId=%TOPIC_ID%
START python ../python_scripts/beam_pubsub_to_bigquery.py --streaming --runner=DirectRunner --temp_location=gs://%GCS_BUCKET% --subscription=%SUBSCRIPTION% --projectId=%PROJECT% --datasetId=%DATASET% --tableId=%TABLE%
ECHO ========================================
ECHO PIPELINE DEPLOYED.
ECHO ========================================