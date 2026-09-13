<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\AuditLog;
use App\Models\Computer;
use App\Models\Violation;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class AgentViolationController extends Controller
{
    public function report(Request $request): JsonResponse
    {
        /** @var Computer $computer */
        $computer = $request->get('current_computer');

        $validated = $request->validate([
            'process_name' => 'required|string|max:255',
            'detected_at' => 'nullable|string',
            'screenshot' => 'nullable|file|mimes:jpeg,jpg,png,webp|max:10240', // max 10MB
            'active_user' => 'nullable|string|max:100',
        ]);

        $screenshotPath = null;
        if ($request->hasFile('screenshot')) {
            $file = $request->file('screenshot');
            $filename = 'violation_' . $computer->id . '_' . time() . '.' . $file->getClientOriginalExtension();
            $path = $file->storeAs('violations', $filename, 'public');
            $screenshotPath = '/storage/' . $path;
        } elseif ($request->filled('screenshot_base64')) {
            $data = base64_decode($request->screenshot_base64);
            if ($data !== false && strlen($data) > 0) {
                $filename = 'violation_' . $computer->id . '_' . time() . '.jpg';
                \Illuminate\Support\Facades\Storage::disk('public')->put('violations/' . $filename, $data);
                $screenshotPath = '/storage/violations/' . $filename;
            }
        }

        $detectedAt = !empty($validated['detected_at'])
            ? Carbon::parse($validated['detected_at'])
            : Carbon::now();

        $violation = Violation::create([
            'computer_id' => $computer->id,
            'process_name' => $validated['process_name'],
            'screenshot_path' => $screenshotPath,
            'detected_at' => $detectedAt,
            'resolved' => false,
        ]);

        \App\Services\TelegramService::notifyViolation($violation);

        AuditLog::create([
            'user_id' => null,
            'aksi' => 'violation_detected',
            'target' => "Computer #{$computer->id} ({$computer->nama_pc})",
            'detail' => [
                'violation_id' => $violation->id,
                'process_name' => $validated['process_name'],
                'active_user' => $validated['active_user'] ?? $computer->status,
                'screenshot' => $screenshotPath,
            ],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Laporan pelanggaran berhasil dicatat.',
            'violation_id' => $violation->id,
        ]);
    }
}
