<?php
require_once 'config/app.php';
require_once 'includes/FirebaseService.php';

header("Content-Type: application/xml; charset=utf-8");

echo '<?xml version="1.0" encoding="UTF-8"?>';
?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <!-- Static Pages -->
    <url>
        <loc><?php echo SITE_URL; ?>/</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>daily</changefreq>
        <priority>1.0</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/hakkimizda</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.8</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/iletisim</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.8</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/firmalar</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>daily</changefreq>
        <priority>0.9</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/kampanyalar</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>daily</changefreq>
        <priority>0.9</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/customer/login.php</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.6</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/firma-girisi</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.6</priority>
    </url>
    <url>
        <loc><?php echo SITE_URL; ?>/firma-kayit</loc>
        <lastmod><?php echo date('Y-m-d'); ?></lastmod>
        <changefreq>monthly</changefreq>
        <priority>0.7</priority>
    </url>

    <!-- Dynamic Firms -->
    <?php
    try {
        $firebase = new FirebaseService();
        $firms = $firebase->getDocuments('firms', 200); // Fetch last 200 firms
    
        foreach ($firms as $firm) {
            // Check if firm is approved (simple check if field exists and is true)
            // Note: If isApproved is strictly boolean true.
            if (isset($firm['isApproved']) && $firm['isApproved']) {
                $id = $firm['id'];
                $slug = isset($firm['slug']) ? $firm['slug'] : (isset($firm['name']) ? slugify($firm['name']) : 'firma');

                // Construct SEO Friendly URL
                $url = SITE_URL . "/firma/" . $slug . "-" . $id;

                echo "<url>\n";
                echo "    <loc>{$url}</loc>\n";
                echo "    <lastmod>" . date('Y-m-d') . "</lastmod>\n"; // Ideally use firm updated_at
                echo "    <changefreq>weekly</changefreq>\n";
                echo "    <priority>0.8</priority>\n";
                echo "</url>\n";
            }
        }

        // Dynamic Campaigns
        $campaigns = $firebase->getDocuments('campaigns', 100);
        foreach ($campaigns as $campaign) {
            if (isset($campaign['isActive']) && $campaign['isActive']) {
                // Check if campaign is expired
                $endDate = isset($campaign['endDate']) ? strtotime($campaign['endDate']) : time() + 86400;
                if ($endDate > time()) {
                    // Campaigns usually point to firm detail or have their own page?
                    // Currently campaigns link to firm detail in the UI. 
                    // But if we want them indexed, maybe they are just additional entry points to firm.
                    // Or if there is a specific campaign page, add it.
                    // For now, let's skip campaigns as individual URLs if they don't have unique pages,
                    // BUT valid SEO strategy is to have them if they have content.
                    // The UI shows a modal. No specific page.
                    // So we might skip adding campaign URLs if they just open a modal on homepage.
                    // However, we CAN link to firm page with a query param or anchor?
                    // Let's stick to Firms for now as they are the main content.
                }
            }
        }

    } catch (Exception $e) {
        // Silently fail or log error, but don't break XML
    }

    /**
     * Helper to create SEO friendly slug
     */
    function slugify($text)
    {
        $text = preg_replace('~[^\pL\d]+~u', '-', $text);
        $text = iconv('utf-8', 'us-ascii//TRANSLIT', $text);
        $text = preg_replace('~[^-\w]+~', '', $text);
        $text = trim($text, '-');
        $text = strtolower($text);
        if (empty($text))
            return 'n-a';
        return $text;
    }
    ?>
</urlset>