#!/bin/sh

OUTPUT=users_add.ldif

echo "# Test environment People ou" > $OUTPUT
echo "" >> $OUTPUT
#
# First, generate users that have corresponding usernames in AD
#
echo "# LDAP/AD users" >> $OUTPUT
echo "" >> $OUTPUT
for i in {1..20}; do
  j=$(printf "%02d" $i)
  cat <<EOF
dn: uid=testuser${i},ou=users,dc=vlab,dc=local
cn: Test User ${i}
gecos: Test User ${i},,,
gidnumber: 1001
homedirectory: /ifs/home/testuser${i}
loginshell: /bin/bash
mail: testuser${i}@vlab.local
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: shadowAccount
shadowlastchange: 12477
shadowmax: 99999
shadowwarning: 7
sn: User
uid: testuser${i}
uidnumber: 10${j}
userpassword: {crypt}$1$iorFDDPCfdadfd7yyXjLg7StvxBGJ1D5ON.

EOF
done >> $OUTPUT

#
# Next, generate users that have mixed-case usernames in AD
#
echo "# LDAP/AD users with mixed-case AD names" >> $OUTPUT
echo "" >> $OUTPUT
for i in {1..10}; do
  j=$(printf "%02d" $i)
  cat <<EOF
dn: uid=MixedUser${i},ou=users,dc=vlab,dc=local
cn: Mixed-Case Test User ${i}
gecos: Mixed-Case Test User ${i},,,
gidnumber: 1001
homedirectory: /ifs/home/MixedUser${i}
loginshell: /bin/bash
mail: MixedUser${i}@vlab.local
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: shadowAccount
shadowlastchange: 12477
shadowmax: 99999
shadowwarning: 7
sn: User
uid: MixedUser${i}
uidnumber: 30${j}
userpassword: {crypt}$1$iorFDDPCfdadfd7yyXjLg7StvxBGJ1D5ON.

EOF
done >> $OUTPUT

#
# Finally, generate users that only exist in LDAP, not in AD
#
echo "# LDAP-only users" >> $OUTPUT
echo "" >> $OUTPUT
for i in {1..10}; do
  j=$(printf "%02d" $i)
  cat <<EOF
dn: uid=ldapuser${i},ou=users,dc=vlab,dc=local
cn: LDAP-only Test User ${i}
gecos: LDAP-only Test User ${i},,,
gidnumber: 1001
homedirectory: /ifs/home/ldapuser${i}
loginshell: /bin/bash
mail: ldapuser${i}@vlab.local
objectclass: inetOrgPerson
objectclass: posixAccount
objectclass: shadowAccount
shadowlastchange: 12477
shadowmax: 99999
shadowwarning: 7
sn: User
uid: ldapuser${i}
uidnumber: 20${j}
userpassword: {crypt}$1$iorFDDPCfdadfd7yyXjLg7StvxBGJ1D5ON.

EOF
done >> $OUTPUT

echo "# End of test People ou" >> $OUTPUT
