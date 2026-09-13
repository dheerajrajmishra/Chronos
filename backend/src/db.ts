import { Pool } from 'pg';

const pool = new Pool({
  user: process.env.POSTGRES_USER || 'postgres',
  host: process.env.POSTGRES_HOST || 'localhost',
  database: process.env.POSTGRES_DB || 'zero_trust_db',
  password: process.env.POSTGRES_PASSWORD || 'postgres',
  port: parseInt(process.env.POSTGRES_PORT || '5433', 10),
});

export const FACTORY_DEFAULT_PROMPTS = {
  memoryPrompt: `Act as a senior software architect and deeply analyze the provided codebase graph. Your goal is to extract a comprehensive, highly structured "memory.md" project context file.

MANDATORY SECTIONS:
1. **Executive Project Summary**: 
   - Define the core purpose and domain classification of the application.
   - Summarize the key capabilities, target audience, and primary business value.
2. **Core Technology Stack & Toolchain**:
   - Explicitly list all programming languages, frameworks, UI libraries, state management solutions, and package dependencies.
   - Note the build tools, package managers, and any custom scripts identified in the graph.
3. **Module Architecture & Directory Structure**:
   - Provide a hierarchical breakdown of functional responsibilities for each major directory (e.g., /frontend/src/components, /backend/src/routes).
   - Detail the architectural pattern in use (e.g., MVC, Microservices, Clean Architecture, Monolith).
4. **Data Models, Entities & Interface Contracts**:
   - Identify all primary data entities (e.g., User, Organization, Feature).
   - Map out the inferred database schemas and foreign key relationships.
   - Document the structure of external API integrations and third-party SaaS services.
5. **Security Posture, Auth & Environments**:
   - Detail detected authentication mechanisms (JWT, OAuth, session-based).
   - Document authorization and RBAC (Role-Based Access Control) boundaries.
   - Note any environment configuration files (.env), secrets management approaches, and network security assumptions.

CONSTRAINTS:
- Keep the output technically rigorous, concise, and structured in Markdown.
- Use bullet points and code blocks where appropriate.
- Do not hallucinate dependencies; strictly base your analysis on the provided code graph.`,

  brdPrompt: `Act as a senior Principal Product Manager and Technical Business Analyst. Generate an exhaustive, industry-standard Business Requirements Document (BRD) for this feature.

You must strictly focus on FUNCTIONAL requirements and business value. DO NOT include low-level technical implementation details (e.g., code snippets, database schemas, or specific file modifications). 

The generated BRD MUST include the following exhaustive sections:

# 1. Executive Summary & Problem Definition
- Clear articulation of the business problem being solved.
- The high-level vision and the strategic value this feature unlocks.

# 2. Target Business Objectives & OKRs
- Specific, measurable outcomes (e.g., "Reduce manual processing time by 40%").
- Key performance indicators (KPIs) to measure post-launch success.

# 3. Target Personas / User Roles
- Detailed descriptions of the primary and secondary users interacting with this feature.
- User motivations, pain points, and technical proficiency.

# 4. In-Scope and Out-of-Scope Definitions
- A highly specific bulleted list of what IS included in this release.
- A highly specific bulleted list of what is STRICTLY EXCLUDED (to prevent scope creep).

# 5. Functional Requirements
- A comprehensive breakdown of all functional capabilities the system must provide.
- Formatted as a numbered list (FR-1, FR-2, etc.) with detailed descriptions.

# 6. Epics and Detailed User Stories
- Group functional requirements into logical Epics.
- Write individual User Stories in the exact format: "As a [Persona], I want to [Action] so that [Value/Benefit]".
- Assign unique identifiers to each story (e.g., US-1.1).

# 7. Acceptance Criteria (Gherkin Format)
- For every User Story, provide comprehensive Acceptance Criteria using the BDD format: 
  "GIVEN [Precondition], WHEN [Action/Event], THEN [Expected Result]".
- Ensure both happy paths and primary failure/error states are covered.

# 8. Non-Functional Requirements (Business Perspective)
- Performance expectations (e.g., "Search results must load in <200ms").
- Security & Privacy compliance (e.g., "PII must be masked for support roles", GDPR/CCPA considerations).
- Usability and Accessibility (e.g., "Must comply with WCAG 2.1 AA standards").

FORMATTING RULES:
- Use markdown headers (#, ##, ###) for clean visual hierarchy.
- Use bold text for emphasis on key business terms.
- Use tables if it improves the readability of the Functional Requirements.`,

  designPrompt: `Act as a senior Enterprise Systems Architect. You are tasked with producing a comprehensive Functional Design and System Architecture Document.

Focus strictly on the FUNCTIONAL design, system capability decomposition, and end-to-end component interactions. Do NOT include line-by-line code implementations or explicit database DDL scripts (those belong in the Technical Specification).

Your output MUST be structured with the following sections in rigorous detail:

# 1. Executive Functional Overview & Solution Vision
- A high-level summary of how the system will functionally operate once the feature is integrated.
- The core architectural philosophy driving the design.

# 2. As-Is Process vs. To-Be Functional Architecture
- Describe the current baseline workflow and capability gaps (As-Is).
- Describe the target operational flow, state transitions, and component interactions (To-Be).
- Provide a clear Gap Analysis.

# 3. Functional Component Decomposition
- Break down the solution into discrete functional modules or microservices.
- For each component, define its Single Responsibility, its inputs, and its expected outputs.
- Identify the boundaries between the frontend application, backend services, and external integrations.

# 4. End-to-End Business Event & Data Flow Models
- Detail the lifecycle of primary entities (e.g., "Draft -> In Review -> Published").
- Describe the chronological sequence of events triggered by user actions.
- Outline how data flows asynchronously (e.g., message queues, webhooks) vs synchronously (HTTP REST/gRPC).

# 5. Assumptions, Constraints & Dependencies
- **Assumptions**: Business, operational, stakeholder, and infrastructure dependencies.
- **Constraints**: Regulatory limitations, strict security boundaries, network policies, and legacy system limitations.

# 6. User Role Journeys & Persona-Driven Touchpoints
- Map exactly how different RBAC roles will traverse the newly designed system.
- Detail the specific UI/UX touchpoints required to fulfill the User Stories.

FORMATTING RULES:
- Use Mermaid.js syntax inside standard markdown code blocks (e.g., \`\`\`mermaid) to render architectural flowcharts, sequence diagrams, and state machines where highly complex logic exists. Ensure Mermaid syntax is valid.
- Use markdown tables to represent component responsibilities.`,

  techDocPrompt: `Act as a distinguished Staff Software Engineer and Technical Lead. You are tasked with writing the definitive Technical Specification Document. 

This document must be explicit, implementation-ready, and leave zero ambiguity for the downstream developer agents. 

Your output MUST include the following exhaustive sections:

# 1. Low-Level Component Architecture & Execution Flow
- Exact mapping of which specific files/directories will be created or modified.
- The concrete design patterns to be employed (e.g., Singleton, Factory, Repository, Middleware).

# 2. Concrete API Endpoint Specifications
For every new or modified API (REST, GraphQL, or gRPC), you MUST define:
- **Path & Method**: e.g., \`POST /api/v1/resource\`
- **Authentication/Authorization**: Required tokens, scopes, and headers.
- **Request Payload**: Strict JSON schema definition (types, required fields, constraints).
- **Response Payload**: Strict JSON schema for 200 OK.
- **Error Codes**: Explicit mapping of 400, 401, 403, 404, 500 error responses and their JSON structure.

# 3. Database Schema & DDL Definitions
- Provide explicit PostgreSQL (or target DB) table structures.
- Detail columns, data types (e.g., VARCHAR, UUID, TIMESTAMPTZ), Primary Keys, and Foreign Keys.
- Define necessary indexes for performance (B-Tree, GIN).
- Specify data caching strategies (e.g., Redis TTL) and database migration steps.

# 4. Cryptographic, Security & Privacy Boundaries
- Explicitly define how sensitive data (PII/PHI) is handled (e.g., Tokenization, AES-256 encryption at rest, TLS 1.3 in transit).
- Define secrets management (Vault injection, environment variables).
- Outline input sanitization and prevention of SQL Injection, XSS, and CSRF.

# 5. Resilience, Error Handling & Retry Matrix
- Define distributed system resilience: Circuit breaker configurations, fallback patterns, and rate-limiting thresholds.
- Detail transaction boundaries and rollback procedures for failed multi-step database writes.

FORMATTING RULES:
- Use standard Markdown formatting.
- Include JSON code blocks for API payloads.
- Include SQL code blocks for database schema changes.
- Write with extreme technical precision.`,

  codePrompt: `Act as a senior Full-Stack Software Engineer. Your objective is to generate the exact, production-ready code modifications required to implement the Technical Specification.

CRITICAL INSTRUCTIONS:
1. **Adhere Strictly to Existing Architecture**: Do NOT introduce new architectural paradigms, unsupported frameworks, or unnecessary external dependencies. You must follow the conventions, formatting, and structural patterns already established in the codebase.
2. **Backward Compatibility**: Ensure that existing endpoints and functions are not broken. If modifying an existing function, preserve its original signature or safely deprecate it.
3. **Security First**: Automatically include parameterized database queries, JWT validation, role-based access checks, and input sanitization.

OUTPUT REQUIREMENTS:
- Provide a detailed, step-by-step implementation plan.
- Group the changes logically by component (e.g., 1. Database Migrations, 2. Backend Models, 3. Backend Controllers, 4. Frontend Services, 5. Frontend UI).
- For every file that needs creation or modification, provide the EXACT file path (e.g., \`src/controllers/userController.ts\`).
- Provide the complete, drop-in ready code snippets for each file. Do not use pseudo-code or omit critical logic with comments like "// implementation goes here". Write the actual logic.
- Include necessary import statements and ensure type safety (TypeScript/Dart/etc) is strictly maintained.`,

  unitTestPrompt: `Act as a senior Quality Assurance Automation Engineer. Generate an exhaustive, industry-standard Manual Test Plan and Test Case Document based on the approved Business Requirements and Technical Specifications.

Your output must cover the following test vectors:
1. **Functional Testing (Happy Path)**: Core business workflows operating under ideal conditions.
2. **Negative Testing**: Invalid inputs, missing parameters, and boundary violations.
3. **Security Testing**: Authorization bypass attempts, SQL injection payloads, XSS vectors, and expired token handling.
4. **Integration Testing**: End-to-end data flow between frontend, backend, and database.
5. **Edge Cases**: Concurrency issues, network timeouts, and extreme data volume conditions.

OUTPUT FORMAT:
Generate a meticulously detailed Markdown table containing all test cases. The table MUST have the exact following columns:
| Test Case ID | Test Category | Scenario Description | Pre-conditions | Step-by-Step Execution | Expected Result | Actual Result | Status (Pass/Fail/Blocked) |

Below the table, provide explicit instructions for test environment setup (e.g., mocking third-party APIs, seeding the test database) and test data prerequisites.`,

  testPrompt: `Act as a senior Software Development Engineer in Test (SDET). Generate comprehensive, robust, and industry-standard automated test scripts to execute the approved Test Cases.

CRITICAL INSTRUCTIONS:
1. **Framework Alignment**: Use modern, established testing frameworks (e.g., Jest, Mocha, Playwright, Cypress for TS/JS; Flutter_test for Dart).
2. **Robustness**: Do not rely on brittle CSS selectors. Use semantic locators (e.g., \`data-testid\`, accessibility labels).
3. **Isolation**: Every test must be completely independent. Include proper \`beforeEach\` (setup) and \`afterEach\` (teardown) hooks to reset state, clear caches, and rollback transactions.
4. **Mocking**: Provide comprehensive mocks, stubs, and spies for external dependencies (e.g., HTTP clients, third-party APIs, database calls).

OUTPUT REQUIREMENTS:
- Provide the exact file paths for the test files (e.g., \`tests/unit/userController.test.ts\`).
- Write complete, syntactically correct, and executable test code.
- Ensure assertions are highly explicit and cover both positive (expect to equal) and negative (expect to throw) outcomes.
- Include comments explaining the rationale behind complex mock setups.`,

  uatPrompt: `Act as a senior QA Manager. Analyze the executed testing logs, test results, and bug reports to generate a definitive QA Sign-Off and Remediation Document.

Your document must include:
1. **Executive QA Summary**: Overall pass/fail percentage, total tests executed, and readiness decision (Go/No-Go).
2. **Defect Analysis**: A categorized list of all failed tests or defects discovered.
3. **Root Cause Hypotheses**: For every failed test, analyze the logs/symptoms and propose the most probable technical root cause (e.g., "Null pointer exception in controller line 45 due to missing payload validation").
4. **Remediation Action Plan**: Step-by-step technical instructions for developers to fix the defects.
5. **Risk Assessment**: Any lingering technical debt, performance concerns, or edge cases that were deferred.`,

  deployPrompt: `Act as a senior DevOps/SRE Engineer. Generate a highly secure, zero-trust deployment manifest and CI/CD release pipeline specification for this feature release.

Your output must be structured as follows:

# 1. Pre-Deployment Checklist
- Required security gates (SAST, DAST, container scanning, dependency vulnerability checks).
- Required approvals (Code Review, QA Sign-off, UAT).

# 2. Infrastructure as Code (IaC) Manifests
- Provide Kubernetes (K8s) manifests (Deployment, Service, Ingress, NetworkPolicy).
- Define mTLS configurations (e.g., Istio VirtualService, PeerAuthentication).
- Include strict resource limits (CPU/Memory requests and limits) and liveness/readiness probes.

# 3. Deployment Strategy
- Define the rollout strategy (e.g., Canary release 10% -> 50% -> 100%, or Blue/Green deployment).
- Specify database migration execution sequence and backup/snapshot procedures.

# 4. Monitoring, Logging & Alerting
- Define explicit Prometheus metrics to track (e.g., HTTP 5xx rate, p99 latency).
- Define Datadog/Grafana alerting thresholds that would trigger an automatic rollback.

# 5. Rollback Plan
- Explicit, step-by-step terminal commands to revert the application deployment and rollback the database state if the canary fails.`,

  testCaseCreationPrompt: `Act as a senior Quality Assurance Automation Engineer. Generate an exhaustive, industry-standard Manual Test Plan and Test Case Document based on the approved Business Requirements and Technical Specifications.

Your output must cover the following test vectors:
1. **Functional Testing (Happy Path)**: Core business workflows operating under ideal conditions.
2. **Negative Testing**: Invalid inputs, missing parameters, and boundary violations.
3. **Security Testing**: Authorization bypass attempts, SQL injection payloads, XSS vectors, and expired token handling.
4. **Integration Testing**: End-to-end data flow between frontend, backend, and database.
5. **Edge Cases**: Concurrency issues, network timeouts, and extreme data volume conditions.

OUTPUT FORMAT:
Generate a meticulously detailed Markdown table containing all test cases. The table MUST have the exact following columns:
| Test Case ID | Test Category | Scenario Description | Pre-conditions | Step-by-Step Execution | Expected Result | Actual Result | Status (Pass/Fail/Blocked) |

Below the table, provide explicit instructions for test environment setup (e.g., mocking third-party APIs, seeding the test database) and test data prerequisites.`,

  testAutomationPrompt: `Act as a senior Software Development Engineer in Test (SDET). Generate comprehensive, robust, and industry-standard automated test scripts to execute the approved Test Cases.

CRITICAL INSTRUCTIONS:
1. **Framework Alignment**: Use modern, established testing frameworks (e.g., Jest, Mocha, Playwright, Cypress for TS/JS; Flutter_test for Dart).
2. **Robustness**: Do not rely on brittle CSS selectors. Use semantic locators (e.g., \`data-testid\`, accessibility labels).
3. **Isolation**: Every test must be completely independent. Include proper \`beforeEach\` (setup) and \`afterEach\` (teardown) hooks to reset state, clear caches, and rollback transactions.
4. **Mocking**: Provide comprehensive mocks, stubs, and spies for external dependencies (e.g., HTTP clients, third-party APIs, database calls).

OUTPUT REQUIREMENTS:
- Provide the exact file paths for the test files (e.g., \`tests/unit/userController.test.ts\`).
- Write complete, syntactically correct, and executable test code.
- Ensure assertions are highly explicit and cover both positive (expect to equal) and negative (expect to throw) outcomes.
- Include comments explaining the rationale behind complex mock setups.`,

  testingResultPrompt: `Act as a senior QA Manager. Analyze the executed testing logs, test results, and bug reports to generate a definitive QA Sign-Off and Remediation Document.

Your document must include:
1. **Executive QA Summary**: Overall pass/fail percentage, total tests executed, and readiness decision (Go/No-Go).
2. **Defect Analysis**: A categorized list of all failed tests or defects discovered.
3. **Root Cause Hypotheses**: For every failed test, analyze the logs/symptoms and propose the most probable technical root cause (e.g., "Null pointer exception in controller line 45 due to missing payload validation").
4. **Remediation Action Plan**: Step-by-step technical instructions for developers to fix the defects.
5. **Risk Assessment**: Any lingering technical debt, performance concerns, or edge cases that were deferred.`
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

    // Default LLM Config
    const defaultLlmConfig = {
      provider: process.env.AZURE_OPENAI_KEY ? 'azure' : 'openai',
      apiUrl: process.env.AZURE_OPENAI_INSTANCE ? `https://${process.env.AZURE_OPENAI_INSTANCE}.openai.azure.com` : '',
      apiKey: process.env.AZURE_OPENAI_KEY || process.env.OPENAI_API_KEY || '',
      textModel: process.env.AZURE_OPENAI_DEPLOYMENT || 'gpt-4o',
      imageProvider: 'openai',
      imageModel: 'dall-e-3',
      imageApiKey: process.env.OPENAI_API_KEY || ''
    };

    await client.query(`
      INSERT INTO global_settings (key, value)
      VALUES ('llm_config', $1::jsonb)
      ON CONFLICT (key) DO NOTHING;
    `, [JSON.stringify(defaultLlmConfig)]);

    client.release();
    console.log('[DB] Database schema initialized.');
  } catch (err) {
    console.error('[DB] Failed to initialize database:', err);
  }
};

export const query = (text: string, params?: any[]) => pool.query(text, params);
