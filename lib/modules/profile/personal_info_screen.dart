import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:appkonkos_mobile/utils/app_color.dart';
import 'controllers/profile_controller.dart';

class PersonalInfoScreen extends StatelessWidget {
  PersonalInfoScreen({super.key});
  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF3FB),
      appBar: AppBar(
        backgroundColor: AppColor.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              _buildSection(
                title: 'DATA DIRI',
                children: [
                  _buildField(
                    label: 'Nama Lengkap',
                    controller: controller.nameController,
                    icon: Icons.person_outline,
                  ),
                  _buildField(
                    label: 'Email',
                    controller: controller.emailController,
                    icon: Icons.email_outlined,
                    enabled: false,
                  ),
                  _buildField(
                    label: 'Nomor Telepon/Whatsapp',
                    controller: controller.phoneController,
                    icon: Icons.phone_outlined,
                    isPhone: true,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildField(
                    label: 'Domisili',
                    controller: controller.domisiliController,
                    icon: Icons.location_on_outlined,
                  ),
                   _buildDropdown(
                    label: 'Jenis Kelamin',
                    icon: Icons.wc_outlined,
                    value: controller.selectedJenisKelamin,
                    items: controller.listJenisKelamin,
                    hint: 'Pilih jenis kelamin',
                  ),

                  // ── Pekerjaan Dropdown ──
                  _buildDropdown(
                    label: 'Pekerjaan',
                    icon: Icons.work_outline,
                    value: controller.selectedPekerjaan,
                    items: controller.listPekerjaan,
                    hint: 'Pilih pekerjaan',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.updateProfile(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              )),

              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool isPhone = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            onTap: () {
              if (isPhone && controller.text == '-') controller.clear();
            },
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColor.primary, size: 18),
              filled: true,
              fillColor: enabled
                  ? const Color(0xFFF8FAFC)
                  : const Color(0xFFEEEEEE),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.primary),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildDropdown({
    required String label,
    required IconData icon,
    required RxnString value,
    required List<String> items,
    required String hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Obx(() => DropdownButtonFormField<String>(
            value: value.value,
            hint: Text(hint,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppColor.primary, size: 18),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.primary),
              ),
            ),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item,
                          style: const TextStyle(fontSize: 14)),
                    ))
                .toList(),
            onChanged: (val) => value.value = val,
          )),
        ],
      ),
    );
  }
}