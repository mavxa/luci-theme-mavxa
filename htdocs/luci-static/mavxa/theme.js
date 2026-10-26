/* SPDX-License-Identifier: Apache-2.0 */
(function () {
	'use strict';

	var key = 'luci-theme-mavxa';
	var modes = ['dark', 'light', 'auto'];
	var mode = 'dark';
	var system = window.matchMedia('(prefers-color-scheme: dark)');
	try {
		var saved = window.localStorage.getItem(key);
		if (modes.indexOf(saved) !== -1)
			mode = saved;
	} catch (_) {}

	function apply() {
		var scheme = mode === 'auto' ? (system.matches ? 'dark' : 'light') : mode;
		document.documentElement.dataset.theme = mode;
		document.documentElement.dataset.colorScheme = scheme;
		var meta = document.querySelector('meta[name="theme-color"]');
		if (meta)
			meta.content = scheme === 'dark' ? '#09090b' : '#fafafa';
		var button = document.getElementById('mavxa-theme-toggle');
		if (button) {
			var label = 'Theme: ' + mode.charAt(0).toUpperCase() + mode.slice(1);
			button.textContent = label;
			button.setAttribute('aria-label', label);
		}
	}

	apply();
	system.addEventListener('change', apply);

	document.addEventListener('DOMContentLoaded', function () {
		apply();
		var button = document.getElementById('mavxa-theme-toggle');
		if (button)
			button.addEventListener('click', function () {
				mode = modes[(modes.indexOf(mode) + 1) % modes.length];
				try { window.localStorage.setItem(key, mode); } catch (_) {}
				apply();
			});

		var menu = document.getElementById('mainmenu');
		var toggle = document.querySelector('#menubar > .navigation');
		var overlay = document.getElementById('mavxa-menu-overlay');
		if (!menu || !toggle || !overlay)
			return;

		function syncMenu() {
			var open = menu.classList.contains('active');
			toggle.setAttribute('aria-expanded', String(open));
			document.body.classList.toggle('mavxa-menu-open', open);
		}

		function closeMenu() {
			menu.classList.remove('active');
			toggle.classList.remove('active');
			syncMenu();
			toggle.focus();
		}

		new MutationObserver(syncMenu).observe(menu, { attributes: true, attributeFilter: ['class'] });
		overlay.addEventListener('click', closeMenu);
		document.addEventListener('keydown', function (event) {
			if (event.key === 'Escape' && menu.classList.contains('active'))
				closeMenu();
		});
		syncMenu();
	});
})();
