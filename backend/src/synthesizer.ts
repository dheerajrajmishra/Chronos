import { ChatOpenAI, AzureChatOpenAI } from '@langchain/openai';
import { CodebaseGraph } from './codeGraph/graphEngine';

export interface SynthesisRequest {
  requirement: string;
  maskedRequirement?: string;
  brdPrompt?: string;
  designPrompt?: string;
  techDocPrompt?: string;
  architecture?: string;
  compliance?: string;
  cloudTarget?: string;
  llmModel?: string;
  apiKey?: string;
  repoUrl?: string;
  codeGraph?: CodebaseGraph;
  memoryMd?: string;
}

export interface AgentDeliverableResponse {
  agentName: string;
  agentRole: string;
  iconName: string;
  summary: string;
  markdownContent: string;
  tags: string[];
}

export interface SynthesisResult {
  workflowId: string;
  domain: string;
  usedCloudLlm: boolean;
  deliverables: AgentDeliverableResponse[];
}

// Domain detection helper
function detectDomain(text: string): { domain: string; actors: string[]; keywords: string[] } {
  const lower = text.toLowerCase();

  if (lower.includes('patient') || lower.includes('hospital') || lower.includes('health') || lower.includes('ehr') || lower.includes('fhir') || lower.includes('hipaa') || lower.includes('clinic')) {
    return {
      domain: 'Digital Healthcare & Clinical Informatics',
      actors: ['Attending Physician', 'Clinical Data Officer', 'HIPAA Compliance Auditor', 'EMR Integration Service'],
      keywords: ['ePHI protection', 'HL7 FHIR API', 'audit trail', 'patient consent', 'sub-second telemetry']
    };
  }

  if (lower.includes('payment') || lower.includes('stripe') || lower.includes('bank') || lower.includes('fintech') || lower.includes('transaction') || lower.includes('ledger') || lower.includes('kyc') || lower.includes('crypto')) {
    return {
      domain: 'Fintech & High-Assurance Financial Services',
      actors: ['Risk Officer', 'Payment Settlement Engine', 'PCI-DSS Auditor', 'Merchant API Client'],
      keywords: ['zero-loss ledger', 'idempotent transactions', 'tokenized PAN/CVV', 'anti-money laundering (AML)']
    };
  }

  if (lower.includes('iot') || lower.includes('vehicle') || lower.includes('telemetry') || lower.includes('fleet') || lower.includes('mqtt') || lower.includes('sensor') || lower.includes('device')) {
    return {
      domain: 'Edge IoT & High-Throughput Telemetry Logistics',
      actors: ['Edge Device Gateway', 'Fleet Operations Manager', 'Site Reliability Engineer', 'Anomaly Detection Worker'],
      keywords: ['time-series compression', 'sub-50ms ingestion', 'mTLS hardware security module', 'out-of-order packet reassembly']
    };
  }

  if (lower.includes('auth') || lower.includes('identity') || lower.includes('sso') || lower.includes('oauth') || lower.includes('saml') || lower.includes('jwt') || lower.includes('iam') || lower.includes('permission')) {
    return {
      domain: 'Enterprise Identity & Zero-Trust Access Management',
      actors: ['Identity Provider (IdP)', 'Directory Administrator', 'Security Operations Center (SOC)', 'Federated Client'],
      keywords: ['JIT credential issuance', 'short-lived token lifetimes', 'least-privilege RBAC/ABAC', 'FIDO2 WebAuthn']
    };
  }

  if (lower.includes('commerce') || lower.includes('order') || lower.includes('cart') || lower.includes('inventory') || lower.includes('catalog') || lower.includes('store')) {
    return {
      domain: 'Omnichannel Enterprise E-Commerce & Supply Chain',
      actors: ['Inventory Controller', 'Order Processing Pipeline', 'Fulfillment Partner Service', 'Customer Experience Portal'],
      keywords: ['distributed ACID reservations', 'eventual consistency sync', 'real-time stock reconciliation', 'PCI checkout']
    };
  }

  return {
    domain: 'Zero-Trust Enterprise Cloud Platform',
    actors: ['Enterprise Product Owner', 'Principal Architect', 'InfoSec Auditor', 'Microservice Consumer'],
    keywords: ['confidential computing', 'defense-in-depth', 'immutable audit logs', 'SLO-driven resiliency']
  };
}

