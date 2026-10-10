BEGIN;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "dispatch_room" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "name" text NOT NULL,
    "code" text NOT NULL,
    "description" text,
    "createdById" bigint NOT NULL,
    "createdByName" text NOT NULL,
    "createdAt" timestamp without time zone NOT NULL,
    "cameraIds" json NOT NULL,
    "isActive" boolean NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room_member" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "userId" bigint NOT NULL,
    "userName" text NOT NULL,
    "userRole" text NOT NULL,
    "joinedAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "room_message" (
    "id" bigserial PRIMARY KEY,
    "roomId" bigint NOT NULL,
    "senderId" bigint,
    "senderName" text NOT NULL,
    "senderRole" text,
    "kind" text NOT NULL,
    "content" text NOT NULL,
    "incidentId" bigint,
    "cameraName" text,
    "severity" text,
    "createdAt" timestamp without time zone NOT NULL
);

--
-- ACTION CREATE TABLE
--
CREATE TABLE "user_profile" (
    "id" bigserial PRIMARY KEY,
    "workspaceId" bigint NOT NULL,
    "fullName" text NOT NULL,
    "email" text NOT NULL,
    "role" text NOT NULL,
    "avatarUrl" text,
    "createdAt" timestamp without time zone NOT NULL
);


--
-- MIGRATION VERSION FOR argus
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('argus', '20261010075459638', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010075459638', "timestamp" = now();

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
