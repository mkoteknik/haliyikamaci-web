/**
 * Türkiye API Service for Dynamic Location Data
 * API: https://api.turkiyeapi.dev
 */

const TurkiyeApiService = {
    baseUrl: 'https://api.turkiyeapi.dev/api/v1',

    // Cache for better performance
    cache: {
        provinces: null,
        districts: {},
        neighborhoods: {}
    },

    /**
     * Get all provinces (İller)
     */
    async getProvinces() {
        if (this.cache.provinces) {
            return this.cache.provinces;
        }

        try {
            const response = await fetch(`${this.baseUrl}/provinces`);
            if (!response.ok) throw new Error('API Error');

            const result = await response.json();
            const provinces = result.data.map(p => ({
                id: p.id,
                name: p.name,
                isMetropolitan: p.isMetropolitan
            }));

            // Sort by name
            provinces.sort((a, b) => a.name.localeCompare(b.name, 'tr'));

            this.cache.provinces = provinces;
            return provinces;
        } catch (error) {
            console.error('Provinces fetch error:', error);
            return [];
        }
    },

    /**
     * Get districts (İlçeler) by province ID
     */
    async getDistrictsByProvinceId(provinceId) {
        if (this.cache.districts[provinceId]) {
            return this.cache.districts[provinceId];
        }

        try {
            const response = await fetch(`${this.baseUrl}/provinces/${provinceId}`);
            if (!response.ok) throw new Error('API Error');

            const result = await response.json();
            const districts = (result.data.districts || []).map(d => ({
                id: d.id,
                name: d.name
            }));

            // Sort by name
            districts.sort((a, b) => a.name.localeCompare(b.name, 'tr'));

            this.cache.districts[provinceId] = districts;
            return districts;
        } catch (error) {
            console.error('Districts fetch error:', error);
            return [];
        }
    },

    /**
     * Get neighborhoods (Mahalleler) by district ID
     */
    async getNeighborhoodsByDistrictId(districtId) {
        if (this.cache.neighborhoods[districtId]) {
            return this.cache.neighborhoods[districtId];
        }

        try {
            const response = await fetch(`${this.baseUrl}/districts/${districtId}`);
            if (!response.ok) throw new Error('API Error');

            const result = await response.json();
            const neighborhoods = (result.data.neighborhoods || []).map(n => ({
                id: n.id,
                name: n.name
            }));

            // Sort by name
            neighborhoods.sort((a, b) => a.name.localeCompare(b.name, 'tr'));

            this.cache.neighborhoods[districtId] = neighborhoods;
            return neighborhoods;
        } catch (error) {
            console.error('Neighborhoods fetch error:', error);
            return [];
        }
    }
};

/**
 * Address Selector Component
 * Populates İl / İlçe / Semt dropdowns dynamically
 */
class AddressSelector {
    constructor(options) {
        this.provinceSelect = document.getElementById(options.provinceId);
        this.districtSelect = document.getElementById(options.districtId);
        this.neighborhoodSelect = document.getElementById(options.neighborhoodId);
        this.fullAddressInput = document.getElementById(options.fullAddressId);

        this.onAddressChange = options.onAddressChange || (() => { });

        this.init();
    }

    async init() {
        // Load provinces
        await this.loadProvinces();

        // Province change event
        this.provinceSelect.addEventListener('change', async () => {
            await this.loadDistricts();
            this.clearNeighborhoods();
            this.triggerChange();
        });

        // District change event
        this.districtSelect.addEventListener('change', async () => {
            await this.loadNeighborhoods();
            this.triggerChange();
        });

        // Neighborhood change event
        this.neighborhoodSelect.addEventListener('change', () => {
            this.triggerChange();
        });

        // Full address change event
        if (this.fullAddressInput) {
            this.fullAddressInput.addEventListener('input', () => {
                this.triggerChange();
            });
        }
    }

    async loadProvinces() {
        this.provinceSelect.innerHTML = '<option value="">Yükleniyor...</option>';
        this.provinceSelect.disabled = true;

        const provinces = await TurkiyeApiService.getProvinces();

        this.provinceSelect.innerHTML = '<option value="">İl Seçiniz...</option>';
        provinces.forEach(p => {
            const option = document.createElement('option');
            option.value = p.id;
            option.textContent = p.name;
            option.dataset.name = p.name;
            this.provinceSelect.appendChild(option);
        });

        this.provinceSelect.disabled = false;
    }

