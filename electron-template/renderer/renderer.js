const shortcutsTable = document.getElementById('shortcuts-list');
const addShortcutBtn = document.getElementById('add-shortcut-btn');
const changeSaveLocationBtn = document.getElementById('change-save-location-btn');
const shortcutForm = document.getElementById('shortcut-form');
const addForm = document.getElementById('add-form');
const closeBtn = document.querySelector('.close');
const cancelBtn = document.querySelector('.cancel-btn');
const searchInput = document.getElementById('search-input');
const searchScopeRadios = document.querySelectorAll('input[name="search-scope"]');

let shortcuts = [];

document.addEventListener('DOMContentLoaded', async () => {
  await loadShortcuts();
  renderShortcuts();
  
  addShortcutBtn.addEventListener('click', openShortcutForm);
  closeBtn.addEventListener('click', closeShortcutForm);
  cancelBtn.addEventListener('click', closeShortcutForm);
  addForm.addEventListener('submit', handleFormSubmit);
  changeSaveLocationBtn.addEventListener('click', changeSaveLocation);
  searchInput.addEventListener('input', filterShortcuts);
  searchScopeRadios.forEach(radio => {
    radio.addEventListener('change', filterShortcuts);
  });
  
  window.addEventListener('click', (event) => {
    if (event.target === shortcutForm) {
      closeShortcutForm();
    }
  });
});

async function loadShortcuts() {
  shortcuts = await window.api.loadShortcuts();
}

async function saveShortcuts() {
  await window.api.saveShortcuts(shortcuts);
}

function renderShortcuts(filteredList = null) {
  const list = filteredList || shortcuts;
  shortcutsTable.innerHTML = '';
  
  if (list.length === 0) {
    const emptyRow = document.createElement('tr');
    emptyRow.innerHTML = `<td colspan="4" style="text-align: center;">ショートカットがありません</td>`;
    shortcutsTable.appendChild(emptyRow);
    return;
  }
  
  list.forEach((shortcut, index) => {
    const row = document.createElement('tr');
    row.innerHTML = `
      <td>${shortcut.applicationName}</td>
      <td>${shortcut.featureDescription}</td>
      <td><span class="shortcut-key">${shortcut.shortcutKey}</span></td>
      <td>
        <button class="action-btn delete-btn" data-index="${index}">削除</button>
      </td>
    `;
    shortcutsTable.appendChild(row);
  });
  
  document.querySelectorAll('.delete-btn').forEach(btn => {
    btn.addEventListener('click', handleDelete);
  });
}

function handleDelete(event) {
  const index = parseInt(event.target.dataset.index);
  shortcuts.splice(index, 1);
  saveShortcuts();
  renderShortcuts();
}

function openShortcutForm() {
  shortcutForm.style.display = 'block';
  document.getElementById('app-name').focus();
}

function closeShortcutForm() {
  shortcutForm.style.display = 'none';
  addForm.reset();
}

function handleFormSubmit(event) {
  event.preventDefault();
  
  const applicationName = document.getElementById('app-name').value;
  const featureDescription = document.getElementById('feature-desc').value;
  const shortcutKey = document.getElementById('shortcut-key').value;
  
  const newShortcut = {
    id: Date.now().toString(),
    applicationName,
    featureDescription,
    shortcutKey
  };
  
  shortcuts.push(newShortcut);
  saveShortcuts();
  renderShortcuts();
  closeShortcutForm();
}

async function changeSaveLocation() {
  const newLocation = await window.api.changeSaveLocation();
  if (newLocation) {
    await loadShortcuts();
    renderShortcuts();
  }
}

function filterShortcuts() {
  const searchTerm = searchInput.value.toLowerCase();
  const searchScope = document.querySelector('input[name="search-scope"]:checked').value;
  
  if (!searchTerm) {
    renderShortcuts();
    return;
  }
  
  let filteredList;
  
  switch (searchScope) {
    case 'app':
      filteredList = shortcuts.filter(shortcut => 
        shortcut.applicationName.toLowerCase().includes(searchTerm)
      );
      break;
    case 'feature':
      filteredList = shortcuts.filter(shortcut => 
        shortcut.featureDescription.toLowerCase().includes(searchTerm)
      );
      break;
    default: // 'all'
      filteredList = shortcuts.filter(shortcut => 
        shortcut.applicationName.toLowerCase().includes(searchTerm) ||
        shortcut.featureDescription.toLowerCase().includes(searchTerm) ||
        shortcut.shortcutKey.toLowerCase().includes(searchTerm)
      );
      break;
  }
  
  renderShortcuts(filteredList);
}