// Extract technical entities mentioned in text
function extractEntities(text: string) {
  const dbs = ['PostgreSQL', 'MongoDB', 'Redis', 'TimescaleDB', 'MySQL', 'DynamoDB', 'Cassandra', 'Oracle']
    .filter(db => new RegExp(`\\b${db}\\b`, 'i').test(text));
  const apis = ['REST', 'GraphQL', 'gRPC', 'WebSocket', 'MQTT', 'Kafka', 'Webhook', 'FHIR', 'Stripe']
    .filter(api => new RegExp(`\\b${api}\\b`, 'i').test(text));
  
  return {
    database: dbs.length > 0 ? dbs.join(', ') : 'PostgreSQL 16 (Encrypted at rest via AES-256)',
    protocols: apis.length > 0 ? apis.join(', ') : 'mTLS REST / OpenAPI 3.1 & gRPC Streams',
  };
}

export async function synthesizeDeliverables(req: SynthesisRequest): Promise<SynthesisResult> {
  const workflowId = `ZTSDLC-${Date.now().toString().substring(5)}`;
  const maskedText = req.maskedRequirement || req.requirement;
  const rawText = req.requirement;
  const architecture = req.architecture || 'Event-Driven Microservices';
  const compliance = req.compliance || 'SOC2 Type II & Zero-Trust NIST 800-207';
  const cloudTarget = req.cloudTarget || 'Microsoft Azure (Zero-Trust VPC)';

  const apiKey = req.apiKey || process.env.OPENAI_API_KEY || process.env.AZURE_OPENAI_KEY;

  // Try live LLM if key is available
  if (apiKey && apiKey !== 'dummy_key') {
    try {
      let llm: any;
      if (process.env.AZURE_OPENAI_KEY || req.llmModel?.includes('Azure')) {
        llm = new AzureChatOpenAI({
          azureOpenAIApiKey: apiKey,
          azureOpenAIApiInstanceName: process.env.AZURE_OPENAI_INSTANCE || 'pitchperfectllmengine2',
          azureOpenAIApiDeploymentName: process.env.AZURE_OPENAI_DEPLOYMENT || 'gpt-4o',
          azureOpenAIApiVersion: '2024-02-15-preview',
          temperature: 0.2,
        });
      } else {
        llm = new ChatOpenAI({
          openAIApiKey: apiKey,
          modelName: 'gpt-4o',
          temperature: 0.2,
        });
      }

      const codeGraphPrompt = req.codeGraph ? `
Target Application Context: 
- Original Repository URL: ${req.repoUrl || 'Unknown'}
- Local Clone Path: \`${req.codeGraph.repoPath}\` (${req.codeGraph.filesCount} files)
- Tech Stack: ${req.codeGraph.techStack.join(', ')}
- Modules:
${req.codeGraph.modules.map(m => `  * ${m.directory} (${m.tech}): ${m.keyFiles.join(', ')}`).join('\n')}
` : '';

      const memoryPrompt = req.memoryMd ? `
--- Project Context (memory.md) ---
${req.memoryMd}
-----------------------------------
` : '';

      // Dynamic BRD Directive from user configuration or fallback standard
      const brdDirective = (req.brdPrompt && req.brdPrompt.trim().length > 0)
        ? req.brdPrompt.trim()
        : `Focus strictly on the FUNCTIONAL requirements and business aspects. Do NOT include technical implementation details, file names, or codebase file impact matrices in the BRD. Technical design will be handled separately.

Include the following sections with exhaustive depth:
1. Executive Summary & Problem Definition
2. Target Business Objectives & OKRs
3. Target Personas / User Roles
4. In-Scope and Out-of-Scope boundaries
5. Functional Requirements
6. Epics and Detailed User Stories (US-1.1, US-1.2, etc.)
7. Acceptance Criteria in Gherkin (Given-When-Then) format
8. Non-Functional Requirements & Security Controls (Functional perspective)`;

      const brdPrompt = `
You are an expert AI Business Analyst. Your task is to write a Business Requirements Document (BRD) for the target application described below. 
Do NOT write the BRD about the SDLC platform itself; write it for the target application!

Sanitized Requirement: "${maskedText}"

Compliance Framework: ${compliance}

${memoryPrompt}

${codeGraphPrompt}

--- STAGE DIRECTIVES & USER INSTRUCTIONS ---
${brdDirective}
--------------------------------------------
`;

      const response = await llm.invoke(brdPrompt);
      const brdMarkdown = typeof response.content === 'string' ? response.content : JSON.stringify(response.content);

      // Dynamic System Architecture Directive from user configuration or fallback standard
      const ddDirective = (req.designPrompt && req.designPrompt.trim().length > 0)
        ? req.designPrompt.trim()
        : `Focus strictly on the technical architecture, system design, and implementation details for the target application.

Include the following sections:
1. System Architecture Overview
2. Component Design (Frontend, Backend, Database)
3. API Contracts (REST/GraphQL/gRPC)
4. Data Models & Database Schema Design
5. Security & Authentication Mechanisms
6. Deployment & Infrastructure Strategy`;

      const ddPrompt = `
You are an expert Enterprise Architect. Your task is to write a System Architecture & Design Document (DD) for the target application described below, based on the requirements.
Do NOT write the DD about the SDLC platform itself; write it for the target application!

Sanitized Requirement: "${maskedText}"

Compliance Framework: ${compliance}
Target Infrastructure: ${cloudTarget}
Architecture Pattern: ${architecture}

${memoryPrompt}

${codeGraphPrompt}

--- STAGE DIRECTIVES & USER INSTRUCTIONS ---
${ddDirective}
--------------------------------------------
`;

      const ddResponse = await llm.invoke(ddPrompt);
      const ddMarkdown = typeof ddResponse.content === 'string' ? ddResponse.content : JSON.stringify(ddResponse.content);

      // Dynamic Technical Specification Directive from user configuration or fallback standard
      const techDocDirective = (req.techDocPrompt && req.techDocPrompt.trim().length > 0)
        ? req.techDocPrompt.trim()
        : `Provide exact, implementation-ready technical specifications:
1. Low-Level Module Architecture & Execution Flow
2. Concrete REST / gRPC API Endpoint Specifications (Paths, Methods, Request & Response JSON schemas, Header authentication)
3. Database DDL & Schema Definitions (PostgreSQL tables, fields, types, indexes, and tokenized vault references)
4. Data Contracts & State Transition Models
5. Cryptographic & Security Boundaries (mTLS 1.3, Presidio PII Gateway Tokenization, Vault Token lifecycle)
6. Error Handling, Resilience & Retry Matrix (HTTP status codes, circuit breakers, fallback patterns)`;

      const techDocPrompt = `
You are a Principal Software Engineer and Technical Lead. Your task is to write a comprehensive Low-Level Technical Document (Tech Specs) for the target application described below.
Do NOT write this document about the SDLC platform itself; write it for the target application!

Sanitized Requirement: "${maskedText}"

Compliance Framework: ${compliance}
Target Infrastructure: ${cloudTarget}
Architecture Pattern: ${architecture}

${memoryPrompt}

${codeGraphPrompt}

--- STAGE DIRECTIVES & USER INSTRUCTIONS ---
${techDocDirective}
--------------------------------------------
`;

      const techDocResponse = await llm.invoke(techDocPrompt);
      const techDocMarkdown = typeof techDocResponse.content === 'string' ? techDocResponse.content : JSON.stringify(techDocResponse.content);

      return {
        workflowId,
        domain: detectDomain(rawText).domain,
        usedCloudLlm: true,
        deliverables: [
          {
            agentName: 'Business Analyst Agent',
            agentRole: 'Requirements Engineering & User Story Extraction',
            iconName: 'assignment',
            summary: `Tailored BRD generated by GPT-4o for: ${rawText.substring(0, 80)}...`,
            markdownContent: brdMarkdown,
            tags: ['Live LLM', 'BRD', 'User Stories', compliance],
          },
          {
            agentName: 'Cloud Architect Agent',
            agentRole: 'System Design & Threat Modeling',
            iconName: 'architecture',
            summary: `Tailored Architecture Document generated by GPT-4o`,
            markdownContent: ddMarkdown,
            tags: ['Live LLM', 'Architecture', 'API Specs', 'Database Schema'],
          },
          {
            agentName: 'Technical Lead Agent',
            agentRole: 'Low-Level Technical Specification & API Schemas',
            iconName: 'terminal',
            summary: `Low-level technical specification, API contracts, database DDL and security protocols`,
            markdownContent: techDocMarkdown,
            tags: ['Live LLM', 'Technical Document', 'API Specs', 'Database DDL'],
          },
          generateSecurityDeliverable(rawText, maskedText, compliance, cloudTarget),
        ],
      };
    } catch (err: any) {
      console.warn('[Synthesizer] Cloud LLM invocation failed:', err.message);
      throw new Error(`LLM API Error: ${err.message}`);
    }
  }

  // Autonomous Semantic Synthesizer (Zero-Trust Local Engine)
  // Only runs if no API key is provided
  return generateSemanticDeliverables(workflowId, rawText, maskedText, architecture, compliance, cloudTarget, req.codeGraph);
}

