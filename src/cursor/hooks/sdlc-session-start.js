// AI-SDLC session start hook
// Outputs framework status message
const fs = require('fs');
const path = require('path');

const stateFile = path.join(process.cwd(), '.aidlc', 'STATE.md');
if (fs.existsSync(stateFile)) {
    const content = fs.readFileSync(stateFile, 'utf8');
    const phaseMatch = content.match(/Current Phase: (.+)/);
    const phase = phaseMatch ? phaseMatch[1] : 'unknown';
    console.log(JSON.stringify({
        message: `AI-SDLC active — ${phase}. Use /sdlc-help for commands.`
    }));
} else {
    console.log(JSON.stringify({
        message: 'AI-SDLC framework available. Use /sdlc-new-project to start.'
    }));
}
