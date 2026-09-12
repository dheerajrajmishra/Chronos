import { Pool } from 'pg';

const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'zero_trust_db',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  port: parseInt(process.env.POSTGRES_PORT || '5433', 10),
});

export const FACTORY_DEFAULT_PROMPTS = {
  memoryPrompt: `Analyze the scanned repository code graph and extract a comprehensive "memory.md" project context file:

1. Executive Project Summary: Purpose, domain classification, and key capabilities of the target application.
2. Core Technology Stack: Languages, frameworks, key libraries, and package dependencies.
3. Module Architecture & Directory Structure: Functional responsibilities of each module and directory.
4. Data Models & Interface Contracts: Detected entities, database schemas, and external API integrations.
5. Security Posture & Assumptions: Detected authentication mechanisms, DLP boundaries, and environment configurations.

Keep it technically rigorous, well-structured in markdown, and actionable for downstream SDLC agents.`,

  brdPrompt: `Focus strictly on the FUNCTIONAL requirements and business aspects. Do NOT include technical implementation details, file names, or codebase file impact matrices in the BRD. Technical design will be handled separately.

Include the following sections with exhaustive depth:
1. Executive Summary & Problem Definition
2. Target Business Objectives & OKRs
3. Target Personas / User Roles
4. In-Scope and Out-of-Scope boundaries
5. Functional Requirements
6. Epics and Detailed User Stories (US-1.1, US-1.2, etc.)
7. Acceptance Criteria in Gherkin (Given-When-Then) format
8. Non-Functional Requirements & Security Controls (Functional perspective)`,

  designPrompt: `Focus strictly on the FUNCTIONAL design and system capability level for the target application. Do NOT include low-level code implementation, database DDL scripts, or infrastructure provisioning configs (which belong to the Technical Specification stage).

Include the following sections with comprehensive functional depth:
1. Executive Functional Overview & Solution Vision
2. As-Is Process & System Architecture (Current baseline workflow, legacy systems, operational pain points, and capability gaps)
3. To-Be Functional Design & Target Architecture (Target operational flow, functional capability decomposition, component interactions, and state transitions)
4. As-Is vs. To-Be Gap Analysis & Transition Impact Matrix
5. Assumptions & Constraints of the New Design:
   - Assumptions (Business, operational, stakeholder, and environmental dependencies)
   - Constraints (Regulatory, compliance, security boundaries, organizational policies, and functional limitations)
6. Functional Component Decomposition & Operational Responsibilities
7. End-to-End Business Event & Data Flow Models (Entity relationships, functional life cycles, and trigger events)
8. User Role Journeys & Persona-Driven Functional Touchpoints`,

  techDocPrompt: `Provide exact, implementation-ready technical specifications:
1. Low-Level Module Architecture & Execution Flow
2. Concrete REST / gRPC API Endpoint Specifications (Paths, Methods, Request & Response JSON schemas, Header authentication)
3. Database DDL & Schema Definitions (PostgreSQL tables, fields, types, indexes, and tokenized vault references)
4. Data Contracts & State Transition Models
5. Cryptographic & Security Boundaries (mTLS 1.3, Presidio PII Gateway Tokenization, Vault Token lifecycle)
6. Error Handling, Resilience & Retry Matrix (HTTP status codes, circuit breakers, fallback patterns)`,

  codePrompt: `Generate clean, modular, and type-safe implementation code strictly adhering to the API contracts and database DDL schema defined in the Technical Document.

Include the following:
1. Project scaffolding with proper directory structure and module boundaries
2. REST/gRPC endpoint handlers with full request validation and error handling
3. Database repository layer with parameterized queries (no raw SQL injection vectors)
4. Presidio DLP client wrappers for dynamic PII masking on sensitive fields
5. Authentication & authorization middleware (JWT/mTLS token verification)
6. Environment-aware configuration (dev, staging, production) with secrets vault integration`,

  unitTestPrompt: `Generate comprehensive unit test suites covering all business logic modules and API handlers.

Include the following:
1. Unit test fixtures with parameterized table-driven test cases
2. Mock implementations for database repositories and external API dependencies
3. Coverage for critical happy paths, negative boundaries, and validation errors
4. Edge cases covering expired tokens, malformed payloads, and rate limit excursions
5. Explicit assertions verifying zero PII leakage in assertion logs
6. Test execution script or command-line instructions`,

  testPrompt: `Design and generate an enterprise end-to-end integration and security test suite:
1. Integration test workflows chaining multi-service operations end-to-end
2. Contract testing (Pact/OpenAPI schema conformance validation)
3. Zero-trust security testing: DLP evasion attempts, authorization bypass, and token tampering
4. Performance and load testing profiles (throughput, p95/p99 latency thresholds)
5. Chaos and resilience testing scenarios (network partitioning, timeout injection)`,

  uatPrompt: `Generate comprehensive User Acceptance Testing (UAT) specifications and sign-off criteria:
1. Business process walkthrough scenarios mapped to original BRD user stories
2. Persona-based user acceptance test scripts with step-by-step instructions
3. Expected business outcomes, verification checklists, and audit criteria
4. Failure severity classification matrix (P0 blocker to P3 cosmetic)
5. Stakeholder sign-off and regulatory compliance certification template`,

  deployPrompt: `Generate zero-trust deployment manifests and CI/CD release pipeline specifications:
1. Infrastructure-as-Code manifests (Kubernetes Deployment, Service, NetworkPolicy, mTLS Istio VirtualService)
2. CI/CD pipeline definition with automated security gates (SAST, DAST, Container scan)
3. Zero-downtime deployment strategy (Canary or Blue/Green with automated rollback triggers)
4. Database migration execution with rollback plan
5. Monitoring & alerting configuration (metrics, logs, traces)
6. Cryptographic release seal: SHA-256 state digest of deployed artifacts
7. Post-deployment smoke tests and rollback trigger conditions`,

  testCaseCreationPrompt: `Generate comprehensive test cases covering functional, security, and edge-case scenarios.
1. Outline test objectives mapped to BRD requirements.
2. Define precondition states and necessary test data.
3. Detail step-by-step test execution sequences.
4. Specify expected outcomes and acceptance criteria.`,

  testAutomationPrompt: `Generate code-level test automation scripts using established testing frameworks.
1. Implement test cases using appropriate assertions.
2. Provide necessary mocks or stubs for external dependencies.
3. Structure scripts for execution in a CI/CD pipeline.`,

  testingResultPrompt: `Analyze testing logs and results, providing a summary of outcomes and remediation steps.
1. Summarize pass/fail rates.
2. Highlight any failing tests and suggest probable causes based on logs.
3. Recommend remediation steps for failed tests.`
};

