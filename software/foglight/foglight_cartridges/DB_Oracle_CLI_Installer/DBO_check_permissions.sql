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

--
--  This script if the user connected has the right permission to monitor oracle.
--  The main follow is as follow :
--  1. Verify the user has sufficient privileges to access data dictionary views to verify privilege
--     if not - return error message (-20100,'Check failed - oracle cartridge object privileges are missing.');
--  2. Check the instance is pluggable
--      if yes -
--          check the user is common user
--          check the user is connect to cdb$root
--          if something fails return the following errors :
--            case
--              when not_common and not cdb$root - return -20110
--              when common and not cdb$root - return     -20111
--              when not_common and cdb$root - return     -20112
--            else ok
--       end if;
--  3. Check if we've enough permissions
--           if not return -20100
--
--  16:44 07/01/2014
--
DECLARE
  l_cursor                      NUMBER;
  rc                            NUMBER;
  l_sql                         VARCHAR2(32767);
  l_missing_object_privs        NUMBER;
  missing_advisory_privileges   EXCEPTION;
  PRAGMA EXCEPTION_INIT(missing_advisory_privileges, -20100);
  table_does_not_exist          EXCEPTION;
  PRAGMA EXCEPTION_INIT(table_does_not_exist, -942);
  insufficient_privileges       EXCEPTION;
  PRAGMA EXCEPTION_INIT(insufficient_privileges, -1031);
  vCommon boolean;
  vCdbRoot boolean;
  l_dba_objects varchar2(32767);
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
    rc number;
  begin
    l_cursor := DBMS_SQL.open_cursor;
    DBMS_SQL.parse(l_cursor, pSql, DBMS_SQL.native);
    DBMS_SQL.define_column(l_cursor, 1, l,300);
    rc := DBMS_SQL.execute_and_fetch(l_cursor);
    DBMS_SQL.column_value(l_cursor, 1, l);
    DBMS_SQL.close_cursor(l_cursor);
    return nvl(l,'NO_VALUE_ERR');
    exception when others then
       raise_application_error(-20001,sqlerrm||',sql:'||pSql);
  end getValue;

  function is_common_user return boolean is
  begin
    return upper(getValue('select common from cdb_users  where username=user and rownum<2'))
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

  PROCEDURE cleanup IS
  BEGIN
    IF DBMS_SQL.is_open(l_cursor) THEN
      DBMS_SQL.close_cursor(l_cursor);
    END IF;
  END cleanup;


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

  l_dba_objects:= '
                    ''DBA_CDB_RSRC_PLAN_DIRECTIVES'',
                    ''DBA_WAITERS'',
                    ''DBA_DIRECTORIES'',
                    ''DBA_LIBRARIES'',
                    ''DBA_PDB_HISTORY'',
                    ''DBA_UNDO_EXTENTS'',
                    ''DBA_DATA_FILES'',
                    ''DBA_FREE_SPACE'',
                    ''DBA_JOBS'',
                    ''DBA_JOBS'',
                    ''DBA_JOBS_RUNNING'',
                    ''DBA_OBJECTS'',
                    ''DBA_SCHEDULER_JOBS'',
                    ''DBA_SCHEDULER_RUNNING_JOBS'',
                    ''DBA_TABLESPACES'',
                    ''DBA_TEMP_FREE_SPACE'',
                    ''DBA_TEMP_FILES''
                    ';

  l_sql :=
    'SELECT COUNT(*)
   FROM (
          SELECT name
            FROM sys.v_$fixed_table v
            WHERE name IN (
						   ''V$ARCHIVED_LOG'',
                           ''V$CELL'',
                           ''V$CONTAINERS'',
                           ''V$SERVICES'',
                           ''V$CONTROLFILE'',
                           ''V$DATAGUARD_CONFIG'',
                           ''V$FILESTAT'',
                           ''V$FLASH_RECOVERY_AREA_USAGE'',
                           ''V$FLASHBACK_DATABASE_LOG'',
                           ''V$PGASTAT'',
                           ''V$RESULT_CACHE_STATISTICS'',
                           ''V$SQLTEXT_WITH_NEWLINES'',
                           ''V$SQL_PLAN'',
                           ''V$TEMPFILE'',
                           ''V$TEMPSTAT'',
                           ''V$TEMP_SPACE_HEADER'',
                           ''V$TRANSACTION'',
                           ''V$RMAN_STATUS'',
                           ''V$BACKUP_SET_DETAILS'',
                           ''V$ARCHIVE_DEST'',
                           ''V$ASM_DISK'',
                           ''V$ASM_DISKGROUP'',
                           ''V$ASM_DISKGROUP'',
                           ''V$ASM_DISKGROUP_STAT'',
                           ''V$ASM_DISK_STAT'',
                           ''V$ASM_OPERATION'',
                           ''V$ASM_TEMPLATE'',
                           ''V$DATABASE'',
                           ''V$DATAFILE'',
                           ''V$DATAGUARD_STATUS'',
                           ''V$DBFILE'',
                           ''V$DISPATCHER'',
                           ''V$ENQUEUE_STAT'',
                           ''V$ENQUEUE_STATISTICS'',
                           ''V$EVENT_NAME'',
                           ''V$INSTANCE'',
                           ''V$INSTANCE_CACHE_TRANSFER'',
			               ''V$IOSTAT_FILE'',
                           ''V$LIBRARYCACHE'',
                           ''V$LOCK'',
                           ''V$LOG'',
                           ''V$LOGFILE'',
                           ''V$LOG_HISTORY'',
						   ''V$MEMORY_TARGET_ADVICE'',
                           ''V$OPEN_CURSOR'',
			               ''V$OSSTAT'',
                           ''V$PARAMETER'',
						   ''V$PGA_TARGET_ADVICE'',
                           ''V$PQ_SYSSTAT'',
                           ''V$PROCESS'',
                           ''V$RECOVERY_FILE_DEST'',
                           ''V$RESOURCE'',
                           ''V$ROWCACHE'',
                           ''V$SEGSTAT'',
			               ''V$SEGMENT_STATISTICS'',
                           ''V$SESSION'',
                           ''V$SESSION_EVENT'',
                           ''V$SESSION_WAIT'',
                           ''V$SESSTAT'',
                           ''V$SESS_TIME_MODEL'',
                           ''V$SGA'',
                           ''V$SGAINFO'',
                           ''V$SGASTAT'',
                           ''V$SGA_DYNAMIC_COMPONENTS'',
						   ''V$SGA_TARGET_ADVICE'',
                           ''V$SPPARAMETER'',
                           ''V$SQL'',
						   ''V$SQL_SHARED_CURSOR'',
                           ''V$SQLAREA'',
                           ''V$STANDBY_LOG'',
                           ''V$STATNAME'',
                           ''V$SYSSTAT'',
			               ''V$SYSMETRIC'',
                           ''V$SYSTEM_EVENT'',
                           ''V$SYSTEM_PARAMETER'',
                           ''V$CON_SYSTEM_EVENT'',
                           ''V$TABLESPACE'',
                           ''V$TEMP_EXTENT_POOL'',
                           ''V$UNDOSTAT''
                           )
             AND NOT EXISTS(
                   SELECT object_name
                     FROM all_objects
                    WHERE owner = ''SYS''
                      AND object_name =
                               SUBSTR(v.name, 1, 1) || ''_''
                               || SUBSTR(v.name, 2))
          UNION ALL
          SELECT name
            FROM sys.v_$fixed_table v
            WHERE name IN (''GV$ARCHIVED_LOG'',
                           ''GV$ARCHIVE_DEST'',
                           ''GV$ARCHIVE_DEST_STATUS'',
                           ''GV$DATAGUARD_STATS'',
                           ''GV$DATAGUARD_STATUS'',
                           ''GV$LOCK'',
                           ''GV$MANAGED_STANDBY'',
                           ''GV$SESSION'',
                           ''GV$INSTANCE'',
                           ''GV$SQL'',
                           ''GV$SESSION_WAIT'',
                           ''GV$SYSSTAT'',
                           ''GV$SPPARAMETER'',
                           ''GV$PQ_SYSSTAT'',
                           ''GV$ARCHIVE_DEST'',
                           ''GV$INSTANCE_CACHE_TRANSFER'',
                           ''GV$UNDOSTAT'',
                           ''GV$RMAN_CONFIGURATION'',
                           ''GV$RMAN_OUTPUT'',
                           ''GV$TEMP_EXTENT_POOL'',
                           ''GV$SORT_SEGMENT'')
             AND NOT EXISTS(
                   SELECT object_name
                     FROM all_objects
                    WHERE owner = ''SYS''
                      AND object_name =
                               SUBSTR(v.name, 1, 2) || ''_''
                               || SUBSTR(v.name, 3))
          UNION ALL
          SELECT object_name
            FROM sys.dba_objects v
           WHERE owner = ''SYS''
             AND object_type = ''TABLE''
             AND object_name IN
                   (''FET$'',
                    ''UET$'',
                    ''FILE$'',
                    ''OBJ$'',
                    ''TS$'',
                    ''USER$'',
                    ''RECYCLEBIN$'')
             AND NOT EXISTS(
                   SELECT object_name
                     FROM all_objects
                    WHERE owner = ''SYS''
                      AND object_name = v.object_name)
          UNION ALL
          SELECT object_name
            FROM sys.dba_objects v
           WHERE owner = ''SYS''
             AND object_type = ''VIEW''
             AND object_name IN
                   ('||l_dba_objects||')
             AND NOT EXISTS(
                   SELECT object_name
                     FROM all_objects
                    WHERE owner = ''SYS''
                      AND object_name = v.object_name))';

  -- check grants on cdb instead of dba
  if db_version>=12 then  l_sql := replace(upper(l_sql),'DBA','CDB'); end if;

  l_cursor := DBMS_SQL.open_cursor;
  DBMS_SQL.parse(l_cursor, l_sql, DBMS_SQL.native);
  DBMS_SQL.define_column(l_cursor, 1, l_missing_object_privs);
  rc := DBMS_SQL.execute_and_fetch(l_cursor);
  DBMS_SQL.column_value(l_cursor, 1, l_missing_object_privs);
  DBMS_SQL.close_cursor(l_cursor);

  IF l_missing_object_privs > 0 THEN
    RAISE missing_advisory_privileges;
  END IF;


EXCEPTION
  WHEN table_does_not_exist then
    cleanup;
    raise_application_error
                    (-20100,'Check failed - table not exists ');
  WHEN insufficient_privileges then
    cleanup;
    raise_application_error
                    (-20100,'Check failed - insufficient_privileges ');
  WHEN missing_advisory_privileges then
    declare
       l_name varchar2(100);
    begin
    l_sql := replace (l_sql , 'COUNT(*)','NAME')|| ' where rownum<2 ';
      l_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(l_cursor, l_sql, DBMS_SQL.native);
      DBMS_SQL.define_column(l_cursor, 1, l_name,300);
      rc := DBMS_SQL.execute_and_fetch(l_cursor);
      DBMS_SQL.column_value(l_cursor, 1, l_name);
      DBMS_SQL.close_cursor(l_cursor);
    cleanup;
    raise_application_error
                    (-20100,'Check failed - missing_advisory_privileges '||l_name);
   end;
  WHEN OTHERS THEN
    cleanup;
    RAISE;
END;
/