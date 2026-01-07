<?php

class FirebaseService
{
    private $projectId;
    private $apiKey;
    private $databaseId;
    private $baseUrl;

    public function __construct()
    {
        // Config from existing JS files
        $this->projectId = 'halisepetimbl';
        $this->apiKey = 'AIzaSyAZBzUpPtWHnW3mlF38L7YGpiknMB9dZb8';
        $this->databaseId = 'haliyikamacimmbldatabase'; // Named database

        // Firestore REST API Base URL
        // https://firestore.googleapis.com/v1/projects/{projectId}/databases/{databaseId}/documents
        $this->baseUrl = "https://firestore.googleapis.com/v1/projects/{$this->projectId}/databases/{$this->databaseId}/documents";
    }

    /**
     * Get documents from a collection
     * @param string $collection Collection name (e.g. 'firms')
     * @param int $limit Max results
     * @return array
     */
    public function getDocuments($collection, $limit = 100)
    {
        $url = "{$this->baseUrl}/{$collection}?pageSize={$limit}&key={$this->apiKey}";

        $response = $this->makeRequest($url);

        if (isset($response['documents'])) {
            return array_map([$this, 'formatDocument'], $response['documents']);
        }

        return [];
    }

    /**
     * Get a single document by ID
     * @param string $collection
     * @param string $id
     * @return array|null
     */
    public function getDocument($collection, $id)
    {
        $url = "{$this->baseUrl}/{$collection}/{$id}?key={$this->apiKey}";

        $response = $this->makeRequest($url);

        if (isset($response['fields'])) {
            return $this->formatDocument($response);
        }

        return null;
    }

    private function makeRequest($url)
    {
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // For local dev, might need true in prod
        curl_setopt($ch, CURLOPT_TIMEOUT, 5);

        $result = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($httpCode >= 200 && $httpCode < 300) {
            return json_decode($result, true);
        }

        return null;
    }

    /**
     * Convert Firestore raw JSON format to simple array
     * Firestore format: {"fields": {"name": {"stringValue": "..."}}}
     */
    private function formatDocument($doc)
    {
        if (!isset($doc['fields']))
            return [];

        $data = [];
        // Extract ID from name path: projects/.../documents/collection/ID
        $pathParts = explode('/', $doc['name']);
        $data['id'] = end($pathParts);

        foreach ($doc['fields'] as $key => $value) {
            $data[$key] = $this->parseValue($value);
        }

        return $data;
    }

    private function parseValue($value)
    {
        if (isset($value['stringValue']))
            return $value['stringValue'];
        if (isset($value['integerValue']))
            return (int) $value['integerValue'];
        if (isset($value['doubleValue']))
            return (float) $value['doubleValue'];
        if (isset($value['booleanValue']))
            return $value['booleanValue'];
        if (isset($value['timestampValue']))
            return $value['timestampValue'];
        if (isset($value['arrayValue'])) {
            $arr = [];
            if (isset($value['arrayValue']['values'])) {
                foreach ($value['arrayValue']['values'] as $v) {
                    $arr[] = $this->parseValue($v);
                }
            }
            return $arr;
        }
        if (isset($value['mapValue'])) {
            $map = [];
            if (isset($value['mapValue']['fields'])) {
                foreach ($value['mapValue']['fields'] as $k => $v) {
                    $map[$k] = $this->parseValue($v);
                }
            }
            return $map;
        }
        return null;
    }
}
