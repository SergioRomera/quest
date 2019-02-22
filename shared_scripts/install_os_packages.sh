echo "******************************************************************************"
echo "Prepare yum repos and install base packages." `date`
echo "******************************************************************************"
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
cd /etc/yum.repos.d
rm -f public-yum-ol7.repo
wget https://yum.oracle.com/public-yum-ol7.repo
yum install -y yum-utils
yum-config-manager --enable ol7_developer_EPEL
yum install -y zip unzip mlocate telnet tree # sshpass 
yum install -y oracle-rdbms-server-12cR1-preinstall
#yum -y update
