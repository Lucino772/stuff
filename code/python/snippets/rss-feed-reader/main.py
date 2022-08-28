import feedparser
import sys
import time

# Fix error with ssl in feedparser
import ssl
if hasattr(ssl, '_create_unverified_context'):
    ssl._create_default_https_context = ssl._create_unverified_context

def main():
    args = sys.argv[1:]
    
    url, timeout = None, 10
    if len(args) == 0:
        print("Usage: ./main.py <url> [<timeout>]")
        exit(1)

    if len(args) >= 1:
        url = args[0]
    
    if len(args) == 2:
        timeout = int(args[1])

    try:
        last_modified, etag = None, None
        while True:
            feed = feedparser.parse(url, modified=last_modified, etag=etag)
            last_modified = getattr(feed, 'modified', None)
            etag = getattr(feed, 'etag', None)
            if feed.status == 200:
                print(f'New Update ! Feed {feed.feed.title} at {feed.feed.updated}')
                print(f'Title "{feed.entries[0].title}" view at {feed.entries[0].link} (Published at {feed.entries[0].published})')
            time.sleep(timeout)
    except KeyboardInterrupt:
        pass

if __name__ == "__main__":
    main()