/*
 * $Header: /home/cvs/jakarta-slide/src/conf/schema/createPostgresSchema.sql,v 1.3 2004/06/03 10:30:22 ozeigermann Exp $
 * $Revision: 1.3 $
 * $Date: 2004/06/03 10:30:22 $
 *
 * ====================================================================
 *
 * Copyright 1999-2002 The Apache Software Foundation 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/*
 * create the SQL schema used by org.apache.slide.impl.rdbms.PostgresAdapter.
 * Tested with Postgres 7.4.
 *
 */

CREATE TABLE URI (
    URI_ID          serial               PRIMARY KEY  NOT NULL,
    URI_STRING      text                 UNIQUE NOT NULL
);



CREATE TABLE OBJECT (
    URI_ID          integer               PRIMARY KEY,
    CLASS_NAME      text                  NOT NULL,
    CONSTRAINT      FK_OBJECT_URI_ID
       FOREIGN KEY (URI_ID)
       REFERENCES   URI (URI_ID)
);


CREATE TABLE BINDING (
  URI_ID         integer   		NOT NULL  REFERENCES URI(URI_ID), 
  NAME           text           NOT NULL,
  CHILD_UURI_ID  integer   		NOT NULL  REFERENCES URI(URI_ID), 
  PRIMARY KEY    (URI_ID, NAME, CHILD_UURI_ID) 
);


CREATE TABLE PARENT_BINDING (
    URI_ID        integer               NOT NULL  REFERENCES  URI (URI_ID),
    NAME          text                  NOT NULL, 
    PARENT_UURI_ID integer              NOT NULL  REFERENCES  URI (URI_ID),
    PRIMARY KEY    (URI_ID, NAME, PARENT_UURI_ID)
); 

/* TODO Which indices for binding? */


CREATE TABLE LINKS (
    URI_ID          integer               NOT NULL  REFERENCES  URI (URI_ID),
    LINK_TO_ID      integer               NOT NULL  REFERENCES  URI (URI_ID),
    UNIQUE (URI_ID, LINK_TO_ID)
);

CREATE INDEX XURI_ID
	ON LINKS(URI_ID); 


CREATE INDEX XLINK_TO_ID
	ON LINKS(LINK_TO_ID); 

CREATE TABLE LOCKS (
    LOCK_ID         integer               PRIMARY KEY, 
    OBJECT_ID       integer               REFERENCES   URI (URI_ID),
    SUBJECT_ID      integer               REFERENCES   URI (URI_ID),
    TYPE_ID         integer               REFERENCES   URI (URI_ID),
    EXPIRATION_DATE numeric(14, 0)   	  NOT NULL,
    IS_INHERITABLE  smallint              NOT NULL, 
    IS_EXCLUSIVE    smallint              NOT NULL,
    OWNER           text,                	
    CONSTRAINT      FK_LOCKS_LOCK_ID
       FOREIGN KEY (LOCK_ID)
       REFERENCES   URI (URI_ID)
);


CREATE TABLE BRANCH ( 
    BRANCH_ID       serial               UNIQUE NOT NULL,
    BRANCH_STRING   text                 UNIQUE NOT NULL
);

CREATE TABLE LABEL (
    LABEL_ID        serial               UNIQUE NOT NULL,
    LABEL_STRING    text                 NOT NULL
);

CREATE TABLE VERSION (
    URI_ID          integer               PRIMARY KEY,
    IS_VERSIONED    smallint                   NOT NULL,    
    CONSTRAINT      FK_VERSION_URI_ID
       FOREIGN KEY (URI_ID)
       REFERENCES   URI (URI_ID)
);


CREATE TABLE VERSION_HISTORY (
    VERSION_ID      serial               UNIQUE NOT NULL,
    URI_ID          integer               NOT NULL  REFERENCES   URI (URI_ID),
    BRANCH_ID       integer               NOT NULL  REFERENCES   BRANCH (BRANCH_ID),
    REVISION_NO     text                  NOT NULL,
    UNIQUE (URI_ID, BRANCH_ID, REVISION_NO)
);

CREATE INDEX XVERSION_HISTORY1 
	ON VERSION_HISTORY(URI_ID, BRANCH_ID, REVISION_NO); 


