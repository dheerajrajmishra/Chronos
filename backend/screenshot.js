const puppeteer = require('puppeteer');

(async () => {
  const browser = await puppeteer.launch({ headless: true });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 800 });

  // Navigate to Dashboard
  await page.goto('http://localhost:3000', { waitUntil: 'networkidle2' });
  await page.screenshot({ path: 'C:\\Users\\Hp\\.gemini\\antigravity\\brain\\01befc2a-0c3c-4602-85f0-48108f9535f3\\dashboard.png' });

  // Navigate to Requirement Input
  await page.goto('http://localhost:3000/#/requirement-input', { waitUntil: 'networkidle2' });
  await page.screenshot({ path: 'C:\\Users\\Hp\\.gemini\\antigravity\\brain\\01befc2a-0c3c-4602-85f0-48108f9535f3\\requirement_input.png' });

  // Navigate to Approval Gate
  await page.goto('http://localhost:3000/#/approval-gate', { waitUntil: 'networkidle2' });
  await page.screenshot({ path: 'C:\\Users\\Hp\\.gemini\\antigravity\\brain\\01befc2a-0c3c-4602-85f0-48108f9535f3\\approval_gate.png' });

  await browser.close();
})();
