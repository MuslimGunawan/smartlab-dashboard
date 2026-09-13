<?php

use App\Http\Controllers\AuditLogController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BlocklistController;
use App\Http\Controllers\ComputerController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\IssueReportController;
use App\Http\Controllers\KioskController;
use App\Http\Controllers\LabController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\ScheduleController;
use App\Http\Controllers\SettingController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\ViolationController;
use Illuminate\Support\Facades\Route;

// Authentication
Route::middleware('guest')->group(function () {
    Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
    Route::post('/login', [AuthController::class, 'login']);
});

Route::post('/logout', [AuthController::class, 'logout'])->name('logout')->middleware('auth');

// Public Issue Reporting (Mahasiswa Scan QR Meja / Link dari PC)
Route::get('/report-issue/{token}', [IssueReportController::class, 'create'])->name('report-issue.create');
Route::post('/report-issue/{token}', [IssueReportController::class, 'store'])->name('report-issue.store');
Route::get('/report-issue/{token}/success', [IssueReportController::class, 'success'])->name('report-issue.success');

// Protected Dashboard Routes (All Authenticated ASLAB / Admin)
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
    Route::delete('/computers/{computer}', [ComputerController::class, 'destroy'])->name('computers.destroy')->middleware('role:super_admin,aslab_senior');
    Route::post('/computers/{computer}/commands', [ComputerController::class, 'sendCommand'])->name('computers.commands');
    Route::post('/computers/{computer}/wake', [ComputerController::class, 'wake'])->name('computers.wake');
    Route::post('/computers/{computer}/cleanup', [ComputerController::class, 'cleanup'])->name('computers.cleanup');
    Route::post('/computers/{computer}/software/{softwareId}/uninstall', [ComputerController::class, 'uninstallSoftware'])->name('computers.software.uninstall')->middleware('role:super_admin,aslab_senior');

    // Issue Tracker (Fase 4)
    Route::get('/issues', [IssueReportController::class, 'index'])->name('issues.index');
    Route::patch('/issues/{issue}', [IssueReportController::class, 'updateStatus'])->name('issues.update-status');
    Route::delete('/issues/{issue}', [IssueReportController::class, 'destroy'])->name('issues.destroy')->middleware('role:super_admin,aslab_senior');

    // Laporan Bulanan & Export (Fase 4)
    Route::get('/reports/monthly', [ReportController::class, 'monthly'])->name('reports.monthly');
    Route::get('/reports/monthly/export-csv', [ReportController::class, 'exportCsv'])->name('reports.monthly.export-csv');

    // Schedules (Fase 2)
    Route::get('/schedules', [ScheduleController::class, 'index'])->name('schedules.index');
    Route::post('/schedules', [ScheduleController::class, 'store'])->name('schedules.store')->middleware('role:super_admin,aslab_senior');
    Route::post('/schedules/{schedule}/toggle', [ScheduleController::class, 'toggle'])->name('schedules.toggle')->middleware('role:super_admin,aslab_senior');
    Route::delete('/schedules/{schedule}', [ScheduleController::class, 'destroy'])->name('schedules.destroy')->middleware('role:super_admin,aslab_senior');

    // Kiosk Mode (Fase 2)
    Route::get('/kiosk-mode', [KioskController::class, 'index'])->name('kiosk.index');
    Route::post('/labs/{lab}/kiosk', [KioskController::class, 'updateLab'])->name('kiosk.update-lab')->middleware('role:super_admin,aslab_senior');

    // Blocklist Apps (Fase 3)
    Route::get('/blocklist', [BlocklistController::class, 'index'])->name('blocklist.index');
    Route::post('/blocklist', [BlocklistController::class, 'store'])->name('blocklist.store')->middleware('role:super_admin,aslab_senior');
    Route::patch('/blocklist/{blocklist}/toggle', [BlocklistController::class, 'toggle'])->name('blocklist.toggle')->middleware('role:super_admin,aslab_senior');
    Route::delete('/blocklist/{blocklist}', [BlocklistController::class, 'destroy'])->name('blocklist.destroy')->middleware('role:super_admin,aslab_senior');

    // Violations (Fase 3)
    Route::get('/violations', [ViolationController::class, 'index'])->name('violations.index');
    Route::patch('/violations/{violation}/resolve', [ViolationController::class, 'resolve'])->name('violations.resolve');

    // Audit Logs & Commands History
    Route::get('/audit-logs', [AuditLogController::class, 'index'])->name('audit-logs.index');

    // User Management (Fase 4 - Super Admin Only)
    Route::middleware('role:super_admin')->group(function () {
        Route::get('/users', [UserController::class, 'index'])->name('users.index');
        Route::post('/users', [UserController::class, 'store'])->name('users.store');
        Route::put('/users/{user}', [UserController::class, 'update'])->name('users.update');
        Route::delete('/users/{user}', [UserController::class, 'destroy'])->name('users.destroy');
    });

    // System Settings & Telegram (Fase 4 - Super Admin & Senior)
    Route::middleware('role:super_admin,aslab_senior')->group(function () {
        Route::get('/settings', [SettingController::class, 'index'])->name('settings.index');
        Route::post('/settings', [SettingController::class, 'store'])->name('settings.store');
        Route::post('/settings/test-telegram', [SettingController::class, 'testTelegram'])->name('settings.test-telegram');
    });
});
