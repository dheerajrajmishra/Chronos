import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/sdlc_models.dart';
import '../models/workflow_model.dart';
import '../services/api_service.dart';

class EnterpriseSDLCController extends GetxController {
  // Navigation & Role State
  final Rx<SDLCStageType> currentStage = SDLCStageType.projectHub.obs;
  final RxString userRole = 'Principal Security Architect'.obs;
  final RxBool isSidebarCollapsed = false.obs;

  // Theme Mode State (Default is Light Theme as requested)
  final RxBool isDarkMode = false.obs;

  // Global Configured Prompts & Settings State
  final RxMap<String, String> globalDefaultPrompts = <String, String>{}.obs;
  final RxMap<String, String> factoryDefaultPrompts = <String, String>{}.obs;
  final RxBool isLoadingSettings = false.obs;

  // New Project and Feature Models
  final RxList<Project> projectList = <Project>[].obs;
  final Rxn<Project> activeProject = Rxn<Project>();
  
  final RxList<Feature> activeProjectFeatures = <Feature>[].obs;
  final Rxn<Feature> activeFeature = Rxn<Feature>();
  
  final Rxn<WorkflowState> activeWorkflow = Rxn<WorkflowState>();

  final RxBool isProcessing = false.obs;
  
  final RxMap<String, dynamic> telemetry = <String, dynamic>{
    'gatewayStatus': 'ONLINE',
    'postgresStatus': 'HEALTHY',
    'zeroTrustScore': '99.9%',
  }.obs;

