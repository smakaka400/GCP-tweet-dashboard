# GCP-tweet-dashboard

This repo contains code for streaming filtered tweets in (near) real-time to a dashboard, using resources on Google Cloud Platform.

The Data Studio dashboard can be found here:

https://datastudio.google.com/reporting/36f30b15-8113-4e38-a2d6-4eabd3017555

The repo is organised as follows:
* `notebooks` contains a small demo notebook for obtaining tweets in different ways from Twitter.
* `python_scripts` contains python scripts for streaming live tweets to Cloud Pub/Sub and for streaming data from Cloud Pub/Sub to BigQuery.
* `deployment_scripts` contains scripts for creating and deleting the required GCP resources, as well as running the aforementioned python scripts. 

## Architecture

The aim was to use Data Studio in order to display the tweets. BigQuery is a convenient database for storing data and can connect live to Data Studio. Obtaining live tweets is easily done through the use of the python library [Tweepy](https://www.tweepy.org/), what remained was to thus process and stream tweets using this library into BigQuery. The architecture decided was as follows:
1. Stream tweets to a Cloud Pub/Sub topic and corresponding subscription
2. Pull messages from the Cloud Pub/Sub subscription into Cloud Dataflow
3. Process messages in Cloud Dataflow and stream into BigQuery
4. Connect Data Studio to BigQuery to view the tweets

The architecture diagram is as follows:

![alt text](https://github.com/smakaka400/GCP-tweet-dashboard/raw/main/architecture_diagram.PNG?raw=true "Architecture Diagram")

## Considerations

The main consideration to take into account was the requirement to stay within Google Cloud's [free tier](https://cloud.google.com/free). The free tier of each tool is as follows:
* Cloud Pub/Sub allows 10GB of messages per month
* Cloud Dataflow uses Compute Engine resources, the only Compute Engine resource that is free is not compatible with Dataflow
* BigQuery allows 1TB of queries and 10GB of storage per month. Loading data into BigQuery is free as long as it is batch loaded and not streamed
* Data Studio is a completely free service

Therefore, in order to remain within the free tier, we had to use the free open-source version of Cloud Dataflow, namely Apache Beam. Fortunately with this tool we could still batch load data into BigQuery, instead of streaming immediately.
The loading frequency was set at once a minute in order to stay within the quota of 1500 file loads per table per day.
Note that this method also requires a Cloud Storage bucket to exist in order to store the files that are loaded into BigQuery. Cloud Storage provides 5GB-months of standard storage if the data is in a specific US location. For this project the public data was stored in the US.

The size of each tweet is on the order of bytes, and filtered tweets appeared to arrive every few seconds, so it is feasible to leave the pipeline running.


## Prerequisites

In order to deploy the resources there are a number of prerequisites. 

Firstly, you will need a Google Cloud Platform account, and you will need to download the gcloud sdk and store authentication credentials in the base directory of the repo.

You will also need to sign up for a Twitter Developer account via the following link: https://developer.twitter.com/en/apply-for-access
Once you have an account you will need to store the authorisation credentials in the base directory of the repo. 

You will need Python3.7+ installed on your machine, along with the libraries detailed in requirements.txt.

Finally, this repo assumes that commands are run from a machine running Windows. For machines running MacOS/Linux the deployment scripts will have to be refactored accordingly.

## Deployment

In order to deploy the pipeline, first ensure you have met the prerequisites detailed above. Then navigate to the deployment_scripts folder.

Run `create_gcp_resources.cmd` in order to create the required GCP resources. Then run `stream_tweets_to_pubsub.cmd` to stream filtered tweets to PubSub, and run `stream_pubsub_to_bigquery.cmd` to stream from PubSub into BigQuery.

Navigate to the dashboard in order to see the latest tweets with the hashtag #london. The dashboard automatically refreshes the data every 15 minutes, or you can also hit refresh to refresh the data immediately.

To tear down the deployment, run `delete_gcp_resources.cmd`. This will delete the GCP resources, and by extension stop the streaming pipelines. The dashboard will still remain, but will not show anything. 
If you want to stop only the pipelines but maintain the resources, you will have to interrupt the processes on the command line.

## Improvements

Improvements that could be made in future iterations include:
* Updating formatting of tweets and visuals of the dashboard
* Streamlining the deployment process
* Limiting the amount of data stored in BigQuery and Cloud Storage