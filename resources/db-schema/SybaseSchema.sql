/**********************************************************************/
/******    DROP SLIDE TABLES                                     ******/
/**********************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'OBJECT')
DROP TABLE OBJECT
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'BINDING')
DROP TABLE BINDING
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'PARENT_BINDING')
DROP TABLE PARENT_BINDING
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'LINKS')
DROP TABLE LINKS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'LOCKS')
DROP TABLE LOCKS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'VERSION_CONTENT')
DROP TABLE VERSION_CONTENT
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'PROPERTIES')
DROP TABLE PROPERTIES
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'PERMISSIONS')
DROP TABLE PERMISSIONS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'VERSION_PREDS')
DROP TABLE VERSION_PREDS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'VERSION_LABELS')
DROP TABLE VERSION_LABELS
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'VERSION_HISTORY')
DROP TABLE VERSION_HISTORY
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'VERSION')
DROP TABLE VERSION
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'BRANCH')
DROP TABLE BRANCH
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'LABEL')
DROP TABLE LABEL
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE name = 'URI')
DROP TABLE URI
GO

/**********************************************************************/
/******    DROP EXISTING USER DEFINED DATA TYPES                 ******/
/**********************************************************************/

sp_droptype id_type
GO

sp_droptype uri_str_type
GO

sp_droptype revision_no_type
GO

sp_droptype hash_type
GO

sp_droptype literal_str_type
GO

sp_droptype value_str_type
GO


/**********************************************************************/
/******    ADD USER DEFINED DATA TYPES                           ******/
/**********************************************************************/

sp_addtype id_type,      "numeric(18,0)"
GO

sp_addtype uri_str_type, "varchar(255)"
GO

sp_addtype revision_no_type, "varchar(20)"
GO

sp_addtype hash_type,         "numeric(18,0)"
GO

sp_addtype value_str_type,   "varchar(255)"
GO

/**********************************************************************/
/******    CREATE SLIDE TABLES                                   ******/
/**********************************************************************/

CREATE TABLE dbo.URI (
    URI_ID          id_type               IDENTITY  UNIQUE  NOT NULL,
    URI_STRING      uri_str_type          UNIQUE  NOT NULL,
 --   UNIQUE NONCLUSTERED (URI_ID)
)
GO

CREATE INDEX XUID
	ON URI(URI_ID) 
GO

CREATE INDEX XUSTRING
	ON URI(URI_STRING) 
GO

CREATE TABLE dbo.OBJECT (
    URI_ID          id_type               PRIMARY KEY,
    CLASS_NAME      varchar(255)          NOT NULL,
    CONSTRAINT      FK_OBJECT_URI_ID
       FOREIGN KEY (URI_ID)
       REFERENCES   URI (URI_ID)
)
GO    

CREATE TABLE dbo.BINDING (
    URI_ID          id_type               NOT NULL
        REFERENCES  URI (URI_ID),
    NAME            varchar(238)          NOT NULL, -- index must not be more than 256 bytes
    CHILD_UURI_ID    id_type              NOT NULL
        REFERENCES  URI (URI_ID),
    UNIQUE CLUSTERED (URI_ID, NAME, CHILD_UURI_ID)
)
GO

CREATE TABLE dbo.PARENT_BINDING (
    URI_ID          id_type               NOT NULL
        REFERENCES  URI (URI_ID),
    NAME            varchar(238)          NOT NULL, -- index must not be more than 256 bytes
    PARENT_UURI_ID    id_type             NOT NULL
        REFERENCES  URI (URI_ID),
    UNIQUE CLUSTERED (URI_ID, NAME, PARENT_UURI_ID)
) 
GO

-- early versions of Sybase do not allow more than 16 tables per query
-- URI has too many foreign keys which internally add to the tables used in a query on it
-- remove foreign keys to URI from links as they are likely to be used little
CREATE TABLE dbo.LINKS (
    URI_ID          id_type               NOT NULL
/*        REFERENCES  URI (URI_ID) */ ,  
    LINK_TO_ID      id_type               NOT NULL
/*        REFERENCES  URI (URI_ID) */ ,
    --UNIQUE CLUSTERED (URI_ID, LINK_TO_ID)
)
GO

CREATE INDEX XURI_ID
	ON LINKS(URI_ID) 
GO


CREATE INDEX XLINK_TO_ID
	ON LINKS(LINK_TO_ID) 
GO