    async loadDistricts() {
        const provinceId = this.provinceSelect.value;

        if (!provinceId) {
            this.clearDistricts();
            return;
        }

        this.districtSelect.innerHTML = '<option value="">Yükleniyor...</option>';
        this.districtSelect.disabled = true;

        const districts = await TurkiyeApiService.getDistrictsByProvinceId(provinceId);

        this.districtSelect.innerHTML = '<option value="">İlçe Seçiniz...</option>';
        districts.forEach(d => {
            const option = document.createElement('option');
            option.value = d.id;
            option.textContent = d.name;
            option.dataset.name = d.name;
            this.districtSelect.appendChild(option);
        });

        this.districtSelect.disabled = false;
    }

    async loadNeighborhoods() {
        const districtId = this.districtSelect.value;

        if (!districtId) {
            this.clearNeighborhoods();
            return;
        }

        this.neighborhoodSelect.innerHTML = '<option value="">Yükleniyor...</option>';
        this.neighborhoodSelect.disabled = true;

        const neighborhoods = await TurkiyeApiService.getNeighborhoodsByDistrictId(districtId);

        this.neighborhoodSelect.innerHTML = '<option value="">Mahalle Seçiniz...</option>';
        neighborhoods.forEach(n => {
            const option = document.createElement('option');
            option.value = n.id;
            option.textContent = n.name;
            option.dataset.name = n.name;
            this.neighborhoodSelect.appendChild(option);
        });

        this.neighborhoodSelect.disabled = false;
    }

    clearDistricts() {
        this.districtSelect.innerHTML = '<option value="">Önce il seçiniz...</option>';
        this.districtSelect.disabled = true;
        this.clearNeighborhoods();
    }

    clearNeighborhoods() {
        this.neighborhoodSelect.innerHTML = '<option value="">Önce ilçe seçiniz...</option>';
        this.neighborhoodSelect.disabled = true;
    }

    triggerChange() {
        const address = this.getAddress();
        this.onAddressChange(address);
    }

    getAddress() {
        const provinceOption = this.provinceSelect.selectedOptions[0];
        const districtOption = this.districtSelect.selectedOptions[0];
        const neighborhoodOption = this.neighborhoodSelect.selectedOptions[0];

        return {
            provinceId: this.provinceSelect.value,
            provinceName: provinceOption?.dataset?.name || '',
            districtId: this.districtSelect.value,
            districtName: districtOption?.dataset?.name || '',
            neighborhoodId: this.neighborhoodSelect.value,
            neighborhoodName: neighborhoodOption?.dataset?.name || '',
            fullAddress: this.fullAddressInput?.value || ''
        };
    }

    isValid() {
        const address = this.getAddress();
        return address.provinceId && address.districtId && address.neighborhoodId;
    }

