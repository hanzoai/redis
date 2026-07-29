# Hanzo Memory (Redis Fork)

## Overview

**Hanzo Memory** is a fork of Redis optimized for the Hanzo AI platform's caching and real-time needs. It provides:

- **Session Storage** - User sessions, API keys
- **Rate Limiting** - Token bucket, sliding window
- **Real-time PubSub** - WebSocket notifications
- **Caching Layer** - LLM responses, embeddings
- **Queue Management** - Background job processing

Repository: https://github.com/hanzoai/redis

## Quick Start

```bash
# Start Redis with Hanzo config
cd hanzo
docker compose up -d

# Connect to Redis
docker exec -it hanzo-redis redis-cli

# Test connection
PING
```

## Hanzo Modules

Pre-configured modules:
- **RedisJSON** - Native JSON support
- **RediSearch** - Full-text search
- **RedisTimeSeries** - Time-series data
- **RedisBloom** - Probabilistic data structures

## Key Namespaces

```
hanzo:session:{session_id}     - User sessions
hanzo:api_key:{key_hash}       - API key data
hanzo:rate:{org_id}:{endpoint} - Rate limit counters
hanzo:cache:llm:{hash}         - LLM response cache
hanzo:cache:embed:{hash}       - Embedding cache
hanzo:queue:{queue_name}       - Job queues
hanzo:pubsub:{channel}         - Real-time channels
```

## Integration Points

### With hanzo/console (LangFuse fork)

Console uses Redis for caching:
```env
REDIS_URL=redis://localhost:6379
```

### With hanzo/llm (LiteLLM fork)

LLM Gateway caches responses:
```env
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=hanzo_dev
```

## Syncing with Upstream

```bash
# Fetch upstream changes
git fetch upstream

# Merge upstream unstable
git merge upstream/unstable

# Keep hanzo/ directory
git checkout --ours hanzo/

git push origin unstable
```

## Performance Tuning

### Memory Management

```
# redis.conf
maxmemory 2gb
maxmemory-policy allkeys-lru

# Persistence
save 900 1
save 300 10
save 60 10000
appendonly yes
appendfsync everysec
```

### Client Limits

```
# Connection limits
maxclients 10000
timeout 300

# Slow log
slowlog-log-slower-than 10000
slowlog-max-len 128
```

## Docker Compose

See `hanzo/compose.yml` for local development with:
- Redis Stack (includes modules)
- RedisInsight for management
- Prometheus metrics export

## Caching Patterns

### LLM Response Caching

```python
# Cache key: sha256(model + prompt + params)
cache_key = f"hanzo:cache:llm:{hash}"
ttl = 3600  # 1 hour

# Set with JSON
redis.json().set(cache_key, "$", response)
redis.expire(cache_key, ttl)
```

### Rate Limiting (Sliding Window)

```python
# Key: hanzo:rate:{org_id}:{endpoint}
key = f"hanzo:rate:{org_id}:chat_completions"
window_seconds = 60
max_requests = 100

# Lua script for atomic operation
```

### Session Storage

```python
# Key: hanzo:session:{session_id}
session_key = f"hanzo:session:{session_id}"
ttl = 86400  # 24 hours

redis.json().set(session_key, "$", session_data)
redis.expire(session_key, ttl)
```

## Related Repositories

- **hanzo/console** - AI observability (caching)
- **hanzo/llm** - LLM Gateway (response cache)
- **hanzo/datastore** - ClickHouse fork (OLAP)
- **hanzo/relational** - PostgreSQL fork (OLTP)
