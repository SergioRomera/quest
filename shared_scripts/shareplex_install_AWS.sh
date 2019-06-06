. /vagrant_config/install.env

echo ""
echo "******************************************************************************"
echo "Quest Shareplex AWS queue configuration." `date`
echo "******************************************************************************"
cat > ${SHAREPLEX_VARDIR}/config/my_config_AWS_oracle.cfg <<EOF
datasource:o.pdb1
#AWS configuration
#source tables       target tables           routing map
expand test.%        test.%                  ol7-121-splex2@o.pdb1
expand quest_perf.%  quest_perf.%            ol7-121-splex1@o.${RDS_DB_NAME}
EOF
chmod 777 ${SHAREPLEX_VARDIR}/config/my_config_AWS_oracle.cfg

echo ""
echo "******************************************************************************"
echo "Quest Shareplex AWS ora_setup." `date`
echo "******************************************************************************"
cd ${SHAREPLEX_DIRINSTALL}/bin
echo -e "n\ny\n${RDS_DB_NAME}\n${RDS_USER}\n${RDS_PASSWORD}\nn\nsplex\nsplex\n\n\n\n\n\n" | ./ora_setup