CREATE TABLE VERSION_PREDS (
    VERSION_ID         integer            NOT NULL  REFERENCES  VERSION_HISTORY (VERSION_ID),
    PREDECESSOR_ID     integer            NOT NULL  REFERENCES  VERSION_HISTORY (VERSION_ID),
    UNIQUE (VERSION_ID, PREDECESSOR_ID)
);

CREATE INDEX XVERSION_PREDS1 
	ON VERSION_PREDS(VERSION_ID, PREDECESSOR_ID); 


CREATE TABLE VERSION_LABELS (
    VERSION_ID         integer            NOT NULL  REFERENCES  VERSION_HISTORY (VERSION_ID),
    LABEL_ID           integer            NOT NULL  REFERENCES  LABEL (LABEL_ID), 
    UNIQUE (VERSION_ID, LABEL_ID)
);


CREATE TABLE VERSION_CONTENT (
    VERSION_ID         integer            PRIMARY KEY REFERENCES VERSION_HISTORY (VERSION_ID),
    CONTENT            bytea
);


CREATE TABLE PROPERTIES (
    VERSION_ID         integer            NOT NULL  REFERENCES  VERSION_HISTORY (VERSION_ID),    
    PROPERTY_NAMESPACE text               NOT NULL, 
    PROPERTY_NAME      text               NOT NULL,        
    PROPERTY_VALUE     text               NOT NULL,
    PROPERTY_TYPE      text               NOT NULL, 
    IS_PROTECTED       smallint                NOT NULL,
    UNIQUE  (VERSION_ID, PROPERTY_NAMESPACE, PROPERTY_NAME)
);


CREATE TABLE PERMISSIONS (
    OBJECT_ID       integer               NOT NULL  REFERENCES   URI (URI_ID),
    SUBJECT_ID      integer               NOT NULL  REFERENCES   URI (URI_ID),
    ACTION_ID       integer               NOT NULL  REFERENCES   URI (URI_ID),
    VERSION_NO      text                  NULL,
    IS_INHERITABLE  smallint                   NOT NULL,
    IS_NEGATIVE     smallint                   NOT NULL,
    -- Both order and sequence would be more suitable, but can not be used
    SUCCESSION      int                   NOT NULL,
    UNIQUE (OBJECT_ID, SUBJECT_ID, ACTION_ID),
    UNIQUE (OBJECT_ID, SUCCESSION)
);

/**
 * The views are not used by slide, but only as a  debugging/administration help. 
 */
CREATE VIEW OBJECT_VIEW AS 
  SELECT u.URI_STRING,o.CLASS_NAME FROM URI u, OBJECT o WHERE o.URI_ID = u.URI_ID;

CREATE VIEW BINDING_VIEW AS 
   SELECT u1.URI_STRING AS PARENT,u2.URI_STRING AS CHILD 
	FROM BINDING b,URI u1, URI u2 WHERE b.URI_ID = u1.URI_ID AND b.CHILD_UURI_ID = u2.URI_ID;

CREATE VIEW PERMISSIONS_VIEW AS 
   SELECT u1.URI_STRING AS OBJECT, u2.URI_STRING AS SUBJECT, u3.URI_STRING AS ACTION,
	  p.VERSION_NO,p.IS_INHERITABLE,p.IS_NEGATIVE, p.SUCCESSION
	FROM PERMISSIONS p,URI u1,URI u2, URI u3
	WHERE p.OBJECT_ID = u1.URI_ID AND p.SUBJECT_ID = u2.URI_ID AND p.ACTION_ID = u3.URI_ID;

CREATE VIEW LOCKS_VIEW AS
  SELECT l.LOCK_ID,ou.URI_STRING AS OBJECT,su.URI_STRING AS SUBJECT,tu.URI_STRING AS TYPE ,l.EXPIRATION_DATE,l.IS_INHERITABLE,l.IS_EXCLUSIVE
    FROM LOCKS l, URI ou,URI su,URI tu 
    WHERE l.OBJECT_ID = ou.URI_ID AND 	l.SUBJECT_ID = su.URI_ID AND l.TYPE_ID = su.URI_ID;