function generateSemanticDeliverables(
  workflowId: string,
  rawText: string,
  maskedText: string,
  architecture: string,
  compliance: string,
  cloudTarget: string,
  codeGraph?: CodebaseGraph
): SynthesisResult {
  const { domain, actors, keywords } = detectDomain(rawText);
  const tech = extractEntities(rawText);

  // Derive feature title
  const cleanSnippet = rawText.replace(/[\n\r]+/g, ' ').trim();
  const summaryTitle = cleanSnippet.length > 90 ? cleanSnippet.substring(0, 90) + '...' : cleanSnippet;

  const scopeSection = `
## 2. In-Scope vs. Out-of-Scope Matrix

| Category | In-Scope Deliverables | Out-of-Scope Constraints |
| :--- | :--- | :--- |
| **Data Ingestion** | Real-time payload sanitization and verification. | Ingestion of unencrypted plain-text payloads over unverified networks. |
| **Core Processing** | Autonomous business logic generation based on ${tech.protocols}. | Direct unmasked third-party external LLM calls. |
| **Integration** | Secure connectors for ${tech.database}. | Hardcoded database credentials or static production tokens. |
| **Governance** | Dual-signature Human-in-the-Loop approval gate. | Auto-deployment to production bypass gates without compliance officer review. |
`;


  const brdMarkdown = `# Business Requirements Document (BRD)
**Workflow Reference:** \`${workflowId}\`  
**System Classification:** ${domain.toUpperCase()} // RESTRICTED ZERO-TRUST  
**Compliance Baseline:** ${compliance}  
**Cloud Enclave:** ${cloudTarget}  
**Target Architecture:** ${architecture}  
${codeGraph ? `**Codebase Repository:** \`${codeGraph.repoPath}\` (${codeGraph.filesCount} files indexed)  ` : ''}

