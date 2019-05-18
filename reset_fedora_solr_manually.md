RESET FEDORA/SOLR MANUALLY

1. Log into data machine.

1. rm -rf the Solr data directory for the `hyrax` core:
   ```
   rm -rf /var/solr/data/hyrax
   ```

1. Re-create the Solr core
   ```
   # start solr if it's not already running...
   sudo /opt/solr/bin/init.d/solr restart
   sudo -u solr /opt/solr/bin/solr create -c hyrax -d /tmp/hyrax_solr_config -p 8983
   ```

   NOTE: The above command requires having your Solr config in /tmp/hyrax_solr_confg. I had to SCP it there from my local machine.
   To do that, do this...
   ```
   # FROM LOCAL MACHINE...
   cd /path/to/ams
   scp -r config ec2-user@AMS_DATA_HOST:/tmp
   ```
   ... where `AMS_DATA_HOST` is the publicly accessible IP. Also, the EC2 instance must have a security group that allows inbound traffic on port 22 before you can SCP in.

1. Delete the contents of the directory for the `fcrepo.home` option:
   ```
   rm -rf /mnt/fedora-data/*
   ```
   NOTE: if you delete the `fedora-data` directory itself, you need to recreate it, and set the owner and group to be `tomcat`:
   ```
   mkdir /mnt/fedora-data
   chown -R tomcat /mnt/fedora-data
   chgrp -R tomcat /mnt/fedora-data
   ```

1. Truncate the `modeshape_repository` table in Postgres.
   ```
   # Log into postgres
   psql -U ams --password -h localhost fcrepo
   fcrepo=> TRUNCATE TABLE modeshape_repository;
   ```

1. Restart Tomcat (which restarts Fedora):
   ```
   sudo service tomcat7 restart
   ```

1. Test access to Solr and Fedora from the web machine:
   ```
   # from the web machine
   curl -IL $SOLR_URL/select
   # => should return an HTTP 200 status code

   curl -IL $FCREPO_URL
   # => should return an HTTP 200 status code
   ```

1. At this point, your Fedora repo and Solr index should be fully reset. However,
   the AMS application has other database tables that may need to be reset.
