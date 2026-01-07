/**
 * Simple Cookie Consent Banner
 * - Stores consent in localStorage
 * - Shows banner if no consent found
 */
(function () {
    const CONSENT_KEY = 'cookie_consent_accepted';

    // Check if already accepted
    if (localStorage.getItem(CONSENT_KEY) === 'true') {
        return;
    }

    // Create banner HTML
    const banner = document.createElement('div');
    banner.id = 'cookie-banner';
    banner.style.position = 'fixed';
    banner.style.bottom = '0';
    banner.style.left = '0';
    banner.style.width = '100%';
    banner.style.backgroundColor = '#1a1a2e';
    banner.style.color = '#fff';
    banner.style.padding = '15px 20px';
    banner.style.zIndex = '9999';
    banner.style.boxShadow = '0 -2px 10px rgba(0,0,0,0.2)';
    banner.style.display = 'flex';
    banner.style.flexDirection = 'column';
    banner.style.alignItems = 'center';
    banner.style.justifyContent = 'center';
    banner.style.gap = '15px';

    // Responsive layout
    if (window.innerWidth > 768) {
        banner.style.flexDirection = 'row';
        banner.style.justifyContent = 'space-between';
    }

    const text = document.createElement('div');
    text.innerHTML = `
        <span style="font-size: 14px;">
            Size daha iyi bir deneyim sunmak için çerezleri (cookies) kullanıyoruz. 
            Detaylı bilgi için <a href="/yasal/cerez-politikasi" style="color: #E91E63; text-decoration: underline;">Çerez Politikamızı</a> 
            inceleyebilirsiniz.
        </span>
    `;

    const btnContainer = document.createElement('div');
    btnContainer.style.display = 'flex';
    btnContainer.style.gap = '10px';

    const acceptBtn = document.createElement('button');
    acceptBtn.innerText = 'Kabul Et';
    acceptBtn.style.backgroundColor = '#E91E63';
    acceptBtn.style.color = '#fff';
    acceptBtn.style.border = 'none';
    acceptBtn.style.padding = '8px 20px';
    acceptBtn.style.borderRadius = '5px';
    acceptBtn.style.cursor = 'pointer';
    acceptBtn.style.fontWeight = 'bold';
    acceptBtn.style.fontSize = '13px';

    acceptBtn.onclick = function () {
        localStorage.setItem(CONSENT_KEY, 'true');
        banner.style.display = 'none';
    };

    btnContainer.appendChild(acceptBtn);
    banner.appendChild(text);
    banner.appendChild(btnContainer);

    document.body.appendChild(banner);
})();
