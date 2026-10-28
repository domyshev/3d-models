// Apply the theme before CSS paints; explicit choices override the device theme.
(() => {
  const key = 'iliago-3d-theme';
  const media = window.matchMedia('(prefers-color-scheme: dark)');
  let preference = 'system';
  try { preference = localStorage.getItem(key) || 'system'; } catch {}
  const valid = (value) => ['light', 'dark', 'system'].includes(value) ? value : 'system';
  preference = valid(preference);
  function apply() {
    const dark = preference === 'dark' || (preference === 'system' && media.matches);
    document.documentElement.dataset.theme = dark ? 'dark' : 'light';
    document.querySelector('meta[name="theme-color"]')?.setAttribute('content', dark ? '#191418' : '#faf7f7');
    const control = document.getElementById('theme');
    if (control) control.value = preference;
    window.dispatchEvent(new Event('themechange'));
  }
  apply();
  media.addEventListener('change', apply);
  window.addEventListener('storage', (event) => {
    if (event.key === key || event.key === null) {
      preference = valid(event.newValue);
      apply();
    }
  });
  document.addEventListener('DOMContentLoaded', () => {
    const control = document.getElementById('theme');
    control.value = preference;
    control.addEventListener('change', () => {
      preference = valid(control.value);
      try { localStorage.setItem(key, preference); } catch {}
      apply();
    });
  });
})();
