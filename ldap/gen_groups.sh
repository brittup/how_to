#!/bin/sh

# Test groups
#
# All users are part of testgroup1
# All regular users are part of testgroup2
# All mixedcase users are part of testgroup3
# All LDAP-only users are part of testgroup4
# testgroup5 has a mixture
# testgroup6 is empty
#

OUTPUT=groups_add.ldif

echo "# Test environment Groups ou" > $OUTPUT
echo "" >> $OUTPUT
#
# testgroup1 - all users
#
{
echo "# testgroup1: all users"
echo ""
cat <<EOF
dn: cn=testgroup1,ou=groups,dc=vlab,dc=local
cn: testgroup1
gidnumber: 1001
objectclass: posixGroup
userpassword: {crypt}x
EOF
for i in {1..20} ; do
  echo "memberuid: testuser${i}"
done
for i in {1..10} ; do
  echo "memberuid: MixedUser${i}"
done
for i in {1..10} ; do
  echo "memberuid: ldapuser${i}"
done
echo ''
} >> $OUTPUT

#
# testgroup2 - all AD/LDAP users
#
{
echo "# testgroup2: all AD/LDAP users"
echo ""
cat <<EOF
dn: cn=testgroup2,ou=Groups,dc=vlab,dc=local
cn: testgroup2
gidnumber: 1002
objectclass: posixGroup
userpassword: {crypt}x
EOF
for i in {1..20} ; do
  echo "memberuid: testuser${i}"
done
echo ''
} >> $OUTPUT

#
# testgroup3 - all mixed case users
#
{
echo "# testgroup3: all mixed case users"
echo ""
cat <<EOF
dn: cn=testgroup3,ou=groups,dc=vlab,dc=local
cn: testgroup3
gidnumber: 1003
objectclass: posixGroup
userpassword: {crypt}x
EOF
for i in {1..10} ; do
  echo "memberuid: MixedUser${i}"
done
echo ''
} >> $OUTPUT

#
# testgroup4 - all LDAP-only users
#
{
echo "# testgroup4: all LDAP-only users"
echo ""
cat <<EOF
dn: cn=testgroup4,ou=groups,dc=vlab,dc=local
cn: testgroup4
gidnumber: 1004
objectclass: posixGroup
userpassword: {crypt}x
EOF
for i in {1..10} ; do
  echo "memberuid: ldapuser${i}"
done
echo ''
} >> $OUTPUT

#
# testgroup5 - mixed set of users
#
{
echo "# testgroup5: mixed set of users"
echo ""
cat <<EOF
dn: cn=testgroup5,ou=groups,dc=vlab,dc=local
cn: testgroup5
gidnumber: 1005
objectclass: posixGroup
userpassword: {crypt}x
memberuid: testuser1
memberuid: testuser4
memberuid: testuser8
memberuid: testuser15
memberuid: MixedUser1
memberuid: MixedUser4
memberuid: MixedUser8
memberuid: ldapuser1
memberuid: ldapuser4
memberuid: ldapuser8
EOF
echo ''
} >> $OUTPUT

#
# testgroup6 - empty group
#
{
echo "# testgroup6: empty group"
echo ""
cat <<EOF
dn: cn=testgroup6,ou=groups,dc=vlab,dc=local
cn: testgroup6
gidnumber: 1006
objectclass: posixGroup
userpassword: {crypt}x
EOF
echo ''
} >> $OUTPUT

echo "# End of test Groups ou" >> $OUTPUT
