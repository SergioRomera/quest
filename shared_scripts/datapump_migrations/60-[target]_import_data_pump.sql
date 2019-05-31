/* Formatted on 15/05/2019 15:52:18 (QP5 v5.336) */
SET LINESIZE 200
SET SERVEROUTPUT ON
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE
    hdnl           NUMBER;
    l_status       VARCHAR2 (255);
    ind            NUMBER;                                       -- Loop index
    h1             NUMBER;                             -- Data Pump job handle
    percent_done   NUMBER;                       -- Percentage of job complete
    job_state      VARCHAR2 (30);                -- To keep track of job state
    le             ku$_LogEntry;                 -- For WIP and error messages
    js             ku$_JobStatus;            -- The job status from get_status
    jd             ku$_JobDesc;         -- The job description from get_status
    sts            ku$_Status;     -- The status object returned by get_status
BEGIN
    hdnl :=
        DBMS_DATAPUMP.OPEN (operation   => 'IMPORT',
                            job_mode    => 'SCHEMA',
                            job_name    => 'IMPORT_QUEST_PERF');
    DBMS_DATAPUMP.ADD_FILE (handle      => hdnl,
                            filename    => '&1',
                            directory   => '&2',
                            filetype    => 1);
    DBMS_DATAPUMP.METADATA_FILTER (hdnl, 'SCHEMA_EXPR', 'IN (''&3'')');
    DBMS_DATAPUMP.START_JOB (hdnl);
    --DBMS_DATAPUMP.WAIT_FOR_JOB(handle=>hdnl,job_state=>l_status);
    --DBMS_OUTPUT.PUT_LINE('State: '||l_status);

    percent_done := 0;
    job_state := 'UNDEFINED';

    WHILE (job_state != 'COMPLETED') AND (job_state != 'STOPPED')
    LOOP
        DBMS_DATAPUMP.get_status (
            hdnl,
              DBMS_DATAPUMP.ku$_status_job_error
            + DBMS_DATAPUMP.ku$_status_job_status
            + DBMS_DATAPUMP.ku$_status_wip,
            -1,
            job_state,
            sts);
        js := sts.job_status;

        -- If the percentage done changed, display the new value.

        IF js.percent_done != percent_done
        THEN
            DBMS_OUTPUT.put_line (
                '*** Job percent done = ' || TO_CHAR (js.percent_done));
            percent_done := js.percent_done;
        END IF;

        -- If any work-in-progress (WIP) or error messages were received for the job,
        -- display them.

        IF (BITAND (sts.mask, DBMS_DATAPUMP.ku$_status_wip) != 0)
        THEN
            le := sts.wip;
        ELSE
            IF (BITAND (sts.mask, DBMS_DATAPUMP.ku$_status_job_error) != 0)
            THEN
                le := sts.error;
            ELSE
                le := NULL;
            END IF;
        END IF;

        IF le IS NOT NULL
        THEN
            ind := le.FIRST;

            WHILE ind IS NOT NULL
            LOOP
                DBMS_OUTPUT.put_line (le (ind).LogText);
                ind := le.NEXT (ind);
            END LOOP;
        END IF;
    END LOOP;

    -- Indicate that the job finished and detach from it.

    DBMS_OUTPUT.put_line ('Job has completed');
    DBMS_OUTPUT.put_line ('Final job state = ' || job_state);
    DBMS_DATAPUMP.detach (hdnl);
END;
/
