import tweepy
import json
from google.cloud import pubsub_v1

# Set up PubSub client
project_id = "tweets-dashboard-297018"
topic_id = "live_tweets"
publisher = pubsub_v1.PublisherClient()
topic_path = publisher.topic_path(project_id, topic_id)

# Variables that contains the credentials to access Twitter API
with open('tweet_auth.json') as json_file:
    auth_creds = json.load(json_file)

CONSUMER_KEY = auth_creds['consumer_key']
CONSUMER_SECRET = auth_creds['consumer_secret']
ACCESS_TOKEN = auth_creds['access_token']
ACCESS_SECRET = auth_creds['access_token_secret']

# Setup access to Twitter API
def connect_to_twitter_OAuth():
    auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
    auth.set_access_token(ACCESS_TOKEN, ACCESS_SECRET)
    api = tweepy.API(auth)
    return api


# Create API object
api = connect_to_twitter_OAuth()


class StreamListener(tweepy.StreamListener):
    def on_status(self, status):
        payload = {}
        payload["username"] = status.user.screen_name
        payload["timestamp"] = str(status.created_at)
        if hasattr(status, "retweeted_status"):  # Check if Retweet
            try:
                payload["text"] = status.retweeted_status.extended_tweet["full_text"]
            except AttributeError:
                payload["text"] = status.retweeted_status.text
        else:
            try:
                payload["text"] = status.extended_tweet["full_text"]
            except AttributeError:
                payload["text"] = status.text
        stream = publisher.publish(topic_path, json.dumps(payload).encode('utf-8'))
        print(stream.result())

    def on_error(self, status_code):
        if status_code == 420:
            # returning False in on_error disconnects the stream
            return False


streamListener = StreamListener()
stream = tweepy.Stream(auth=api.auth, listener=streamListener, tweet_mode='extended')

tags = ["#london"]

stream.filter(track=tags)
