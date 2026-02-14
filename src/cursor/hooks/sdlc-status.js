// AI-SDLC stop hook — show current phase on completion
const fs = require('fs');
const path = require('path');

const stateFile = path.join(process.cwd(), '.aidlc', 'STATE.md');
if (fs.existsSync(stateFile)) {
    const content = fs.readFileSync(stateFile, 'utf8');
    const phaseMatch = content.match(/Current Phase: (.+)/);
    if (phaseMatch) {
        console.log(JSON.stringify({ message: `AI-SDLC: ${phaseMatch[1]}` }));
    }
}
