. ./common.sh

tnsping AWSDB> /dev/null 2>&1
st=$?

if [ $st -eq 0 ]; then
  info "tnsping AWSDB    : OK"
else
  error "tnsping AWSDB    : KO"
fi

tnsping pdb1> /dev/null 2>&1
st=$?

if [ $st -eq 0 ]; then
  info "tnsping PDB1     : OK"
else
  error "tnsping PDB1     : KO"
fi

echo "exit" | sqlplus -L quest/questuser@AWSDB | grep Connected > /dev/null
if [ $? -eq 0 ] 
then
   info "sqlplus AWSDB    : OK"
else
   error "sqlplus AWSDB    : KO"
fi

echo "exit" | sqlplus -L test/test@pdb1 | grep Connected > /dev/null
if [ $? -eq 0 ] 
then
   info "sqlplus VM1 pdb1 : OK"
else
   error "sqlplus VM1 pdb1 : KO"
fi

