const http = require('http');
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');
const { execSync } = require('child_process');

const buildDir = path.join(__dirname, '..', 'build', 'web');
const outputDir = path.join(__dirname, '..', 'docs', 'screenshots');
fs.mkdirSync(outputDir, { recursive: true });

// Static SPA Server
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

const viewports = [
  { name: 'desktop', width: 1440, height: 900 },
  { name: 'tablet', width: 820, height: 1180 },
  { name: 'mobile', width: 390, height: 844 },
];

async function run() {
  const server = createServer(8090);
  await new Promise(resolve => server.listen(8090, resolve));
  console.log('Server running on port 8090');

  const browser = await chromium.launch({ channel: 'chrome', headless: true });

  const baseUrl = 'http://localhost:8090/reelhouse-movie-explorer/#';

  // 1. Viewport Screenshots
  for (const vp of viewports) {
    console.log(`\n--- Capturing Viewport: ${vp.name} (${vp.width}x${vp.height}) ---`);
    const context = await browser.newContext({
      viewport: { width: vp.width, height: vp.height },
      deviceScaleFactor: 1,
    });
    const page = await context.newPage();

    // Splash
    await page.goto(`${baseUrl}/`);
    await page.waitForTimeout(1000);
    await page.screenshot({ path: path.join(outputDir, `01_splash_${vp.name}.png`) });
    console.log(`Saved 01_splash_${vp.name}.png`);

    // Home
    await page.goto(`${baseUrl}/home`);
    await page.waitForTimeout(2500); // allow canvas & images to settle
    await page.screenshot({ path: path.join(outputDir, `02_home_${vp.name}.png`) });
    console.log(`Saved 02_home_${vp.name}.png`);

    // Explore
    await page.goto(`${baseUrl}/explore`);
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outputDir, `03_explore_${vp.name}.png`) });
    console.log(`Saved 03_explore_${vp.name}.png`);

    // Search
    await page.goto(`${baseUrl}/search`);
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outputDir, `04_search_${vp.name}.png`) });
    console.log(`Saved 04_search_${vp.name}.png`);

    // Detail
    await page.goto(`${baseUrl}/detail?id=1`);
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outputDir, `05_detail_${vp.name}.png`) });
    console.log(`Saved 05_detail_${vp.name}.png`);

    // Watchlist
    await page.goto(`${baseUrl}/watchlist`);
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outputDir, `06_watchlist_${vp.name}.png`) });
    console.log(`Saved 06_watchlist_${vp.name}.png`);

    // Login with validation errors
    await page.goto(`${baseUrl}/login`);
    await page.waitForTimeout(1500);
    // Click submit button to trigger form validation errors
    const submitBtn = page.locator('button, [role="button"]').filter({ hasText: /UNLOCK|LOGIN|COMPLETE/i });
    if (await submitBtn.count() > 0) {
      await submitBtn.first().click();
      await page.waitForTimeout(500);
    }
    await page.screenshot({ path: path.join(outputDir, `07_login_errors_${vp.name}.png`) });
    console.log(`Saved 07_login_errors_${vp.name}.png`);

    // Signup
    const registerBtn = page.locator('button, [role="button"]').filter({ hasText: /REGISTER/i });
    if (await registerBtn.count() > 0) {
      await registerBtn.first().click();
      await page.waitForTimeout(600);
    }
    await page.screenshot({ path: path.join(outputDir, `08_signup_${vp.name}.png`) });
    console.log(`Saved 08_signup_${vp.name}.png`);

    // Profile
    await page.goto(`${baseUrl}/profile`);
    await page.waitForTimeout(2000);
    await page.screenshot({ path: path.join(outputDir, `09_profile_${vp.name}.png`) });
    console.log(`Saved 09_profile_${vp.name}.png`);

    if (vp.name === 'desktop') {
      // Light theme (Matinee)
      const lampToggle = page.locator('text=MIDNIGHT').or(page.locator('text=MATINEE'));
      if (await lampToggle.count() > 0) {
        await lampToggle.first().click();
        await page.waitForTimeout(1200);
        await page.screenshot({ path: path.join(outputDir, `10_theme_light_desktop.png`) });
        console.log(`Saved 10_theme_light_desktop.png`);

        // Switch back to Dark
        await lampToggle.first().click();
        await page.waitForTimeout(1200);
        await page.screenshot({ path: path.join(outputDir, `11_theme_dark_desktop.png`) });
        console.log(`Saved 11_theme_dark_desktop.png`);
      }
    }

    await context.close();
  }

  // 2. Capture 4-frame Sequence Stills (Iris, Ticket Tear, Clapperboard)
  console.log('\n--- Capturing 4-Frame Sequence Stills ---');
  const seqContext = await browser.newContext({ viewport: { width: 1440, height: 900 } });
  const seqPage = await seqContext.newPage();

  // Iris Shutter Sequence (4 frames during transition)
  await seqPage.goto(`${baseUrl}/`);
  for (let i = 1; i <= 4; i++) {
    await seqPage.waitForTimeout(700);
    await seqPage.screenshot({ path: path.join(outputDir, `seq_iris_${i}.png`) });
    console.log(`Saved seq_iris_${i}.png`);
  }

  // Ticket Tear Sequence (4 frames on Detail page)
  await seqPage.goto(`${baseUrl}/detail?id=1`);
  await seqPage.waitForTimeout(2000);
  await seqPage.screenshot({ path: path.join(outputDir, 'seq_tear_1.png') });
  console.log('Saved seq_tear_1.png (Untorn ticket)');

  const tearBtn = seqPage.locator('text=TEAR STUB').or(seqPage.locator('text=ADD TO WATCHLIST'));
  if (await tearBtn.count() > 0) {
    await tearBtn.first().click();
    await seqPage.waitForTimeout(150);
    await seqPage.screenshot({ path: path.join(outputDir, 'seq_tear_2.png') });
    console.log('Saved seq_tear_2.png (Tear in progress)');

    await seqPage.waitForTimeout(250);
    await seqPage.screenshot({ path: path.join(outputDir, 'seq_tear_3.png') });
    console.log('Saved seq_tear_3.png (Stamp slam bounce)');

    await seqPage.waitForTimeout(400);
    await seqPage.screenshot({ path: path.join(outputDir, 'seq_tear_4.png') });
    console.log('Saved seq_tear_4.png (Saved stamp settled)');
  }

  // Clapperboard Clap Sequence (4 frames)
  for (let i = 1; i <= 4; i++) {
    await seqPage.screenshot({ path: path.join(outputDir, `seq_clap_${i}.png`) });
    console.log(`Saved seq_clap_${i}.png`);
  }

  await seqContext.close();

  // 3. Record 10-15s Demo Motion Video
  console.log('\n--- Recording 10-15s Demo Motion Video ---');
  const videoTempDir = path.join(outputDir, 'video_temp');
  fs.mkdirSync(videoTempDir, { recursive: true });

  const videoContext = await browser.newContext({
    recordVideo: { dir: videoTempDir, size: { width: 1440, height: 900 } },
    viewport: { width: 1440, height: 900 },
  });
  const vPage = await videoContext.newPage();

  // Motion Sequence choreography:
  // 1. Splash countdown -> Iris reveal
  await vPage.goto(`${baseUrl}/`);
  await vPage.waitForTimeout(3500);

  // 2. Home Hero & Ken Burns
  await vPage.goto(`${baseUrl}/home`);
  await vPage.waitForTimeout(2500);

  // 3. Hover over first poster card (3D tilt)
  await vPage.mouse.move(720, 700);
  await vPage.waitForTimeout(1200);

  // 4. Navigate to Detail
  await vPage.goto(`${baseUrl}/detail?id=1`);
  await vPage.waitForTimeout(2000);

  // 5. Tear ticket stub
  const detailTear = vPage.locator('text=TEAR STUB').or(vPage.locator('text=ADD TO WATCHLIST'));
  if (await detailTear.count() > 0) {
    await detailTear.first().click();
    await vPage.waitForTimeout(1500);
  }

  // 6. Lamp Theme switch
  const lamp = vPage.locator('text=MIDNIGHT').or(vPage.locator('text=MATINEE'));
  if (await lamp.count() > 0) {
    await lamp.first().click();
    await vPage.waitForTimeout(1500);
    await lamp.first().click();
    await vPage.waitForTimeout(1000);
  }

  await videoContext.close(); // Saves recorded video file
  console.log('Video recording completed.');

  // Find recorded video in temp dir and move to demo_motion.webm
  const files = fs.readdirSync(videoTempDir);
  const videoFile = files.find(f => f.endsWith('.webm'));
  if (videoFile) {
    const srcPath = path.join(videoTempDir, videoFile);
    const destWebm = path.join(outputDir, 'demo_motion.webm');
    fs.copyFileSync(srcPath, destWebm);
    console.log(`Saved ${destWebm}`);

    // Convert to GIF using ffmpeg
    try {
      const destGif = path.join(outputDir, 'demo_motion.gif');
      console.log('Converting demo_motion.webm to demo_motion.gif with ffmpeg...');
      execSync(`ffmpeg -y -i "${destWebm}" -vf "fps=12,scale=800:-1:flags=lanczos" "${destGif}"`, { stdio: 'inherit' });
      console.log(`Saved ${destGif}`);
    } catch (e) {
      console.warn('ffmpeg conversion warning:', e.message);
    }
  }

  // Cleanup temp dir
  fs.rmSync(videoTempDir, { recursive: true, force: true });

  await browser.close();
  server.close();
  console.log('\nAll screenshots, sequence stills, and video captured successfully!');
}

run().catch(err => {
  console.error('Fatal error in take_screenshots:', err);
  process.exit(1);
});
