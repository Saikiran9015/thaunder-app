const logger = require('../utils/logger');

class GCodeGenerator {
    constructor(options = {}) {
        this.speed = options.speed || 50; // mm/s
        this.pressure = options.pressure || 300; // grams
        this.zUp = options.zUp || 5; // mm (blade up)
        this.zDown = options.zDown || 0; // mm (blade down)
        this.units = options.units || 'mm'; // mm or inches
    }

    /**
     * Generate G-code header
     */
    generateHeader() {
        return [
            '; ThunderCut G-code',
            '; Generated: ' + new Date().toISOString(),
            'G21 ; Set units to millimeters',
            'G90 ; Absolute positioning',
            'G28 ; Home all axes',
            `M3 S${this.pressure} ; Set blade pressure`,
            `F${this.speed * 60} ; Set feed rate`,
            ''
        ];
    }

    /**
     * Generate G-code footer
     */
    generateFooter() {
        return [
            '',
            'G0 Z' + this.zUp + ' ; Lift blade',
            'G28 X Y ; Return to home',
            'M5 ; Blade off',
            'M2 ; Program end'
        ];
    }

    /**
     * Convert SVG path to G-code
     * @param {Array} pathData - Array of path commands from SVG
     * @param {Object} options - Scaling and offset options
     */
    pathToGCode(pathData, options = {}) {
        const {
            scaleX = 1,
            scaleY = 1,
            offsetX = 0,
            offsetY = 0,
            mirror = false
        } = options;

        const gcode = [...this.generateHeader()];
        let isFirstMove = true;

        for (const segment of pathData) {
            const { command, x, y, x1, y1, x2, y2 } = segment;

            // Apply transformations
            const transformX = (val) => (mirror ? -val : val) * scaleX + offsetX;
            const transformY = (val) => val * scaleY + offsetY;

            switch (command) {
                case 'M': // Move to
                    if (isFirstMove) {
                        gcode.push(`G0 X${transformX(x).toFixed(3)} Y${transformY(y).toFixed(3)} ; Move to start`);
                        gcode.push(`G1 Z${this.zDown} ; Lower blade`);
                        isFirstMove = false;
                    } else {
                        gcode.push(`G0 Z${this.zUp} ; Lift blade`);
                        gcode.push(`G0 X${transformX(x).toFixed(3)} Y${transformY(y).toFixed(3)}`);
                        gcode.push(`G1 Z${this.zDown} ; Lower blade`);
                    }
                    break;

                case 'L': // Line to
                    gcode.push(`G1 X${transformX(x).toFixed(3)} Y${transformY(y).toFixed(3)}`);
                    break;

                case 'C': // Cubic Bezier curve
                    // Approximate curve with line segments
                    const curvePoints = this.bezierToPoints(
                        { x: transformX(x1), y: transformY(y1) },
                        { x: transformX(x2), y: transformY(y2) },
                        { x: transformX(x), y: transformY(y) },
                        20 // Number of segments
                    );
                    curvePoints.forEach(point => {
                        gcode.push(`G1 X${point.x.toFixed(3)} Y${point.y.toFixed(3)}`);
                    });
                    break;

                case 'Z': // Close path
                    gcode.push('; Close path');
                    break;
            }
        }

        gcode.push(...this.generateFooter());
        return gcode;
    }

    /**
     * Convert rectangle to G-code
     */
    rectangleToGCode(x, y, width, height) {
        const gcode = [...this.generateHeader()];

        gcode.push(`G0 X${x.toFixed(3)} Y${y.toFixed(3)} ; Move to start`);
        gcode.push(`G1 Z${this.zDown} ; Lower blade`);
        gcode.push(`G1 X${(x + width).toFixed(3)} Y${y.toFixed(3)}`);
        gcode.push(`G1 X${(x + width).toFixed(3)} Y${(y + height).toFixed(3)}`);
        gcode.push(`G1 X${x.toFixed(3)} Y${(y + height).toFixed(3)}`);
        gcode.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)} ; Close rectangle`);

        gcode.push(...this.generateFooter());
        return gcode;
    }

    /**
     * Convert circle to G-code
     */
    circleToGCode(centerX, centerY, radius, segments = 36) {
        const gcode = [...this.generateHeader()];

        // Start at rightmost point
        const startX = centerX + radius;
        const startY = centerY;

        gcode.push(`G0 X${startX.toFixed(3)} Y${startY.toFixed(3)} ; Move to start`);
        gcode.push(`G1 Z${this.zDown} ; Lower blade`);

        // Generate circle points
        for (let i = 1; i <= segments; i++) {
            const angle = (i / segments) * 2 * Math.PI;
            const x = centerX + radius * Math.cos(angle);
            const y = centerY + radius * Math.sin(angle);
            gcode.push(`G1 X${x.toFixed(3)} Y${y.toFixed(3)}`);
        }

        gcode.push(...this.generateFooter());
        return gcode;
    }

    /**
     * Approximate Bezier curve with line segments
     */
    bezierToPoints(cp1, cp2, end, segments) {
        const points = [];
        for (let i = 1; i <= segments; i++) {
            const t = i / segments;
            const mt = 1 - t;
            const mt2 = mt * mt;
            const t2 = t * t;

            const x = mt2 * cp1.x + 2 * mt * t * cp2.x + t2 * end.x;
            const y = mt2 * cp1.y + 2 * mt * t * cp2.y + t2 * end.y;

            points.push({ x, y });
        }
        return points;
    }

    /**
     * Optimize G-code (remove redundant commands)
     */
    optimize(gcode) {
        const optimized = [];
        let lastX = null;
        let lastY = null;

        for (const line of gcode) {
            // Skip empty lines and comments in optimization
            if (!line.trim() || line.startsWith(';')) {
                optimized.push(line);
                continue;
            }

            // Extract X and Y values
            const xMatch = line.match(/X([\d.-]+)/);
            const yMatch = line.match(/Y([\d.-]+)/);

            const currentX = xMatch ? parseFloat(xMatch[1]) : lastX;
            const currentY = yMatch ? parseFloat(yMatch[1]) : lastY;

            // Skip if position hasn't changed
            if (currentX === lastX && currentY === lastY && line.startsWith('G0')) {
                continue;
            }

            optimized.push(line);
            lastX = currentX;
            lastY = currentY;
        }

        return optimized;
    }

    /**
     * Set cutting parameters
     */
    setParameters(speed, pressure) {
        if (speed) this.speed = speed;
        if (pressure) this.pressure = pressure;
    }

    /**
     * Generate test pattern
     */
    generateTestPattern() {
        const gcode = [...this.generateHeader()];

        gcode.push('; Test Pattern - Square');
        gcode.push('G0 X10 Y10');
        gcode.push(`G1 Z${this.zDown}`);
        gcode.push('G1 X50 Y10');
        gcode.push('G1 X50 Y50');
        gcode.push('G1 X10 Y50');
        gcode.push('G1 X10 Y10');

        gcode.push(...this.generateFooter());
        return gcode;
    }
}

module.exports = GCodeGenerator;
