document.addEventListener('DOMContentLoaded', () => {
    // Theme Toggler
    const themeToggle = document.getElementById('theme-toggle');
    const body = document.body;

    // Load saved theme from localStorage
    const savedTheme = localStorage.getItem('theme') || 'dark-theme';
    body.className = savedTheme;

    themeToggle.addEventListener('click', () => {
        if (body.classList.contains('dark-theme')) {
            body.classList.replace('dark-theme', 'light-theme');
            localStorage.setItem('theme', 'light-theme');
        } else {
            body.classList.replace('light-theme', 'dark-theme');
            localStorage.setItem('theme', 'dark-theme');
        }
    });

    // Accordion Logic
    const accordions = document.querySelectorAll('.accordion-button');

    accordions.forEach(button => {
        button.addEventListener('click', () => {
            button.classList.toggle('active');
            const panel = button.nextElementSibling;

            if (panel.style.maxHeight) {
                panel.style.maxHeight = null;
            } else {
                panel.style.maxHeight = panel.scrollHeight + "px";
            }
        });
    });
});
