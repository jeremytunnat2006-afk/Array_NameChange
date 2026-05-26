const wrapper = document.getElementById('action-container');

// Standardmäßig für FiveM verstecken
if (window.invokeNative) {
    wrapper.style.display = 'none';
}

// NUI Messages empfangen
window.addEventListener('message', (event) => {
    const item = event.data;
    
    if (item.action === "open") {
        wrapper.style.display = 'flex';
        // Eingabefelder beim Öffnen leeren und fokussieren
        const fnInput = document.getElementById('firstname');
        fnInput.value = '';
        document.getElementById('lastname').value = '';
        fnInput.focus();
        
    } else if (item.action === "close") {
        wrapper.style.display = 'none';
    }
});

// Bestätigen (Name Ändern)
document.getElementById('submit-btn').addEventListener('click', () => {
    const firstname = document.getElementById('firstname').value.trim();
    const lastname = document.getElementById('lastname').value.trim();

    // Verhindert leere Eingaben
    if (!firstname || !lastname) return; 

    // Sende die Daten an den Client zurück
    fetch(`https://${GetParentResourceName()}/confirmNameChange`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({ firstname, lastname })
    }).then(resp => resp.json());
});

// Abbrechen Funktion
const closeUI = () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    }).then(resp => resp.json());
};

// Event-Listener für Schließen-Buttons & ESC-Taste
document.getElementById('close-btn').addEventListener('click', closeUI);
document.getElementById('close-x-btn').addEventListener('click', closeUI);

document.addEventListener('keydown', (e) => {
    if (e.key === "Escape" && wrapper.style.display === 'flex') {
        closeUI();
    }
});