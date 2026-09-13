<?php

use App\Http\Controllers\Api\AgentCommandController;
use App\Http\Controllers\Api\AgentConfigController;
use App\Http\Controllers\Api\AgentHeartbeatController;
use App\Http\Controllers\Api\AgentRegistrationController;
use App\Http\Middleware\EnsureValidDeviceToken;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// API Version 1
Route::prefix('v1')->group(function () {
    // 1. Agent Registration / Pairing (Public endpoint with Pairing Code)
    Route::post('/agent/register', [AgentRegistrationController::class, 'register']);

    // 2. Authenticated Agent Endpoints (Requires Bearer <device_token>)
    Route::middleware([EnsureValidDeviceToken::class])->group(function () {
        Route::post('/agent/heartbeat', [AgentHeartbeatController::class, 'heartbeat']);
        Route::post('/agent/commands/{id}/ack', [AgentCommandController::class, 'ack']);
        Route::get('/agent/config', [AgentConfigController::class, 'getConfig']);
        Route::post('/agent/hardware', [\App\Http\Controllers\Api\AgentHardwareController::class, 'sync']);
        Route::post('/agent/software', [\App\Http\Controllers\Api\AgentSoftwareController::class, 'sync']);
        Route::post('/agent/violations', [\App\Http\Controllers\Api\AgentViolationController::class, 'report']);
    });
});
