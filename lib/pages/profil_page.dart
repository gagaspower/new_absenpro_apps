import 'package:absenpro/pages/auth/login_page.dart';
import 'package:absenpro/providers/auth/auth_provider.dart';
import 'package:absenpro/pages/reset_password/reset_password_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  static const Color primaryTeal = Color(0xFF2FC7CF);

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  void initState() {
    super.initState();
    // Kalau app baru dibuka lagi (state provider kosong), ambil dari local storage
    final authProvider = context.read<AuthProvider>();
    if (authProvider.user == null) {
      authProvider.loadUserFromStorage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Pegawai'),
        automaticallyImplyLeading: false, // tidak ada tombol back
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final user = auth.user;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final employee = user.employee;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Foto profil bulat
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: ProfilPage.primaryTeal, width: 2),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: ClipOval(
                      child: employee?.photoUrl != null
                          ? Image.network(
                              // Diambil dari face_profile.reference_photo_path
                              employee!.photoUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: const Color(0xFFEDEDED),
                                child: const Icon(Icons.person,
                                    size: 40, color: Colors.black26),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFEDEDED),
                              child: const Icon(Icons.person,
                                  size: 40, color: Colors.black26),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    employee?.fullName ?? user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    employee?.position?.name ?? user.roleName,
                    style: const TextStyle(fontSize: 13, color: Colors.black45),
                  ),
                  const SizedBox(height: 24),

                  // Kartu biodata
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _BiodataRow(
                          label: 'Nama Lengkap',
                          value: employee?.fullName ?? user.name,
                        ),
                        _BiodataRow(
                          label: 'Alamat',
                          value: employee?.address ?? '-',
                        ),
                        _BiodataRow(
                          label: 'Email',
                          value: user.email,
                        ),
                        if (employee?.employeeCode.isNotEmpty ?? false)
                          _BiodataRow(
                            label: 'Kode Pegawai',
                            value: employee!.employeeCode,
                          ),
                        _BiodataRow(
                          label: 'Wilayah Kerja',
                          value: employee?.branch?.name ?? '-',
                        ),
                        _BiodataRow(
                          label: 'Departemen',
                          value: employee?.department?.name ?? '-',
                        ),
                        _BiodataRow(
                          label: 'Jabatan',
                          value: employee?.position?.name ?? '-',
                        ),
                        _BiodataRow(
                          label: 'Shift',
                          value: employee?.shift?.name ?? '-',
                        ),
                        _BiodataRow(
                          label: 'Role',
                          value: user.roleName,
                          isLast: true,
                        ),

                        // TODO: field berikut belum tersedia di response API,
                        // tampilkan kalau backend sudah menyediakan:
                        // - Nomer HP
                        // - Jenis Kelamin
                        // - Tempat, Tgl Lahir
                        // - Status Pegawai
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Menu Ganti Password & Keluar
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _MenuTile(
                          icon: Icons.lock_outline,
                          iconBgColor: const Color(0xFFDCEBFA),
                          iconColor: const Color(0xFF4A87C9),
                          label: 'Ganti Password',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ResetPasswordPage()),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _MenuTile(
                          icon: Icons.logout,
                          iconBgColor: const Color(0xFFFBE0E4),
                          iconColor: const Color(0xFFE0637A),
                          label: 'Keluar',
                          labelColor: const Color(0xFFE0637A),
                          onTap: () => _showLogoutConfirm(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // tutup dialog konfirmasi saja

              // Tampilkan modal loading, pakai context asli ProfilPage
              // (bukan context dialog konfirmasi yang sudah ditutup)
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const _LogoutLoadingDialog(),
              );

              final authProvider = context.read<AuthProvider>();
              await authProvider.logout();

              if (!context.mounted) return;

              // Tutup modal loading lewat root navigator
              Navigator.of(context, rootNavigator: true).pop();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

/// Baris biodata dengan label & titik dua rapi, aman untuk teks panjang.
class _BiodataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _BiodataRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const Text(
            ':',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String label;
  final Color? labelColor;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.label,
    required this.onTap,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: labelColor ?? Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

/// Modal loading saat proses logout (revoke session) berlangsung.
class _LogoutLoadingDialog extends StatelessWidget {
  const _LogoutLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: ProfilPage.primaryTeal,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Sedang menghapus sesi...',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
