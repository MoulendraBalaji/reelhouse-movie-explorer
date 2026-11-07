const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');
const http = require('http');

const buildDir = path.join(__dirname, '..', 'build', 'web');
const outputDir = path.join(__dirname, '..', 'docs', 'screenshots');

function createServer(port) {
  return http.createServer((req, res) => {
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
      const indexPath = path.join(buildDir, 'index.html');
      res.writeHead(200, { 'Content-Type': 'text/html' });
      fs.createReadStream(indexPath).pipe(res);
    }
  });
}

async function run() {
  const server = createServer(8092);
  await new Promise(resolve => server.listen(8092, resolve));

  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const baseUrl = 'http://localhost:8092/reelhouse-movie-explorer/#';

  await page.goto(`${baseUrl}/home`);
  await page.waitForTimeout(2500);

  // In the top app bar on Desktop (width 1440), the LampThemeSwitch is near the right edge:
  // Layout: Logo ... Nav Links ... Offline badge ... LampThemeSwitch ... Watchlist icon ... Profile icon
  // In 1440px width, LampThemeSwitch is roughly around x=1260 to 1340, y=32
  // Let's click at x=1300, y=32
  console.log('Clicking lamp theme toggle...');
  await page.mouse.click(1300, 32);
  await page.waitForTimeout(1500);

  await page.screenshot({ path: path.join(outputDir, '10_theme_light_desktop.png') });
  console.log('Saved 10_theme_light_desktop.png');

  // Click again to toggle back to Midnight dark
  await page.mouse.click(1300, 32);
  await page.waitForTimeout(1500);

  await page.screenshot({ path: path.join(outputDir, '11_theme_dark_desktop.png') });
  console.log('Saved 11_theme_dark_desktop.png');

  await browser.close();
  server.close();
  console.log('Theme capture complete!');
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
