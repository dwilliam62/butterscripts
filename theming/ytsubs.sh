#!/usr/bin/env bash
# DESC: Fetch YouTube channel subscriber count using YouTube Data API v3
#
# YouTube Subscriber Count Fetcher
# Uses YouTube Data API v3 (official and reliable method)
# 
# Setup:
# 1. Get a YouTube Data API key from https://console.cloud.google.com/
# 2. Set your API key: export YOUTUBE_API_KEY="your-api-key"
# 3. Run: ./ytsubs.sh [channel_id]
#
# Example: ./ytsubs.sh UC2rUTe_XMx88LR3JLJwyutw

# Check if API key is set
if [ -z "$YOUTUBE_API_KEY" ]; then
    echo "Error: YOUTUBE_API_KEY environment variable not set" >&2
    echo "Get an API key from: https://console.cloud.google.com/" >&2
    exit 1
fi

# Use provided channel ID or default
CHANNEL_ID="${1:-UC2rUTe_XMx88LR3JLJwyutw}"

# Make API request
response=$(curl -s -f "https://www.googleapis.com/youtube/v3/channels?part=statistics&id=${CHANNEL_ID}&key=${YOUTUBE_API_KEY}")

# Check if request was successful
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch data from YouTube API" >&2
    exit 1
fi

# Extract subscriber count using jq (if available) or grep/sed
if command -v jq &> /dev/null; then
    subscriber_count=$(echo "$response" | jq -r '.items[0].statistics.subscriberCount // "0"')
else
    # Fallback for systems without jq
    subscriber_count=$(echo "$response" | grep -o '"subscriberCount": *"[0-9]*"' | sed 's/.*"subscriberCount": *"\([0-9]*\)".*/\1/')
fi

# Check if we got a valid count
if [ -z "$subscriber_count" ] || [ "$subscriber_count" = "0" ]; then
    echo "Error: Could not parse subscriber count" >&2
    echo "Response: $response" >&2
    exit 1
fi

# Format number with commas for readability
formatted_count=$(printf "%'d" "$subscriber_count" 2>/dev/null || echo "$subscriber_count")

# Output the count
echo "${formatted_count} subscribers"