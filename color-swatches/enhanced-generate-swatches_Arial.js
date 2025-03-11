const { createCanvas, registerFont } = require('canvas');
const fs = require('fs');
const namer = require('color-namer');
const { exec } = require('child_process');
const path = require('path');

// Configuration
const CONFIG = {
  outputDir: '/Users/data/Scripts/tmp/color-swatches/',
  fontPath: '/System/Library/Fonts/Supplemental/Arial.ttf',
  canvasWidth: 300,
  canvasHeight: 450,
  swatchHeight: 300,
  textHeight: 150
};

// Utility functions
const utils = {
  toTitleCase: (str) => {
    return str.replace(/\b\w/g, char => char.toUpperCase());
  },
  
  getReadableColorName: (hex) => {
    try {
      const names = namer(hex);
      return utils.toTitleCase(names.ntc[0].name);
    } catch (error) {
      notify.error(`Failed to get color name for ${hex}: ${error.message}`);
      return "Unknown Color";
    }
  },
  
  validateHexColor: (hex) => {
    return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(hex);
  },
  
  ensureDirectoryExists: (directory) => {
    if (!fs.existsSync(directory)) {
      try {
        fs.mkdirSync(directory, { recursive: true });
        notify.success(`Created directory: ${directory}`);
      } catch (error) {
        throw new Error(`Failed to create directory ${directory}: ${error.message}`);
      }
    }
  }
};

// Notification handler
const notify = {
  send: (title, message, sound = 'default') => {
    const script = `osascript -e 'display notification "${message}" with title "${title}" sound name "${sound}"'`;
    exec(script, (error) => {
      if (error) {
        console.error(`Notification failed: ${error.message}`);
      }
    });
  },
  
  success: (message) => {
    notify.send('Color Swatch Generator', message, 'Glass');
    console.log(`✅ ${message}`);
  },
  
  error: (message) => {
    notify.send('Color Swatch Generator Error', message, 'Basso');
    console.error(`❌ ${message}`);
  },
  
  info: (message) => {
    notify.send('Color Swatch Generator', message);
    console.log(`ℹ️ ${message}`);
  }
};

// Canvas operations
const canvasOps = {
  initCanvas: () => {
    try {
      registerFont(CONFIG.fontPath, { family: 'Arial' });
      return true;
    } catch (error) {
      throw new Error(`Failed to register font: ${error.message}`);
    }
  },
  
  createSwatch: (colorName, hexCode) => {
    try {
      // Validate hex code
      if (!utils.validateHexColor(hexCode)) {
        throw new Error(`Invalid hex color code: ${hexCode}`);
      }
      
      const { canvasWidth, canvasHeight, swatchHeight, textHeight } = CONFIG;
      const canvas = createCanvas(canvasWidth, canvasHeight);
      const ctx = canvas.getContext('2d');

      // Draw color swatch
      ctx.fillStyle = hexCode;
      ctx.fillRect(0, 0, canvasWidth, swatchHeight);

      // Draw white text area
      ctx.fillStyle = 'white';
      ctx.fillRect(0, swatchHeight, canvasWidth, textHeight);

      // Text settings
      ctx.fillStyle = 'black';
      ctx.font = '20px Arial';
      ctx.textAlign = 'center';

      // Get readable color names
      const titleCaseName = utils.toTitleCase(colorName);
      const readableName = utils.getReadableColorName(hexCode);

      // Position text
      ctx.fillText(titleCaseName, canvasWidth / 2, swatchHeight + 30);
      ctx.fillText(hexCode, canvasWidth / 2, swatchHeight + 60);
      ctx.fillText(readableName, canvasWidth / 2, swatchHeight + 90);

      // Define output file name
      const fileName = path.join(CONFIG.outputDir, `${colorName}.png`);
      fs.writeFileSync(fileName, canvas.toBuffer('image/png'));
      
      return fileName;
    } catch (error) {
      throw new Error(`Failed to create swatch for ${colorName}: ${error.message}`);
    }
  }
};

// Main process
const processColors = (colors) => {
  const swatchDictionary = {};
  let successCount = 0;
  let failCount = 0;
  
  utils.ensureDirectoryExists(CONFIG.outputDir);
  canvasOps.initCanvas();
  
  notify.info(`Starting to process ${Object.keys(colors).length} colors...`);
  
  Object.entries(colors).forEach(([name, hex]) => {
    try {
      const fileName = canvasOps.createSwatch(name, hex);
      swatchDictionary[fileName] = name;
      successCount++;
    } catch (error) {
      notify.error(error.message);
      failCount++;
    }
  });
  
  notify.success(`Completed: ${successCount} swatches created, ${failCount} failed`);
  return swatchDictionary;
};

// Read input JSON from Shortcuts (via stdin)
let inputData = '';
process.stdin.on('data', chunk => {
  inputData += chunk;
});

process.stdin.on('end', () => {
  try {
    const colors = JSON.parse(inputData);
    const swatchDictionary = processColors(colors);
    console.log(JSON.stringify(swatchDictionary));
  } catch (error) {
    notify.error(`Failed to process input: ${error.message}`);
    console.log(JSON.stringify({ error: error.message })); // Ensures Shortcuts doesn't crash
    process.exit(1);
  }
});

// Handle process errors
process.on('uncaughtException', (error) => {
  notify.error(`Uncaught exception: ${error.message}`);
  console.log(JSON.stringify({ error: error.message }));
  process.exit(1);
});

process.on('unhandledRejection', (reason) => {
  notify.error(`Unhandled rejection: ${reason}`);
  console.log(JSON.stringify({ error: reason }));
  process.exit(1);
});
