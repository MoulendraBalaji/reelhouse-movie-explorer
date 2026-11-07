const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const buildDir = path.join(__dirname, '..', 'build', 'web');

// Simple static file server supporting /reelhouse-movie-explorer/
const server = http.createServer((req, res) => {
  let reqPath = req.url.split('?')[0];
  if (reqPath.startsWith('/reelhouse-movie-explorer/')) {
    reqPath = reqPath.replace('/reelhouse-movie-explorer/', '/');
  }
  if (reqPath === '/' || reqPath === '') reqPath = '/index.html';

  const filePath = path.join(buildDir, reqPath);
  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    let contentType = 'text/html';
    if (filePath.endsWith('.js')) contentType = 'application/javascript';
    if (filePath.endsWith('.json')) contentType = 'application/json';
    if (filePath.endsWith('.css')) contentType = 'text/css';
    if (filePath.endsWith('.png')) contentType = 'image/png';
    if (filePath.endsWith('.wasm')) contentType = 'application/wasm';
    if (filePath.endsWith('.ttf')) contentType = 'font/ttf';

    res.writeHead(200, { 'Content-Type': contentType });
    fs.createReadStream(filePath).pipe(res);
  } else {
    // SPA fallback
    const indexPath = path.join(buildDir, 'index.html');
    res.writeHead(200, { 'Content-Type': 'text/html' });
    fs.createReadStream(indexPath).pipe(res);
  }
});

server.listen(8088, async () => {
  console.log('Local test server listening on http://localhost:8088');
  try {
    const browser = await chromium.launch({ channel: 'chrome', headless: true });
    const page = await browser.newPage();
    await page.goto('http://localhost:8088/reelhouse-movie-explorer/#/home', { waitUntil: 'networkidle' });
    // Wait for Flutter canvas to render
    await page.waitForTimeout(3000);
    const title = await page.title();
    console.log('Page title loaded:', title);
    await page.screenshot({ path: path.join(__dirname, '..', 'docs', 'screenshots', 'test_local.png') });
    console.log('Test screenshot saved!');
    await browser.close();
  } catch (err) {
    console.error('Error testing:', err);
  } finally {
    server.close();
  }
});
