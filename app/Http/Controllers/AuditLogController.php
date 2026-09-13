<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Command;
use Illuminate\View\View;

class AuditLogController extends Controller
{
    public function index(): View
    {
        $auditLogs = AuditLog::with('user')
            ->latest()
            ->paginate(30);

        $commands = Command::with(['computer', 'lab', 'creator'])
            ->latest()
            ->take(30)
            ->get();

        return view('audit_logs.index', compact('auditLogs', 'commands'));
    }
}
