<?php
// Default values if not set
$searchCity = isset($_GET['city']) ? htmlspecialchars($_GET['city']) : '';
$searchDistrict = isset($_GET['district']) ? htmlspecialchars($_GET['district']) : '';
$searchQuery = isset($_GET['q']) ? htmlspecialchars($_GET['q']) : '';

// Form ID can be customized if needed, default to mainSearchForm
$formId = isset($searchFormId) ? $searchFormId : 'mainSearchForm';
?>

<div class="search-box">
    <form action="<?php echo SITE_URL; ?>/firmalar" method="GET" id="<?php echo $formId; ?>">
        <div class="row g-3 align-items-center">
            <!-- City Selection -->
            <div class="col-md-3">
                <div class="input-group">
                    <span class="input-group-text bg-transparent border-0">
                        <i class="fas fa-map-marker-alt text-primary"></i>
                    </span>
                    <select name="city" id="searchCity" class="form-select border-0 bg-light" aria-label="İl Seçin">
                        <option value="">İl Seçin</option>
                        <?php if ($searchCity): ?>
                            <option value="<?php echo $searchCity; ?>" selected><?php echo $searchCity; ?></option>
                        <?php endif; ?>
                    </select>
                </div>
            </div>
            <!-- District Selection -->
            <div class="col-md-3">
                <div class="input-group">
                    <span class="input-group-text bg-transparent border-0">
                        <i class="fas fa-map-pin text-primary"></i>
                    </span>
                    <select name="district" id="searchDistrict" class="form-select border-0 bg-light"
                        aria-label="İlçe Seçin" <?php echo empty($searchDistrict) ? 'disabled' : ''; ?>>
                        <option value="">İlçe Seçin</option>
                        <?php if ($searchDistrict): ?>
                            <option value="<?php echo $searchDistrict; ?>" selected><?php echo $searchDistrict; ?></option>
                        <?php endif; ?>
                    </select>
                </div>
            </div>
            <!-- Search Input -->
            <div class="col-md-4">
                <div class="input-group">
                    <span class="input-group-text bg-transparent border-0">
                        <i class="fas fa-search text-primary"></i>
                    </span>
                    <input type="text" name="q" id="searchQuery" class="form-control border-0 bg-light"
                        aria-label="Arama metni" placeholder="Firma adı veya hizmet ara..."
                        value="<?php echo $searchQuery; ?>">
                </div>
            </div>
            <!-- Filter Button -->
            <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100">
                    <i class="fas fa-search me-2"></i>Ara
                </button>
            </div>
        </div>
    </form>
</div>

<script>
    document.addEventListener('DOMContentLoaded', async function () {
        const citySelect = document.getElementById('searchCity');
        const districtSelect = document.getElementById('searchDistrict');
        const initialCity = "<?php echo $searchCity; ?>";
        const initialDistrict = "<?php echo $searchDistrict; ?>";

        // Helper to check if TurkiyeApiService is available
        function waitForApi() {
            if (typeof TurkiyeApiService !== 'undefined') {
                initDropdowns();
            } else {
                setTimeout(waitForApi, 100);
            }
        }

        waitForApi();

        async function initDropdowns() {
            try {
                // If options not loaded (length <= 2 means only default + selected), load them
                if (citySelect.options.length <= 2) {
                    // Load Cities
                    const provinces = await TurkiyeApiService.getProvinces();

                    // Clear but keep selected if exists
                    const currentVal = citySelect.value;
                    citySelect.innerHTML = '<option value="">İl Seçin</option>';

                    provinces.forEach(p => {
                        const opt = document.createElement('option');
                        opt.value = p.name;
                        opt.dataset.id = p.id;
                        opt.textContent = p.name;
                        if (p.name === currentVal) opt.selected = true;
                        citySelect.appendChild(opt);
                    });
                }

                // If city is selected, load districts
                if (citySelect.value) {
                    const selectedOpt = citySelect.options[citySelect.selectedIndex];
                    const provinceId = selectedOpt.dataset.id || (await TurkiyeApiService.getProvinces()).find(p => p.name === citySelect.value)?.id;

                    if (provinceId) {
                        const districts = await TurkiyeApiService.getDistrictsByProvinceId(provinceId);
                        const currentDist = districtSelect.value; // saved from PHP render

                        districtSelect.innerHTML = '<option value="">İlçe Seçin</option>';
                        districts.forEach(d => {
                            const opt = document.createElement('option');
                            opt.value = d.name;
                            opt.textContent = d.name;
                            if (d.name === currentDist) opt.selected = true;
                            districtSelect.appendChild(opt);
                        });
                        districtSelect.disabled = false;
                    }
                }

                // Handle City Change
                citySelect.addEventListener('change', async function () {
                    const selectedOption = this.options[this.selectedIndex];
                    const provinceId = selectedOption.dataset.id;

                    if (!provinceId) {
                        districtSelect.innerHTML = '<option value="">İlçe Seçin</option>';
                        districtSelect.disabled = true;
                        return;
                    }

                    // Load Districts
                    districtSelect.innerHTML = '<option value="">Yükleniyor...</option>';
                    districtSelect.disabled = true;

                    const districts = await TurkiyeApiService.getDistrictsByProvinceId(provinceId);

                    districtSelect.innerHTML = '<option value="">İlçe Seçin</option>';
                    districts.forEach(d => {
                        const opt = document.createElement('option');
                        opt.value = d.name;
                        opt.textContent = d.name;
                        districtSelect.appendChild(opt);
                    });
                    districtSelect.disabled = false;
                });

            } catch (error) {
                console.error('Konum verileri yüklenirken hata:', error);
            }
        }
    });
</script>