export const initDB = async () => {
  try {
    const client = await pool.connect();
    console.log('[DB] Connected to PostgreSQL successfully.');
    
    // Create Projects Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS projects (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create Features Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS features (
        id SERIAL PRIMARY KEY,
        project_id INTEGER REFERENCES projects(id) ON DELETE CASCADE,
        name VARCHAR(255) NOT NULL,
        code_access JSONB,
        db_access JSONB,
        base_requirement TEXT,
        brd_prompt TEXT,
        design_prompt TEXT,
        code_prompt TEXT,
        test_prompt TEXT,
        memory_md TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS memory_md TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS memory_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS design_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS code_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS test_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS tech_doc_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS unit_test_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS uat_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS deploy_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS test_case_creation_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS test_automation_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS testing_result_prompt TEXT;`);
    await client.query(`ALTER TABLE features ADD COLUMN IF NOT EXISTS stage_prompts JSONB DEFAULT '{}';`);

    // Create Workflows Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS workflows (
        id SERIAL PRIMARY KEY,
        feature_id INTEGER REFERENCES features(id) ON DELETE CASCADE,
        current_stage INTEGER DEFAULT 1,
        status VARCHAR(50) DEFAULT 'pending',
        stage_data JSONB DEFAULT '{}',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Create Global Settings Table
    await client.query(`
      CREATE TABLE IF NOT EXISTS global_settings (
        key VARCHAR(100) PRIMARY KEY,
        value JSONB NOT NULL,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Seed default theme and factory prompts if not present
    await client.query(`
      INSERT INTO global_settings (key, value)
      VALUES ('theme', '{"mode": "light"}'::jsonb)
      ON CONFLICT (key) DO NOTHING;
    `);

    await client.query(`
      INSERT INTO global_settings (key, value)
      VALUES ('default_prompts', $1::jsonb)
      ON CONFLICT (key) DO UPDATE
      SET value = $1::jsonb || global_settings.value;
    `, [JSON.stringify(FACTORY_DEFAULT_PROMPTS)]);

    client.release();
    console.log('[DB] Database schema initialized.');
  } catch (err) {
    console.error('[DB] Failed to initialize database:', err);
  }
};

export const query = (text: string, params?: any[]) => pool.query(text, params);
