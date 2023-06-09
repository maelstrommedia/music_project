from flask_cors import CORS
from flask import Flask, jsonify
from redis.sentinel import Sentinel
import logging
import redis
from flask_cors import CORS

def connect_to_redis():
    r = redis.Redis(
        host='localhost',
        port=6379, 
        password='MyStr0ngP@ssw0rd')

cache_master_name = 'mymaster'
cache_password = 'test'
cache_sentinel_string = "redis-sentinel-0:7000,redis-sentinel-1:7000,redis-sentinel-2:7000"
cache_sentinels = [(item.split(':')[0], int(item.split(':')[1])) for item in cache_sentinel_string.split(',')]
cache_sentinel_object = Sentinel(cache_sentinels, socket_timeout=0.1)
cache_master = cache_sentinel_object.master_for(cache_master_name,password = cache_password, socket_timeout=0.1)

app = Flask(__name__)
CORS(app)

@app.route('/music/ui/api/hits')
def hello():
    cache_master.incr('hits')
    hits = cache_master.get('hits')
    app.logger.info('Page hit: %s', hits.decode())
    return jsonify({"message" : hits.decode()}),200


@app.route('/music/ui/api/health')
def health():
    return jsonify({}),200


@app.route('/music/ui/api/cache')
def cache_index():
    r = connect_to_redis()
    if r.ping():
        return 'Connected to Redis', 200
    else:
        return 'Failed to connect to Redis', 500
    


handler = logging.FileHandler('flask.log')
handler.setLevel(logging.INFO)
app.logger.addHandler(handler)

if __name__ == "__main__":
    app.run(host='0.0.0.0',debug=True)