(() => {
  const root = document.documentElement;
  const themeButton = document.getElementById('theme-toggle');
  const themes = ['system', 'light', 'dark'];

  const themeLabel = (theme) => `Color theme: ${theme}`;
  const updateThemeButton = () => {
    if (!themeButton) return;
    const theme = root.dataset.theme || 'system';
    themeButton.dataset.theme = theme;
    themeButton.title = themeLabel(theme);
    themeButton.setAttribute('aria-label', `${themeLabel(theme)}. Activate to change.`);
  };

  themeButton?.addEventListener('click', () => {
    const current = root.dataset.theme || 'system';
    const next = themes[(themes.indexOf(current) + 1) % themes.length];
    root.dataset.theme = next;
    localStorage.setItem('ulp-docs-theme', next);
    updateThemeButton();
  });
  updateThemeButton();

  const navigation = document.getElementById('documentation-navigation');
  const navigationButton = document.getElementById('navigation-toggle');
  navigationButton?.addEventListener('click', () => {
    const isOpen = navigation?.classList.toggle('open') ?? false;
    navigationButton.setAttribute('aria-expanded', String(isOpen));
  });
  navigation?.addEventListener('click', (event) => {
    if (event.target instanceof HTMLAnchorElement && window.innerWidth < 900) {
      navigation.classList.remove('open');
      navigationButton?.setAttribute('aria-expanded', 'false');
    }
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === '/' && !event.ctrlKey && !event.metaKey && !event.altKey &&
        !(event.target instanceof HTMLInputElement) && !(event.target instanceof HTMLTextAreaElement)) {
      event.preventDefault();
      document.getElementById('top-search')?.focus();
    }
  });

  document.querySelectorAll('.markdown-body pre').forEach((block) => {
    const code = block.querySelector('code');
    if (!code) return;
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'copy-code';
    button.textContent = 'Copy';
    button.setAttribute('aria-label', 'Copy code block');
    button.addEventListener('click', async () => {
      await navigator.clipboard.writeText(code.textContent || '');
      button.textContent = 'Copied';
      window.setTimeout(() => { button.textContent = 'Copy'; }, 1400);
    });
    block.appendChild(button);
  });
})();

