const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require(path.join(process.env.LOCALAPPDATA, 'npm-cache/_npx/e41f203b7505f1fb/node_modules/playwright'));
const folder = __dirname;
const fixtures = JSON.parse(fs.readFileSync(path.join(folder, 'fixture_state.json'), 'utf8'));
const AsyncFunction = Object.getPrototypeOf(async function(){}).constructor;

(async () => {
  fs.mkdirSync(path.join(folder, 'screenshots'), { recursive: true });
  const browser = await chromium.launch({ executablePath:path.join(process.env.LOCALAPPDATA,'Google/Chrome/Application/chrome.exe'), headless:true });
  const context = await browser.newContext({ viewport:{width:480,height:1000}, deviceScaleFactor:1 });
  const page = await context.newPage();
  const events = [];
  page.on('pageerror', e => events.push({type:'pageerror',message:String(e)}));
  page.on('response', async r => {
    if (r.url().includes('127.0.0.1:8000/api/')) {
      const item={type:'api',method:r.request().method(),url:r.url(),status:r.status()};
      if (!/\/(login|me)(\?|$)/.test(r.url())) {
        try { const data=await r.json(); item.message=data.message; } catch {}
      }
      events.push(item);
      fs.writeFileSync(path.join(folder,'network_events.json'), JSON.stringify(events,null,2));
    }
  });
  const shot = async label => {
    const file=path.join(folder,'screenshots',label.replace(/[^a-zA-Z0-9_-]/g,'_')+'.png');
    await page.screenshot({path:file}); return file;
  };
  const dump = async () => ({url:page.url(), text:await page.locator('body').innerText(), inputs:await page.locator('input,textarea').evaluateAll(xs=>xs.map(x=>({tag:x.tagName,label:x.getAttribute('aria-label'),type:x.type,value:x.value}))), events:events.slice(-6)});
  const server = http.createServer(async (req,res)=>{
    if(req.method!=='POST'){res.writeHead(200);res.end('Chrome app test controller');return;}
    let data='';for await(const chunk of req)data+=chunk;
    try {
      const {code}=JSON.parse(data);
      const value=await new AsyncFunction('page','context','browser','fixtures','shot','dump','events','folder',code)(page,context,browser,fixtures,shot,dump,events,folder);
      res.writeHead(200,{'Content-Type':'application/json'});res.end(JSON.stringify({ok:true,value}));
    } catch(e) {res.writeHead(200,{'Content-Type':'application/json'});res.end(JSON.stringify({ok:false,error:String(e),stack:e.stack}));}
  });
  server.listen(8766,'127.0.0.1',()=>console.log('Chrome controller ready at 127.0.0.1:8766'));
  process.on('SIGINT',async()=>{await browser.close();server.close();process.exit();});
})().catch(e=>{console.error(e);process.exit(1);});
