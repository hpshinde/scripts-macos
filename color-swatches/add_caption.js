// Node.js Script (used in the shortcut)
const { createCanvas, loadImage, registerFont } = require('canvas');
const fs = require('fs');
const path = require('path');

// Register the Arial font from the specified location
registerFont('/System/Library/Fonts/Supplemental/Arial.ttf', { family: 'Arial' });

let inputData = '';
process.stdin.on('data', chunk => { inputData += chunk; });

process.stdin.on('end', async () => {
    try {
        // Parse the JSON input
        const parsedData = JSON.parse(inputData);
        const imagePath = parsedData.imagePath?.trim();
        const captionBase64 = parsedData.captionText?.trim();

        // Check if the image path is valid
        if (!imagePath || !fs.existsSync(imagePath)) {
            console.error("Error: Image file not found.");
            process.exit(1);
        }

        // Decode Base64 text
        let captionText = Buffer.from(captionBase64, 'base64').toString('utf-8');

        // Load the image
        const image = await loadImage(imagePath);
        const imgWidth = image.width;
        const imgHeight = image.height;

        // Define text properties
        let fontSize = 20;
        const padding = 20;
        const lineHeight = fontSize + 5; // Reduced line spacing
        const maxTextWidth = imgWidth - 2 * padding;

        // Create a temporary canvas to measure text width
        const tempCanvas = createCanvas(imgWidth, 200);
        const tempCtx = tempCanvas.getContext('2d');
        tempCtx.font = `${fontSize}px Arial`;

        let lines = captionText.split("\n");
        const wrappedLines = [];

        // Wrap the text
        lines.forEach(line => {
            let words = line.split(/\s+/);
            let currentLine = "";

            for (let word of words) {
                const testLine = currentLine.length === 0 ? word : `${currentLine} ${word}`;
                const testWidth = tempCtx.measureText(testLine).width;

                if (testWidth < maxTextWidth) {
                    currentLine = testLine;
                } else {
                    wrappedLines.push(currentLine);
                    currentLine = word;
                }
            }
            wrappedLines.push(currentLine);
        });

        // Adjust font size if needed
        while (wrappedLines.length * lineHeight > 200 && fontSize > 15) {
            fontSize -= 2;
            tempCtx.font = `${fontSize}px Arial`;
        }

        const textAreaHeight = wrappedLines.length * lineHeight + padding; // Adjusted bottom padding
        const canvas = createCanvas(imgWidth, imgHeight + textAreaHeight);
        const ctx = canvas.getContext('2d');

        // Draw the original image
        ctx.drawImage(image, 0, 0, imgWidth, imgHeight);

        // Draw the background for the text
        ctx.fillStyle = '#DBDBDB'; // Changed background color
        ctx.fillRect(0, imgHeight, imgWidth, textAreaHeight);

        // Draw the text
        ctx.fillStyle = 'black';
        ctx.font = `${fontSize}px Arial`;
        ctx.textAlign = 'left';
        ctx.textBaseline = 'top';

        let yPos = imgHeight + padding;
        wrappedLines.forEach(line => {
            ctx.fillText(line, padding, yPos);
            yPos += lineHeight;
        });

        // Save the output image
        const outputPath = path.join(path.dirname(imagePath), path.basename(imagePath, path.extname(imagePath)) + '-captioned.jpg');
        fs.writeFileSync(outputPath, canvas.toBuffer('image/jpeg', { quality: 0.95 }));

        console.log(`Success! Output saved at: ${outputPath}`);
    } catch (error) {
        console.error("Error parsing JSON:", error.message);
        process.exit(1);
    }
});