---

## 1. Executive Summary & Problem Statement
This Business Requirements Document establishes the engineering, architectural, and governance contract for:
> **Requirement Specification (Sanitized Context):**  
> *"${maskedText}"*

### 1.1 Business Problem Definition
The current operational model requires an automated, cryptographically secured implementation for **${summaryTitle}**. Existing manual or loosely coupled workflows risk unauthorized exposure of high-entropy credentials, connection strings, and sensitive payloads before strict compliance evaluation. 

### 1.2 Target Solution Scope
Deploy an isolated zero-trust service subsystem conforming to **${compliance}** standards, interfacing with **${tech.database}** and communicating over **${tech.protocols}** within the **${cloudTarget}** private perimeter.

---
${scopeSection}
---

## 4. Target Objectives & Key Results (OKRs)

- **OKR-1 (Zero-Trust Security):** Achieve **0% raw PII / Secret leakage** to external reasoning models by verifying 100% token substitution at the Presidio DLP Gateway.
- **OKR-2 (Performance SLA):** Guarantee end-to-end ingestion and processing latency of **P95 < 250ms** across all authenticated ${tech.protocols} endpoints.
- **OKR-3 (Audit Integrity):** Record 100% of pipeline events into immutable audit logs with non-repudiable SHA-256 state signatures.
- **OKR-4 (Compliance Baseline):** Zero unmitigated high/critical CVEs in the generated Software Bill of Materials (SBOM), satisfying **${compliance}**.

---

## 4. Epics & Detailed User Stories