CREATE TABLE dbo.LOCKS (
    LOCK_ID         id_type               PRIMARY KEY,
    OBJECT_ID       id_type               NOT NULL
       REFERENCES   URI (URI_ID),
    SUBJECT_ID      id_type               NOT NULL
       REFERENCES   URI (URI_ID),
    TYPE_ID         id_type               NOT NULL
       REFERENCES   URI (URI_ID),
    EXPIRATION_DATE numeric(14, 0)   	  NOT NULL,
    IS_INHERITABLE  bit                   NOT NULL, 
    IS_EXCLUSIVE    bit                   NOT NULL,
    OWNER           varchar(255),
    CONSTRAINT      FK_LOCKS_LOCK_ID
       FOREIGN KEY (LOCK_ID)
       REFERENCES   URI (URI_ID)
)
GO

CREATE TABLE dbo.BRANCH ( 
    BRANCH_ID       id_type               IDENTITY  UNIQUE NOT NULL,
    BRANCH_STRING   varchar(255)          UNIQUE NOT NULL
)
GO

CREATE TABLE dbo.LABEL (
    LABEL_ID        id_type               IDENTITY  UNIQUE NOT NULL,
    LABEL_STRING    varchar(255)          NOT NULL
)
GO

CREATE TABLE dbo.VERSION (
    URI_ID          id_type               PRIMARY KEY,
    IS_VERSIONED    bit                   NOT NULL,    
    CONSTRAINT      FK_VERSION_URI_ID
       FOREIGN KEY (URI_ID)
       REFERENCES   URI (URI_ID)
)
GO

CREATE TABLE dbo.VERSION_HISTORY (
    VERSION_ID      id_type               IDENTITY  UNIQUE NOT NULL,
    URI_ID          id_type               NOT NULL
       REFERENCES   VERSION (URI_ID),
    BRANCH_ID       id_type               NOT NULL
       REFERENCES   BRANCH (BRANCH_ID),
    REVISION_NO     VARCHAR(20)	       	  NOT NULL,
    --UNIQUE CLUSTERED (URI_ID, BRANCH_ID, REVISION_NO)
)
GO
CREATE INDEX XVERSION_HISTORY1 
	ON VERSION_HISTORY(URI_ID, BRANCH_ID, REVISION_NO) 
GO

CREATE TABLE dbo.VERSION_PREDS (
    VERSION_ID         id_type            NOT NULL
        REFERENCES  VERSION_HISTORY (VERSION_ID),
    PREDECESSOR_ID     id_type            NOT NULL
        REFERENCES  VERSION_HISTORY (VERSION_ID),
    UNIQUE CLUSTERED (VERSION_ID, PREDECESSOR_ID)
)
GO
CREATE INDEX XVERSION_PREDS1 
	ON VERSION_PREDS(VERSION_ID, PREDECESSOR_ID) 
GO

CREATE TABLE dbo.VERSION_LABELS (
    VERSION_ID         id_type            NOT NULL
        REFERENCES  VERSION_HISTORY (VERSION_ID),
    LABEL_ID           id_type            NOT NULL
        REFERENCES  LABEL (LABEL_ID), 
    UNIQUE CLUSTERED (VERSION_ID, LABEL_ID)
)
GO

CREATE TABLE dbo.VERSION_CONTENT (
    VERSION_ID         id_type            PRIMARY KEY,
    CONTENT            image              NOT NULL,
    CONSTRAINT FK_VC_VERSION_ID 
        FOREIGN KEY (VERSION_ID)
        REFERENCES  VERSION_HISTORY (VERSION_ID),
)
GO

CREATE TABLE dbo.PROPERTIES (
    VERSION_ID         id_type            NOT NULL
        REFERENCES  VERSION_HISTORY (VERSION_ID),    
    PROPERTY_NAMESPACE varchar(50)        NOT NULL, 
    PROPERTY_NAME      varchar(50)        NOT NULL,        
    PROPERTY_VALUE     varchar(255)       NOT NULL,
    PROPERTY_TYPE      varchar(50)        NOT NULL, 
    IS_PROTECTED       bit                NOT NULL,
    UNIQUE CLUSTERED (VERSION_ID, PROPERTY_NAMESPACE, PROPERTY_NAME)
)
GO

CREATE TABLE dbo.PERMISSIONS (
    OBJECT_ID       id_type               NOT NULL
       REFERENCES   URI (URI_ID),
    SUBJECT_ID      id_type               NOT NULL
       REFERENCES   URI (URI_ID),
    ACTION_ID       id_type               NOT NULL
       REFERENCES   URI (URI_ID),
    VERSION_NO      VARCHAR(20)           NULL,
    IS_INHERITABLE  bit                   NOT NULL,
    IS_NEGATIVE     bit                   NOT NULL,
    -- Both order and sequence would be more suitable, but can not be used
    SUCCESSION      int                   NOT NULL,
    UNIQUE CLUSTERED (OBJECT_ID, SUBJECT_ID, ACTION_ID),
    UNIQUE (OBJECT_ID, SUCCESSION)
)
GO

