After running 'maven eclipse:generate-classpath' for 
this project you need to add the following line into .classpath 
so that log4j.properties will still be in classpath for
the eclipse tomcat plugin:

<classpathentry kind="lib" path="WEB-INF/classes"/>


----------------------------------

To use slide you first need, at the moment, to run one db-schema on your database.
The db-schema is located under resources/db-schema.

