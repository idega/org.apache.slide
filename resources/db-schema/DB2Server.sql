--==============================================================
-- DBMS name:      IBM DB2 UDB 8.x Common Server
-- Created on:     6/8/2004 3:41:55 PM
--==============================================================


drop table BINDING;

drop table BRANCH;

drop table "LABEL";

drop table LINKS;

drop table LOCKS;

drop table OBJECT;

drop table PARENT_BINDING;

drop table PERMISSIONS;

drop table PROPERTIES;

drop table URI;

drop table VERSION;

drop table VERSION_CONTENT;

drop table VERSION_HISTORY;

drop table VERSION_LABELS;

drop table VERSION_PREDS;


--==============================================================
-- Table: BINDING
--==============================================================
create table BINDING
(
   URI_ID               NUMERIC(10)            not null,
   "NAME"               VARCHAR(512)           not null,
   CHILD_UURI_ID        NUMERIC(10)            not null,
   constraint "P_Key_1" primary key (URI_ID, "NAME", CHILD_UURI_ID)
);

--==============================================================
-- Table: BRANCH
--==============================================================
create table BRANCH
(
   BRANCH_ID            NUMERIC(10)            not null,
   BRANCH_STRING        VARCHAR(512)           not null,
   constraint "P_Key_1" primary key (BRANCH_ID),
   constraint "A_Key_2" unique (BRANCH_STRING)
);

--==============================================================
-- Table: "LABEL"
--==============================================================
create table "LABEL"
(
   LABEL_ID             NUMERIC(10)            not null,
   LABEL_STRING         VARCHAR(512)           not null,
   constraint "P_Key_1" primary key (LABEL_ID)
);

--==============================================================
-- Table: LINKS
--==============================================================
create table LINKS
(
   URI_ID               NUMERIC(10)            not null,
   LINK_TO_ID           NUMERIC(10)            not null,
   constraint "P_Key_1" primary key (URI_ID, LINK_TO_ID)
);

--==============================================================
-- Table: LOCKS
--==============================================================
create table LOCKS
(
   LOCK_ID              NUMERIC(10)            not null,
   OBJECT_ID            NUMERIC(10)            not null,
   SUBJECT_ID           NUMERIC(10)            not null,
   TYPE_ID              NUMERIC(10)            not null,
   EXPIRATION_DATE      NUMERIC(14)            not null,
   IS_INHERITABLE       NUMERIC(1)             not null,
   IS_EXCLUSIVE         NUMERIC(1)             not null,
   OWNER                VARCHAR(512),
   constraint "P_Key_1" primary key (LOCK_ID)
);

--==============================================================
-- Table: OBJECT
--==============================================================
create table OBJECT
(
   URI_ID               NUMERIC(10)            not null,
   CLASS_NAME           VARCHAR(255)           not null,
   constraint "P_Key_1" primary key (URI_ID)
);

--==============================================================
-- Table: PARENT_BINDING
--==============================================================
create table PARENT_BINDING
(
   URI_ID               NUMERIC(10)            not null,
   "NAME"               VARCHAR(512)           not null,
   PARENT_UURI_ID       NUMERIC(10)            not null,
   constraint "P_Key_1" primary key (URI_ID, "NAME", PARENT_UURI_ID)
);

--==============================================================
-- Table: PERMISSIONS
--==============================================================
create table PERMISSIONS
(
   OBJECT_ID            NUMERIC(10)            not null,
   SUBJECT_ID           NUMERIC(10)            not null,
   ACTION_ID            NUMERIC(10)            not null,
   VERSION_NO           VARCHAR(20),
   IS_INHERITABLE       NUMERIC(1)             not null,
   IS_NEGATIVE          NUMERIC(1)             not null,
   SUCCESSION           NUMERIC(10)            not null,
   constraint "A_Key_1" unique (OBJECT_ID, SUBJECT_ID, ACTION_ID),
   constraint "A_Key_2" unique (OBJECT_ID, SUCCESSION)
);

--==============================================================
-- Table: PROPERTIES
--==============================================================
create table PROPERTIES
(
   VERSION_ID           NUMERIC(10)            not null,
   PROPERTY_NAMESPACE   VARCHAR(50)            not null,
   PROPERTY_NAME        VARCHAR(50)            not null,
   PROPERTY_VALUE       VARCHAR(255),
   PROPERTY_TYPE        VARCHAR(50),
   IS_PROTECTED         NUMERIC(1)             not null,
   constraint "A_Key_1" unique (VERSION_ID, PROPERTY_NAMESPACE, PROPERTY_NAME)
);

--==============================================================
-- Table: URI
--==============================================================
create table URI
(
   URI_ID               NUMERIC(10)            not null,
   URI_STRING           VARCHAR(250)          not null,
   constraint "P_Key_1" primary key (URI_ID),
   constraint "A_Key_2" unique (URI_STRING)
);

--==============================================================
-- Table: VERSION
--==============================================================
create table VERSION
(
   URI_ID               NUMERIC(10)            not null,
   IS_VERSIONED         NUMERIC(1)             not null,
   constraint "P_Key_1" primary key (URI_ID)
);

--==============================================================
-- Table: VERSION_CONTENT
--==============================================================
create table VERSION_CONTENT
(
   VERSION_ID           NUMERIC(10)            not null,
   CONTENT              blob(1000m),
   constraint "P_Key_1" primary key (VERSION_ID)
);

