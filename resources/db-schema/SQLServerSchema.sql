/**********************************************************************/
/******    DROP SLIDE TABLES                                     ******/
/**********************************************************************/

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[OBJECT]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[OBJECT]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BINDING]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[BINDING]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PARENT_BINDING]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[PARENT_BINDING]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[CHILDREN]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[CHILDREN]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LINKS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[LINKS]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LOCKS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[LOCKS]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[VERSION_CONTENT]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[VERSION_CONTENT]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PROPERTIES]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[PROPERTIES]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[PERMISSIONS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[PERMISSIONS]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[VERSION_PREDS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[VERSION_PREDS]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[VERSION_LABELS]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[VERSION_LABELS]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[VERSION_HISTORY]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[VERSION_HISTORY]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[VERSION]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[VERSION]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[BRANCH]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[BRANCH]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[LABEL]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[LABEL]
GO

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[URI]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[URI]
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

sp_addtype id_type,           bigint
GO

sp_addtype uri_str_type,     "nvarchar(800)"
GO

sp_addtype revision_no_type, "nvarchar(20)"
GO

sp_addtype hash_type,         bigint
GO

sp_addtype literal_str_type, "nvarchar(3000)"
GO

sp_addtype value_str_type,   "nvarchar(255)"
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
    CLASS_NAME      nvarchar(255)          NOT NULL,
    CONSTRAINT      FK_OBJECT_URI_ID
       FOREIGN KEY (URI_ID)
       REFERENCES   URI (URI_ID)
)
GO    

CREATE TABLE dbo.BINDING (
    URI_ID          id_type               NOT NULL
        REFERENCES  URI (URI_ID),
    NAME            uri_str_type          NOT NULL,
    CHILD_UURI_ID    id_type              NOT NULL
        REFERENCES  URI (URI_ID),
    UNIQUE CLUSTERED (URI_ID, NAME, CHILD_UURI_ID)
)
GO

CREATE TABLE dbo.PARENT_BINDING (
    URI_ID          id_type               NOT NULL
        REFERENCES  URI (URI_ID),
    NAME            uri_str_type          NOT NULL,
    PARENT_UURI_ID    id_type             NOT NULL
        REFERENCES  URI (URI_ID),
    UNIQUE CLUSTERED (URI_ID, NAME, PARENT_UURI_ID)
) 
GO

CREATE TABLE dbo.LINKS (
    URI_ID          id_type               NOT NULL  FOREIGN KEY
        REFERENCES  URI (URI_ID),
    LINK_TO_ID      id_type               NOT NULL  FOREIGN KEY
        REFERENCES  URI (URI_ID),
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
    OBJECT_ID       id_type               NOT NULL  FOREIGN KEY
       REFERENCES   URI (URI_ID),
    SUBJECT_ID      id_type               NOT NULL  FOREIGN KEY
       REFERENCES   URI (URI_ID),
    TYPE_ID         id_type               NOT NULL  FOREIGN KEY
       REFERENCES   URI (URI_ID),
    EXPIRATION_DATE numeric(14, 0)   	  NOT NULL,
    IS_INHERITABLE  bit                   NOT NULL, 
    IS_EXCLUSIVE    bit                   NOT NULL,
    OWNER           nvarchar(255),
    CONSTRAINT      FK_LOCKS_LOCK_ID
       FOREIGN KEY (LOCK_ID)
       REFERENCES   URI (URI_ID)
)
GO

CREATE TABLE dbo.BRANCH ( 
    BRANCH_ID       id_type               IDENTITY  UNIQUE NOT NULL,
    BRANCH_STRING   nvarchar(255)          UNIQUE NOT NULL,
    UNIQUE NONCLUSTERED (BRANCH_ID)
)
GO

CREATE TABLE dbo.LABEL (
    LABEL_ID        id_type               IDENTITY  UNIQUE NOT NULL,
    LABEL_STRING    nvarchar(255)          NOT NULL,
    UNIQUE NONCLUSTERED (LABEL_ID)
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
    URI_ID          id_type               NOT NULL  FOREIGN KEY
       REFERENCES   VERSION (URI_ID),
    BRANCH_ID       id_type               NOT NULL  FOREIGN KEY
       REFERENCES   BRANCH (BRANCH_ID),
    REVISION_NO     nVARCHAR(20)	       	  NOT NULL,
    --UNIQUE CLUSTERED (URI_ID, BRANCH_ID, REVISION_NO)
)
GO
CREATE INDEX XVERSION_HISTORY1 
	ON VERSION_HISTORY(URI_ID, BRANCH_ID, REVISION_NO) 
GO

CREATE TABLE dbo.VERSION_PREDS (
    VERSION_ID         id_type            NOT NULL  FOREIGN KEY 
        REFERENCES  VERSION_HISTORY (VERSION_ID),
    PREDECESSOR_ID     id_type            NOT NULL  FOREIGN KEY
        REFERENCES  VERSION_HISTORY (VERSION_ID),
    UNIQUE CLUSTERED (VERSION_ID, PREDECESSOR_ID)
)
GO
CREATE INDEX XVERSION_PREDS1 
	ON VERSION_PREDS(VERSION_ID, PREDECESSOR_ID) 
GO

CREATE TABLE dbo.VERSION_LABELS (
    VERSION_ID         id_type            NOT NULL  FOREIGN KEY
        REFERENCES  VERSION_HISTORY (VERSION_ID),
    LABEL_ID           id_type            NOT NULL  FOREIGN KEY
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
    VERSION_ID         id_type            NOT NULL  FOREIGN KEY
        REFERENCES  VERSION_HISTORY (VERSION_ID),    
    PROPERTY_NAMESPACE nvarchar(50)        NOT NULL, 
    PROPERTY_NAME      nvarchar(50)        NOT NULL,        
    PROPERTY_VALUE     ntext		       NOT NULL,
    PROPERTY_TYPE      nvarchar(50)        NOT NULL, 
    IS_PROTECTED       bit                NOT NULL,
    UNIQUE CLUSTERED (VERSION_ID, PROPERTY_NAMESPACE, PROPERTY_NAME)
)
GO

CREATE TABLE dbo.PERMISSIONS (
    OBJECT_ID       id_type               NOT NULL  FOREIGN KEY
       REFERENCES   URI (URI_ID),
    SUBJECT_ID      id_type               NOT NULL  FOREIGN KEY
       REFERENCES   URI (URI_ID),
    ACTION_ID       id_type               NOT NULL  FOREIGN KEY
       REFERENCES   URI (URI_ID),
    VERSION_NO      nVARCHAR(20)           NULL,
    IS_INHERITABLE  bit                   NOT NULL,
    IS_NEGATIVE     bit                   NOT NULL,
    -- Both order and sequence would be more suitable, but can not be used
    SUCCESSION      int                   NOT NULL,
    UNIQUE CLUSTERED (OBJECT_ID, SUBJECT_ID, ACTION_ID),
    UNIQUE (OBJECT_ID, SUCCESSION)
)
GO