BEGIN;

--
-- ACTION DROP TABLE
--
DROP TABLE "argus_workspace" CASCADE;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_workspace" (
    "id" bigserial PRIMARY KEY,
    "ownerUserId" text NOT NULL,
    "name" text NOT NULL,
    "description" text,
    "organizerCode" text NOT NULL,
    "supervisorCode" text NOT NULL,
    "guardCode" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "isActive" boolean NOT NULL,
    "settings" json NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "argus_workspace_member" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "userName" text NOT NULL,
    "userRole" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR argus
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('argus', '20261010110759456', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010110759456', "timestamp" = now();

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
