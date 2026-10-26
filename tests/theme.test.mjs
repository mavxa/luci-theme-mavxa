import assert from 'node:assert/strict';
import { readFileSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { execFileSync } from 'node:child_process';
import { runInNewContext } from 'node:vm';
import test from 'node:test';

const root = new URL('../', import.meta.url);
const source = readFileSync(new URL('htdocs/luci-static/mavxa/theme.js', root), 'utf8');

function element() {
	const classes = new Set();
	return {
		attrs: {}, events: {}, textContent: '', focused: false,
		setAttribute(name, value) { this.attrs[name] = value; },
		addEventListener(name, callback) { this.events[name] = callback; },
		focus() { this.focused = true; },
		classList: {
			contains(name) { return classes.has(name); },
			add(name) { classes.add(name); },
			remove(name) { classes.delete(name); },
			toggle(name, enabled) { enabled ? classes.add(name) : classes.delete(name); }
		}
	};
}

function browser(saved, denied = false) {
	const button = element(), menu = element(), toggle = element(), overlay = element(), meta = element();
	const document = {
		documentElement: { dataset: {} }, body: element(), events: {},
		getElementById(id) { return { 'mavxa-theme-toggle': button, mainmenu: menu, 'mavxa-menu-overlay': overlay }[id]; },
		querySelector(selector) { return selector.startsWith('meta') ? meta : toggle; },
		addEventListener(name, callback) { this.events[name] = callback; }
	};
	const system = { matches: true, addEventListener(_, callback) { this.change = callback; } };
	const writes = [];
	const localStorage = {
		getItem() { if (denied) throw Error('Storage blocked'); return saved; },
		setItem(...args) { if (denied) throw Error('Storage blocked'); writes.push(args); }
	};
	let observe;
	runInNewContext(source, {
		document, window: { localStorage, matchMedia: () => system },
		MutationObserver: class { constructor(callback) { observe = callback; } observe() {} }
	});
	document.events.DOMContentLoaded();
	return { document, button, system, writes, menu, toggle, overlay, observe };
}

test('default dark mode does not write a preference until the user changes it', () => {
	const page = browser(null);
	assert.equal(page.document.documentElement.dataset.colorScheme, 'dark');
	assert.equal(page.button.textContent, 'Theme: Dark');
	assert.equal(page.writes.length, 0);
});

test('mode cycle persists the choice and auto follows the operating system', () => {
	const page = browser('dark');
	page.button.events.click();
	assert.equal(page.document.documentElement.dataset.colorScheme, 'light');
	page.button.events.click();
	assert.equal(page.document.documentElement.dataset.theme, 'auto');
	page.system.matches = false;
	page.system.change();
	assert.equal(page.document.documentElement.dataset.colorScheme, 'light');
	assert.deepEqual(page.writes.at(-1), ['luci-theme-mavxa', 'auto']);
});

test('invalid preferences and unavailable storage do not prevent theme changes', () => {
	assert.equal(browser('invalid').document.documentElement.dataset.theme, 'dark');
	const page = browser(null, true);
	assert.doesNotThrow(() => page.button.events.click());
	assert.equal(page.document.documentElement.dataset.theme, 'light');
});

test('Escape and overlay click close navigation and restore keyboard focus', () => {
	const page = browser(null);
	page.menu.classList.add('active');
	page.observe();
	assert.equal(page.toggle.attrs['aria-expanded'], 'true');
	page.document.events.keydown({ key: 'Escape' });
	assert.equal(page.menu.classList.contains('active'), false);
	assert.equal(page.toggle.focused, true);
	page.menu.classList.add('active');
	page.overlay.events.click();
	assert.equal(page.menu.classList.contains('active'), false);
});

test('registration preserves the selected theme and retries safely', () => {
	const folder = mkdtempSync(join(tmpdir(), 'mavxa-theme-test-'));
	try {
		const calls = join(folder, 'calls');
		writeFileSync(join(folder, 'uci'), '#!/bin/sh\nprintf "%s\\n" "$*" >> "$UCI_CALLS"\ncase "$*" in "-q get luci.themes") exit 1;; esac\n', { mode: 0o755 });
		const script = new URL('root/etc/uci-defaults/30_luci-theme-mavxa', root);
		for (let attempt = 0; attempt < 2; attempt++)
			execFileSync('sh', [script.pathname], { env: { ...process.env, PATH: folder + ':' + process.env.PATH, UCI_CALLS: calls } });
		const result = readFileSync(calls, 'utf8');
		assert.match(result, /set luci.themes.Mavxa=\/luci-static\/mavxa/);
		assert.doesNotMatch(result, /mediaurlbase|\.lang=|firewall|network/);
	} finally { rmSync(folder, { recursive: true, force: true }); }
});
