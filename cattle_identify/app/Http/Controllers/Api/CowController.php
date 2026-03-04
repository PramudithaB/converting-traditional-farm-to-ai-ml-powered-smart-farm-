<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cow;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class CowController extends Controller
{
    /**
     * GET /api/cows
     */
    public function index()
    {
        return response()->json(Cow::all());
    }

    /**
     * POST /api/cows
     * Cow registration
     */
    public function store(Request $request)
    {
        $data = $request->validate([
            'cow_id'           => 'required|string|max:255|unique:cows,cow_id',
            'name'             => 'required|string|max:255',
            'birthdate'        => 'nullable|date',
            'breed'            => 'nullable|string|max:255',
            'lactation_month'  => 'nullable|integer|min:0',
            'image'            => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        // Get the uploaded file ONCE
        $uploadedFile = $request->file('image'); // instance of UploadedFile

        // 1) Call Python service first, using the original temp file path
        $embeddingArray = null;

        try {
            $pythonResponse = Http::attach(
                'image', // field name expected by Python service
                file_get_contents($uploadedFile->getRealPath()),
                $uploadedFile->getClientOriginalName()
            )->post('http://127.0.0.1:5000/register');

            if (! $pythonResponse->successful()) {
                return response()->json([
                    'message' => 'Failed to get embedding from Python service.',
                    'error'   => $pythonResponse->body(),
                ], 502);
            }

            $json = $pythonResponse->json();

            // Adjust if your Python API returns a different JSON structure
            $embeddingArray = $json['embedding'] ?? null;

            if (! is_array($embeddingArray) || count($embeddingArray) !== 2048) {
                return response()->json([
                    'message' => 'Invalid embedding returned from Python service.',
                    'length'  => is_array($embeddingArray) ? count($embeddingArray) : null,
                ], 502);
            }
        } catch (\Throwable $e) {
            Log::error('Error calling Python embedding service', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Error calling embedding service.',
                'error'   => $e->getMessage(),
            ], 502);
        }

        // 2) Now move the file to your permanent location
        $imagePath = null;

        $extension = $uploadedFile->getClientOriginalExtension();
        $imageName = time() . '_' . Str::random(10) . '.' . $extension;

        $uploadedFile->move(public_path('uploads/assetImg'), $imageName);
        $imagePath = 'uploads/assetImg/' . $imageName;

        // 3) Save cow with embedding stored as JSON string
        $cow = Cow::create([
            'cow_id'          => $data['cow_id'],
            'name'            => $data['name'],
            'birthdate'       => $data['birthdate'] ?? null,
            'breed'           => $data['breed'] ?? null,
            'lactation_month' => $data['lactation_month'] ?? null,
            'image_path'      => $imagePath,
            'embedding'       => json_encode($embeddingArray),
        ]);

        return response()->json([
            'message' => 'Cow registered successfully.',
            'cow'     => $cow,
        ], 201);
    }

    /**
     * GET /api/cows/{cow}
     */
    public function show(Cow $cow)
    {
        return response()->json($cow);
    }

    /**
     * PUT/PATCH /api/cows/{cow}
     */
    public function update(Request $request, Cow $cow)
    {
        $data = $request->validate([
            'cow_id'           => 'sometimes|string|max:255|unique:cows,cow_id,' . $cow->id,
            'name'             => 'sometimes|string|max:255',
            'birthdate'        => 'nullable|date',
            'breed'            => 'nullable|string|max:255',
            'lactation_month'  => 'nullable|integer|min:0',
            'image'            => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
            'embedding'        => 'nullable',
        ]);

        // Start with existing image path
        $imagePath = $cow->image_path;

        // If a new image is uploaded, save it and optionally you could also re-generate embedding
        if ($request->hasFile('image')) {
            $uploadedFile = $request->file('image');

            $extension = $uploadedFile->getClientOriginalExtension();
            $imageName = time() . '_' . Str::random(10) . '.' . $extension;

            $uploadedFile->move(public_path('uploads/assetImg'), $imageName);
            $imagePath = 'uploads/assetImg/' . $imageName;
        }

        $cow->update([
            'cow_id'          => $data['cow_id'] ?? $cow->cow_id,
            'name'            => $data['name'] ?? $cow->name,
            'birthdate'       => $data['birthdate'] ?? $cow->birthdate,
            'breed'           => $data['breed'] ?? $cow->breed,
            'lactation_month' => $data['lactation_month'] ?? $cow->lactation_month,
            'image_path'      => $imagePath,
            'embedding'       => $data['embedding'] ?? $cow->embedding,
        ]);

        return response()->json([
            'message' => 'Cow updated successfully.',
            'cow'     => $cow,
        ]);
    }

    /**
     * DELETE /api/cows/{cow}
     */
    public function destroy(Cow $cow)
    {
        $cow->delete();

        return response()->json([
            'message' => 'Cow deleted successfully.',
        ], 204);
    }

    /**
     * POST /api/cows/identify
     * Identify cow from image by comparing embeddings
     */
    public function identify(Request $request)
    {
        $data = $request->validate([
            'image' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        $uploadedFile = $request->file('image');

        // 1) Get embedding for the input image from Python service
        try {
            $pythonResponse = Http::attach(
                'image',
                file_get_contents($uploadedFile->getRealPath()),
                $uploadedFile->getClientOriginalName()
            )->post('http://127.0.0.1:5000/register');

            if (! $pythonResponse->successful()) {
                return response()->json([
                    'message' => 'Failed to get embedding from Python service.',
                    'error'   => $pythonResponse->body(),
                ], 502);
            }

            $json = $pythonResponse->json();
            $queryEmbedding = $json['embedding'] ?? null;

            if (! is_array($queryEmbedding) || count($queryEmbedding) !== 2048) {
                return response()->json([
                    'message' => 'Invalid embedding returned from Python service.',
                    'length'  => is_array($queryEmbedding) ? count($queryEmbedding) : null,
                ], 502);
            }
        } catch (\Throwable $e) {
            Log::error('Error calling Python embedding service for identify', [
                'error' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => 'Error calling embedding service.',
                'error'   => $e->getMessage(),
            ], 502);
        }

        // 2) Compare with all stored cows
        $cows = Cow::all();

        if ($cows->isEmpty()) {
            return response()->json([
                'message' => 'No cows found in database.',
            ], 404);
        }

        $bestCow   = null;
        $bestScore = -INF;

        foreach ($cows as $cow) {
            if (empty($cow->embedding)) {
                continue;
            }

            $dbEmbedding = json_decode($cow->embedding, true);

            if (! is_array($dbEmbedding) || count($dbEmbedding) !== 2048) {
                continue;
            }

            $score = $this->cosineSimilarity($queryEmbedding, $dbEmbedding);

            if ($score > $bestScore) {
                $bestScore = $score;
                $bestCow   = $cow;
            }
        }

        if (! $bestCow) {
            return response()->json([
                'message' => 'No valid embeddings found to compare.',
            ], 404);
        }

        return response()->json([
            'message'    => 'Cow identified successfully.',
            'cow'        => $bestCow,
            'similarity' => $bestScore,
        ]);
    }

    public function indexWithoutEmbedding()
    {
        // Option 1: hide embedding using makeHidden
        $cows = Cow::all()->makeHidden(['embedding']);

        return response()->json($cows);
    }
    /**
     * Compute cosine similarity between two equal-length numeric arrays.
     */
    protected function cosineSimilarity(array $a, array $b): float
    {
        $dot   = 0.0;
        $normA = 0.0;
        $normB = 0.0;

        $count = count($a);
        for ($i = 0; $i < $count; $i++) {
            $ai = (float) $a[$i];
            $bi = (float) $b[$i];

            $dot   += $ai * $bi;
            $normA += $ai * $ai;
            $normB += $bi * $bi;
        }

        if ($normA == 0.0 || $normB == 0.0) {
            return -INF;
        }

        return $dot / (sqrt($normA) * sqrt($normB));
    }
}