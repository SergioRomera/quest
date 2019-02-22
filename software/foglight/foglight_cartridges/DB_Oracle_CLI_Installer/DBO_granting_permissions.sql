--
-- This software is confidential. Quest Software Inc., or one of its subsidiaries, has supplied this software to you
-- under terms of a license agreement, nondisclosure agreement or both.
--
-- You may not copy, disclose, or use this software except in accordance with those terms.
--
-- Copyright 2017 Quest Software Inc. ALL RIGHTS RESERVED.
--
-- QUEST SOFTWARE INC. MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
-- OR NON-INFRINGEMENT. QUEST SOFTWARE SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
-- MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
--

DECLARE
  vCommon boolean;
  vCdbRoot boolean;
  db_version number ;

  function getVersion return number is
    version varchar2(100);
    compatibility varchar2(100);
  begin
     DBMS_UTILITY.DB_VERSION(version,compatibility);
     return to_number(substr(version,1,instr(version,'.')-1));
  end getVersion;

  function getValue(pSql varchar2) return varchar2 is
    l_cursor number;
    l varchar2(300);
    rc number ;
  begin
    l_cursor := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(l_cursor, pSql, DBMS_SQL.native);
    DBMS_SQL.define_column(l_cursor, 1, l,300);
    rc := DBMS_SQL.execute_and_fetch(l_cursor);
    DBMS_SQL.column_value(l_cursor, 1, l);
    DBMS_SQL.close_cursor(l_cursor);
    return l;
  end getValue;

  function is_common_user return boolean is
  begin
    return upper(getValue('select common from cdb_users  where username=upper(''&&USER_NAME'') and rownum<2'))
                  ='YES';
  end is_common_user;

  function is_pluggable return boolean is
  begin
    return upper(getValue('select cdb  From v$database'))='YES';
  end is_pluggable;

  function is_cdb_root return boolean is
  begin
    return getValue('select con_id from V$session where sid=sys_context(''USERENV'',''SID'')')=1;
  end is_cdb_root;



BEGIN
  db_version:=getVersion;
  if db_version>=12 then
      if is_pluggable then
         vCommon:=is_common_user;
         vCdbRoot:=is_cdb_root;
         case
           when not vCommon and not vCdbRoot then  raise_application_error(-20110,'no common,no cdb$root');
           when  vCommon and not vCdbRoot then  raise_application_error(-20111,' common,no cdb$root');
           when  not vCommon and vCdbRoot then  raise_application_error(-20112,' not common,cdb$root');
           else null;
         end case;
      end if;
  end if;
end;
/


GRANT CREATE  SESSION   TO &&USER_NAME
/


begin
execute immediate 'grant SET CONTAINER to &&USER_NAME container=all';
exception when others then  if sqlcode=-65117 or sqlcode=-990 then null; else raise ; end if;
end;
/


CREATE OR REPLACE
PROCEDURE execute_immediate(p_sql_text varchar2,pignore number default null) IS

        l_cursor integer default 0;
        rc       integer default 0;
        v_sql_text     varchar2(4000):=p_sql_text;

       table_already_exists EXCEPTION;
   PRAGMA EXCEPTION_INIT(table_already_exists,-955);

   table_not_exists EXCEPTION;
   PRAGMA EXCEPTION_INIT(table_not_exists,-942);

   insuff_privs EXCEPTION;
   PRAGMA EXCEPTION_INIT(insuff_privs,-1031);

BEGIN
            l_cursor:=dbms_sql.open_cursor;
             dbms_sql.parse(l_cursor,v_sql_text,dbms_sql.native);
             rc:=dbms_sql.execute(l_cursor);
            dbms_sql.close_cursor(l_cursor);

   EXCEPTION
      WHEN table_already_exists THEN
         DBMS_SQL.CLOSE_CURSOR(l_cursor);

      WHEN table_not_exists THEN
         DBMS_SQL.CLOSE_CURSOR(l_cursor);

      WHEN insuff_privs THEN
         raise_application_error(-1031,'unsufficient privileges, please specify SYSDBA user');
     when others then
         if sqlcode=pignore then null;
         else
           raise_application_error(-20001,sqlerrm||',sql:'||v_sql_text);
         end if;
END execute_immediate;
/


DECLARE
    type array_t is table of varchar2(30);
   array array_t ;
   vcmd varchar2(4000);

   owner_name varchar2(30) := upper('&&USER_NAME');
   isContainer boolean := false;

    function getValue(pSql varchar2) return varchar2 is
    rc number ;
    l_cursor number;
    l varchar2(300);
      begin
        l_cursor := DBMS_SQL.open_cursor;
        DBMS_SQL.parse(l_cursor, pSql, DBMS_SQL.native);
        DBMS_SQL.define_column(l_cursor, 1, l,300);
        rc := DBMS_SQL.execute_and_fetch(l_cursor);
        DBMS_SQL.column_value(l_cursor, 1, l);
        DBMS_SQL.close_cursor(l_cursor);
        return l;
      end getValue;


      function is_pluggable return boolean is
      begin
        return upper(getValue('select cdb  From v$database'))='YES';
      end is_pluggable;

     function getVersion return number is
        version varchar2(100);
        compatibility varchar2(100);
      begin
         DBMS_UTILITY.DB_VERSION(version,compatibility);
         return to_number(substr(version,1,instr(version,'.')-1));
      end getVersion;


