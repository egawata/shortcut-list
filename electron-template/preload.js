const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  loadShortcuts: () => ipcRenderer.invoke('load-shortcuts'),
  
  saveShortcuts: (shortcuts) => ipcRenderer.invoke('save-shortcuts', shortcuts),
  
  changeSaveLocation: () => ipcRenderer.invoke('change-save-location')
});
