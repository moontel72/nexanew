<?php

namespace App\Http\Controllers\Cricket;

use App\Http\Controllers\Controller;
use App\Http\Middleware\Cricket\CricketManagerAuth;
use App\Models\Cricket\ManagerSessionLog;
use App\Models\Cricket\VoiceScoreLog;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

/**
 * VoiceScoreController — Voice-to-Score via DeepSeek V4 Pro API.
 *
 * Cricket Manager speaks score updates (e.g., "four runs", "wicket, caught behind").
 * The audio is transcribed and sent to DeepSeek V4 Pro for structured parsing.
 *
 * Flow:
 *   1. Manager uploads audio or sends transcript text
 *   2. System sends to DeepSeek V4 Pro for parsing
 *   3. Parsed result is stored; manager confirms before applying to live score
 */
class VoiceScoreController extends Controller
{
    private const DEEPSEEK_API_URL = 'https://api.deepseek.com/v1/chat/completions';

    /**
     * Process voice input (transcript text) and return parsed score data.
     */
    public function process(Request $request): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $validator = Validator::make($request->all(), [
            'match_id' => 'required|uuid|exists:cricket_matches,id',
            'transcript' => 'required|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $matchId = $request->match_id;
        $transcript = $request->transcript;

        // Create log entry
        $log = VoiceScoreLog::create([
            'match_id' => $matchId,
            'cricket_manager_id' => $manager->id,
            'raw_transcript' => $transcript,
            'status' => 'processing',
        ]);

        $startTime = microtime(true);

        try {
            $parsed = $this->callDeepSeekForScoreParsing($transcript);
            $processingTime = (int) ((microtime(true) - $startTime) * 1000);

            $log->update([
                'parsed_score_data' => $parsed,
                'ai_response' => $parsed['_raw_response'] ?? null,
                'processing_time_ms' => $processingTime,
                'status' => 'parsed',
            ]);

            ManagerSessionLog::create([
                'cricket_manager_id' => $manager->id,
                'match_id' => $matchId,
                'action' => 'voice_score_input',
                'metadata' => ['transcript' => $transcript, 'parsed' => $parsed],
                'ip_address' => $request->ip(),
            ]);

            return response()->json([
                'message' => 'Voice input processed.',
                'voice_log_id' => $log->id,
                'parsed' => $parsed,
                'processing_time_ms' => $processingTime,
            ]);
        } catch (\Throwable $e) {
            $processingTime = (int) ((microtime(true) - $startTime) * 1000);

            $log->update([
                'status' => 'error',
                'error_message' => $e->getMessage(),
                'processing_time_ms' => $processingTime,
            ]);

            Log::error('Cricket Voice Score: DeepSeek API error', [
                'error' => $e->getMessage(),
                'transcript' => $transcript,
            ]);

            return response()->json([
                'message' => 'Voice parsing failed. Please enter score manually.',
                'error' => $e->getMessage(),
            ], 422);
        }
    }

    /**
     * Confirm and apply a parsed voice score to the live match.
     */
    public function apply(Request $request, string $logId): \Illuminate\Http\JsonResponse
    {
        $manager = CricketManagerAuth::manager($request);

        $log = VoiceScoreLog::findOrFail($logId);

        if ($log->status !== 'parsed') {
            return response()->json(['message' => 'Voice log is not in parsed state.'], 422);
        }

        $log->was_applied = true;
        $log->status = 'applied';
        $log->save();

        return response()->json([
            'message' => 'Voice score marked as applied.',
            'parsed_data' => $log->parsed_score_data,
        ]);
    }

    /**
     * Reject a parsed voice score without applying.
     */
    public function reject(Request $request, string $logId): \Illuminate\Http\JsonResponse
    {
        $log = VoiceScoreLog::findOrFail($logId);
        $log->status = 'rejected';
        $log->save();

        return response()->json(['message' => 'Voice score rejected.']);
    }

    /**
     * Get voice score logs for a match.
     */
    public function history(Request $request, string $matchId): \Illuminate\Http\JsonResponse
    {
        $logs = VoiceScoreLog::where('match_id', $matchId)
            ->with('cricketManager:id,name')
            ->latest()
            ->limit(50)
            ->get();

        return response()->json($logs);
    }

    /**
     * Health check — verify DeepSeek API key works.
     */
    public function health(): \Illuminate\Http\JsonResponse
    {
        $apiKey = config('services.deepseek.api_key');

        if (empty($apiKey)) {
            return response()->json(['status' => 'error', 'message' => 'No API key configured.'], 500);
        }

        try {
            $response = \Illuminate\Support\Facades\Http::timeout(5)
                ->withToken($apiKey)
                ->post('https://api.deepseek.com/v1/chat/completions', [
                    'model' => 'deepseek-chat',
                    'messages' => [
                        ['role' => 'user', 'content' => 'Say "DeepSeek API is working!"'],
                    ],
                    'max_tokens' => 20,
                ]);

            if ($response->successful()) {
                return response()->json([
                    'status' => 'ok',
                    'message' => 'DeepSeek API connected successfully.',
                    'response' => $response->json('choices.0.message.content'),
                ]);
            }

            return response()->json([
                'status' => 'error',
                'message' => 'API returned HTTP ' . $response->status(),
                'body' => $response->body(),
            ], 500);
        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Call DeepSeek V4 Pro API to parse cricket score voice input.
     *
     * The system prompt instructs the AI to extract structured cricket
     * scoring data from natural language input.
     */
    private function callDeepSeekForScoreParsing(string $transcript): array
    {
        $apiKey = config('services.deepseek.api_key');

        if (empty($apiKey)) {
            // Fallback: use local pattern matching
            return $this->localFallbackParsing($transcript);
        }

        $systemPrompt = <<<'PROMPT'
You are a cricket scoring assistant. Parse the user's voice input into a structured JSON object for a cricket score update.

Output ONLY valid JSON with these fields:
{
  "runs": integer (0-7),
  "is_wicket": boolean,
  "wicket_type": string or null (one of: "bowled", "caught", "lbw", "run_out", "stumped", "hit_wicket"),
  "dismissed_player_name": string or null,
  "extras_type": string or null (one of: "wide", "no_ball", "bye", "leg_bye"),
  "commentary_hint": string (brief description of what happened)
}

Rules:
- "dot ball", "no run" → runs: 0
- "single", "one run" → runs: 1
- "two runs", "double" → runs: 2
- "three runs" → runs: 3
- "four", "boundary" → runs: 4
- "six", "maximum" → runs: 6
- If a wicket fell, set is_wicket: true and infer wicket_type
- "wide" → extras_type: "wide", runs: 1
- "no ball" → extras_type: "no_ball", runs: 1
- "bye" → extras_type: "bye"
- "leg bye" → extras_type: "leg_bye"

Example inputs and outputs:
Input: "Four runs through covers"
Output: {"runs":4,"is_wicket":false,"wicket_type":null,"dismissed_player_name":null,"extras_type":null,"commentary_hint":"Four runs through covers"}

Input: "Bowled him! Clean bowled, middle stump"
Output: {"runs":0,"is_wicket":true,"wicket_type":"bowled","dismissed_player_name":null,"extras_type":null,"commentary_hint":"Bowled! Clean bowled, middle stump"}

Input: "Wide ball down leg side"
Output: {"runs":1,"is_wicket":false,"wicket_type":null,"dismissed_player_name":null,"extras_type":"wide","commentary_hint":"Wide ball down leg side"}
PROMPT;

        $response = Http::timeout(10)
            ->withToken($apiKey)
            ->post(self::DEEPSEEK_API_URL, [
                'model' => 'deepseek-chat',
                'messages' => [
                    ['role' => 'system', 'content' => $systemPrompt],
                    ['role' => 'user', 'content' => "Parse this cricket commentary: \"{$transcript}\""],
                ],
                'temperature' => 0.1,
                'max_tokens' => 200,
            ]);

        if (!$response->successful()) {
            throw new \RuntimeException('DeepSeek API error: ' . $response->status());
        }

        $body = $response->json();
        $content = $body['choices'][0]['message']['content'] ?? '{}';

        // Extract JSON from response (in case AI wraps it in markdown)
        $json = $this->extractJson($content);
        $parsed = json_decode($json, true);

        if (!is_array($parsed)) {
            throw new \RuntimeException('Failed to parse AI response as JSON.');
        }

        $parsed['_raw_response'] = $content;

        return $parsed;
    }

    /**
     * Local fallback when DeepSeek API is unavailable.
     */
    private function localFallbackParsing(string $transcript): array
    {
        $transcript = strtolower(trim($transcript));
        $result = [
            'runs' => 0,
            'is_wicket' => false,
            'wicket_type' => null,
            'dismissed_player_name' => null,
            'extras_type' => null,
            'commentary_hint' => $transcript,
        ];

        // Detect runs
        if (preg_match('/\b(six|maximum|sixer)\b/', $transcript)) {
            $result['runs'] = 6;
        } elseif (preg_match('/\b(four|boundary|four runs?)\b/', $transcript)) {
            $result['runs'] = 4;
        } elseif (preg_match('/\b(three runs?|3 runs?)\b/', $transcript)) {
            $result['runs'] = 3;
        } elseif (preg_match('/\b(two runs?|double|2 runs?)\b/', $transcript)) {
            $result['runs'] = 2;
        } elseif (preg_match('/\b(single|one run|1 run)\b/', $transcript)) {
            $result['runs'] = 1;
        }

        // Detect wickets
        if (preg_match('/\b(bowl(ed)?|clean bowl)\b/', $transcript)) {
            $result['is_wicket'] = true;
            $result['wicket_type'] = 'bowled';
        } elseif (preg_match('/\b(caught|caught behind|caught and bowled)\b/', $transcript)) {
            $result['is_wicket'] = true;
            $result['wicket_type'] = 'caught';
        } elseif (preg_match('/\b(lbw|leg before)\b/', $transcript)) {
            $result['is_wicket'] = true;
            $result['wicket_type'] = 'lbw';
        } elseif (preg_match('/\b(run out|runout)\b/', $transcript)) {
            $result['is_wicket'] = true;
            $result['wicket_type'] = 'run_out';
        } elseif (preg_match('/\b(stump(ed)?)\b/', $transcript)) {
            $result['is_wicket'] = true;
            $result['wicket_type'] = 'stumped';
        } elseif (preg_match('/\b(wicket|out)\b/', $transcript)) {
            $result['is_wicket'] = true;
        }

        // Detect extras
        if (preg_match('/\b(wide)\b/', $transcript)) {
            $result['extras_type'] = 'wide';
            $result['runs'] = max($result['runs'], 1);
        } elseif (preg_match('/\b(no ball|no-ball)\b/', $transcript)) {
            $result['extras_type'] = 'no_ball';
            $result['runs'] = max($result['runs'], 1);
        } elseif (preg_match('/\b(bye|byes)\b/', $transcript)) {
            $result['extras_type'] = 'bye';
        } elseif (preg_match('/\b(leg bye|leg byes)\b/', $transcript)) {
            $result['extras_type'] = 'leg_bye';
        }

        $result['_raw_response'] = 'local_fallback';
        return $result;
    }

    private function extractJson(string $content): string
    {
        // Remove markdown code fences if present
        $content = preg_replace('/```(?:json)?\s*/', '', $content);
        $content = str_replace('```', '', $content);
        $content = trim($content);

        return $content;
    }
}
