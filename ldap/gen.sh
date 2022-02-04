#!/bin/sh


### run this file to create the base ldif's for users and groups

./gen_users.sh
./gen_groups.sh



### use these commands to add users and groups into LDAP Server from the ldif's

#ldapadd -f users_add.ldif -D cn=ldapadm,dc=demo,dc=local -w password
#ldapadd -f groups_add.ldif -D cn=ldapadm,dc=demo,dc=local -w password
