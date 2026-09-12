import 'dart:async';
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

  // Theme Mode State
  final RxBool isDarkMode = true.obs;

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
    fetchProjects();
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
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
  }) async {
    try {
      final f = await ApiService.createFeature(
        projectId: projectId,
        name: name,
        codeAccess: codeAccess,
        dbAccess: dbAccess,
        baseRequirement: baseRequirement,
        brdPrompt: brdPrompt,
      );
      activeProjectFeatures.insert(0, f);
      selectFeature(f);
      logTerminal("Feature Created: ${f.name}", level: "FEATURE");
    } catch (e) {
      logTerminal("Error creating feature: $e", level: "ERROR");
    }
  }

  Future<void> selectFeature(Feature feature) async {
    activeFeature.value = feature;
    logTerminal("Selected Feature: ${feature.name}", level: "FEATURE");
    await fetchWorkflowForFeature(feature.id);
    setStage(SDLCStageType.stage1Brd); // Jump to Stage 1
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
}
