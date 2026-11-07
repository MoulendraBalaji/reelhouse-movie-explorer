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
  const server = createServer(8091);
  await new Promise(resolve => server.listen(8091, resolve));
  console.log('Server running on 8091');

  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const context = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const page = await context.newPage();

  const baseUrl = 'http://localhost:8091/reelhouse-movie-explorer/#';

  // 1. DETAIL SCREEN - Ticket Tear sequence
  console.log('Navigating to detail screen...');
  await page.goto(`${baseUrl}/detail?id=1`);
  await page.waitForTimeout(2500);

  // Scroll down to reveal the ticket stub
  await page.mouse.wheel(0, 750);
  await page.waitForTimeout(1000);

  // Frame 1: Untorn
  await page.screenshot({ path: path.join(outputDir, 'seq_tear_1.png') });
  console.log('Saved seq_tear_1.png');

  // Find position or click the ticket stub area (roughly center-right of content, around x=720, y=550)
  // Let's click the stub: In desktop 1440, the content is centered ~ 450 to 950 width, y ~ 500-650
  await page.mouse.click(800, 580);
  
  // Frame 2: Tear in progress
  await page.waitForTimeout(180);
  await page.screenshot({ path: path.join(outputDir, 'seq_tear_2.png') });
  console.log('Saved seq_tear_2.png');

  // Frame 3: Stamp slam
  await page.waitForTimeout(220);
  await page.screenshot({ path: path.join(outputDir, 'seq_tear_3.png') });
  console.log('Saved seq_tear_3.png');

  // Frame 4: Settled saved state
  await page.waitForTimeout(400);
  await page.screenshot({ path: path.join(outputDir, 'seq_tear_4.png') });
  console.log('Saved seq_tear_4.png');

  // 2. CLAPPERBOARD SEQUENCE
  // Scroll further down to the review clapperboard form
  await page.mouse.wheel(0, 500);
  await page.waitForTimeout(800);

  // Frame 1: Open clapperboard
  await page.screenshot({ path: path.join(outputDir, 'seq_clap_1.png') });
  console.log('Saved seq_clap_1.png');

  // Click submit review button area (bottom center)
  await page.mouse.click(720, 750);

  // Frame 2: Snapping shut
  await page.waitForTimeout(120);
  await page.screenshot({ path: path.join(outputDir, 'seq_clap_2.png') });
  console.log('Saved seq_clap_2.png');

  // Frame 3: Impact bounce
  await page.waitForTimeout(180);
  await page.screenshot({ path: path.join(outputDir, 'seq_clap_3.png') });
  console.log('Saved seq_clap_3.png');

  // Frame 4: Settled shut with verification badge
  await page.waitForTimeout(400);
  await page.screenshot({ path: path.join(outputDir, 'seq_clap_4.png') });
  console.log('Saved seq_clap_4.png');

  await browser.close();
  server.close();
  console.log('Sequence capture complete!');
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
