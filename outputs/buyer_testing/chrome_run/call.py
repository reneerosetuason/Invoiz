from pathlib import Path
import datetime
import json
import sys
import requests

sys.stdout.reconfigure(encoding='utf-8')
code = sys.stdin.read()
result = requests.post('http://127.0.0.1:8766',json={'code':code},timeout=90).json()
with (Path(__file__).resolve().parent/'browser_actions.jsonl').open('a',encoding='utf-8') as f:
    f.write(json.dumps({'at':datetime.datetime.now().isoformat(),'action':code,'result':result},ensure_ascii=False)+'\n')
print(json.dumps(result,ensure_ascii=False))
