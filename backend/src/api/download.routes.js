const express = require('express');
const router = express.Router();
const path = require('path');
const fs = require('fs');

/**
 * GET /api/download/setup
 * Triggers the download of the ThunderCut_Setup.zip
 */
router.get('/setup', (req, res) => {
    // We assume the zip is created in the root of the project by the user or a script
    const filePath = path.join(__dirname, '../../../ThunderCut_Setup.zip');

    if (fs.existsSync(filePath)) {
        res.download(filePath, 'ThunderCut_Setup.zip');
    } else {
        res.status(404).send({ message: "Setup file not found." });
    }
});

/**
 * GET /api/download/exe
 * Triggers the download of the ThunderCut_Installer.exe
 */
router.get('/exe', (req, res) => {
    const filePath = path.join(__dirname, '../../../ThunderCut_Installer.exe');

    if (fs.existsSync(filePath)) {
        res.download(filePath, 'ThunderCut_Installer.exe');
    } else {
        res.status(404).send({ message: "Installer EXE not found." });
    }
});

module.exports = router;
