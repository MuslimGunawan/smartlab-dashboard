<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Issue Reports (Pelaporan kerusakan hardware/meja oleh mahasiswa)
        Schema::create('issue_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->nullable()->constrained('computers')->nullOnDelete();
            $table->foreignId('lab_id')->nullable()->constrained('labs')->nullOnDelete();
            $table->string('reporter_name', 120);
            $table->string('reporter_nim', 32)->nullable();
            $table->string('reporter_contact', 64)->nullable(); // No WhatsApp / HP
            $table->string('category', 64); // mouse, keyboard, monitor, pc_hang, network, software, other
            $table->text('description');
            $table->string('status', 32)->default('pending')->index(); // pending, in_progress, resolved
            $table->foreignId('resolved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('resolution_notes')->nullable();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();
            $table->index(['computer_id', 'status']);
            $table->index(['lab_id', 'status']);
        });

        // 2. Settings (Pengaturan sistem seperti Telegram alerts, email, dll)
        Schema::create('settings', function (Blueprint $table) {
            $table->id();
            $table->string('key', 128)->unique();
            $table->text('value')->nullable();
            $table->string('group', 64)->default('general');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('issue_reports');
        Schema::dropIfExists('settings');
    }
};
