#!/bin/bash

help(){
  echo " Use: $0 <client/server>"
}

test_ping(){
  ping -q -c4 "$1" > /dev/null 2>&1
}

show_status(){
  if [ $? -eq 0 ]
  then
    echo "OK"
  else
    echo "Failed"
  fi
}

[ "$(id -u)" != "0" ] && echo " Error. This script must be run as root" 1>&2 && exit 1
[ $# != 1 ] && help && exit 1
[ "$1" != "client" -a "$1" != "server" ] && help && exit 2
. "$PWD"/settings.sh

# client test
if [ "$1" = "client" ]; then
  echo ""
  echo " [ Private Cloud ] "
  echo -n " * Connectivity Primary DNS Private Cloud..."
  test_ping "$PRIMARY_DNS"
  show_status

  echo -n " * Connectivity Secundary DNS Private Cloud..."
  test_ping "$SECONDARY_DNS"
  show_status

  echo " [ DNS ] "
  echo -n " * Connectivity DNS Name..."
  test_ping "$DNS_NAME"
  show_status

  echo -n " * Connectivity Primary DNS Name..."
  test_ping ns1."$DNS_NAME"
  show_status

  echo -n " * Connectivity Secondary DNS Name..."
  test_ping ns2."$DNS_NAME"
  show_status

  echo -n " * Connectivity External Query..."
  test_ping google.com
  show_status

  echo " [ LDAP ] "
  echo -n " * Connectivity LDAP Server..."
  test_ping ldap."$DNS_NAME"
  show_status

  echo -n " * Check read LDAP..."
  sudo ldapsearch -x -H ldap://ldap."$DNS_NAME" -b "cn=User One,ou=st,o=um,c=es" mobile > /dev/null 2>&1
  show_status

  echo " [ SMTP ] "
  echo -n " * Connectivity SMTP Server..."
  test_ping smtp."$DNS_NAME"
  show_status

  echo " [ POP ] "
  echo -n " * Connectivity POP Server..."
  test_ping pop3."$DNS_NAME"
  show_status

  echo " [ HTTP ] "
  echo -n " * Connectivity HTTP Server..."
  test_ping www."$DNS_NAME"
  show_status

  echo -n " * Connectivity www.st.um..."
  test_ping www.st.um
  show_status

  echo -n " * Connectivity www1.st.um..."
  test_ping www.st.um
  show_status

  echo -n " * Connectivity www2.st.um..."
  test_ping www.st.um
  show_status

  echo -n " * Connectivity www3.st.um..."
  test_ping www.st.um
  show_status

# Server test
else
  echo " [ BIND Check Files ] "
  echo -n " * Check Config file..."
  named-checkconf
  show_status

  echo -n " * Check Database file..."
  named-checkzone cat /etc/bind/db."$DNS_NAME".um.zone
  show_status

  echo " [ LDAP ]"
  echo -n " * Connectivity LDAP local..."
  sudo ldapsearch -Y EXTERNAL -H ldapi:/// -b "cn=config" olcRootDN olcRootPW > /dev/null 2>&1
  show_status
fi
