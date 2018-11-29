#!/bin/sh

./gen_users.sh
./gen_groups.sh



#ldapadd -f users_add.ldif -D cn=ldapadm,dc=demo,dc=local -w password
#ldapadd -f groups_add.ldif -D cn=ldapadm,dc=demo,dc=local -w password