### Epic 1: Secure Ingestion & Tokenized Vaulting
- **US-1.1 (Payload Interception):** As an **${actors[0]}**, I want all incoming payloads related to *${summaryTitle}* to be evaluated against Presidio zero-trust filters so that high-entropy secrets and sensitive entities are immediately vaulted before processing.
- **US-1.2 (Cryptographic Token Mapping):** As a **Security Officer**, I want deterministic surrogate tokens generated for vaulted items so that downstream reasoning agents process realistic structure without ever exposing raw credentials.

### Epic 2: Core Domain Logic & Data Persistence
- **US-2.1 (Domain Workflow Execution):** As a **${actors[1] || 'Platform Engineer'}**, I want the service to execute the requested business logic with atomic transactions on **${tech.database}** to maintain consistent system state.
- **US-2.2 (Interface Protocols):** As an **${actors[2] || 'API Consumer'}**, I require low-latency communication via **${tech.protocols}** with automated retry policies and exponential backoff.

### Epic 3: Governance & Regulatory Compliance
- **US-3.1 (Pre-Flight Verification):** As a **${actors[3] || 'Compliance Auditor'}**, I require an approval gate with a complete review of synthesized artifacts prior to deploying changes to ${cloudTarget}.
- **US-3.2 (Immutable State Verification):** As a **Security Officer**, I want the ability to verify that the unmasked deployable artifact mathematically matches the pre-approval SHA-256 state digest.

---

## 5. Acceptance Criteria (Gherkin Scenarios)

\`\`\`gherkin
Scenario: Successful Zero-Trust Ingestion and Execution
  Given a validated client request matching requirement "${summaryTitle}"
  And the request contains sensitive configuration parameters
  When the payload passes through the Zero-Trust DLP Gateway
  Then all credentials must be substituted with surrogate tokens
  And an entry must be persisted in the Redis Token Vault
  And the workflow state must transition to "SYNTHESIS_COMPLETE"

Scenario: Database Transaction with JIT Credentials
  Given an approved workflow execution for "${workflowId}"
  When the worker activity interfaces with "${tech.database}"
  Then it must request an ephemeral credential valid for no more than 30 minutes
  And all query results must be returned over TLS 1.3 encrypted sockets
\`\`\`

---

## 6. Non-Functional Requirements (NFRs)

1. **Availability & Fault Tolerance:** 99.99% service uptime backed by Temporal durable state execution and automatic activity retries.
2. **Confidentiality:** Mutual TLS (mTLS) with rotating X.509 certificates for all inter-service communications within ${cloudTarget}.
3. **Data Protection:** ${keywords.join(', ')}.
4. **Disaster Recovery:** Recovery Point Objective (RPO) = 0 seconds; Recovery Time Objective (RTO) < 60 seconds.
`;

  return {
    workflowId,
    domain,
    usedCloudLlm: false,
    deliverables: [
      {
        agentName: 'Business Analyst Agent',
        agentRole: 'Requirements Engineering & User Story Extraction',
        iconName: 'assignment',
        summary: `Dynamic 8-part BRD synthesized for: ${summaryTitle}`,
        markdownContent: brdMarkdown,
        tags: ['BRD', 'User Stories', domain, compliance],
      },
      generateArchitectDeliverable(rawText, maskedText, architecture, compliance, cloudTarget, codeGraph),
      generateTechDocDeliverable(rawText, maskedText, architecture, compliance, cloudTarget, codeGraph),
      generateSecurityDeliverable(rawText, maskedText, compliance, cloudTarget),
    ],
  };
}

function generateArchitectDeliverable(
  rawText: string,
  maskedText: string,
  architecture: string,
  compliance: string,
  cloudTarget: string,
  codeGraph?: CodebaseGraph
): AgentDeliverableResponse {
  const { domain } = detectDomain(rawText);
  const tech = extractEntities(rawText);

  const clientDir = codeGraph?.modules.find(m => m.directory.includes('frontend'))?.directory || 'frontend/lib';
  const gatewayDir = codeGraph?.modules.find(m => m.directory.includes('gateway'))?.directory || 'zero_trust_gateway';
  const backendDir = codeGraph?.modules.find(m => m.directory.includes('backend'))?.directory || 'backend/src';

  const markdown = `# System Architecture Specification
**Architecture Pattern:** ${architecture}  
**Target Infrastructure:** ${cloudTarget}  
**Classification:** ${domain} Architecture Blueprint  
${codeGraph ? `**Existing Repository Context:** \`${codeGraph.repoPath}\` (${codeGraph.techStack.join(', ')})  ` : ''}

