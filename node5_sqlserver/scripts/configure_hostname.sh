echo "******************************************************************************"
echo "Set Hostname." `date`
echo "******************************************************************************"
hostname ${NODE5_HOSTNAME}
cat > /etc/hostname <<EOF
${NODE5_HOSTNAME}
EOF
