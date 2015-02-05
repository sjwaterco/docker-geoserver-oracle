#-------- Generic stuff all our Dockerfiles should start with so we get caching ------------
FROM tomcat:8.0
MAINTAINER Tim Sutton<tim@linfiniti.com>

RUN  export DEBIAN_FRONTEND=noninteractive
ENV  DEBIAN_FRONTEND noninteractive
RUN  dpkg-divert --local --rename --add /sbin/initctl
#RUN  ln -s /bin/true /sbin/initctl

# Use local cached debs from host (saves your bandwidth!)
# Change ip below to that of your apt-cacher-ng host
# Or comment this line out if you do not with to use caching
ADD 71-apt-cacher-ng /etc/apt/apt.conf.d/71-apt-cacher-ng

RUN apt-get -y update

#-------------Application Specific Stuff ----------------------------------------------------

RUN apt-get -y install unzip openjdk-7-jre-headless openjdk-7-jre

ADD resources /tmp/resources

# A little logic that will fetch the geoserver zip file if it
# is not available locally in the resources dir and
RUN if [ ! -f /tmp/resources/geoserver.zip ]; then \
    wget -c http://downloads.sourceforge.net/project/geoserver/GeoServer/2.6.2/geoserver-2.6.2-bin.zip -O /tmp/resources/geoserver.zip; \
    fi; \
    unzip /tmp/resources/geoserver.zip -d /opt && mv -v /opt/geoserver* /opt/geoserver;
RUN if [ ! -f /tmp/resources/geoserver-oracle.zip ]; then \
    wget -c http://sourceforge.net/projects/geoserver/files/GeoServer/2.6.2/extensions/geoserver-2.6.2-oracle-plugin.zip -O /tmp/resources/geoserver-oracle.zip; \
    fi; \
    unzip /tmp/resources/geoserver-oracle.zip -d /opt/gsora && mv -v /opt/gsora/* /opt/geoserver/webapps/geoserver/WEB-INF/lib;

# If you would like the jdbc config module to be installed, uncomment these lines. 
# NOTE that you will need to configure this module with your connection info.  
# I've included a sample properties file for GeoServer here, since there's not one 
# included with the default setup at this point (2/5/15) but you'll need to move it
# into your geoserver data directory / jdbcconfig folder.    
#RUN if [ ! -f /tmp/resources/geoserver-jdbc-config.zip ]; then \
#    wget http://ares.boundlessgeo.com/geoserver/2.6.x/community-latest/geoserver-2.6-SNAPSHOT-jdbcconfig-plugin.zip -O /tmp/resources/geoserver-jdbcconfig.zip; \
#    fi; \
#    unzip /tmp/resources/geoserver-jdbcconfig.zip -d /opt/gsjdbcconfig && mv -v /opt/gsjdbcconfig/* /opt/geoserver/webapps/geoserver/WEB-INF/lib;

# I upgraded ojdbc14 to ojdbc7.  If you want to do this, place it in the resources
# folder "resources" and run the build process.  I'm not including it in this repo
# because of licensing issues. 
#RUN mv /tmp/resources/ojdbc7.jar /opt/geoserver/webapps/geoserver/WEB-INF/lib;
#RUN if [ -f /opt/geoserver/webapps/geoserver/WEB-INF/lib/ojdbc14.jar ]; then \
#    rm /opt/geoserver/webapps/geoserver/WEB-INF/lib/ojdbc14.jar; \
#    fi;

ENV GEOSERVER_HOME /opt/geoserver
ENV JAVA_HOME /usr/
# If using ojdbc7, you may have to set this.
# ENV JAVA_OPTS -Duser.timezone=America/Los_Angeles

#ENTRYPOINT "/opt/geoserver/bin/startup.sh"
CMD "/opt/geoserver/bin/startup.sh"
EXPOSE 8080
