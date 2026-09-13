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
        // 1. Labs
        Schema::create('labs', function (Blueprint $table) {
            $table->id();
            $table->string('nama_lab');
            $table->string('lokasi')->nullable();
            $table->text('deskripsi')->nullable();
            $table->timestamps();
        });

        // 2. User Lab Pivot
        Schema::create('user_lab', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('lab_id')->constrained('labs')->onDelete('cascade');
            $table->timestamps();
            $table->unique(['user_id', 'lab_id']);
        });

        // 3. Computers
        Schema::create('computers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_id')->nullable()->constrained('labs')->nullOnDelete();
            $table->string('nama_pc');
            $table->string('hostname')->nullable();
            $table->string('device_token', 128)->unique();
            $table->string('mac_address', 64)->nullable()->index();
            $table->string('ip_terakhir', 64)->nullable();
            $table->string('status', 32)->default('offline')->index(); // online, offline
            $table->string('versi_agent', 32)->nullable();
            $table->string('active_user', 64)->nullable();
            $table->unsignedBigInteger('uptime_seconds')->default(0);
            $table->timestamp('last_seen_at')->nullable()->index();
            $table->timestamps();
        });

        // 4. Pairing Codes
        Schema::create('pairing_codes', function (Blueprint $table) {
            $table->id();
            $table->string('code', 32)->unique();
            $table->foreignId('lab_id')->constrained('labs')->onDelete('cascade');
            $table->foreignId('computer_id')->nullable()->constrained('computers')->nullOnDelete();
            $table->boolean('is_used')->default(false);
            $table->timestamp('expired_at')->index();
            $table->timestamps();
        });

        // 5. Commands
        Schema::create('commands', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->nullable()->constrained('computers')->cascadeOnDelete();
            $table->foreignId('lab_id')->nullable()->constrained('labs')->nullOnDelete();
            $table->string('tipe', 64); // shutdown, restart, broadcast, wol, uninstall_agent, kiosk_toggle, cleanup, etc.
            $table->json('payload')->nullable();
            $table->string('status', 32)->default('pending')->index(); // pending, executed, failed
            $table->text('result_message')->nullable();
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('executed_at')->nullable();
            $table->timestamps();

            $table->index(['computer_id', 'status']);
            $table->index(['created_at']);
        });

        // 6. Schedules
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_id')->constrained('labs')->cascadeOnDelete();
            $table->string('tipe', 32); // shutdown, restart, cleanup
            $table->time('waktu');
            $table->json('hari'); // ["senin", "selasa", ...]
            $table->boolean('aktif')->default(true);
            $table->timestamps();
        });

        // 7. Agent Versions
        Schema::create('agent_versions', function (Blueprint $table) {
            $table->id();
            $table->string('versi', 32)->unique();
            $table->text('changelog')->nullable();
            $table->string('github_release_url')->nullable();
            $table->boolean('mandatory')->default(false);
            $table->timestamp('released_at')->nullable();
            $table->timestamps();
        });

        // 8. Audit Logs
        Schema::create('audit_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->string('aksi');
            $table->string('target')->nullable();
            $table->json('detail')->nullable();
            $table->timestamps();

            $table->index(['created_at']);
        });

        // 9. Blocklist Apps
        Schema::create('blocklist_apps', function (Blueprint $table) {
            $table->id();
            $table->string('process_name');
            $table->string('keterangan')->nullable();
            $table->foreignId('dibuat_oleh')->nullable()->constrained('users')->nullOnDelete();
            $table->boolean('aktif')->default(true);
            $table->timestamps();
        });

        // 10. Violations
        Schema::create('violations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->constrained('computers')->cascadeOnDelete();
            $table->string('process_name');
            $table->string('screenshot_path')->nullable();
            $table->string('webcam_path')->nullable();
            $table->timestamp('detected_at')->index();
            $table->boolean('resolved')->default(false);
            $table->timestamps();

            $table->index(['computer_id', 'detected_at']);
        });

        // 11. Installed Software
        Schema::create('installed_software', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->constrained('computers')->cascadeOnDelete();
            $table->string('nama');
            $table->string('versi')->nullable();
            $table->string('tanggal_install')->nullable();
            $table->unsignedBigInteger('ukuran_kb')->nullable();
            $table->text('uninstall_string')->nullable();
            $table->timestamp('terdeteksi_pertama_at')->nullable();
            $table->timestamp('terakhir_dicek_at')->nullable();
            $table->timestamps();

            $table->index(['computer_id', 'nama']);
        });

        // 12. Software Actions
        Schema::create('software_actions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->constrained('computers')->cascadeOnDelete();
            $table->string('software_name');
            $table->string('aksi'); // uninstall
            $table->string('status')->default('pending'); // pending, success, failed
            $table->foreignId('dikirim_oleh')->nullable()->constrained('users')->nullOnDelete();
            $table->text('keterangan_gagal')->nullable();
            $table->timestamps();
        });

        // 13. Software Events
        Schema::create('software_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->constrained('computers')->cascadeOnDelete();
            $table->string('software_name');
            $table->string('tipe'); // installed, removed
            $table->timestamp('detected_at')->index();
            $table->timestamps();

            $table->index(['computer_id', 'detected_at']);
        });

        // 14. Hardware Specs
        Schema::create('hardware_specs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->unique()->constrained('computers')->cascadeOnDelete();
            $table->string('serial_number')->nullable();
            $table->string('processor')->nullable();
            $table->decimal('ram_gb', 8, 2)->nullable();
            $table->string('os_version')->nullable();
            $table->timestamps();
        });

        // 15. Disk Partitions
        Schema::create('disk_partitions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('computer_id')->constrained('computers')->cascadeOnDelete();
            $table->string('drive_letter', 8);
            $table->decimal('total_gb', 10, 2)->default(0);
            $table->decimal('free_gb', 10, 2)->default(0);
            $table->timestamps();

            $table->index(['computer_id', 'drive_letter']);
        });

        // 16. Kiosk Settings
        Schema::create('kiosk_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('lab_id')->nullable()->constrained('labs')->cascadeOnDelete();
            $table->foreignId('computer_id')->nullable()->constrained('computers')->cascadeOnDelete();
            $table->boolean('disable_taskmgr')->default(false);
            $table->boolean('disable_cmd')->default(false);
            $table->boolean('disable_regedit')->default(false);
            $table->boolean('disable_control_panel')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kiosk_settings');
        Schema::dropIfExists('disk_partitions');
        Schema::dropIfExists('hardware_specs');
        Schema::dropIfExists('software_events');
        Schema::dropIfExists('software_actions');
        Schema::dropIfExists('installed_software');
        Schema::dropIfExists('violations');
        Schema::dropIfExists('blocklist_apps');
        Schema::dropIfExists('audit_logs');
        Schema::dropIfExists('agent_versions');
        Schema::dropIfExists('schedules');
        Schema::dropIfExists('commands');
        Schema::dropIfExists('pairing_codes');
        Schema::dropIfExists('computers');
        Schema::dropIfExists('user_lab');
        Schema::dropIfExists('labs');
    }
};
