After running 'maven eclipse:generate-classpath' for 
this project you need to add the following line into .classpath 
so that log4j.properties will still be in classpath for
the eclipse tomcat plugin:

<classpathentry kind="lib" path="WEB-INF/classes"/>

