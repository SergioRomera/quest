# usage: $0 <target_server>
# Ex: $0 ol7-121-splex2

if [ -z "$1" ]; then
  echo "Usage: $0 <target_server>"
  exit
fi

if [ `whoami` != "oracle" ]
then
echo "You must execute this as oracle!!!";exit
fi

LOCAL=`hostname -s`
#REMOTE=`sed -n 2p $HOME/nodeinfo`
REMOTE=$1

ssh $REMOTE rm -rf /home/oracle/.ssh

rm -rf /home/oracle/.ssh

ssh-keygen -t rsa  -f $HOME/.ssh/id_rsa -N '' -q

touch $HOME/.ssh/authorized_keys
chmod 600  $HOME/.ssh/authorized_keys
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
chmod 400  $HOME/.ssh/authorized_keys

ssh -o StrictHostKeyChecking=no -q $LOCAL /bin/true
scp -o StrictHostKeyChecking=no -q -r $HOME/.ssh $REMOTE:

# and now add the host keys for the FQDN  hostnames
ssh -o StrictHostKeyChecking=no -q ${LOCAL} /bin/true
ssh -o StrictHostKeyChecking=no -q ${REMOTE} /bin/true

ssh -o StrictHostKeyChecking=no -q ${LOCAL}.us.oracle.com /bin/true
ssh -o StrictHostKeyChecking=no -q ${REMOTE}.us.oracle.com /bin/true

scp -q $HOME/.ssh/known_hosts $REMOTE:$HOME/.ssh/known_hosts
