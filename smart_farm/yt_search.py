import urllib.request
import re
import json

def get_kannada_videos():
    url = "https://www.youtube.com/results?search_query=profitable+kannada+farming+guide"
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    html = urllib.request.urlopen(req).read().decode('utf-8')
    
    match = re.search(r'var ytInitialData = ({.*?});</script>', html)
    if not match: return []
    data = json.loads(match.group(1))
    
    videos = []
    try:
        contents = data['contents']['twoColumnSearchResultsRenderer']['primaryContents']['sectionListRenderer']['contents'][0]['itemSectionRenderer']['contents']
        for item in contents:
            if 'videoRenderer' in item:
                vid = item['videoRenderer']['videoId']
                title = item['videoRenderer']['title']['runs'][0]['text']
                videos.append((vid, title))
    except Exception as e:
        print(e)
    
    return videos[:10]

with open('yt_ids.txt', 'w', encoding='utf-8') as f:
    for v in get_kannada_videos():
        f.write(f"{v[0]}||{v[1]}\n")
