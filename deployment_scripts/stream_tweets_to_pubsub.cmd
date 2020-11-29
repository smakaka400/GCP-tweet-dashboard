@ECHO OFF
set GCS_BUCKET=tweets_dashboard_data
set PROJECT=tweets-dashboard-297018
set TOPIC_ID=live_tweets
set TOPIC=projects/%PROJECT%/topics/%TOPIC_ID%
set SUBSCRIPTION=projects/%PROJECT%/subscriptions/%TOPIC_ID%
set DATASET=tweets_data
set TABLE=tweets
set GOOGLE_APPLICATION_CREDENTIALS=../GCP_creds.json

python ../python_scripts/tweets_to_pubsub.py --projectId=%PROJECT% --topicId=%TOPIC_ID%