---

## 1. C4 Container Architecture Diagram
The container model illustrates the zero-trust isolation boundaries integrated with the active repository:

\`\`\`mermaid
graph TD
    Client["Client / Portal Web (${clientDir})"] -->|mTLS 1.3| ZTGateway["Zero-Trust DLP Gateway (${gatewayDir})"]
    ZTGateway -->|Store Tokens| RedisVault[("Redis Token Vault (In-Memory)")]
    ZTGateway -->|Sanitized Workflow| Temporal["Temporal Durable Orchestrator (${backendDir})"]
    Temporal -->|Task Queue: sdlc-queue| WorkerPool["Activity Workers Pool"]
    WorkerPool -->|Masked Payload| ReasoningEngine["Reasoning / CodeGen Engine"]
    WorkerPool -->|JIT Unmasked Conn| TargetDB[("${tech.database}")]
    WorkerPool -->|Audit Signals| AuditLog[("Immutable Audit Ledger")]
\`\`\`

---

## 2. Interface Contract Specification (${tech.protocols})

\`\`\`yaml
openapi: 3.1.0
info:
  title: Zero-Trust Subsystem API
  version: 1.0.0
  description: Auto-synthesized contract for ${rawText.substring(0, 60)}...
paths:
  /api/v1/subsystem/execute:
    post:
      summary: Execute sanitized business transaction
      security:
        - OAuth2Bearer: []
        - MutualTLS: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                workflowId: { type: string }
                payloadDigest: { type: string }
      responses:
        '200':
          description: Successful execution under zero-trust controls
\`\`\`

---

## 3. Data Storage & Schema Design (${tech.database})

\`\`\`sql
-- Enterprise ACID schema definition for ${domain}
CREATE TABLE IF NOT EXISTS subsystem_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workflow_id VARCHAR(64) NOT NULL,
    domain VARCHAR(128) NOT NULL,
    payload_hash CHAR(64) NOT NULL,
    execution_status VARCHAR(32) DEFAULT 'PENDING',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_subsystem_workflow ON subsystem_records(workflow_id);
\`\`\`
`;

  return {
    agentName: 'Solutions Architect Agent',
    agentRole: 'C4 Architecture, Data Schemas & API Specifications',
    iconName: 'architecture',
    summary: `C4 Container Model & ${tech.database} schema specification for ${architecture}`,
    markdownContent: markdown,
    tags: ['C4 Architecture', tech.protocols, tech.database, architecture],
  };
}

