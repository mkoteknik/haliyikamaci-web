/**
 * Halı Yıkamacı - Firebase Initialization
 */

// Firebase configuration
const firebaseConfig = {
    apiKey: "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8",
    authDomain: "halisepetimbl.firebaseapp.com",
    projectId: "halisepetimbl",
    storageBucket: "halisepetimbl.firebasestorage.app",
    messagingSenderId: "782891273844",
    appId: "1:782891273844:web:750619b1bfe1939e52cb21"
};

// Initialize Firebase
const app = firebase.initializeApp(firebaseConfig);

// Auth reference
const auth = firebase.auth();

// Firestore with named database - using REST API approach for named database
const FIRESTORE_BASE_URL = `https://firestore.googleapis.com/v1/projects/${firebaseConfig.projectId}/databases/haliyikamacimmbldatabase/documents`;

// Helper function to fetch from Firestore REST API
async function firestoreGet(collection, queryParams = '') {
    const separator = queryParams ? '&' : '?';
    const url = `${FIRESTORE_BASE_URL}/${collection}?key=${firebaseConfig.apiKey}${queryParams ? separator + queryParams : ''}`;
    const response = await fetch(url);
    if (!response.ok) {
        const errorText = await response.text();
        console.error('Firestore error:', response.status, errorText);
        throw new Error(`Firestore error: ${response.status}`);
    }
    return response.json();
}

// Parse Firestore document format
function parseFirestoreDoc(doc) {
    const data = {};
    if (!doc.fields) return data;

    for (const [key, value] of Object.entries(doc.fields)) {
        if (value.stringValue !== undefined) data[key] = value.stringValue;
        else if (value.integerValue !== undefined) data[key] = parseInt(value.integerValue);
        else if (value.doubleValue !== undefined) data[key] = value.doubleValue;
        else if (value.booleanValue !== undefined) data[key] = value.booleanValue;
        else if (value.timestampValue !== undefined) data[key] = new Date(value.timestampValue);
        else if (value.mapValue !== undefined) data[key] = parseFirestoreDoc(value.mapValue);
        else if (value.arrayValue !== undefined) {
            data[key] = (value.arrayValue.values || []).map(v => {
                if (v.stringValue !== undefined) return v.stringValue;
                if (v.mapValue !== undefined) return parseFirestoreDoc(v.mapValue);
                return v;
            });
        }
    }
    return data;
}

// Get document ID from name
function getDocId(docName) {
    const parts = docName.split('/');
    return parts[parts.length - 1];
}

// Auth state observer
auth.onAuthStateChanged((user) => {
    const userAuthArea = document.getElementById('userAuthArea');

    if (user) {
        // Kullanıcı giriş yapmış
        userAuthArea.innerHTML = `
            <div class="dropdown">
                <button class="btn btn-warning btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                    <i class="fas fa-user me-1"></i>${user.phoneNumber || user.email || 'Hesabım'}
                </button>
                <ul class="dropdown-menu dropdown-menu-end">
                    <li><a class="dropdown-item" href="/customer/my-orders.php">
                        <i class="fas fa-box me-2"></i>Siparişlerim
                    </a></li>
                    <li><a class="dropdown-item" href="/customer/profile.php">
                        <i class="fas fa-user-cog me-2"></i>Profilim
                    </a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item text-danger" href="#" onclick="signOut()">
                        <i class="fas fa-sign-out-alt me-2"></i>Çıkış Yap
                    </a></li>
                </ul>
            </div>
        `;
    } else {
        // Kullanıcı giriş yapmamış
        userAuthArea.innerHTML = `
            <a href="/customer/login.php" class="btn btn-warning btn-sm">
                <i class="fas fa-user me-1"></i>Giriş Yap
            </a>
        `;
    }
});

// Sign out function
function signOut() {
    auth.signOut().then(() => {
        window.location.href = '/';
    }).catch((error) => {
        console.error('Çıkış hatası:', error);
    });
}

// Helper functions
function formatPrice(price) {
    return new Intl.NumberFormat('tr-TR', {
        style: 'currency',
        currency: 'TRY'
    }).format(price);
}

function formatDate(timestamp) {
    if (!timestamp) return '-';
    const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
    return new Intl.DateTimeFormat('tr-TR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    }).format(date);
}

// Status labels
const ORDER_STATUSES = {
    pending: 'Bekliyor',
    confirmed: 'Onaylandı',
    picked_up: 'Teslim Alındı',
    measured: 'Ölçüm Yapıldı',
    out_for_delivery: 'Dağıtıma Çıktı',
    delivered: 'Teslim Edildi',
    cancelled: 'İptal'
};

function getStatusBadge(status) {
    return `<span class="badge badge-status badge-${status}">${ORDER_STATUSES[status] || status}</span>`;
}