  // Live Terminal Logs
  final RxList<String> liveTerminalLogs = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadGlobalSettings();
    _initSession();
  }

  Future<void> _initSession() async {
    await fetchProjects();
    await _restoreState();
  }

  Future<void> _restoreState() async {
    final savedProjectId = html.window.localStorage['activeProjectId'];
    if (savedProjectId != null) {
      try {
        final pid = int.parse(savedProjectId);
        final project = projectList.firstWhere((p) => p.id == pid);
        activeProject.value = project;
        await fetchFeaturesForProject(pid);

        final savedFeatureId = html.window.localStorage['activeFeatureId'];
        if (savedFeatureId != null) {
          final fid = int.parse(savedFeatureId);
          final feature = activeProjectFeatures.firstWhere((f) => f.id == fid);
          activeFeature.value = feature;
          await fetchWorkflowForFeature(fid);
          
          final savedStage = html.window.localStorage['currentStage'];
          if (savedStage != null) {
            currentStage.value = SDLCStageType.values.firstWhere(
              (e) => e.name == savedStage, 
              orElse: () => SDLCStageType.stage1Brd
            );
          } else {
             currentStage.value = SDLCStageType.stage1Brd;
          }
        }
      } catch (e) {
        logTerminal("Could not restore full session state: $e", level: "WARN");
      }
    }
  }

  Future<void> loadGlobalSettings() async {
    try {
      isLoadingSettings.value = true;
      final settings = await ApiService.getGlobalSettings();
      if (settings.containsKey('theme') && settings['theme'] is Map) {
        final mode = settings['theme']['mode'];
        if (mode == 'dark') {
          isDarkMode.value = true;
          Get.changeThemeMode(ThemeMode.dark);
        } else if (mode == 'light') {
          isDarkMode.value = false;
          Get.changeThemeMode(ThemeMode.light);
        }
      }
      if (settings.containsKey('defaultPrompts') && settings['defaultPrompts'] is Map) {
        final Map<String, dynamic> dp = settings['defaultPrompts'];
        globalDefaultPrompts.clear();
        dp.forEach((k, v) => globalDefaultPrompts[k] = v.toString());
      }
      if (settings.containsKey('factoryDefaults') && settings['factoryDefaults'] is Map) {
        final Map<String, dynamic> fd = settings['factoryDefaults'];
        factoryDefaultPrompts.clear();
        fd.forEach((k, v) => factoryDefaultPrompts[k] = v.toString());
      }
    } catch (e) {
      logTerminal("Failed to load global settings: $e", level: "WARN");
    } finally {
      isLoadingSettings.value = false;
    }
  }

  void setThemeMode(bool dark) {
    isDarkMode.value = dark;
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
    ApiService.saveGlobalSettings(theme: {'mode': dark ? 'dark' : 'light'}).catchError((_) => false);
  }

  void toggleTheme() {
    setThemeMode(!isDarkMode.value);
  }

  Future<bool> saveGlobalPrompts(Map<String, String> prompts) async {
    try {
      final success = await ApiService.saveGlobalSettings(defaultPrompts: prompts);
      if (success) {
        globalDefaultPrompts.assignAll(prompts);
        logTerminal("Global default prompts successfully saved to database.", level: "SUCCESS");
        return true;
      }
    } catch (e) {
      logTerminal("Failed to save global default prompts: $e", level: "ERROR");
    }
    return false;
  }

  Future<bool> resetGlobalPrompts() async {
    try {
      final res = await ApiService.resetDefaultPrompts();
      if (res.containsKey('defaultPrompts') && res['defaultPrompts'] is Map) {
        final Map<String, dynamic> dp = res['defaultPrompts'];
        globalDefaultPrompts.clear();
        dp.forEach((k, v) => globalDefaultPrompts[k] = v.toString());
        logTerminal("Default prompts reset to factory baseline.", level: "SUCCESS");
        return true;
      }
    } catch (e) {
      logTerminal("Failed to reset prompts: $e", level: "ERROR");
    }
    return false;
  }

  void logTerminal(String message, {String level = 'INFO'}) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    final logLine = "[$timeStr] [$level] $message";
    liveTerminalLogs.insert(0, logLine);
    if (liveTerminalLogs.length > 200) {
      liveTerminalLogs.removeLast();
    }
  }

  void setStage(SDLCStageType stage) {
    currentStage.value = stage;
    html.window.localStorage['currentStage'] = stage.name;
    
    if (stage == SDLCStageType.projectHub) {
      activeFeature.value = null;
      activeWorkflow.value = null;
      html.window.localStorage.remove('activeFeatureId');
    }
    
    logTerminal("Navigated to: ${stage.name.toUpperCase()}", level: "NAV");
  }

  void setUserRole(String role) {
    userRole.value = role;
    logTerminal("Security context switched to role: $role", level: "AUTH");
  }

  // --- API Integrations ---

  Future<void> fetchProjects() async {
    try {
      final list = await ApiService.getProjects();
      projectList.value = list;
    } catch (e) {
      logTerminal("Failed to fetch projects: $e", level: "ERROR");
    }
  }

  Future<void> createProject(String name, String description) async {
    try {
      final p = await ApiService.createProject(name, description);
      projectList.insert(0, p);
      activeProject.value = p;
      logTerminal("Project Created: ${p.name}", level: "PROJECT");
      await fetchFeaturesForProject(p.id);
    } catch (e) {
      logTerminal("Error creating project: $e", level: "ERROR");
    }
  }

  Future<void> selectProject(Project project) async {
    activeProject.value = project;
    activeFeature.value = null;
    activeWorkflow.value = null;
    html.window.localStorage['activeProjectId'] = project.id.toString();
    html.window.localStorage.remove('activeFeatureId');
    logTerminal("Selected Project: ${project.name}", level: "PROJECT");
    await fetchFeaturesForProject(project.id);
  }

  Future<void> fetchFeaturesForProject(int projectId) async {
    try {
      final list = await ApiService.getFeatures(projectId);
      activeProjectFeatures.value = list;
    } catch (e) {
      logTerminal("Failed to fetch features: $e", level: "ERROR");
    }
  }

  Future<void> createFeature({
    required int projectId,
    required String name,
    required Map<String, dynamic> codeAccess,
    required Map<String, dynamic> dbAccess,
    required String baseRequirement,
    required String brdPrompt,
    String designPrompt = "",
    String codePrompt = "",
    String testPrompt = "",
    String memoryMd = "",
  }) async {
    try {
      final f = await ApiService.createFeature(
        projectId: projectId,
        name: name,
        codeAccess: codeAccess,
        dbAccess: dbAccess,
        baseRequirement: baseRequirement,
        brdPrompt: brdPrompt,
        designPrompt: designPrompt,
        codePrompt: codePrompt,
        testPrompt: testPrompt,
        memoryMd: memoryMd,
      );
      activeProjectFeatures.insert(0, f);
      selectFeature(f);
      logTerminal("Feature Created: ${f.name}", level: "FEATURE");
    } catch (e) {
      logTerminal("Error creating feature: $e", level: "ERROR");
    }
  }

  Future<void> deleteFeature(Feature feature) async {
    try {
      await ApiService.deleteFeature(feature.id);
      activeProjectFeatures.removeWhere((f) => f.id == feature.id);
      if (activeFeature.value?.id == feature.id) {
        activeFeature.value = null;
        activeWorkflow.value = null;
      }
      logTerminal("Feature Deleted: ${feature.name}", level: "FEATURE");
    } catch (e) {
      logTerminal("Error deleting feature: $e", level: "ERROR");
    }
  }

  Future<void> selectFeature(Feature feature) async {
    activeFeature.value = feature;
    html.window.localStorage['activeFeatureId'] = feature.id.toString();
    logTerminal("Selected Feature: ${feature.name}", level: "FEATURE");
    await fetchWorkflowForFeature(feature.id);
    
    // If we're selecting a feature directly (e.g. from the hub), we should jump to BRD or preserve the state?
    // Let's just always set to Stage 1 when a feature is manually selected. 
    // setStage will update localStorage.
    setStage(SDLCStageType.stage1Brd);
  }

  Future<void> fetchWorkflowForFeature(int featureId) async {
    try {
      final wf = await ApiService.getWorkflowState(featureId);
      activeWorkflow.value = wf;
    } catch (e) {
      logTerminal("Failed to fetch workflow: $e", level: "ERROR");
    }
  }

  Future<void> updateWorkflowStage(int stage, String status, Map<String, dynamic> data) async {
    if (activeFeature.value == null) return;
    try {
      final wf = await ApiService.updateWorkflowStage(
        activeFeature.value!.id,
        stage,
        status,
        data,
      );
      activeWorkflow.value = wf;
      logTerminal("Workflow updated to stage $stage ($status)", level: "WORKFLOW");
    } catch (e) {
      logTerminal("Failed to update workflow: $e", level: "ERROR");
    }
  }

  Future<bool> updateFeaturePrompts({
    String? brdPrompt,
    String? designPrompt,
    String? techDocPrompt,
    String? codePrompt,
    String? testCaseCreationPrompt,
    String? testAutomationPrompt,
    String? testingResultPrompt,
    String? deployPrompt,
    String? memoryPrompt,
    Map<String, dynamic>? stagePrompts,
  }) async {
    if (activeFeature.value == null) return false;
    try {
      final updated = await ApiService.updateFeaturePrompts(
        activeFeature.value!.id,
        brdPrompt: brdPrompt,
        designPrompt: designPrompt,
        techDocPrompt: techDocPrompt,
        codePrompt: codePrompt,
        testCaseCreationPrompt: testCaseCreationPrompt,
        testAutomationPrompt: testAutomationPrompt,
        testingResultPrompt: testingResultPrompt,
        deployPrompt: deployPrompt,
        memoryPrompt: memoryPrompt,
        stagePrompts: stagePrompts,
      );
      activeFeature.value = updated;
      
      // Also update in list
      final idx = activeProjectFeatures.indexWhere((f) => f.id == updated.id);
      if (idx != -1) {
        activeProjectFeatures[idx] = updated;
      }
      
      logTerminal("Stage prompts saved to database for feature: ${updated.name}", level: "CONFIG");
      return true;
    } catch (e) {
      logTerminal("Failed to save stage prompts: $e", level: "ERROR");
      return false;
    }
  }
}
