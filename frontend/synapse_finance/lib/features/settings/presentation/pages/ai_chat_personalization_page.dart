import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../assistant/data/datasources/ai_service.dart';
import '../../domain/entities/ai_settings.dart';
import '../bloc/ai_settings_cubit.dart';
import '../bloc/ai_settings_state.dart';

class AiChatPersonalizationPage extends StatefulWidget {
  const AiChatPersonalizationPage({super.key});

  @override
  State<AiChatPersonalizationPage> createState() =>
      _AiChatPersonalizationPageState();
}

class _AiChatPersonalizationPageState extends State<AiChatPersonalizationPage> {
  late final TextEditingController _baseUrlController;
  late final TextEditingController _modelController;
  late final TextEditingController _apiKeyController;
  late final AiSettingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _baseUrlController = TextEditingController();
    _modelController = TextEditingController();
    _apiKeyController = TextEditingController();
    _cubit = getIt<AiSettingsCubit>();
    _cubit.loadSettings();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _updateControllers(AiSettings settings) {
    _baseUrlController.text = settings.baseUrl;
    _modelController.text = settings.model;
    _apiKeyController.text = settings.apiKey ?? '';
  }

  Future<void> _saveSettings() async {
    if (_cubit.state.settings == null) return;

    final settings = AiSettings(
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      apiKey: _apiKeyController.text.trim().isEmpty
          ? null
          : _apiKeyController.text.trim(),
    );

    await _cubit.saveSettings(settings);

    // Update the AI service with new settings
    final aiService = getIt<AiService>();
    aiService.configure(
      baseUrl: settings.baseUrl,
      model: settings.model,
      apiKey: settings.apiKey,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    final settings = AiSettings(
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      apiKey: _apiKeyController.text.trim().isEmpty
          ? null
          : _apiKeyController.text.trim(),
    );

    try {
      final aiService = getIt<AiService>();
      aiService.configure(
        baseUrl: settings.baseUrl,
        model: settings.model,
        apiKey: settings.apiKey,
      );

      // Test with a simple message
      final testMessages = [
        {'role': 'user', 'content': 'Hello, can you respond with just "OK"?'},
      ];

      await aiService.sendMessageSync(
        messages: testMessages,
        systemPrompt: 'You are a helpful assistant. Respond with just "OK".',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connection test successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection test failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'AI Chat Personalization',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocConsumer<AiSettingsCubit, AiSettingsState>(
          listener: (context, state) {
            if (state.settings != null) {
              _updateControllers(state.settings!);
            }
            if (state.error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildSettingsCard(state),
                  const SizedBox(height: 24),
                  _buildActionButtons(state),
                  const SizedBox(height: 24),
                  _buildPresetButtons(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Configuration',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure your AI assistant settings. You can use local models (Ollama) or cloud providers (OpenAI, Anthropic).',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(AiSettingsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Service Configuration',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _baseUrlController,
            label: 'Base URL',
            hint: 'http://192.168.1.15:11434/v1',

            onChanged: (value) => _cubit.updateBaseUrl(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _modelController,
            label: 'Model',
            hint: 'llama3.1:8b',

            onChanged: (value) => _cubit.updateModel(value),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _apiKeyController,
            label: 'API Key (Optional)',
            hint: 'Enter API key if required',
            obscureText: true,
            onChanged: (value) =>
                _cubit.updateApiKey(value.isEmpty ? null : value),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildActionButtons(AiSettingsState state) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: state.isSaving ? null : _testConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surface,
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: const Text('Test Connection'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: state.isSaving ? null : _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: state.isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save Settings'),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Presets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildPresetChip(
              'Ollama Local',
              'http://localhost:11434/api/chat',
              'gemma3:4b',
              null,
            ),
            _buildPresetChip(
              'OpenAI GPT-4',
              'https://api.openai.com/v1/responses',
              'gpt-4',
              'sk-...',
            ),
            _buildPresetChip(
              'Anthropic Claude',
              'https://api.anthropic.com/v1',
              'claude-3-sonnet-20240229',
              'sk-ant-...',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetChip(
    String label,
    String baseUrl,
    String model,
    String? apiKeyHint,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _baseUrlController.text = baseUrl;
        _modelController.text = model;
        if (apiKeyHint != null) {
          _apiKeyController.text = apiKeyHint;
        }
        _cubit.updateBaseUrl(baseUrl);
        _cubit.updateModel(model);
        if (apiKeyHint != null) {
          _cubit.updateApiKey(apiKeyHint);
        }
      },
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(color: AppColors.textPrimary),
      side: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.3)),
    );
  }
}
