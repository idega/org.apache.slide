/*
 * $Header: /home/cvs/jakarta-slide/src/conf/schema/dropPostgresSchema.sql,v 1.1 2004/02/25 09:13:20 ozeigermann Exp $
 * $Revision: 1.1 $
 * $Date: 2004/02/25 09:13:20 $
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
 * drop the SQL schema used by org.apache.slide.impl.rdbms.PostgresAdapter.
 * Tested with Postgres 7.4.
 *
 */

DROP VIEW LOCKS_VIEW;
DROP VIEW PERMISSIONS_VIEW;
DROP VIEW BINDING_VIEW;
DROP VIEW OBJECT_VIEW;
DROP TABLE PROPERTIES; 
DROP TABLE VERSION_CONTENT; 
DROP TABLE VERSION_PREDS;
DROP TABLE VERSION_LABELS;
DROP TABLE VERSION_HISTORY; 
DROP TABLE VERSION; 
DROP TABLE BINDING;
DROP TABLE PARENT_BINDING;
DROP TABLE LINKS;
DROP TABLE LOCKS;
DROP TABLE BRANCH;
DROP TABLE LABEL; 
DROP TABLE PERMISSIONS; 
DROP TABLE OBJECT;
DROP TABLE URI;
