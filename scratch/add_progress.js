const fs = require('fs');
const path = require('path');

const stagesDir = path.join(__dirname, '../frontend/lib/screens/stages');
const files = fs.readdirSync(stagesDir).filter(f => f.endsWith('.dart'));

for (const file of files) {
  const filePath = path.join(stagesDir, file);
  let content = fs.readFileSync(filePath, 'utf8');
  let changed = false;

  // 1. Add isLoading parameter to _buildGradientButton
  if (content.includes('_buildGradientButton(') && !content.includes('bool isLoading = false')) {
    content = content.replace(
      /Widget _buildGradientButton\(\{(.*?)\}\) \{/,
      'Widget _buildGradientButton({$1, bool isLoading = false}) {'
    );
    // Replace the ElevatedButton.icon to support isLoading
    const oldIcon = /icon: Icon\(icon, size: 16, color: Colors\.white\),/;
    const newIcon = `icon: isLoading
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Icon(icon, size: 16, color: Colors.white),`;
    content = content.replace(oldIcon, newIcon);
    
    // Change onPressed to disable if loading
    content = content.replace(
      /onPressed: onPressed,/,
      'onPressed: isLoading ? () {} : onPressed,'
    );
    changed = true;
  }

  // 2. Add bool _isApproving = false; to the State
  if (!content.includes('bool _isApproving = false;')) {
    content = content.replace(
      /class _Stage.*State extends State<.*> \{/,
      `$&
  bool _isApproving = false;`
    );
    changed = true;
  }

  // 3. Update 'Approve & Confirm' button
  if (content.includes('label: \'Approve & Confirm\',')) {
    content = content.replace(
      /await controller\.updateWorkflowStage\(.*?\);/g,
      `setState(() => _isApproving = true);
                    $&
                    setState(() => _isApproving = false);`
    );
    
    content = content.replace(
      /label: 'Approve & Confirm',/g,
      `isLoading: _isApproving,
                  label: 'Approve & Confirm',`
    );
  }

  // Update 'Save & Approve' button
  if (content.includes('label: \'Save & Approve\',')) {
    content = content.replace(
      /label: 'Save & Approve',/g,
      `isLoading: _isApproving,
                  label: 'Save & Approve',`
    );
  }

  // Update "Generate" button
  if (content.includes('isGenerating ? \'Generating...\'')) {
    content = content.replace(
      /label: isGenerating \? 'Generating\.\.\.' :/,
      `isLoading: isGenerating,
                label: isGenerating ? 'Generating...' :`
    );
  }
  
  if (content.includes('isProcessing ? \'Generating...\'')) {
    content = content.replace(
      /label: isProcessing \? 'Generating\.\.\.' :/,
      `isLoading: isProcessing,
                label: isProcessing ? 'Generating...' :`
    );
  }

  if (changed) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log('Updated ' + file);
  }
}
