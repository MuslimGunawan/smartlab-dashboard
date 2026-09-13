<?php

namespace App\Http\Controllers;

use App\Models\AuditLog;
use App\Models\Lab;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Tampilkan Daftar Pengguna ASLAB & Super Admin
     */
    public function index()
    {
        $users = User::with('labs')->latest()->paginate(15);
        $labs = Lab::orderBy('nama_lab')->get();

        return view('users.index', compact('users', 'labs'));
    }

    /**
     * Buat Pengguna Baru
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:120',
            'email' => 'required|email|unique:users,email|max:120',
            'password' => 'required|string|min:6',
            'role' => 'required|in:super_admin,aslab_senior,aslab_junior',
            'labs' => 'nullable|array',
            'labs.*' => 'exists:labs,id',
        ], [
            'name.required' => 'Nama pengguna wajib diisi.',
            'email.required' => 'Email wajib diisi.',
            'email.unique' => 'Email ini sudah terdaftar di sistem.',
            'password.required' => 'Password wajib diisi.',
            'password.min' => 'Password minimal 6 karakter.',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'role' => $validated['role'],
        ]);

        if (!empty($validated['labs'])) {
            $user->labs()->sync($validated['labs']);
        }

        AuditLog::log(auth()->id(), 'create_user', "User {$user->name} ({$user->role})", [
            'email' => $user->email,
            'role' => $user->role,
        ]);

        return back()->with('success', "Pengguna {$user->name} berhasil ditambahkan!");
    }

    /**
     * Update Pengguna
     */
    public function update(Request $request, User $user)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:120',
            'email' => ['required', 'email', 'max:120', Rule::unique('users')->ignore($user->id)],
            'password' => 'nullable|string|min:6',
            'role' => 'required|in:super_admin,aslab_senior,aslab_junior',
            'labs' => 'nullable|array',
            'labs.*' => 'exists:labs,id',
        ]);

        $data = [
            'name' => $validated['name'],
            'email' => $validated['email'],
            'role' => $validated['role'],
        ];

        if (!empty($validated['password'])) {
            $data['password'] = Hash::make($validated['password']);
        }

        $user->update($data);

        if (isset($validated['labs'])) {
            $user->labs()->sync($validated['labs']);
        } else {
            $user->labs()->detach();
        }

        AuditLog::log(auth()->id(), 'update_user', "User {$user->name}", [
            'email' => $user->email,
            'role' => $user->role,
        ]);

        return back()->with('success', "Data pengguna {$user->name} berhasil diperbarui!");
    }

    /**
     * Hapus Pengguna
     */
    public function destroy(User $user)
    {
        if ($user->id === auth()->id()) {
            return back()->with('error', 'Anda tidak dapat menghapus akun Anda sendiri yang sedang aktif!');
        }

        $name = $user->name;
        $user->labs()->detach();
        $user->delete();

        AuditLog::log(auth()->id(), 'delete_user', "User {$name}", []);

        return back()->with('success', "Pengguna {$name} berhasil dihapus dari sistem.");
    }
}
