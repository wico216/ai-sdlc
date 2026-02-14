// AI-SDLC afterFileEdit hook — track audit trail modifications
const fs = require('fs');

let input = '';
process.stdin.on('data', (chunk) => { input += chunk; });
process.stdin.on('end', () => {
    try {
        const payload = JSON.parse(input);
        if (payload.filePath && payload.filePath.includes('.aidlc/audit.md')) {
            const content = fs.readFileSync(payload.filePath, 'utf8');
            const entries = content.split('\n').filter(l => l.startsWith('### Entry'));
            const last = entries[entries.length - 1];
            if (last) {
                console.log(JSON.stringify({ message: `Audit: ${last}` }));
            }
        }
    } catch (e) {
        // Silently ignore parse errors — hook should never block
    }
});
