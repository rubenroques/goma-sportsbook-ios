const sketch = require('sketch');
const fs = require('@skpm/fs');

export default function() {
  const document = sketch.getSelectedDocument();
  const textLayers = document.selectedLayers.layers.filter(layer => 
layer.type === 'Text');

  let text = '';
  textLayers.forEach(layer => {
    text += layer.text + '\n';
  });

  try {
    fs.writeFileSync(`${document.path}.txt`, text);
    sketch.UI.message(`Text extracted to ${document.path}.txt`);
  } catch (err) {
    console.error(err);
    sketch.UI.message(`Error extracting text: ${err}`);
  }
};

