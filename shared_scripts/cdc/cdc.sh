
. ./00-drop_tables.sh
. ./20-[target]-create_target_tables_with_cdc.sh
. ./99-shareplex_ora_cleansp.sh
. ./10-[source]-create_tables.sh
. ./25-[source]-activate_cdc_config.sh
#cd /vagrant_scripts/cdc
#. ./\[target\]-shareplex_config.sh
. ./30-[source]-inserts.sh
. ./40-[source]-show_cdc_table.sh
. ./60-[source]-show_config.sh
#. ./50-[source]-delete_table.sh
