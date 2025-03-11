const { createCanvas, registerFont } = require('canvas');
const fs = require('fs');
const namer = require('color-namer');
const { exec } = require('child_process');
const path = require('path');

// Configuration with enhanced customization options
const CONFIG = {
  // Output settings
  outputDir: '/Users/data/Scripts/tmp/color-swatches/',
  
  // Canvas dimensions
  canvas: {
    width: 300,
    height: 420
  },
  
  // Swatch settings
  swatch: {
    height: 300,
    backgroundColor: null // Will be set to the hex color being processed
  },
  
  // Info panel settings
  infoPanel: {
    height: 110,
    backgroundColor: '#F1F0E9',
    padding: {
      top: 30,
      bottom: 10
    }
  },
  
  // Font settings
  font: {
    path: '/Users/data/Library/Fonts/RobotoCondensed-Regular.ttf',
    family: 'Roboto Condensed',
    style: 'Regular',
    size: 20,
    color: '#403e3f',
    lineHeight: 30,
    align: 'center'
  },
  
  // Notification sounds
  sounds: {
    success: 'Glass',
    error: 'Basso',
    info: 'default'
  }
};

// Utility module for common functions
const Utils = {
  toTitleCase: (str) => {
    return str.replace(/\b\w/g, char => char.toUpperCase());
  },
  
  getReadableColorName: (hex) => {
    try {
      const names = namer(hex);
      return Utils.toTitleCase(names.ntc[0].name);
    } catch (error) {
      Notify.error(`Failed to get color name for ${hex}: ${error.message}`);
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
        Notify.success(`Created directory: ${directory}`);
      } catch (error) {
        throw new Error(`Failed to create directory ${directory}: ${error.message}`);
      }
    }
  }
};

// Notification handler module
const Notify = {
  send: (title, message, sound = CONFIG.sounds.info) => {
    const script = `osascript -e 'display notification "${message}" with title "${title}" sound name "${sound}"'`;
    exec(script, (error) => {
      if (error) {
        console.error(`Notification failed: ${error.message}`);
      }
    });
  },
  
  success: (message) => {
    Notify.send('Color Swatch Generator', message, CONFIG.sounds.success);
    console.log(`✅ ${message}`);
  },
  
  error: (message) => {
    Notify.send('Color Swatch Generator Error', message, CONFIG.sounds.error);
    console.error(`❌ ${message}`);
  },
  
  info: (message) => {
    Notify.send('Color Swatch Generator', message);
    console.log(`ℹ️ ${message}`);
  }
};

// Canvas operations module
const CanvasManager = {
  initCanvas: () => {
    try {
      // Register font with specific weight/style
      registerFont(CONFIG.font.path, { 
        family: CONFIG.font.family,
        weight: 'normal',
        style: 'normal'
      });
      
      Notify.info(`Registered font: ${CONFIG.font.family} ${CONFIG.font.style}`);
      return true;
    } catch (error) {
      throw new Error(`Failed to register font: ${error.message}`);
    }
  },
  
  createSwatch: (colorName, hexCode) => {
    try {
      // Validate hex code
      if (!Utils.validateHexColor(hexCode)) {
        throw new Error(`Invalid hex color code: ${hexCode}`);
      }
      
      const canvas = createCanvas(CONFIG.canvas.width, CONFIG.canvas.height);
      const ctx = canvas.getContext('2d');

      // Draw color swatch
      ctx.fillStyle = hexCode;
      ctx.fillRect(0, 0, CONFIG.canvas.width, CONFIG.swatch.height);

      // Draw info panel background
      ctx.fillStyle = CONFIG.infoPanel.backgroundColor;
      ctx.fillRect(0, CONFIG.swatch.height, CONFIG.canvas.width, CONFIG.infoPanel.height);

      // Set text properties
      ctx.fillStyle = CONFIG.font.color;
      ctx.font = `normal ${CONFIG.font.size}px "${CONFIG.font.family}"`;
      ctx.textAlign = CONFIG.font.align;

      // Get readable color names
      const titleCaseName = Utils.toTitleCase(colorName);
      const readableName = Utils.getReadableColorName(hexCode);

      // Calculate text y-positions based on config
      const textStartY = CONFIG.swatch.height + CONFIG.infoPanel.padding.top;
      
      // Position and draw text
      ctx.fillText(titleCaseName, CONFIG.canvas.width / 2, textStartY);
      ctx.fillText(hexCode, CONFIG.canvas.width / 2, textStartY + CONFIG.font.lineHeight);
      ctx.fillText(readableName, CONFIG.canvas.width / 2, textStartY + (CONFIG.font.lineHeight * 2));

      // Define output file name
      const fileName = path.join(CONFIG.outputDir, `${colorName}.png`);
      fs.writeFileSync(fileName, canvas.toBuffer('image/png'));
      
      return fileName;
    } catch (error) {
      throw new Error(`Failed to create swatch for ${colorName}: ${error.message}`);
    }
  }
};

// SwatchProcessor handles the main processing logic
const SwatchProcessor = {
  process: (colors) => {
    const swatchDictionary = {};
    let successCount = 0;
    let failCount = 0;
    
    Utils.ensureDirectoryExists(CONFIG.outputDir);
    CanvasManager.initCanvas();
    
    Notify.info(`Starting to process ${Object.keys(colors).length} colors...`);
    
    Object.entries(colors).forEach(([name, hex]) => {
      try {
        const fileName = CanvasManager.createSwatch(name, hex);
        swatchDictionary[fileName] = name;
        successCount++;
      } catch (error) {
        Notify.error(error.message);
        failCount++;
      }
    });
    
    Notify.success(`Completed: ${successCount} swatches created, ${failCount} failed`);
    return swatchDictionary;
  }
};

// Error Handler module
const ErrorHandler = {
  setup: () => {
    // Handle process errors
    process.on('uncaughtException', (error) => {
      Notify.error(`Uncaught exception: ${error.message}`);
      console.log(JSON.stringify({ error: error.message }));
      process.exit(1);
    });

    process.on('unhandledRejection', (reason) => {
      Notify.error(`Unhandled rejection: ${reason}`);
      console.log(JSON.stringify({ error: reason }));
      process.exit(1);
    });
  }
};

// Main application entry point
const App = {
  init: () => {
    ErrorHandler.setup();
    
    // Read input JSON from Shortcuts (via stdin)
    let inputData = '';
    process.stdin.on('data', chunk => {
      inputData += chunk;
    });

    process.stdin.on('end', () => {
      try {
        const colors = JSON.parse(inputData);
        const swatchDictionary = SwatchProcessor.process(colors);
        console.log(JSON.stringify(swatchDictionary));
      } catch (error) {
        Notify.error(`Failed to process input: ${error.message}`);
        console.log(JSON.stringify({ error: error.message })); // Ensures Shortcuts doesn't crash
        process.exit(1);
      }
    });
  }
};

// Start the application
App.init();