--==============================================================
-- Table: VERSION_HISTORY
--==============================================================
create table VERSION_HISTORY
(
   VERSION_ID           NUMERIC(10)            not null,
   URI_ID               NUMERIC(10)            not null,
   BRANCH_ID            NUMERIC(10)            not null,
   REVISION_NO          VARCHAR(20)            not null,
   constraint "P_Key_1" primary key (VERSION_ID),
   constraint "A_Key_2" unique (URI_ID, BRANCH_ID, REVISION_NO)
);

--==============================================================
-- Table: VERSION_LABELS
--==============================================================
create table VERSION_LABELS
(
   VERSION_ID           NUMERIC(10)            not null,
   LABEL_ID             NUMERIC(10)            not null,
   constraint "A_Key_1" unique (VERSION_ID, LABEL_ID)
);

--==============================================================
-- Table: VERSION_PREDS
--==============================================================
create table VERSION_PREDS
(
   VERSION_ID           NUMERIC(10)            not null,
   PREDECESSOR_ID       NUMERIC(10)            not null,
   constraint "A_Key_1" unique (VERSION_ID, PREDECESSOR_ID)
);

CREATE TRIGGER URI_TRG NO CASCADE BEFORE INSERT ON URI  referencing NEW AS newrow FOR EACH ROW MODE DB2SQL SET  newrow.URI_ID = COALESCE((SELECT MAX(URI_ID) FROM URI) + 1, 1);

CREATE TRIGGER BRANCH_TRG NO CASCADE BEFORE INSERT ON BRANCH  referencing NEW AS newrow FOR EACH ROW MODE DB2SQL SET  newrow.BRANCH_ID = COALESCE((SELECT MAX(BRANCH_ID) FROM BRANCH) + 1, 1);

CREATE TRIGGER LABEL_TRG NO CASCADE BEFORE INSERT ON LABEL  referencing NEW AS newrow FOR EACH ROW MODE DB2SQL SET  newrow.LABEL_ID = COALESCE((SELECT MAX(LABEL_ID) FROM LABEL) + 1, 1);

CREATE TRIGGER VERSION_HIST_TRG NO CASCADE BEFORE INSERT ON VERSION_HISTORY  referencing NEW AS newrow FOR EACH ROW MODE DB2SQL SET  newrow.VERSION_ID = COALESCE((SELECT MAX(VERSION_ID) FROM VERSION_HISTORY) + 1, 1);


alter table BINDING
   add constraint "F_Reference_2" foreign key (URI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table BINDING
   add constraint "F_Reference_3" foreign key (CHILD_UURI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table LINKS
   add constraint "F_Reference_6" foreign key (URI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table LINKS
   add constraint "F_Reference_7" foreign key (LINK_TO_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table LOCKS
   add constraint "F_Reference_10" foreign key (SUBJECT_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table LOCKS
   add constraint "F_Reference_11" foreign key (TYPE_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table LOCKS
   add constraint "F_Reference_8" foreign key (LOCK_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table LOCKS
   add constraint "F_Reference_9" foreign key (OBJECT_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table OBJECT
   add constraint "F_Reference_1" foreign key (URI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table PARENT_BINDING
   add constraint "F_Reference_4" foreign key (URI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table PARENT_BINDING
   add constraint "F_Reference_5" foreign key (PARENT_UURI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table PERMISSIONS
   add constraint "F_Reference_21" foreign key (OBJECT_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table PERMISSIONS
   add constraint "F_Reference_22" foreign key (SUBJECT_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table PERMISSIONS
   add constraint "F_Reference_23" foreign key (ACTION_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table PROPERTIES
   add constraint "F_Reference_20" foreign key (VERSION_ID)
      references VERSION_HISTORY (VERSION_ID)
      on delete restrict on update restrict;

alter table VERSION
   add constraint "F_Reference_12" foreign key (URI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table VERSION_CONTENT
   add constraint "F_Reference_19" foreign key (VERSION_ID)
      references VERSION_HISTORY (VERSION_ID)
      on delete restrict on update restrict;

alter table VERSION_HISTORY
   add constraint "F_Reference_13" foreign key (URI_ID)
      references URI (URI_ID)
      on delete restrict on update restrict;

alter table VERSION_HISTORY
   add constraint "F_Reference_14" foreign key (BRANCH_ID)
      references BRANCH (BRANCH_ID)
      on delete restrict on update restrict;

alter table VERSION_LABELS
   add constraint "F_Reference_17" foreign key (VERSION_ID)
      references VERSION_HISTORY (VERSION_ID)
      on delete restrict on update restrict;

alter table VERSION_LABELS
   add constraint "F_Reference_18" foreign key (LABEL_ID)
      references "LABEL" (LABEL_ID)
      on delete restrict on update restrict;

alter table VERSION_PREDS
   add constraint "F_Reference_15" foreign key (VERSION_ID)
      references VERSION_HISTORY (VERSION_ID)
      on delete restrict on update restrict;

alter table VERSION_PREDS
   add constraint "F_Reference_16" foreign key (PREDECESSOR_ID)
      references VERSION_HISTORY (VERSION_ID)
      on delete restrict on update restrict;


