 # Use the official Tomcat 8 image as the base image
FROM tomcat:8.5

# Remove the default Tomcat applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy the WAR file from your local machine into the Tomcat webapps directory
COPY target/DemoApp-0.0.1-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war
# COPY /usr/local/tomcat/webapps/*.war /usr/local/tomcat/webapps/ROOT.war

# Expose the default Tomcat port
EXPOSE 8080

# Start Tomcat when the container launches
CMD ["catalina.sh", "run"]