#!/usr/bin/env node
// Check for AI-SDLC updates in background, write result to cache
// Called by SessionStart hook - runs once per session

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn } = require('child_process');

const homeDir = os.homedir();
const cwd = process.cwd();
const cacheDir = path.join(homeDir, '.claude', 'cache');
const cacheFile = path.join(cacheDir, 'sdlc-update-check.json');

// VERSION file locations (check project first, then global)
const projectVersionFile = path.join(cwd, '.claude', 'ai-sdlc', 'VERSION');
const globalVersionFile = path.join(homeDir, '.claude', 'ai-sdlc', 'VERSION');

// Ensure cache directory exists
if (!fs.existsSync(cacheDir)) {
  fs.mkdirSync(cacheDir, { recursive: true });
}

// Run check in background (spawn background process)
const child = spawn(process.execPath, ['-e', `
  const fs = require('fs');
  const https = require('https');

  const cacheFile = ${JSON.stringify(cacheFile)};
  const projectVersionFile = ${JSON.stringify(projectVersionFile)};
  const globalVersionFile = ${JSON.stringify(globalVersionFile)};

  // Check project directory first (local install), then global
  let installed = '0.0.0';
  try {
    if (fs.existsSync(projectVersionFile)) {
      installed = fs.readFileSync(projectVersionFile, 'utf8').trim();
    } else if (fs.existsSync(globalVersionFile)) {
      installed = fs.readFileSync(globalVersionFile, 'utf8').trim();
    }
  } catch (e) {}

  // Check GitHub for latest release
  const options = {
    hostname: 'api.github.com',
    path: '/repos/wico216/ai-sdlc/releases/latest',
    headers: { 'User-Agent': 'ai-sdlc-update-check' },
    timeout: 10000
  };

  const req = https.get(options, (res) => {
    let data = '';
    res.on('data', chunk => data += chunk);
    res.on('end', () => {
      let latest = null;
      try {
        const json = JSON.parse(data);
        if (json.tag_name) {
          latest = json.tag_name.replace(/^v/, '');
        }
      } catch (e) {}

      // If no releases yet, try raw VERSION file from main branch
      if (!latest) {
        const fallback = https.get({
          hostname: 'raw.githubusercontent.com',
          path: '/wico216/ai-sdlc/main/src/VERSION',
          headers: { 'User-Agent': 'ai-sdlc-update-check' },
          timeout: 10000
        }, (fRes) => {
          let fData = '';
          fRes.on('data', chunk => fData += chunk);
          fRes.on('end', () => {
            latest = fData.trim() || null;
            writeResult(installed, latest);
          });
        });
        fallback.on('error', () => writeResult(installed, null));
        return;
      }

      writeResult(installed, latest);
    });
  });

  req.on('error', () => writeResult(installed, null));

  function writeResult(installed, latest) {
    const result = {
      update_available: latest && installed !== latest && latest !== '404: Not Found',
      installed,
      latest: latest || 'unknown',
      checked: Math.floor(Date.now() / 1000)
    };
    fs.writeFileSync(cacheFile, JSON.stringify(result));
  }
`], {
  stdio: 'ignore',
  windowsHide: true
});

child.unref();