    /**
     * Auto-fill address from GPS location
     * Uses OpenStreetMap Nominatim for Reverse Geocoding
     * @param {Function} onStatus Callback (status, message) => {}
     */
    async autoFillFromLocation(onStatus) {
        if (!navigator.geolocation) {
            onStatus('error', 'Tarayıcınız konum servisini desteklemiyor.');
            return;
        }

        // Ensure provinces are loaded
        if (this.provinceSelect.options.length <= 1) {
            onStatus('loading', 'İl listesi yükleniyor...');
            try {
                await this.loadProvinces();
            } catch (e) {
                onStatus('error', 'İl listesi yüklenemedi. İnternet bağlantınızı kontrol edin.');
                return;
            }
        }

        onStatus('loading', 'Konum alınıyor...');

        const getPosition = (options) => {
            return new Promise((resolve, reject) => {
                navigator.geolocation.getCurrentPosition(resolve, reject, options);
            });
        };

        try {
            let position;
            try {
                // Attempt 1: High Accuracy (Short timeout, fresh)
                position = await getPosition({ enableHighAccuracy: true, timeout: 5000, maximumAge: 0 });
            } catch (err) {
                // High accuracy failed, trying low accuracy

                // Attempt 2: Low Accuracy (Longer timeout, allow cached)
                onStatus('loading', 'Konum hassas alınamadı, genel konumdeneniyor...');
                position = await getPosition({ enableHighAccuracy: false, timeout: 15000, maximumAge: 300000 });
            }

            const lat = position.coords.latitude;
            const lon = position.coords.longitude;

            onStatus('loading', 'Adres çözümleniyor...');

            // Use local proxy to avoid CORS/Network issues
            // Fetches from Nominatim via PHP server-side
            const response = await fetch(`/api/get_location.php?lat=${lat}&lon=${lon}`);

            if (!response.ok) throw new Error(`Sunucu hatası: ${response.status}`);

            const data = await response.json();
            const addr = data.address;

            if (!addr) throw new Error('Adres bulunamadı');

            // Map OSM fields to our structure
            const provinceName = addr.province || addr.city || addr.state;
            const districtName = addr.town || addr.district || addr.county || addr.city_district || addr.city;
            const neighborhoodName = addr.suburb || addr.neighbourhood || addr.quarter;
            const road = addr.road || '';
            const houseNumber = addr.house_number || '';

            // Construct full address
            let fullAddressRaw = '';
            if (road) fullAddressRaw += road;
            if (houseNumber) fullAddressRaw += ' No: ' + houseNumber;

            // 1. Select Province
            if (await this.selectOptionByName(this.provinceSelect, provinceName)) {
                await this.loadDistricts();
                await new Promise(r => setTimeout(r, 100)); // Render delay
            }

            // 2. Select District
            if (await this.selectOptionByName(this.districtSelect, districtName)) {
                await this.loadNeighborhoods();
                await new Promise(r => setTimeout(r, 100)); // Render delay
            }

            // 3. Select Neighborhood
            await this.selectOptionByName(this.neighborhoodSelect, neighborhoodName);

            // 4. Fill Full Address
            if (this.fullAddressInput) {
                this.fullAddressInput.value = fullAddressRaw;
            }

            this.triggerChange();
            onStatus('success', `Adres bulundu: ${provinceName}/${districtName}`);

        } catch (err) {
            console.error(err);
            let msg = 'Konum alınamadı.';
            if (err.code === 1) msg = 'Konum izni reddedildi.';
            else if (err.code === 2) msg = 'Konum verisi alınamadı.';
            else if (err.code === 3) msg = 'Konum zaman aşımı.';
            else if (err.message) msg = err.message;

            if (msg === 'Failed to fetch') msg = 'Harita servisine ulaşılamadı. Bağlantınızı kontrol edin.';

            onStatus('error', msg);
        }
    }

    async selectOptionByName(selectElement, name) {
        if (!name) return false;
        // Normalize: Turkish lowercase and trim
        const search = name.toLocaleLowerCase('tr').trim();
        const options = selectElement.options;

        // 1. Exact match
        for (let i = 0; i < options.length; i++) {
            if (options[i].textContent.toLocaleLowerCase('tr').trim() === search) {
                selectElement.selectedIndex = i;
                return true;
            }
        }

        // 2. Remove Common Suffixes (İli, İlçesi, Mah., Mahallesi, Merkez)
        const cleanName = (str) => str
            .replace(' ili', '')
            .replace(' ilçesi', '')
            .replace(' mahallesi', '')
            .replace(' mah.', '')
            .replace(' mah', '')
            .replace(' merkez', '')
            .replace(' belediyesi', '')
            .replace(' valiliği', '')
            .replace(' kaymakamlığı', '')
            .trim();

        const cleanSearch = cleanName(search);

        for (let i = 0; i < options.length; i++) {
            const optName = options[i].textContent.toLocaleLowerCase('tr').trim();
            if (cleanName(optName) === cleanSearch) {
                selectElement.selectedIndex = i;
                return true;
            }
        }

        // 3. Contains / Partial Match
        if (search.length > 3) {
            for (let i = 0; i < options.length; i++) {
                const optName = options[i].textContent.toLocaleLowerCase('tr').trim();
                if (optName.includes(search) || search.includes(optName)) {
                    selectElement.selectedIndex = i;
                    return true;
                }
            }
        }

        return false;
    }


}