BEGIN

  if getVersion>=12 then
      if is_pluggable then
         isContainer:=true;
      end if;
  end if;

    
  if getVersion>=12 then
    array := array_t
            ('cdb_waiters'    ,
        'cdb_PDB_HISTORY'    ,
        'cdb_cdb_RSRC_PLAN_DIRECTIVES',
        'cdb_cons_columns',
        'cdb_constraints',
        'cdb_data_files',
        'cdb_db_links',
        'cdb_directories',
        'cdb_extents',
        'cdb_free_space',
        'cdb_indexes',
        'cdb_jobs',
        'cdb_jobs_running',
        'cdb_libraries',
        'cdb_objects',
        'cdb_profiles',
        'cdb_role_privs',
        'cdb_roles',
        'cdb_rollback_segs',
        'cdb_scheduler_jobs',
        'cdb_scheduler_running_jobs',
        'cdb_segments',
        'cdb_sequences',
        'cdb_sequences',
        'cdb_synonyms',
        'cdb_sys_privs',
        'cdb_tab_columns',
        'cdb_tab_privs',
        'cdb_tables',
        'cdb_tablespaces',
        'cdb_temp_files',
        'cdb_temp_free_space',
        'cdb_undo_extents',
        'cdb_users',
        'cdb_views',
        'cdb_recyclebin',
        'fet$',
        'file$',
        'gv_$archive_dest',
        'gv_$archive_dest_status',
        'gv_$archived_log',
        'gv_$dataguard_stats',
        'gv_$dataguard_status',
        'gv_$instance',
        'gv_$instance_cache_transfer',
        'gv_$lock',
        'gv_$managed_standby',
        'gv_$pq_sysstat',
        'gv_$rman_configuration',
        'gv_$rman_output',
        'gv_$session',
        'gv_$session_wait',
        'gv_$sort_segment',
        'gv_$spparameter',
        'gv_$sql',
        'gv_$sysstat',
        'gv_$temp_extent_pool',
        'gv_$undostat',
        'obj$',
        'recyclebin$',
        'ts$',
        'uet$',
        'user$',
        'v_$archive_dest',
        'v_$archived_log',
        'v_$asm_disk',
        'v_$asm_disk_stat',
        'v_$asm_diskgroup',
        'v_$asm_diskgroup',
        'v_$asm_diskgroup_stat',
        'v_$asm_operation',
        'v_$asm_template',
        'v_$cell',
        'v_$containers',
        'V_$SERVICES',
        'v_$controlfile',
        'v_$con_sysstat',
        'v_$con_system_event',
        'v_$database',
        'v_$datafile',
        'v_$dataguard_config',
        'v_$dataguard_status',
        'v_$dbfile',
        'v_$dispatcher',
        'v_$enqueue_stat',
        'v_$enqueue_statistics',
        'v_$event_name',
        'v_$filestat',
        'v_$fixed_table',
        'v_$flash_recovery_area_usage',
        'v_$flashback_database_log',
        'v_$instance',
        'v_$instance_cache_transfer',
    	'v_$iostat_file',
        'v_$librarycache',
        'v_$lock',
        'v_$log',
        'v_$log_history',
        'v_$logfile',
		'v_$memory_target_advice',
        'v_$open_cursor',
    	'v_$osstat',
        'v_$parameter',
        'v_$pdbs',
		'v_$pga_target_advice',
        'v_$pgastat',
        'v_$pq_sysstat',
        'v_$process',
        'v_$recovery_file_dest',
        'v_$resource',
        'v_$result_cache_statistics',
        'v_$rman_status',
        'v_$backup_set_details',
        'v_$rowcache',
        'v_$segstat',
   	'v_$segment_statistics',
        'v_$sess_time_model',
        'v_$session',
        'v_$session_event',
        'v_$session_wait',
        'v_$sesstat',
        'v_$sga',
        'v_$sga_dynamic_components',
		'v_$sga_target_advice',
        'v_$sgainfo',
        'v_$sgastat',
        'v_$spparameter',
        'v_$sql',
        'v_$sql_plan',
		'v_$sql_shared_cursor',
        'v_$sqlarea',
        'v_$sqltext_with_newlines',
        'v_$standby_log',
        'v_$statname',
        'v_$sysmetric',
        'v_$sysstat',
        'v_$system_event',
        'v_$system_parameter',
        'v_$tablespace',
        'v_$temp_extent_pool',
        'v_$temp_space_header',
        'v_$tempfile',
        'v_$tempstat',
        'v_$transaction',
        'v_$undostat'
        );

            if isContainer then
                for i in 1..array.count loop
                  vcmd :=' grant select on '||array(i)||' to '||owner_name || ' CONTAINER=all';
                  execute_immediate(vcmd,-02030);
                  end loop;
                 vcmd:='alter user '||owner_name|| ' set container_data=ALL CONTAINER=current';
                -- ignore ORA-65058: object-specific CONTAINER_DATA attribute may only be specified for a CONTAINER_DATA object
                 execute_immediate(vcmd,-65058);
            else
                for i in 1..array.count loop
                  vcmd :=' grant select on '||array(i)||' to '||owner_name ;
                  execute_immediate(vcmd,-02030);
                  end loop;
            end if;
    else
        array := array_t
         ('dba_waiters'    ,
        'dba_constraints',
        'dba_data_files',
        'dba_db_links',
        'dba_directories',
        'dba_extents',
        'dba_free_space',
        'dba_indexes',
        'dba_jobs',
        'dba_jobs_running',
        'dba_libraries',
        'dba_objects',
        'dba_profiles',
        'dba_role_privs',
        'V_$SERVICES',
        'dba_roles',
        'dba_rollback_segs',
        'dba_scheduler_jobs',
        'dba_scheduler_running_jobs',
        'dba_segments',
        'dba_sequences',
        'dba_sequences',
        'dba_synonyms',
        'dba_sys_privs',
        'dba_tab_columns',
        'dba_tab_privs',
        'dba_tables',
        'dba_tablespaces',
        'dba_temp_files',
    	'dba_temp_free_space',
        'dba_undo_extents',
        'dba_users',
        'dba_views',
        'dba_recyclebin',
        'fet$',
        'file$',
        'gv_$archive_dest',
        'gv_$archive_dest_status',
        'gv_$archived_log',
        'gv_$dataguard_stats',
        'gv_$dataguard_status',
        'gv_$instance',
        'gv_$instance_cache_transfer',
        'gv_$lock',
        'gv_$managed_standby',
        'gv_$pq_sysstat',
        'gv_$rman_configuration',
        'gv_$rman_output',
        'gv_$session',
        'gv_$session_wait',
        'gv_$sort_segment',
        'gv_$spparameter',
        'gv_$sql',
        'gv_$sysstat',
        'gv_$temp_extent_pool',
        'gv_$undostat',
        'obj$',
        'recyclebin$',
        'ts$',
        'uet$',
        'user$',
        'v_$archive_dest',
        'v_$archived_log',
        'v_$asm_disk',
        'v_$asm_disk_stat',
        'v_$asm_diskgroup',
        'v_$asm_diskgroup',
        'v_$asm_diskgroup_stat',
        'v_$asm_operation',
        'v_$asm_template',
        'v_$cell',
        'v_$controlfile',
        'v_$database',
        'v_$datafile',
        'v_$dataguard_config',
        'v_$dataguard_status',
        'v_$dbfile',
        'v_$dispatcher',
        'v_$enqueue_stat',
        'v_$enqueue_statistics',
        'v_$event_name',
        'v_$filestat',
        'v_$fixed_table',
        'v_$flash_recovery_area_usage',
        'v_$flashback_database_log',
        'v_$instance',
        'v_$instance_cache_transfer',
 	    'v_$iostat_file',
        'v_$librarycache',
        'v_$lock',
        'v_$log',
        'v_$log_history',
        'v_$logfile',
		'v_$memory_target_advice',
        'v_$open_cursor',
   	    'v_$osstat',
        'v_$parameter',
		'v_$pga_target_advice',
        'v_$pgastat',
        'v_$pq_sysstat',
        'v_$process',
        'v_$recovery_file_dest',
        'v_$resource',
        'v_$result_cache_statistics',
        'v_$rman_status',
        'v_$backup_set_details',
        'v_$rowcache',
        'v_$segstat',
  	    'v_$segment_statistics',
        'v_$sess_time_model',
        'v_$session',
        'v_$session_event',
        'v_$session_wait',
        'v_$sesstat',
        'v_$sga',
        'v_$sga_dynamic_components',
        'v_$sgainfo',
		'v_$sga_target_advice',
        'v_$sgastat',
        'v_$spparameter',
        'v_$sql',
        'v_$sql_plan',
		'v_$sql_shared_cursor',
        'v_$sqlarea',
        'v_$sqltext_with_newlines',
        'v_$standby_log',
        'v_$statname',
        'v_$sysmetric',
        'v_$sysstat',
        'v_$system_event',
        'v_$system_parameter',
        'v_$tablespace',
        'v_$temp_extent_pool',
        'v_$temp_space_header',
        'v_$tempfile',
        'v_$tempstat',
        'v_$transaction',
        'v_$undostat'
        );
        for i in 1..array.count loop
          vcmd :=' grant select on '||array(i)||' to '||owner_name ;
          execute_immediate(vcmd,-02030);
          end loop;
    end if;
END;
/

DECLARE
   l_cursor INTEGER DEFAULT 0;
   rc       INTEGER DEFAULT 0;
BEGIN
   l_cursor := DBMS_SQL.OPEN_CURSOR;
   DBMS_SQL.PARSE(l_cursor, 'DROP PROCEDURE EXECUTE_IMMEDIATE', DBMS_SQL.NATIVE);
   rc := DBMS_SQL.EXECUTE(l_cursor);
   DBMS_SQL.CLOSE_CURSOR(l_cursor);
END;
/