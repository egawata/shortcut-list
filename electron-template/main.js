const { app, BrowserWindow, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs');

let mainWindow;
let shortcutsFilePath = path.join(app.getPath('userData'), 'shortcuts.json');

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 900,
    height: 700,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile(path.join(__dirname, 'renderer', 'index.html'));
  
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

ipcMain.handle('load-shortcuts', async () => {
  try {
    if (fs.existsSync(shortcutsFilePath)) {
      const data = fs.readFileSync(shortcutsFilePath, 'utf8');
      return JSON.parse(data);
    }
    return [];
  } catch (error) {
    console.error('Failed to load shortcuts:', error);
    return [];
  }
});

ipcMain.handle('save-shortcuts', async (event, shortcuts) => {
  try {
    fs.writeFileSync(shortcutsFilePath, JSON.stringify(shortcuts, null, 2), 'utf8');
    return true;
  } catch (error) {
    console.error('Failed to save shortcuts:', error);
    return false;
  }
});

ipcMain.handle('change-save-location', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory']
  });
  
  if (!result.canceled && result.filePaths.length > 0) {
    shortcutsFilePath = path.join(result.filePaths[0], 'shortcuts.json');
    return shortcutsFilePath;
  }
  
  return null;
});
