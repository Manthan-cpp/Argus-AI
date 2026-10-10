BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "dispatch_room" ADD COLUMN "organizerCode" text;
ALTER TABLE "dispatch_room" ADD COLUMN "supervisorCode" text;
ALTER TABLE "dispatch_room" ADD COLUMN "guardCode" text;
--
-- ACTION ALTER TABLE
--
ALTER TABLE "user_profile" ADD COLUMN "passwordHash" text;
ALTER TABLE "user_profile" ALTER COLUMN "email" DROP NOT NULL;

--
-- MIGRATION VERSION FOR argus
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('argus', '20261010082351605', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261010082351605', "timestamp" = now();

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
