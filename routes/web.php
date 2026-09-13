<?php

use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ComputerController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\KioskController;
use App\Http\Controllers\LabController;
use App\Http\Controllers\ScheduleController;
use Illuminate\Support\Facades\Route;

// Authentication
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
});

Route::post('/logout', [AuthController::class, 'logout'])->name('logout')->middleware('auth');

// Protected Dashboard Routes
Route::middleware('auth')->group(function () {
    Route::get('/', [DashboardController::class, 'index'])->name('home');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/dashboard/status-feed', [DashboardController::class, 'statusFeed'])->name('dashboard.status-feed');

    // Labs
    Route::get('/labs', [LabController::class, 'index'])->name('labs.index');
    Route::post('/labs', [LabController::class, 'store'])->name('labs.store');
    Route::get('/labs/{lab}', [LabController::class, 'show'])->name('labs.show');
    Route::post('/labs/{lab}/pairing-code', [LabController::class, 'generatePairingCode'])->name('labs.pairing-code');
    Route::post('/labs/{lab}/commands', [LabController::class, 'sendCommand'])->name('labs.commands');

    // Computers
    Route::get('/computers', [ComputerController::class, 'index'])->name('computers.index');
    Route::get('/computers/{computer}', [ComputerController::class, 'show'])->name('computers.show');
    Route::put('/computers/{computer}', [ComputerController::class, 'update'])->name('computers.update');
    Route::delete('/computers/{computer}', [ComputerController::class, 'destroy'])->name('computers.destroy');
    Route::post('/computers/{computer}/commands', [ComputerController::class, 'sendCommand'])->name('computers.commands');
    Route::post('/computers/{computer}/wake', [ComputerController::class, 'wake'])->name('computers.wake');

    // Schedules (Fase 2)
    Route::get('/schedules', [ScheduleController::class, 'index'])->name('schedules.index');
    Route::post('/schedules', [ScheduleController::class, 'store'])->name('schedules.store');
    Route::post('/schedules/{schedule}/toggle', [ScheduleController::class, 'toggle'])->name('schedules.toggle');
    Route::delete('/schedules/{schedule}', [ScheduleController::class, 'destroy'])->name('schedules.destroy');

    // Kiosk Mode (Fase 2)
    Route::get('/kiosk-mode', [KioskController::class, 'index'])->name('kiosk.index');
    Route::post('/labs/{lab}/kiosk', [KioskController::class, 'updateLab'])->name('kiosk.update-lab');

    // Audit Logs & Commands History
    Route::get('/audit-logs', [AuditLogController::class, 'index'])->name('audit-logs.index');
});
