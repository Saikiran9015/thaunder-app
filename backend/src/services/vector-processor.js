const fs = require('fs').promises;
const path = require('path');
const logger = require('../utils/logger');

class VectorProcessor {
    constructor() {
        this.supportedFormats = ['.svg', '.dxf'];
    }

    /**
     * Process a vector file and extract path data
     */
    async processFile(filePath) {
        const ext = path.extname(filePath).toLowerCase();

        if (!this.supportedFormats.includes(ext)) {
            throw new Error(`Unsupported file format: ${ext}`);
        }

        switch (ext) {
            case '.svg':
                return await this.processSVG(filePath);
            case '.dxf':
                return await this.processDXF(filePath);
            default:
                throw new Error('Unknown file format');
        }
    }

    /**
     * Process SVG file
     */
    async processSVG(filePath) {
        try {
            const content = await fs.readFile(filePath, 'utf-8');

            // Extract path elements from SVG
            const pathRegex = /<path[^>]*\sd="([^"]*)"/g;
            const paths = [];
            let match;

            while ((match = pathRegex.exec(content)) !== null) {
                const pathData = match[1];
                // Store raw path data - will be processed by G-code generator
                paths.push({ type: 'path', data: pathData });
            }

            // Also extract basic shapes (rect, circle, ellipse)
            paths.push(...this.extractSVGShapes(content));

            logger.info(`Extracted ${paths.length} path segments from SVG`);
            return paths;
        } catch (error) {
            logger.error('Error processing SVG:', error);
            throw error;
        }
    }

    /**
     * Extract basic SVG shapes and convert to paths
     */
    extractSVGShapes(svgContent) {
        const shapes = [];

        // Extract rectangles
        const rectRegex = /<rect[^>]*x="([\d.]+)"[^>]*y="([\d.]+)"[^>]*width="([\d.]+)"[^>]*height="([\d.]+)"/g;
        let match;

        while ((match = rectRegex.exec(svgContent)) !== null) {
            const [, x, y, width, height] = match.map(parseFloat);
            shapes.push(...this.rectangleToPath(x, y, width, height));
        }

        // Extract circles
        const circleRegex = /<circle[^>]*cx="([\d.]+)"[^>]*cy="([\d.]+)"[^>]*r="([\d.]+)"/g;

        while ((match = circleRegex.exec(svgContent)) !== null) {
            const [, cx, cy, r] = match.map(parseFloat);
            shapes.push(...this.circleToPath(cx, cy, r));
        }

        return shapes;
    }

    /**
     * Convert rectangle to path commands
     */
    rectangleToPath(x, y, width, height) {
        return [
            { command: 'M', x, y },
            { command: 'L', x: x + width, y },
            { command: 'L', x: x + width, y: y + height },
            { command: 'L', x, y: y + height },
            { command: 'Z' }
        ];
    }

    /**
     * Convert circle to path commands (approximation)
     */
    circleToPath(cx, cy, r, segments = 36) {
        const path = [];

        for (let i = 0; i <= segments; i++) {
            const angle = (i / segments) * 2 * Math.PI;
            const x = cx + r * Math.cos(angle);
            const y = cy + r * Math.sin(angle);

            path.push({
                command: i === 0 ? 'M' : 'L',
                x,
                y
            });
        }

        path.push({ command: 'Z' });
        return path;
    }

    /**
     * Process DXF file (basic implementation)
     */
    async processDXF(filePath) {
        try {
            const content = await fs.readFile(filePath, 'utf-8');

            // Basic DXF parsing (simplified)
            // In production, use a proper DXF parser library
            logger.warn('DXF processing is simplified. Use dedicated parser for production.');

            return [];
        } catch (error) {
            logger.error('Error processing DXF:', error);
            throw error;
        }
    }

    /**
     * Normalize path data to consistent format
     */
    normalizePath(pathData) {
        const normalized = [];
        let currentX = 0;
        let currentY = 0;

        for (const segment of pathData) {
            const cmd = segment.code.toUpperCase();

            switch (cmd) {
                case 'M': // Move to
                    currentX = segment.x;
                    currentY = segment.y;
                    normalized.push({ command: 'M', x: currentX, y: currentY });
                    break;

                case 'L': // Line to
                    currentX = segment.x;
                    currentY = segment.y;
                    normalized.push({ command: 'L', x: currentX, y: currentY });
                    break;

                case 'H': // Horizontal line
                    currentX = segment.x;
                    normalized.push({ command: 'L', x: currentX, y: currentY });
                    break;

                case 'V': // Vertical line
                    currentY = segment.y;
                    normalized.push({ command: 'L', x: currentX, y: currentY });
                    break;

                case 'C': // Cubic Bezier
                    normalized.push({
                        command: 'C',
                        x1: segment.x1,
                        y1: segment.y1,
                        x2: segment.x2,
                        y2: segment.y2,
                        x: segment.x,
                        y: segment.y
                    });
                    currentX = segment.x;
                    currentY = segment.y;
                    break;

                case 'Q': // Quadratic Bezier
                    normalized.push({
                        command: 'Q',
                        x1: segment.x1,
                        y1: segment.y1,
                        x: segment.x,
                        y: segment.y
                    });
                    currentX = segment.x;
                    currentY = segment.y;
                    break;

                case 'Z': // Close path
                    normalized.push({ command: 'Z' });
                    break;
            }
        }

        return normalized;
    }

    /**
     * Calculate bounding box of path data
     */
    getBounds(pathData) {
        let minX = Infinity;
        let minY = Infinity;
        let maxX = -Infinity;
        let maxY = -Infinity;

        for (const segment of pathData) {
            if (segment.x !== undefined) {
                minX = Math.min(minX, segment.x);
                maxX = Math.max(maxX, segment.x);
            }
            if (segment.y !== undefined) {
                minY = Math.min(minY, segment.y);
                maxY = Math.max(maxY, segment.y);
            }
        }

        return {
            minX,
            minY,
            maxX,
            maxY,
            width: maxX - minX,
            height: maxY - minY
        };
    }

    /**
     * Scale path data
     */
    scalePath(pathData, scaleX, scaleY) {
        return pathData.map(segment => {
            const scaled = { ...segment };

            if (segment.x !== undefined) scaled.x *= scaleX;
            if (segment.y !== undefined) scaled.y *= scaleY;
            if (segment.x1 !== undefined) scaled.x1 *= scaleX;
            if (segment.y1 !== undefined) scaled.y1 *= scaleY;
            if (segment.x2 !== undefined) scaled.x2 *= scaleX;
            if (segment.y2 !== undefined) scaled.y2 *= scaleY;

            return scaled;
        });
    }

    /**
     * Translate path data
     */
    translatePath(pathData, offsetX, offsetY) {
        return pathData.map(segment => {
            const translated = { ...segment };

            if (segment.x !== undefined) translated.x += offsetX;
            if (segment.y !== undefined) translated.y += offsetY;
            if (segment.x1 !== undefined) translated.x1 += offsetX;
            if (segment.y1 !== undefined) translated.y1 += offsetY;
            if (segment.x2 !== undefined) translated.x2 += offsetX;
            if (segment.y2 !== undefined) translated.y2 += offsetY;

            return translated;
        });
    }
}

module.exports = VectorProcessor;
