// Clipboard sync for noVNC
// Handles: Ctrl+V, Ctrl+Shift+V, Cmd+V, Ctrl+X, Cmd+X
// Does NOT intercept: Ctrl+C, Ctrl+Shift+C (let them go to remote)

(function() {
  'use strict';

  let clipboardEnabled = false;
  let rfb = null;

  // X11 keysyms
  const XK = {
    Control_L: 0xFFE3,
    Shift_L: 0xFFE1,
    c: 0x0063,
    v: 0x0076,
    x: 0x0078,
    C: 0x0043,
    V: 0x0056,
    X: 0x0058
  };

  // Wait for noVNC to initialize
  function waitForRFB(callback, timeout = 10000) {
    const start = Date.now();
    const check = setInterval(() => {
      if (window.UI && window.UI.rfb) {
        clearInterval(check);
        callback(window.UI.rfb);
      } else if (Date.now() - start > timeout) {
        clearInterval(check);
        console.warn('noVNC clipboard: RFB not found');
      }
    }, 100);
  }

  // Request clipboard permission (must be called from user gesture)
  async function enableClipboard() {
    try {
      // This may trigger permission prompt in some browsers
      await navigator.clipboard.readText();
    } catch (e) {
      // Permission denied or not available - still enable partial functionality
      console.log('Clipboard read permission:', e.message);
    }

    clipboardEnabled = true;
    updateButton(true);
    console.log('noVNC clipboard: enabled');
  }

  function updateButton(enabled) {
    const btn = document.getElementById('clipboardBtn');
    if (btn) {
      btn.style.background = enabled ? '#50fa7b' : '';
      btn.title = enabled ? 'Clipboard sync enabled' : 'Click to enable clipboard sync';
    }
  }

  // Remote -> Local: VNC server sends clipboard
  function setupRemoteToLocal(rfbInstance) {
    rfbInstance.addEventListener('clipboard', async (e) => {
      const text = e?.detail?.text;
      if (!text || !clipboardEnabled) return;

      try {
        await navigator.clipboard.writeText(text);
        console.log('noVNC clipboard: remote -> local OK');
      } catch (err) {
        // writeText may fail without user gesture (Firefox/Safari)
        console.log('noVNC clipboard: remote -> local failed (need gesture)');
      }
    });
  }

  // Send key combination to remote
  function sendKeys(rfbInstance, keysyms) {
    // Press all keys
    for (const k of keysyms) {
      rfbInstance.sendKey(k, null, true);
    }
    // Release in reverse order
    for (let i = keysyms.length - 1; i >= 0; i--) {
      rfbInstance.sendKey(keysyms[i], null, false);
    }
  }

  // Handle paste: sync clipboard then send keystroke
  async function handlePaste(rfbInstance, event, keysyms) {
    event.preventDefault();
    event.stopPropagation();

    try {
      const text = await navigator.clipboard.readText();
      if (text) {
        rfbInstance.clipboardPasteFrom(text);
        console.log('noVNC clipboard: local -> remote OK');
      }
    } catch (err) {
      console.log('noVNC clipboard: read failed', err.message);
    }

    // Send the actual keystroke to trigger paste in remote app
    sendKeys(rfbInstance, keysyms);
  }

  // Keyboard interception
  function setupKeyInterception(rfbInstance) {
    document.addEventListener('keydown', async (e) => {
      if (!clipboardEnabled) return;

      const ctrl = e.ctrlKey;
      const shift = e.shiftKey;
      const meta = e.metaKey; // Cmd on Mac
      const key = e.code;

      // === PASTE shortcuts (need special handling) ===

      // Ctrl+V (standard)
      if (key === 'KeyV' && ctrl && !shift && !meta) {
        await handlePaste(rfbInstance, e, [XK.Control_L, XK.v]);
        return;
      }

      // Ctrl+Shift+V (terminal style)
      if (key === 'KeyV' && ctrl && shift && !meta) {
        await handlePaste(rfbInstance, e, [XK.Control_L, XK.Shift_L, XK.V]);
        return;
      }

      // Cmd+V (Mac) -> send as Ctrl+V to Linux
      if (key === 'KeyV' && meta && !ctrl) {
        await handlePaste(rfbInstance, e, [XK.Control_L, XK.v]);
        return;
      }

      // === CUT shortcuts ===

      // Ctrl+X
      if (key === 'KeyX' && ctrl && !shift && !meta) {
        await handlePaste(rfbInstance, e, [XK.Control_L, XK.x]);
        return;
      }

      // Cmd+X (Mac) -> send as Ctrl+X
      if (key === 'KeyX' && meta && !ctrl) {
        await handlePaste(rfbInstance, e, [XK.Control_L, XK.x]);
        return;
      }

      // === COPY shortcuts - DO NOT INTERCEPT ===
      // Ctrl+C, Ctrl+Shift+C, Cmd+C
      // Let them pass through to remote, we catch the clipboard event

    }, true); // capture phase
  }

  // Add UI button
  function addClipboardButton() {
    // Find control bar
    const controlBar = document.getElementById('noVNC_control_bar_anchor')
                    || document.querySelector('.noVNC_button_anchor');
    if (!controlBar) {
      console.warn('noVNC clipboard: control bar not found');
      return;
    }

    const btn = document.createElement('button');
    btn.id = 'clipboardBtn';
    btn.className = 'noVNC_button';
    btn.title = 'Click to enable clipboard sync';
    btn.innerHTML = '📋';
    btn.style.cssText = 'font-size: 18px; padding: 4px 8px; cursor: pointer; margin: 2px;';
    btn.addEventListener('click', enableClipboard);

    controlBar.appendChild(btn);
  }

  // Initialize
  waitForRFB((rfbInstance) => {
    rfb = rfbInstance;
    addClipboardButton();
    setupRemoteToLocal(rfbInstance);
    setupKeyInterception(rfbInstance);
    console.log('noVNC clipboard: initialized');
  });

})();
