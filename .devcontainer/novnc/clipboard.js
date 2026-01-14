// Clipboard sync for noVNC 1.6.0+
// Auto-enables on first user interaction
// Handles: Ctrl+V, Ctrl+Shift+V, Cmd+V, Ctrl+X, Cmd+X

(function() {
  'use strict';

  let clipboardEnabled = false;
  let initialized = false;

  // X11 keysyms
  const XK = {
    Control_L: 0xFFE3,
    Shift_L: 0xFFE1,
    v: 0x0076,
    x: 0x0078,
    V: 0x0056,
    X: 0x0058
  };

  // Auto-enable clipboard on first user interaction
  async function autoEnable() {
    if (clipboardEnabled) return;

    try {
      // Try to get clipboard permission
      await navigator.clipboard.readText();
    } catch (e) {
      // Permission denied or empty clipboard - that's OK
    }

    clipboardEnabled = true;
    updateButton(true);
    console.log('noVNC clipboard: auto-enabled');
  }

  function updateButton(enabled) {
    const btn = document.getElementById('clipboardSyncBtn');
    if (btn) {
      btn.style.background = enabled ? '#50fa7b' : '';
      btn.title = enabled ? 'Clipboard sync enabled' : 'Click to enable clipboard sync';
    }
  }

  // Setup clipboard sync using noVNC's built-in clipboard textarea
  function setup() {
    if (initialized) return;
    initialized = true;

    addClipboardButton();

    // Auto-enable on any click or keypress
    const enableOnce = () => {
      autoEnable();
      document.removeEventListener('click', enableOnce);
      document.removeEventListener('keydown', enableOnceKey);
    };
    const enableOnceKey = (e) => {
      // Only enable on actual key input, not modifier-only
      if (!e.ctrlKey && !e.metaKey && !e.altKey) {
        autoEnable();
      }
    };
    document.addEventListener('click', enableOnce);
    document.addEventListener('keydown', enableOnceKey, { once: true });

    // Handle paste shortcuts
    document.addEventListener('keydown', async (e) => {
      if (!clipboardEnabled) return;

      const ctrl = e.ctrlKey;
      const shift = e.shiftKey;
      const meta = e.metaKey;
      const key = e.code;

      // Paste: Ctrl+V, Ctrl+Shift+V, Cmd+V
      const isPaste = key === 'KeyV' && (ctrl || meta);
      // Cut: Ctrl+X, Cmd+X
      const isCut = key === 'KeyX' && (ctrl || meta);

      if (isPaste || isCut) {
        e.preventDefault();
        e.stopPropagation();

        try {
          const text = await navigator.clipboard.readText();
          if (text) {
            // Put text in noVNC's clipboard textarea and trigger sync
            const clipboardText = document.getElementById('noVNC_clipboard_text');
            if (clipboardText) {
              clipboardText.value = text;
              // Trigger the input event to sync to VNC
              clipboardText.dispatchEvent(new Event('input', { bubbles: true }));
              clipboardText.dispatchEvent(new Event('change', { bubbles: true }));
              console.log('noVNC clipboard: pasted to VNC clipboard');
            }
          }
        } catch (err) {
          console.log('noVNC clipboard: read failed -', err.message);
        }
      }
    }, true);

    // Sync from noVNC clipboard textarea to local clipboard
    const clipboardText = document.getElementById('noVNC_clipboard_text');
    if (clipboardText) {
      // Watch for changes (from VNC server)
      const observer = new MutationObserver(() => {
        if (clipboardEnabled && clipboardText.value) {
          navigator.clipboard.writeText(clipboardText.value).catch(() => {});
        }
      });

      // Also listen for input/change events
      ['input', 'change'].forEach(evt => {
        clipboardText.addEventListener(evt, async () => {
          if (!clipboardEnabled || !clipboardText.value) return;
          try {
            await navigator.clipboard.writeText(clipboardText.value);
            console.log('noVNC clipboard: synced to local');
          } catch (err) {
            // Silently fail - might need user gesture
          }
        });
      });
    }

    console.log('noVNC clipboard: initialized (click anywhere to enable)');
  }

  // Add UI button
  function addClipboardButton() {
    const controlBar = document.getElementById('noVNC_control_bar');
    if (!controlBar) return;

    const scrollContainer = controlBar.querySelector('.noVNC_scroll');
    if (!scrollContainer) return;

    if (document.getElementById('clipboardSyncBtn')) return;

    const btn = document.createElement('input');
    btn.type = 'image';
    btn.id = 'clipboardSyncBtn';
    btn.className = 'noVNC_button';
    btn.title = 'Click to enable clipboard sync';
    btn.alt = 'Clipboard Sync';
    btn.src = 'data:image/svg+xml,' + encodeURIComponent(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2">' +
      '<path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2"/>' +
      '<rect x="8" y="2" width="8" height="4" rx="1" ry="1"/>' +
      '<path d="M9 14l2 2 4-4"/>' +
      '</svg>'
    );
    btn.style.cssText = 'width: 24px; height: 24px; padding: 4px;';
    btn.addEventListener('click', (e) => {
      e.preventDefault();
      autoEnable();
    });

    const existingClipboard = document.getElementById('noVNC_clipboard_button');
    if (existingClipboard && existingClipboard.parentNode) {
      existingClipboard.parentNode.insertBefore(btn, existingClipboard.nextSibling);
    } else {
      scrollContainer.appendChild(btn);
    }
  }

  // Wait for DOM and noVNC to be ready
  function init() {
    const trySetup = () => {
      // Wait for noVNC clipboard textarea to exist
      if (document.getElementById('noVNC_clipboard_text')) {
        setup();
      } else {
        setTimeout(trySetup, 200);
      }
    };

    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', trySetup);
    } else {
      trySetup();
    }
  }

  init();

})();
