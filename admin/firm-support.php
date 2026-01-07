<?php
require_once 'includes/header.php';
?>

<div class="container-fluid">
    <div class="row">
        <!-- Sidebar: Firm List -->
        <div class="col-md-4 col-lg-3 border-end p-0 bg-white" style="height: calc(100vh - 60px); overflow-y: auto;">
            <div class="p-3 border-bottom sticky-top bg-white">
                <h5 class="mb-0">Firma Mesajları</h5>
                <div class="input-group mt-2">
                    <span class="input-group-text bg-light border-end-0"><i class="fas fa-search text-muted"></i></span>
                    <input type="text" class="form-control bg-light border-start-0" id="searchFirmInput"
                        placeholder="Firma ara...">
                </div>
            </div>
            <div id="firmList" class="list-group list-group-flush">
                <!-- Firms will be loaded here -->
                <div class="text-center p-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Yükleniyor...</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chat Area -->
        <div class="col-md-8 col-lg-9 p-0 d-flex flex-column" style="height: calc(100vh - 60px);">
            <!-- Chat Header -->
            <div id="chatHeader" class="p-3 border-bottom bg-white d-flex justify-content-between align-items-center"
                style="display: none !important;">
                <div class="d-flex align-items-center">
                    <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center me-3"
                        style="width: 40px; height: 40px;">
                        <i class="fas fa-building"></i>
                    </div>
                    <div>
                        <h6 class="mb-0 fw-bold" id="activeFirmName">Firma Adı</h6>
                        <small class="text-muted" id="activeFirmId">ID: ...</small>
                    </div>
                </div>
                <div>
                    <button id="deleteChatBtn" class="btn btn-outline-danger btn-sm me-2" onclick="deleteConversation()"
                        title="Sohbeti Sil">
                        <i class="fas fa-trash-alt"></i>
                    </button>
                    <button class="btn btn-outline-secondary btn-sm" onclick="closeChat()" title="Kapat">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <!-- Empty State -->
            <div id="emptyState"
                class="d-flex flex-column align-items-center justify-content-center flex-grow-1 bg-light">
                <div class="bg-white p-4 rounded-circle shadow-sm mb-3">
                    <i class="fas fa-comments text-muted fa-3x"></i>
                </div>
                <h5 class="text-muted">Bir firma seçin</h5>
                <p class="text-muted small">Mesajlaşmayı başlatmak için soldaki listeden bir firma seçin.</p>
            </div>

            <!-- Chat Messages -->
            <div id="chatMessages" class="flex-grow-1 p-3 bg-light overflow-auto" style="display: none;">
                <!-- Messages will be loaded here -->
            </div>

            <!-- Chat Input -->
            <div id="chatInputArea" class="p-3 bg-white border-top" style="display: none;">
                <form id="messageForm" onsubmit="sendMessage(event)">
                    <div class="input-group">
                        <input type="text" class="form-control" id="messageInput" placeholder="Mesajınızı yazın..."
                            autocomplete="off">
                        <button class="btn btn-primary" type="submit">
                            <i class="fas fa-paper-plane me-1"></i> Gönder
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-app.js";
    import { getAuth, onAuthStateChanged } from 'https://www.gstatic.com/firebasejs/10.7.0/firebase-auth.js';
    import { getFirestore, collection, query, orderBy, onSnapshot, addDoc, serverTimestamp, doc, setDoc, getDoc, updateDoc, deleteDoc, getDocs, writeBatch } from "https://www.gstatic.com/firebasejs/10.7.0/firebase-firestore.js";

    // ... (rest of imports setup) ...
    // Note: I will inject the delete logic at the end of module script or attach to window

    // ... existing defined variables ... 

    // Add delete function to window
    window.deleteConversation = async function () {
        if (!activeFirmId) return;

        if (!confirm('Bu konuşmayı ve tüm mesaj geçmişini silmek istediğinize emin misiniz? Bu işlem geri alınamaz!')) {
            return;
        }

        const deleteBtn = document.getElementById('deleteChatBtn');
        const originalBtnContent = deleteBtn.innerHTML;
        deleteBtn.disabled = true;
        deleteBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';

        try {
            // 1. Delete all messages in subcollection
            const messagesRef = collection(db, "support_channels", activeFirmId, "messages");
            const snapshot = await getDocs(messagesRef);

            // Firestore client cannot delete collection, must delete docs. Use batches.
            const batch = writeBatch(db);
            let operationCounter = 0;

            snapshot.docs.forEach((d) => {
                batch.delete(d.ref);
                operationCounter++;
            });

            // Commit batch for messages
            if (operationCounter > 0) {
                await batch.commit();
            }

            // 2. Delete the channel document
            await deleteDoc(doc(db, "support_channels", activeFirmId));

            alert('Konuşma başarıyla silindi.');
            closeChat();

        } catch (error) {
            console.error("Error deleting conversation:", error);
            alert('Silme işlemi sırasında hata oluştu: ' + error.message);
        } finally {
            // If we didn't close chat (error case), restore button
            if (activeFirmId) {
                deleteBtn.disabled = false;
                deleteBtn.innerHTML = originalBtnContent;
            }
        }
    };

    // Firebase Config matched with support.php
    const firebaseConfig = {
        apiKey: "AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8",
        authDomain: "halisepetimbl.firebaseapp.com",
        projectId: "halisepetimbl",
        storageBucket: "halisepetimbl.firebasestorage.app",
        messagingSenderId: "782891273844",
        appId: "1:782891273844:web:750619b1bfe1939e52cb21"
    };

    // Initialize Firebase
    const app = initializeApp(firebaseConfig);
    const auth = getAuth(app);
    const db = getFirestore(app, 'haliyikamacimmbldatabase');

    let activeFirmId = null;
    let messagesUnsubscribe = null;

    // Auth Check
    onAuthStateChanged(auth, async (user) => {
        if (!user) {
            document.getElementById('firmList').innerHTML = '<div class="p-3 text-danger text-center">Oturum açılmadı.<br><a href="login.php">Giriş Yap</a></div>';
            return;
        }

        // Hide global loader and show layout
        document.getElementById('authCheck').classList.add('d-none');
        document.getElementById('mainLayout').style.display = 'block';

        // Start App
        loadFirms();
    });

    // Load Firms List (from support_channels)
    async function loadFirms() {
        const firmList = document.getElementById('firmList');
        // Because 'support_channels' might contain many firms, we'll listen to it.
        // Assuming document ID is firmId.

        const q = query(collection(db, "support_channels"), orderBy("lastMessageTime", "desc"));

        onSnapshot(q, (snapshot) => {
            firmList.innerHTML = '';

            if (snapshot.empty) {
                firmList.innerHTML = '<div class="p-3 text-muted text-center">Henüz destek mesajı yok.</div>';
                return;
            }

            snapshot.forEach((docSnap) => {
                const data = docSnap.data();
                const firmId = docSnap.id;
                const firmName = data.firmName || 'Bilinmeyen Firma';
                const lastMessage = data.lastMessage || '';

                // Safe Time Conversion
                let time = '';
                if (data.lastMessageTime && data.lastMessageTime.seconds) {
                    time = new Date(data.lastMessageTime.seconds * 1000).toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' });
                }

                const unreadCount = data.unreadCountAdmin || 0;
                const isActive = firmId === activeFirmId;

                const itemHtml = `
                    <a href="#" id="firm-item-${firmId}" class="list-group-item list-group-item-action ${isActive ? 'active' : ''}" onclick="selectFirm('${firmId}', '${firmName.replace(/'/g, "\\'")}')">
                        <div class="d-flex w-100 justify-content-between align-items-center">
                            <h6 class="mb-1 text-truncate" id="firm-name-${firmId}" style="max-width: 70%;">${firmName}</h6>
                            <small class="${isActive ? 'text-light' : 'text-muted'}">${time}</small>
                        </div>
                        <p class="mb-1 text-truncate small ${isActive ? 'text-light' : 'text-muted'}" style="max-width: 85%;">${lastMessage}</p>
                        ${unreadCount > 0 ? `<span class="position-absolute top-50 end-0 translate-middle-y me-3 badge rounded-pill bg-danger">${unreadCount}</span>` : ''}
                    </a>
                `;
                firmList.insertAdjacentHTML('beforeend', itemHtml);

                if (firmName === 'Bilinmeyen Firma') {
                    fetchRealFirmName(firmId);
                }
            });
        }, (error) => {
            console.error("Error loading firms:", error);
            firmList.innerHTML = `<div class="p-3 text-danger">Yükleme hatası: ${error.message}</div>`;
        });
    }

    async function fetchRealFirmName(firmId) {
        try {
            // Check 'firms' collection
            const firmDocRef = doc(db, "firms", firmId);
            const firmSnap = await getDoc(firmDocRef);

            if (firmSnap.exists()) {
                const realName = firmSnap.data().name || 'İsimsiz Firma';

                // Update UI
                const nameEl = document.getElementById(`firm-name-${firmId}`);
                if (nameEl) nameEl.textContent = realName;

                // Update onClick handler of the parent a tag to pass new name
                const itemEl = document.getElementById(`firm-item-${firmId}`);
                if (itemEl) {
                    itemEl.setAttribute('onclick', `selectFirm('${firmId}', '${realName.replace(/'/g, "\\'")}')`);

                    // If this firm is currently active, also update the Header title
                    const activeHeader = document.getElementById('activeFirmName');
                    if (activeHeader && window.activeFirmId === firmId) {
                        activeHeader.textContent = realName;
                    }
                }

                // Update 'support_channels' so we don't fetch next time
                await updateDoc(doc(db, "support_channels", firmId), {
                    firmName: realName
                });
            }
        } catch (e) {
            console.error("Error key fetching firm name:", e);
        }
    }


    window.selectFirm = function (firmId, firmName) {
        if (activeFirmId === firmId) return;
        activeFirmId = firmId;
        window.activeFirmId = firmId; // Allow helper to see it for header update

        // Update UI Header
        document.getElementById('activeFirmName').textContent = firmName;
        document.getElementById('activeFirmId').textContent = 'ID: ' + firmId;

        // Show Chat Area
        document.getElementById('emptyState').style.setProperty('display', 'none', 'important');
        document.getElementById('chatHeader').style.setProperty('display', 'flex', 'important');
        document.getElementById('chatMessages').style.display = 'block';
        document.getElementById('chatInputArea').style.display = 'block';

        // Update Active Class in List
        document.querySelectorAll('#firmList .list-group-item').forEach(el => el.classList.remove('active', 'text-white'));
        // Find the element again (hacky but works for now without proper ID) - actually we redraw list on snapshot so this might flicker.
        // Better: rely on snapshot re-render or add ID to list item.
        // For simplicity, let's just rely on the click behavior triggering a state change which the snapshot listener will eventually reflect if we re-render.
        // But preventing re-render flicker is better. Ideally we separate data from UI properly.
        // For this MVP PHP/JS mix:
        // loadFirms is reactive, so it will re-render list. We just need to make sure 'isActive' logic uses current activeFirmId.

        loadMessages(firmId);

        // Reset Admin Unread Count
        const channelRef = doc(db, "support_channels", firmId);
        updateDoc(channelRef, {
            unreadCountAdmin: 0
        }).catch(err => console.error("Error resetting unread count", err));
    };

    window.closeChat = function () {
        activeFirmId = null;
        if (messagesUnsubscribe) messagesUnsubscribe();

        document.getElementById('emptyState').style.setProperty('display', 'flex', 'important');
        document.getElementById('chatHeader').style.setProperty('display', 'none', 'important');
        document.getElementById('chatMessages').style.display = 'none';
        document.getElementById('chatInputArea').style.display = 'none';
    }

    function loadMessages(firmId) {
        if (messagesUnsubscribe) messagesUnsubscribe();
        const chatContainer = document.getElementById('chatMessages');
        chatContainer.innerHTML = '<div class="text-center p-3"><div class="spinner-border spinner-border-sm text-primary"></div></div>';

        const q = query(collection(db, "support_channels", firmId, "messages"), orderBy("timestamp", "asc"));

        messagesUnsubscribe = onSnapshot(q, (snapshot) => {
            chatContainer.innerHTML = '';

            if (snapshot.empty) {
                chatContainer.innerHTML = '<div class="text-center text-muted mt-5"><i class="fas fa-info-circle mb-2"></i><br>Bu firmayla henüz mesajlaşma geçmişi yok.</div>';
                return;
            }

            let lastDate = null;

            snapshot.forEach((doc) => {
                const msg = doc.data();
                const isMe = msg.senderId === 'admin'; // Admin sent this
                const time = msg.timestamp ? new Date(msg.timestamp.seconds * 1000) : new Date();

                // Date Divider
                const dateStr = time.toLocaleDateString('tr-TR');
                if (dateStr !== lastDate) {
                    chatContainer.insertAdjacentHTML('beforeend', `<div class="text-center my-3"><span class="badge bg-secondary opacity-50 fw-normal">${dateStr}</span></div>`);
                    lastDate = dateStr;
                }

                const bubbleHtml = `
                    <div class="d-flex mb-3 ${isMe ? 'justify-content-end' : 'justify-content-start'}">
                        <div class="card ${isMe ? 'bg-primary text-white border-primary' : 'bg-white border-light'} shadow-sm" style="max-width: 75%; border-radius: 12px; ${isMe ? 'border-bottom-right-radius: 2px' : 'border-bottom-left-radius: 2px'};">
                            <div class="card-body p-2 px-3">
                                <div class="d-flex justify-content-between align-items-center mb-1">
                                    <small class="${isMe ? 'text-white-50' : 'text-primary'} fw-bold me-3" style="font-size: 0.75rem;">${isMe ? 'Yönetici' : (msg.senderName || 'Firma')}</small>
                                </div>
                                <p class="mb-1" style="white-space: pre-wrap;">${msg.message}</p>
                                <div class="text-end">
                                    <small class="${isMe ? 'text-white-50' : 'text-muted'}" style="font-size: 0.7rem;">${time.toLocaleTimeString('tr-TR', { hour: '2-digit', minute: '2-digit' })}</small>
                                </div>
                            </div>
                        </div>
                    </div>
                `;
                chatContainer.insertAdjacentHTML('beforeend', bubbleHtml);
            });

            // Scroll to bottom
            chatContainer.scrollTop = chatContainer.scrollHeight;
        });
    }

    window.sendMessage = async function (e) {
        e.preventDefault();
        const input = document.getElementById('messageInput');
        const message = input.value.trim();

        if (!message || !activeFirmId) return;

        input.value = ''; // Clear early

        try {
            // 1. Add message to subcollection
            await addDoc(collection(db, "support_channels", activeFirmId, "messages"), {
                message: message,
                senderId: 'admin',
                senderName: 'Yönetici',
                timestamp: serverTimestamp(),
                isRead: false
            });

            // 2. Update channel metadata
            // Only update unreadCountFirm, reset unreadCountAdmin (since we are admin reading it)
            // Need current unreadCountFirm? safer to increment transactionally, but simple update is okay for now.
            // For now, let's just set fields directly.

            // To increment unreadforFirm, we need to know current. Or just set a flag 'hasUnreadForFirm: true'.
            // The mobile app uses 'hasUnreadForFirm' (boolean) on Orders, but for Support Channel likely similar approach.
            // Let's assume we maintain a counter or boolean.

            const channelRef = doc(db, "support_channels", activeFirmId);

            // We need to fetch current data to increment properly, or use increment()
            // Using setDoc with merge for lastMessage info
            await setDoc(channelRef, {
                lastMessage: message,
                lastMessageTime: serverTimestamp(),
                lastMessageSenderId: 'admin',
                unreadCountAdmin: 0, // Reset our count
                hasUnreadForFirm: true // Flag for mobile badge
            }, { merge: true });

        } catch (error) {
            console.error("Error sending message:", error);
            alert("Mesaj gönderilemedi.");
        }
    };

    // Start is handled in onAuthStateChanged
    // loadFirms();


    // Toggle Sidebar Mobile
    document.getElementById('sidebarToggle')?.addEventListener('click', () => {
        document.getElementById('sidebar').classList.toggle('show');
        document.getElementById('sidebarOverlay').classList.toggle('show');
    });

    document.getElementById('sidebarOverlay')?.addEventListener('click', () => {
        document.getElementById('sidebar').classList.remove('show');
        document.getElementById('sidebarOverlay').classList.remove('show');
    });
</script>

</div> <!-- End .main-content -->
</div> <!-- End #mainLayout -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>

</html>