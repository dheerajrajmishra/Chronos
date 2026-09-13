const fs = require('fs');
const path = require('path');

const files = [
    { name: 'stage1_brd.dart', stage: 1 },
    { name: 'stage3_tech_doc.dart', stage: 3 },
    { name: 'stage4_code.dart', stage: 4 }
];

const basePath = path.join(__dirname, '..', '..', 'frontend', 'lib', 'screens', 'stages');

files.forEach(f => {
    const filePath = path.join(basePath, f.name);
    let content = fs.readFileSync(filePath, 'utf8');
    
    // Look for the payload definition
    // Usually it looks like:
    // final payload = {
    //   'requirement': feature.baseRequirement,
    
    if (content.includes("final payload = {") && !content.includes("'targetStage':")) {
        content = content.replace(
            "final payload = {",
            `final payload = {\n        'targetStage': ${f.stage},`
        );
        fs.writeFileSync(filePath, content);
        console.log(`Updated ${f.name}`);
    } else {
        console.log(`Skipped ${f.name} (payload not found or already has targetStage)`);
    }
});