function generateTechDocDeliverable(
  rawText: string,
  maskedText: string,
  architecture: string,
  compliance: string,
  cloudTarget: string,
  codeGraph?: CodebaseGraph
): AgentDeliverableResponse {
  const { domain } = detectDomain(rawText);
  const tech = extractEntities(rawText);

  const markdown = `# Low-Level Technical Document (LLD)
**System Domain:** ${domain}  
**Architecture Pattern:** ${architecture}  
**Target Infrastructure:** ${cloudTarget}  
**Security Clearance:** Zero-Trust Tier 1 (${compliance})  

---

## 1. Low-Level Component Architecture
The module executes within an isolated container runtime interfacing with **${tech.database}** and communicating over **${tech.protocols}**:

\`\`\`
+-----------------------+       mTLS 1.3       +------------------------------------+
| API Ingestion Gateway | -------------------> | DLP Tokenizer & Vault Interceptor  |
+-----------------------+                      +------------------------------------+
                                                                  |
                                                                  v
+-----------------------+   PostgreSQL DDL     +------------------------------------+
|  Encrypted Storage    | <------------------- |  Zero-Trust Business Logic Engine  |
+-----------------------+                      +------------------------------------+
\`\`\`

---

## 2. API Contract Specifications (REST / JSON-RPC)

### 2.1 Endpoint: Submit & Sanitize Payload
- **Route:** \`POST /api/v1/workspaces/execute\`
- **Headers:**
  - \`Authorization: Bearer <mTLS-JIT-Token>\`
  - \`X-Zero-Trust-Client-Cert: SHA256:<ClientCertThumbprint>\`
  - \`Content-Type: application/json\`
- **Request Schema:**
\`\`\`json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["payload", "complianceBaseline", "idempotencyKey"],
  "properties": {
    "payload": { "type": "string", "description": "Raw input payload prior to gateway sanitization" },
    "complianceBaseline": { "type": "string", "enum": ["SOC2", "HIPAA", "PCI-DSS", "GDPR"] },
    "idempotencyKey": { "type": "string", "format": "uuid" },
    "executionMode": { "type": "string", "default": "DETERMINISTIC" }
  }
}
\`\`\`
- **Success Response (200 OK):**
\`\`\`json
{
  "status": "SANITIZED_AND_QUEUED",
  "sanitizedTokenCount": 3,
  "transactionId": "tx_9981a20bf12",
  "vaultReceipt": "sha256:7b910e54d...",
  "timestamp": "2026-09-12T16:00:00Z"
}
\`\`\`

---

## 3. Database Schema & Migration DDL (PostgreSQL)

\`\`\`sql
-- Zero-Trust Protected Data Store Migration
CREATE TABLE IF NOT EXISTS secure_audit_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feature_ref VARCHAR(120) NOT NULL,
    sanitized_digest VARCHAR(64) NOT NULL,
    vault_token_reference VARCHAR(128) NOT NULL,
    compliance_tag VARCHAR(50) DEFAULT '${compliance}',
    execution_status VARCHAR(40) NOT NULL DEFAULT 'INITIALIZED',
    actor_id VARCHAR(80) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_audit_feature_ref ON secure_audit_records(feature_ref);
CREATE INDEX IF NOT EXISTS idx_audit_compliance ON secure_audit_records(compliance_tag);
\`\`\`

---

## 4. Cryptographic Enforcement & Resilience
- **Cryptographic Cipher Suites:** TLS_AES_256_GCM_SHA384 and TLS_CHACHA20_POLY1305_SHA256.
- **Circuit Breaker Threshold:** 5 consecutive failures trips breaker for 30 seconds backoff.
- **Token Vault Invalidation:** All in-memory surrogate tokens expire strictly after 30 minutes JIT TTL.
`;

  return {
    agentName: 'Technical Lead Agent',
    agentRole: 'Low-Level Technical Specification & API Schemas',
    iconName: 'terminal',
    summary: `Low-level technical specification, API contracts, database DDL and security protocols`,
    markdownContent: markdown,
    tags: ['Technical Document', 'API Specs', 'Database DDL', 'Security Protocols'],
  };
}

function generateSecurityDeliverable(
  rawText: string,
  maskedText: string,
  compliance: string,
  cloudTarget: string
): AgentDeliverableResponse {
  const { domain } = detectDomain(rawText);
  const tech = extractEntities(rawText);

  const markdown = `# STRIDE Threat Model & Security Posture
**Risk Rating:** LOW (Residual Risk Mitigated)  
**Security Boundary:** ${cloudTarget} Zero-Trust Enclave  
**Compliance Standard:** ${compliance}  

---

## 1. STRIDE Threat Analysis

| Threat Category | Potential Attack Vector | Zero-Trust Mitigation Control | Status |
| :--- | :--- | :--- | :--- |
| **Spoofing** | Rogue caller attempting to execute against ${tech.protocols} | Strict mTLS with hardware-backed X.509 client certs | **MITIGATED** |
| **Tampering** | In-transit payload corruption or parameter injection | SHA-256 HMAC payload verification and signed envelopes | **MITIGATED** |
| **Repudiation** | Actor denies initiating or approving workflow execution | Immutable audit ledger with dual-signature approval trail | **MITIGATED** |
| **Information Disclosure** | Plaintext credential leak from input to reasoning engine | Presidio DLP Gateway + Redis Vault tokenization | **ELIMINATED** |
| **Denial of Service** | Volumetric abuse on ingestion gateway | Distributed Redis token-bucket rate limiting (10,000 req/min) | **MITIGATED** |
| **Elevation of Privilege** | Compromised worker accessing ${tech.database} directly | Just-In-Time (JIT) ephemeral credentials (TTL <= 30m) | **MITIGATED** |

---

## 2. OWASP Top 10 & Zero-Trust Defense Matrix

- **A01: Broken Access Control**: Enforced through RBAC with least-privilege principles at both API Gateway and database role layers.
- **A02: Cryptographic Failures**: All data encrypted in transit (TLS 1.3) and at rest using AES-256-GCM.
- **A03: Injection Attacks**: Strict parameterized queries and prepared statements enforced on **${tech.database}**.
`;

  return {
    agentName: 'CyberSec Ops Agent',
    agentRole: 'STRIDE Threat Modeling & OWASP Mitigation Matrix',
    iconName: 'security',
    summary: `STRIDE matrix & zero-trust threat model addressing ${tech.database} & ${compliance}`,
    markdownContent: markdown,
    tags: ['STRIDE', 'OWASP', compliance, 'Zero-Trust'],
  };
}

