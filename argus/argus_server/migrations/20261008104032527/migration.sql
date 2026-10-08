BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_audit_entry" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "at" timestamp without time zone NOT NULL,
    "actor" text NOT NULL,
    "action" text NOT NULL,
    "targetKind" text NOT NULL,
    "targetId" bigint NOT NULL,
    "detail" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_camera" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "name" text NOT NULL,
    "sourceKind" text NOT NULL,
    "sourceRef" text NOT NULL,
    "enabled" boolean NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "lastSignalAt" timestamp without time zone,
    "status" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_contact" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "name" text NOT NULL,
    "role" text NOT NULL,
    "notifyInApp" boolean NOT NULL,
    "telegramChatId" text,
    "telegramLinkCode" text,
    "isLinked" boolean,
    "createdAt" timestamp without time zone
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_incident" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "cameraId" bigint NOT NULL,
    "ruleId" bigint NOT NULL,
    "ruleSnapshotJson" text NOT NULL,
    "severity" text NOT NULL,
    "status" text NOT NULL,
    "openedAt" timestamp without time zone NOT NULL,
    "ackedAt" timestamp without time zone,
    "resolvedAt" timestamp without time zone,
    "evidenceFileKey" text,
    "verification" json NOT NULL,
    "summary" text NOT NULL,
    "signalContextJson" text NOT NULL,
    "assignedTo" text
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_incident_event" (
    "id" bigserial PRIMARY KEY,
    "incidentId" bigint NOT NULL,
    "at" timestamp without time zone NOT NULL,
    "kind" text NOT NULL,
    "detail" text NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_rule_spec" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "name" text NOT NULL,
    "enabled" boolean NOT NULL,
    "cameraIds" json NOT NULL,
    "trigger" json NOT NULL,
    "conditions" json NOT NULL,
    "severity" text NOT NULL,
    "verify" json NOT NULL,
    "actions" json NOT NULL,
    "cooldownSec" bigint NOT NULL,
    "escalation" json NOT NULL,
    "sourceText" text NOT NULL,
    "parsedBy" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "version" bigint NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_workspace" (
    "id" bigserial PRIMARY KEY,
    "ownerUserId" text NOT NULL,
    "name" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "settings" json NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_zone" (
    "id" bigserial PRIMARY KEY,
    "cameraId" bigint NOT NULL,
    "name" text NOT NULL,
    "kind" text NOT NULL,
    "color" text NOT NULL,
    "polygon" json NOT NULL,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR argus
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('argus', '20261008104032527', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261008104032527', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260924105404509', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105404509', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = now();


COMMIT;
