-- ============================================================
-- Azure Metadata Intelligence Framework
-- Core Metadata Store - v1.0
-- Author: Francesco Fiorenza
-- ============================================================

-- Create dedicated schema
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'metadata')
    EXEC('CREATE SCHEMA metadata');
GO

-- ============================================================
-- md_object : Registry of every discovered object
-- ============================================================
CREATE TABLE metadata.md_object (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    provider NVARCHAR(50) NOT NULL,         -- e.g. sql|adf|pbi|logicapp|dataverse
    type NVARCHAR(100) NOT NULL,            -- table|view|pipeline|measure|...
    qualified_name NVARCHAR(400) NOT NULL,  -- unique object identifier
    name NVARCHAR(200) NULL,
    workspace NVARCHAR(200) NULL,
    environment NVARCHAR(50) NULL,
    owner_principal_id NVARCHAR(200) NULL,
    created_on DATETIME2 DEFAULT SYSUTCDATETIME(),
    updated_on DATETIME2 NULL,
    version_id BIGINT NULL,
    hash VARBINARY(32) NULL,
    raw_ref NVARCHAR(MAX) NULL,
    CONSTRAINT UQ_md_object_qualified UNIQUE (qualified_name)
);
GO

-- ============================================================
-- md_property : Key/value store for object properties
-- ============================================================
CREATE TABLE metadata.md_property (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    object_id BIGINT NOT NULL,
    [key] NVARCHAR(200) NOT NULL,
    [value] NVARCHAR(MAX) NULL,
    value_type NVARCHAR(50) NULL,
    is_computed BIT DEFAULT 0,
    CONSTRAINT FK_md_property_object FOREIGN KEY (object_id) 
        REFERENCES metadata.md_object(id) ON DELETE CASCADE
);
GO

-- ============================================================
-- md_relation : Logical relationships among objects
-- ============================================================
CREATE TABLE metadata.md_relation (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    src_object_id BIGINT NOT NULL,
    dst_object_id BIGINT NOT NULL,
    rel_type NVARCHAR(100) NOT NULL,        -- depends_on | reads_from | writes_to ...
    confidence DECIMAL(5,2) DEFAULT 1.0,
    extractor NVARCHAR(100) NULL,
    notes NVARCHAR(500) NULL,
    CONSTRAINT FK_md_relation_src FOREIGN KEY (src_object_id) REFERENCES metadata.md_object(id),
    CONSTRAINT FK_md_relation_dst FOREIGN KEY (dst_object_id) REFERENCES metadata.md_object(id)
);
GO

-- ============================================================
-- md_snapshot : Versioning of metadata over time
-- ============================================================
CREATE TABLE metadata.md_snapshot (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    snapshot_id UNIQUEIDENTIFIER DEFAULT NEWID(),
    taken_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    scope NVARCHAR(50) NULL,
    hash VARBINARY(32) NULL
);
GO

-- ============================================================
-- md_rule : Definition of conformance & best-practice rules
-- ============================================================
CREATE TABLE metadata.md_rule (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    rule_id NVARCHAR(100) NOT NULL,
    name NVARCHAR(200) NOT NULL,
    scope NVARCHAR(50) NOT NULL,            -- sql|adf|pbi|logicapp
    severity NVARCHAR(10) NOT NULL,
    dsl NVARCHAR(MAX) NULL,                 -- YAML DSL content
    enabled BIT DEFAULT 1
);
GO

-- ============================================================
-- md_rule_result : Execution results of conformance rules
-- ============================================================
CREATE TABLE metadata.md_rule_result (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id UNIQUEIDENTIFIER DEFAULT NEWID(),
    rule_id NVARCHAR(100) NOT NULL,
    object_id BIGINT NULL,
    status NVARCHAR(20) NULL,               -- PASS|WARN|FAIL
    evidence NVARCHAR(MAX) NULL,
    remediation NVARCHAR(MAX) NULL,
    duration_ms INT NULL,
    executed_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    CONSTRAINT FK_md_rule_result_object FOREIGN KEY (object_id) REFERENCES metadata.md_object(id)
);
GO

-- ============================================================
-- md_test_spec : Declarative test definitions
-- ============================================================
CREATE TABLE metadata.md_test_spec (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    test_id NVARCHAR(100) NOT NULL,
    scope NVARCHAR(50) NOT NULL,
    inputs_def NVARCHAR(MAX) NULL,
    asserts_def NVARCHAR(MAX) NULL,
    description NVARCHAR(500) NULL
);
GO

-- ============================================================
-- md_test_run : Execution history of tests
-- ============================================================
CREATE TABLE metadata.md_test_run (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    run_id UNIQUEIDENTIFIER DEFAULT NEWID(),
    test_id NVARCHAR(100) NOT NULL,
    status NVARCHAR(20) NULL,
    metrics NVARCHAR(MAX) NULL,
    artifacts_ref NVARCHAR(MAX) NULL,
    executed_at DATETIME2 DEFAULT SYSUTCDATETIME()
);
GO

-- ============================================================
-- Indices & housekeeping
-- ============================================================
CREATE INDEX IX_md_property_object ON metadata.md_property(object_id);
CREATE INDEX IX_md_relation_src ON metadata.md_relation(src_object_id);
CREATE INDEX IX_md_relation_dst ON metadata.md_relation(dst_object_id);
CREATE INDEX IX_md_rule_result_rule ON metadata.md_rule_result(rule_id);
CREATE INDEX IX_md_rule_result_object ON metadata.md_rule_result(object_id);
GO
