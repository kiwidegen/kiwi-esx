let currentHeading = 0;
let compassWidth = 600; // Pixels
let viewDegrees = 240; // Extended to 240° for smoother fast turns
let pixelsPerDegree = compassWidth / viewDegrees;
let compassElement = document.getElementById('compass');
let centerLabel = document.getElementById('center-label');
let streetInfoElement = document.getElementById('street-info');
let isVisible = true; // HUD is on by default
let streetsVisible = true; // Street info is on by default
let debugEnabled = false;

// Debug: Verify DOM elements
if (!compassElement) console.error('Compass element not found!');
if (!centerLabel) console.error('Center label not found!');
if (!streetInfoElement) console.error('Street info element not found!');

// Receive messages from Lua
window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.type === 'updateHeading') {
        currentHeading = data.heading;
        streetInfoElement.innerText = (data.streetInfo || '').toUpperCase();
        updateCompass();
    } else if (data.type === 'toggleHUD') {
        isVisible = data.state !== undefined ? data.state : !isVisible;
        compassElement.classList.toggle('hidden', !isVisible);
        streetInfoElement.classList.toggle('hidden', !isVisible || !streetsVisible);
    } else if (data.type === 'toggleStreets') {
        streetsVisible = data.state !== undefined ? data.state : !streetsVisible;
        streetInfoElement.classList.toggle('hidden', !isVisible || !streetsVisible);
    } else if (data.type === 'debug') {
        if (data.debugState !== undefined) {
            debugEnabled = data.debugState;
            console.log(`Debug Mode: ${debugEnabled ? 'Enabled' : 'Disabled'}`);
        }
        if (debugEnabled) {
            if (data.heading !== undefined) {
                console.log(`Heading: ${data.heading.toFixed(2)}, Rounded: ${data.roundedHeading}, Street Info: ${data.streetInfo || 'None'}`);
            }
            if (data.visibility !== undefined) {
                console.log(`HUD Visibility Toggled: ${isVisible}`);
            }
            if (data.streetsVisibility !== undefined) {
                console.log(`Street Info Visibility Toggled: ${streetsVisible}`);
            }
        }
    }
});

// Update compass display
function updateCompass() {
    if (!isVisible) return;

    // Clear previous sliding labels and bars
    compassElement.querySelectorAll('.label, .bar').forEach(el => el.remove());

    // Update static center label
    let roundedHeading = Math.round(currentHeading);
    let labelText = '';
    let labelClass = 'center-label';

    if (roundedHeading === 0 || roundedHeading === 360) {
        labelText = 'N';
    } else if (roundedHeading === 90) {
        labelText = 'E';
    } else if (roundedHeading === 180) {
        labelText = 'S';
    } else if (roundedHeading === 270) {
        labelText = 'W';
    } else if (roundedHeading === 45) {
        labelText = 'NE';
        labelClass += ' intercardinal';
    } else if (roundedHeading === 135) {
        labelText = 'SE';
        labelClass += ' intercardinal';
    } else if (roundedHeading === 225) {
        labelText = 'SW';
        labelClass += ' intercardinal';
    } else if (roundedHeading === 315) {
        labelText = 'NW';
        labelClass += ' intercardinal';
    } else {
        labelText = roundedHeading.toString(); // No degree symbol
        labelClass += ' degree';
    }

    centerLabel.className = labelClass;
    centerLabel.innerText = labelText;

    // Calculate sliding directions
    let startDegree = (currentHeading - viewDegrees / 2) % 360;
    if (startDegree < 0) startDegree += 360;

    let labelPositions = []; // Store label positions to avoid bar overlap
    let lastLabelX = -Infinity;

    // First pass: Collect label positions
    for (let i = 0; i <= viewDegrees; i++) {
        let deg = (startDegree + i) % 360;
        let x = i * pixelsPerDegree;

        // Determine label (only cardinal and intercardinal)
        let labelText = '';
        let labelClass = 'label';

        if (Math.abs(deg - 0) < 0.5 || Math.abs(deg - 360) < 0.5) {
            labelText = 'N';
            labelClass += ' cardinal';
        } else if (Math.abs(deg - 90) < 0.5) {
            labelText = 'E';
            labelClass += ' cardinal';
        } else if (Math.abs(deg - 180) < 0.5) {
            labelText = 'S';
            labelClass += ' cardinal';
        } else if (Math.abs(deg - 270) < 0.5) {
            labelText = 'W';
            labelClass += ' cardinal';
        } else if (Math.abs(deg - 45) < 0.5) {
            labelText = 'NE';
            labelClass += ' intercardinal';
        } else if (Math.abs(deg - 135) < 0.5) {
            labelText = 'SE';
            labelClass += ' intercardinal';
        } else if (Math.abs(deg - 225) < 0.5) {
            labelText = 'SW';
            labelClass += ' intercardinal';
        } else if (Math.abs(deg - 315) < 0.5) {
            labelText = 'NW';
            labelClass += ' intercardinal';
        }

        if (labelText) {
            labelPositions.push(x);
            let label = document.createElement('div');
            label.className = labelClass;
            label.style.left = `${x}px`;
            label.innerText = labelText;
            // Fade near center
            let distanceToCenter = Math.abs(x - compassWidth / 2);
            if (distanceToCenter < 38) {
                label.style.opacity = (distanceToCenter - 28) / 10; // Fade from 28px to 38px
            } else {
                label.style.opacity = 1;
            }
            // Fade at edges
            let distanceToEdge = Math.min(x, compassWidth - x);
            if (distanceToEdge < 10) {
                label.style.opacity = distanceToEdge / 10; // Fade from 0px to 10px
            }
            compassElement.appendChild(label);
            lastLabelX = x;
        }
    }

    // Second pass: Add decorative bars, skipping near labels
    for (let i = 0; i <= viewDegrees; i++) {
        let deg = (startDegree + i) % 360;
        let x = i * pixelsPerDegree;

        // Add decorative bars every 10 degrees
        if (Math.round(deg) % 10 === 0) {
            // Check if bar is too close to any label
            let tooClose = labelPositions.some(labelX => Math.abs(x - labelX) < 20); // Increased from 15 to 20
            if (!tooClose) {
                let bar = document.createElement('div');
                bar.className = 'bar';
                bar.style.left = `${x}px`;
                bar.innerText = '|';
                // Fade near center
                let distanceToCenter = Math.abs(x - compassWidth / 2);
                if (distanceToCenter < 38) {
                    bar.style.opacity = (distanceToCenter - 28) / 10; // Fade from 28px to 38px
                } else {
                    bar.style.opacity = 1;
                }
                // Fade at edges
                let distanceToEdge = Math.min(x, compassWidth - x);
                if (distanceToEdge < 10) {
                    bar.style.opacity = distanceToEdge / 10; // Fade from 0px to 10px
                }
                compassElement.appendChild(bar);
            }
        }
    }
}