export async function generateLlmProjectMemory(codeGraph: CodebaseGraph, repoUrl: string): Promise<string> {
  const apiKey = process.env.OPENAI_API_KEY || process.env.AZURE_OPENAI_KEY;
  if (!apiKey || apiKey === 'dummy_key') {
    return `# Project Context: ${repoUrl || 'Local Codebase'}\n\n## Overview\n- **Total Files Scanned:** ${codeGraph.filesCount}\n- **Detected Tech Stack:** ${codeGraph.techStack.join(', ')}\n\n## Codebase Modules\n${codeGraph.modules.map(m => `### ${m.directory}\n- **Primary Tech:** ${m.tech}\n- **Key Files:** ${m.keyFiles.join(', ')}\n`).join('\n')}\n\n## Security & Details\n- **Dependencies:** ${Object.keys(codeGraph.dependencies).length > 0 ? Object.keys(codeGraph.dependencies).join(', ') : 'None detected'}\n`;
  }

  try {
    let llm: any;
    if (process.env.AZURE_OPENAI_KEY) {
      llm = new AzureChatOpenAI({
        azureOpenAIApiKey: apiKey,
        azureOpenAIApiInstanceName: process.env.AZURE_OPENAI_INSTANCE || 'pitchperfectllmengine2',
        azureOpenAIApiDeploymentName: process.env.AZURE_OPENAI_DEPLOYMENT || 'gpt-4o',
        azureOpenAIApiVersion: '2024-02-15-preview',
        temperature: 0.2,
      });
    } else {
      llm = new ChatOpenAI({
        openAIApiKey: apiKey,
        modelName: 'gpt-4o',
        temperature: 0.2,
      });
    }

    const codeGraphPrompt = `
Target Application Context: 
- Original Repository URL: ${repoUrl || 'Unknown'}
- Local Clone Path: \`${codeGraph.repoPath}\` (${codeGraph.filesCount} files)
- Tech Stack: ${codeGraph.techStack.join(', ')}
- Modules:
${codeGraph.modules.map(m => `  * ${m.directory} (${m.tech}): ${m.keyFiles.join(', ')}`).join('\n')}
- Dependencies: ${Object.keys(codeGraph.dependencies).join(', ')}
`;

    const prompt = `
You are an expert Software Architect and Technical Analyst. Your task is to generate a comprehensive "memory.md" markdown file that summarizes the project context based on the code graph data provided below.
This memory file will be used by other AI agents to understand the repository, its architecture, and its capabilities so they can write requirements and generate code.

${codeGraphPrompt}

Generate a well-structured markdown document containing:
1. An Executive Summary of what this codebase appears to be.
2. The core Technology Stack and identified dependencies.
3. Architecture & Modules (describe what each directory likely handles).
4. Any assumptions about the deployment target or security posture based on the tools found.

Keep it highly technical, precise, and concise. Do NOT include generic filler.
`;

    const response = await llm.invoke(prompt);
    return typeof response.content === 'string' ? response.content : JSON.stringify(response.content);
  } catch (err: any) {
    console.warn('[Generate Memory] LLM invocation failed, falling back to static:', err.message);
    return `# Project Context: ${repoUrl || 'Local Codebase'}\n\n## Overview\n- **Total Files Scanned:** ${codeGraph.filesCount}\n- **Detected Tech Stack:** ${codeGraph.techStack.join(', ')}\n\n## Codebase Modules\n${codeGraph.modules.map(m => `### ${m.directory}\n- **Primary Tech:** ${m.tech}\n- **Key Files:** ${m.keyFiles.join(', ')}\n`).join('\n')}\n\n## Security & Details\n- **Dependencies:** ${Object.keys(codeGraph.dependencies).length > 0 ? Object.keys(codeGraph.dependencies).join(', ') : 'None detected'}\n`;
  }
}

