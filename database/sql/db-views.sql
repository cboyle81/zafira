SET SCHEMA 'zafira';

--DELETE OR DETACH ALL TESTS WHERE CREATED_AT::date < '2016-01-01'
DROP VIEW IF EXISTS WEEKLY_VIEW;
DROP VIEW IF EXISTS MONTHLY_VIEW;
DROP VIEW IF EXISTS NIGHTLY_VIEW;

DROP MATERIALIZED VIEW IF EXISTS THIRTY_DAYS_VIEW;


DROP MATERIALIZED VIEW IF EXISTS TOTAL_VIEW;
CREATE MATERIALIZED VIEW TOTAL_VIEW AS (
 SELECT row_number() OVER () AS ID,
         PROJECTS.NAME AS PROJECT,
         USERS.ID AS OWNER_ID,
         USERS.USERNAME AS OWNER_USERNAME,
         USERS.EMAIL AS OWNER_EMAIL,
         USERS.FIRST_NAME AS OWNER_FIRST_NAME,
         USERS.LAST_NAME AS OWNER_LAST_NAME,
         USERS.LAST_LOGIN AS OWNER_LAST_LOGIN,
         USERS.COVER_PHOTO_URL AS OWNER_COVER_PHOTO_URL,
         TEST_RUNS.ENV as ENV,
         case when (TEST_RUNS.PLATFORM IS NULL OR TEST_RUNS.PLATFORM ='') then 'N/A'
            else TEST_RUNS.PLATFORM end AS PLATFORM,
         sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
         sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
         sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
         sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
         sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
         sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
         sum( case when TESTS.STATUS = 'QUEUED' then 1 else 0 end ) AS QUEUED,
         COUNT(*) AS TOTAL,
         date_trunc('month', TESTS.CREATED_AT) AS CREATED_AT,
         sum(EXTRACT(epoch FROM (TESTS.FINISH_TIME - TESTS.START_TIME))/60)::bigint as TOTAL_MINUTES,
         sum(EXTRACT(epoch FROM(TESTS.FINISH_TIME - TESTS.START_TIME))/3600)::bigint as TOTAL_HOURS,
         avg(TESTS.FINISH_TIME - TESTS.START_TIME) as AVG_TIME
  FROM TESTS INNER JOIN
    TEST_RUNS ON TESTS.TEST_RUN_ID = TEST_RUNS.ID INNER JOIN
    TEST_CASES ON TESTS.TEST_CASE_ID = TEST_CASES.ID INNER JOIN
    USERS ON TEST_CASES.PRIMARY_OWNER_ID = USERS.ID INNER JOIN
    PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID
  WHERE TESTS.FINISH_TIME IS NOT NULL
        AND TESTS.START_TIME IS NOT NULL
        AND TESTS.START_TIME < date_trunc('month', current_date)
        AND TESTS.STATUS <> 'IN_PROGRESS'
        GROUP BY PROJECT, OWNER_ID, OWNER_USERNAME, ENV, TEST_RUNS.PLATFORM, date_trunc('month', TESTS.CREATED_AT)
  ORDER BY CREATED_AT
);


DROP INDEX IF EXISTS TOTAL_VIEW_INDEX;
CREATE UNIQUE INDEX TOTAL_VIEW_INDEX ON TOTAL_VIEW (ID);

DROP INDEX IF EXISTS TOTAL_VIEW_PROJECT_INDEX;
CREATE INDEX TOTAL_VIEW_PROJECT_INDEX ON TOTAL_VIEW (PROJECT);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_ID_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_ID_INDEX ON TOTAL_VIEW (OWNER_ID);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_INDEX ON TOTAL_VIEW (OWNER_USERNAME);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_EMAIL_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_EMAIL_INDEX ON TOTAL_VIEW (OWNER_EMAIL);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_FIRST_NAME_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_FIRST_NAME_INDEX ON TOTAL_VIEW (OWNER_FIRST_NAME);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_LAST_NAME_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_LAST_NAME_INDEX ON TOTAL_VIEW (OWNER_LAST_NAME);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_LAST_LOGIN_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_LAST_LOGIN_INDEX ON TOTAL_VIEW (OWNER_LAST_LOGIN);

DROP INDEX IF EXISTS TOTAL_VIEW_OWNER_COVER_PHOTO_URL_INDEX;
CREATE INDEX TOTAL_VIEW_OWNER_COVER_PHOTO_URL_INDEX ON TOTAL_VIEW (OWNER_COVER_PHOTO_URL);

DROP INDEX IF EXISTS TOTAL_VIEW_ENV_INDEX;
CREATE INDEX TOTAL_VIEW_ENV_INDEX ON TOTAL_VIEW (ENV);

DROP INDEX IF EXISTS TOTAL_VIEW_PLATFORM_INDEX;
CREATE INDEX TOTAL_VIEW_PLATFORM_INDEX ON TOTAL_VIEW (PLATFORM);

DROP INDEX IF EXISTS TOTAL_VIEW_CREATED_AT_INDEX;
CREATE INDEX TOTAL_VIEW_CREATED_AT_INDEX ON TOTAL_VIEW (CREATED_AT);

DROP VIEW IF EXISTS NIGHTLY_FAILURES_VIEW;
CREATE VIEW NIGHTLY_FAILURES_VIEW AS (
  SELECT
    row_number() OVER () AS ID,
    PROJECTS.NAME AS PROJECT,
    TESTS.ID AS TEST_ID,
    TESTS.NAME AS TEST_NAME,
    USERS.ID AS OWNER_ID,
    USERS.USERNAME AS OWNER,
    USERS.EMAIL AS EMAIL,
    TEST_RUNS.ENV AS ENV,
    TEST_CONFIGS.PLATFORM AS PLATFORM,
    TEST_CONFIGS.PLATFORM_VERSION as PLATFORM_VERSION,
    TEST_CONFIGS.BROWSER AS BROWSER,
    TEST_CONFIGS.BROWSER_VERSION as BROWSER_VERSION,
    TEST_CONFIGS.APP_VERSION as BUILD,
    TEST_CONFIGS.DEVICE as DEVICE,
    TEST_CONFIGS.URL as URL,
    TEST_CONFIGS.LOCALE as LOCALE,
    TEST_CONFIGS.LANGUAGE as LANGUAGE,
    JOBS.JOB_URL AS JOB_URL,
    JOBS.NAME AS JOB_NAME,
    TEST_SUITES.USER_ID AS JOB_OWNER_ID,
    TEST_SUITES.NAME AS TEST_SUITE_NAME,
    TEST_RUNS.ID AS TEST_RUN_ID,
    TEST_RUNS.STATUS AS TEST_RUN_STATUS,
    TEST_RUNS.BUILD_NUMBER AS BUILD_NUMBER,
    '<a href="#!/tests/runs/' || TEST_RUNS.ID || '" target="_blank">' || JOBS.NAME || '</a>' AS TEST_RUN_URL,
    '<a href="#!/tests/runs/' || TEST_RUNS.ID || '/info/' || TESTS.ID || '" target="_blank">' || JOBS.NAME || '</a>' AS TEST_INFO_URL,
    '<a href="' || JOBS.JOB_URL || '/' || TEST_RUNS.build_number || '/rebuild/parameterized' || '" target="_blank">Rebuild</a>' AS REBUILD,
    TESTS.FINISH_TIME - TESTS.START_TIME AS ELAPSED,
    TESTS.START_TIME AS STARTED,
    TESTS.CREATED_AT::date AS CREATED,
    TEST_RUNS.UPSTREAM_JOB_ID AS UPSTREAM_JOB_ID,
    TEST_RUNS.UPSTREAM_JOB_BUILD_NUMBER AS UPSTREAM_JOB_BUILD_NUMBER,
    UPSTREAM_JOBS.NAME AS UPSTREAM_JOB_NAME,
    UPSTREAM_JOBS.JOB_URL AS UPSTREAM_JOB_URL,
    TEST_RUNS.SCM_URL AS SCM_URL,
    PRIORITY_TAGS.VALUE AS PRIORITY,
    FEATURE_TAGS.VALUE AS FEATURE,
    TESTS.MESSAGE AS MESSAGE,
    TESTS.MESSAGE_HASH_CODE AS MESSAGE_HASHCODE,
    TESTS.BLOCKER AS TEST_BLOCKER,
    TESTS.KNOWN_ISSUE AS TEST_KNOWN_ISSUE
  FROM TESTS
     INNER JOIN TEST_RUNS ON TEST_RUNS.ID=TESTS.TEST_RUN_ID
    INNER JOIN TEST_CASES ON TESTS.TEST_CASE_ID=TEST_CASES.ID
    LEFT JOIN TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID 
    LEFT JOIN PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID 
    INNER JOIN JOBS JOBS ON TEST_RUNS.JOB_ID = JOBS.ID
    LEFT JOIN JOBS UPSTREAM_JOBS ON TEST_RUNS.UPSTREAM_JOB_ID = UPSTREAM_JOBS.ID
    INNER JOIN USERS ON TEST_CASES.PRIMARY_OWNER_ID=USERS.ID
    INNER JOIN TEST_SUITES ON TEST_RUNS.TEST_SUITE_ID = TEST_SUITES.ID
    LEFT JOIN TEST_TAGS PRIORITY_TEST_TAGS ON TESTS.ID = PRIORITY_TEST_TAGS.TEST_ID
    LEFT JOIN TAGS PRIORITY_TAGS ON PRIORITY_TEST_TAGS.TAG_ID = PRIORITY_TAGS.ID AND PRIORITY_TAGS.NAME='priority' 
    LEFT JOIN TEST_TAGS FEATURE_TEST_TAGS ON TESTS.ID = FEATURE_TEST_TAGS.TEST_ID
    LEFT JOIN TAGS FEATURE_TAGS ON FEATURE_TEST_TAGS.TAG_ID = FEATURE_TAGS.ID AND FEATURE_TAGS.NAME='feature'
  WHERE TESTS.CREATED_AT >= current_date AND
        TEST_RUNS.STARTED_AT >= current_date AND
        TESTS.STATUS = 'FAILED'
    GROUP BY PROJECTS.NAME, TESTS.ID, TEST_RUNS.ID, USERS.ID, TEST_CONFIGS.PLATFORM, TEST_CONFIGS.PLATFORM_VERSION, TEST_CONFIGS.BROWSER, TEST_CONFIGS.BROWSER_VERSION,
    TEST_CONFIGS.DEVICE, TEST_CONFIGS.URL, TEST_CONFIGS.LOCALE, TEST_CONFIGS.LANGUAGE, TEST_CONFIGS.APP_VERSION, JOBS.ID, JOBS.JOB_URL, JOBS.NAME,
    UPSTREAM_JOBS.NAME, UPSTREAM_JOBS.JOB_URL, TEST_SUITES.NAME, TEST_SUITES.USER_ID, PRIORITY_TAGS.VALUE, FEATURE_TAGS.VALUE
  
);


DROP MATERIALIZED VIEW IF EXISTS TEST_CASE_HEALTH_VIEW;
CREATE MATERIALIZED VIEW TEST_CASE_HEALTH_VIEW AS (
  SELECT ROW_NUMBER() OVER () AS ID,
         PROJECTS.NAME AS PROJECT,
         TEST_CASES.ID AS TEST_CASE_ID,
         TEST_CASES.TEST_METHOD AS TEST_METHOD_NAME,
         SUM( CASE WHEN TESTS.STATUS = 'PASSED' THEN 1 ELSE 0 END ) AS PASSED,
         SUM( CASE WHEN TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE THEN 1 ELSE 0 END ) AS FAILED,
         SUM( CASE WHEN TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE THEN 1 ELSE 0 END ) AS KNOWN_ISSUE,
         SUM( CASE WHEN TESTS.STATUS = 'SKIPPED' THEN 1 ELSE 0 END ) AS SKIPPED,
         SUM( CASE WHEN TESTS.STATUS = 'ABORTED' THEN 1 ELSE 0 END ) AS ABORTED,
         SUM( CASE WHEN TESTS.STATUS = 'IN_PROGRESS' THEN 1 ELSE 0 END ) AS IN_PROGRESS,
         SUM( case when TESTS.STATUS = 'QUEUED' then 1 else 0 end ) AS QUEUED,
         COUNT(*) AS TOTAL,
         SUM(EXTRACT(EPOCH FROM (TESTS.FINISH_TIME - TESTS.START_TIME))/60)::BIGINT AS TOTAL_MINUTES,
         SUM(EXTRACT(EPOCH FROM(TESTS.FINISH_TIME - TESTS.START_TIME))/3600)::BIGINT AS TOTAL_HOURS,
         AVG(EXTRACT(EPOCH FROM(TESTS.FINISH_TIME - TESTS.START_TIME))) AS AVG_TIME,
         MIN(EXTRACT(EPOCH FROM(TESTS.FINISH_TIME - TESTS.START_TIME))) AS MIN_TIME,
         MAX(EXTRACT(EPOCH FROM(TESTS.FINISH_TIME - TESTS.START_TIME))) AS MAX_TIME,
         ROUND(SUM( CASE WHEN TESTS.STATUS = 'PASSED' THEN 1 ELSE 0 END )*100/COUNT(*)) AS STABILITY,
         ROUND(SUM( CASE WHEN TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE THEN 1 ELSE 0 END )*100/COUNT(*)) AS FAILURE,
         ROUND(SUM( CASE WHEN TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE THEN 1 ELSE 0 END )*100/COUNT(*)) AS KNOWN_FAILURE,
         ROUND(SUM( CASE WHEN TESTS.STATUS = 'SKIPPED' THEN 1 ELSE 0 END )*100/COUNT(*)) AS OMISSION,
         ROUND(SUM( CASE WHEN TESTS.STATUS = 'ABORTED' THEN 1 ELSE 0 END )*100/COUNT(*)) AS INTERRUPT,
         ROUND(SUM( CASE WHEN TESTS.STATUS = 'QUEUED' THEN 1 ELSE 0 END )*100/COUNT(*)) AS QUEUE,
         DATE_TRUNC('MONTH', TESTS.CREATED_AT) AS TESTED_AT
  FROM TESTS INNER JOIN
    TEST_CASES ON TESTS.TEST_CASE_ID = TEST_CASES.ID LEFT JOIN
    PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID
  WHERE TESTS.FINISH_TIME IS NOT NULL
        AND TESTS.START_TIME IS NOT NULL
        AND TESTS.STATUS <> 'IN_PROGRESS'
  GROUP BY PROJECTS.ID, TEST_CASES.ID, TESTED_AT
  ORDER BY TESTED_AT
);

DROP INDEX IF EXISTS TEST_CASE_HEALTH_VIEW_INDEX;
CREATE UNIQUE INDEX TEST_CASE_HEALTH_VIEW_INDEX ON TEST_CASE_HEALTH_VIEW (ID);

DROP INDEX IF EXISTS TEST_CASE_HEALTH_VIEW_TEST_METHOD_NAME_INDEX;
CREATE INDEX TEST_CASE_HEALTH_VIEW_TEST_METHOD_NAME_INDEX ON TEST_CASE_HEALTH_VIEW (TEST_METHOD_NAME);

DROP INDEX IF EXISTS TEST_CASE_HEALTH_VIEW_STABILITY_INDEX;
CREATE INDEX TEST_CASE_HEALTH_VIEW_STABILITY_INDEX ON TEST_CASE_HEALTH_VIEW (STABILITY);

DROP INDEX IF EXISTS TEST_CASE_HEALTH_VIEW_TESTED_AT_INDEX;
CREATE INDEX TEST_CASE_HEALTH_VIEW_TESTED_AT_INDEX ON TEST_CASE_HEALTH_VIEW (TESTED_AT);

DROP MATERIALIZED VIEW IF EXISTS THIRTY_DAYS_VIEW;
CREATE MATERIALIZED VIEW THIRTY_DAYS_VIEW AS (
SELECT  row_number() OVER () AS ID,
          PROJECTS.NAME AS PROJECT,
          USERS.ID AS OWNER_ID,
          USERS.USERNAME AS OWNER_USERNAME,
          USERS.EMAIL AS OWNER_EMAIL,
          USERS.FIRST_NAME AS OWNER_FIRST_NAME,
          USERS.LAST_NAME AS OWNER_LAST_NAME,
          USERS.LAST_LOGIN AS OWNER_LAST_LOGIN,
          USERS.COVER_PHOTO_URL AS OWNER_COVER_PHOTO_URL,
          USERS.CREATED_AT AS OWNER_CREATED_AT,
          case when (TEST_RUNS.PLATFORM IS NULL OR TEST_RUNS.PLATFORM ='') then 'N/A'
            else TEST_RUNS.PLATFORM end AS PLATFORM,
          TEST_CONFIGS.PLATFORM_VERSION AS PLATFORM_VERSION,
          TEST_CONFIGS.BROWSER AS BROWSER,
          TEST_CONFIGS.BROWSER_VERSION AS BROWSER_VERSION,
          case when (TEST_CONFIGS.APP_VERSION IS NULL) then ''
            else TEST_CONFIGS.APP_VERSION end AS APP_VERSION,
          TEST_CONFIGS.DEVICE AS DEVICE,
          TEST_CONFIGS.URL AS URL,
          TEST_CONFIGS.LOCALE AS LOCALE,
          TEST_CONFIGS.LANGUAGE AS LANGUAGE,
          JOBS.JOB_URL AS JOB_URL,
          JOBS.NAME AS JOB_NAME,
          TEST_SUITES.USER_ID AS JOB_OWNER_ID,
          TEST_SUITES.NAME AS TEST_SUITE_NAME,
          TEST_RUNS.ENV as ENV,
          TEST_RUNS.ID AS TEST_RUN_ID,
          TEST_RUNS.STATUS AS TEST_RUN_STATUS,
          TEST_RUNS.SCM_URL AS SCM_URL,
          TEST_RUNS.BUILD_NUMBER AS BUILD_NUMBER,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/ZafiraReport' || '" target="_blank">' || JOBS.NAME || '</a>' as ZAFIRA_REPORT_URL,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/rebuild/parameterized' || '" target="_blank">Rebuild</a>' as REBUILD_URL,
          TEST_RUNS.ELAPSED AS ELAPSED,
          TEST_RUNS.STARTED_AT AS STARTED_AT,
          TEST_RUNS.CREATED_AT::date AS CREATED_AT,
          TEST_RUNS.UPSTREAM_JOB_ID AS UPSTREAM_JOB_ID,
          TEST_RUNS.UPSTREAM_JOB_BUILD_NUMBER AS UPSTREAM_JOB_BUILD_NUMBER,
          TEST_RUNS.BLOCKER AS BLOCKER,
          TEST_RUNS.ETA AS ETA,
          TEST_RUNS.REVIEWED AS REVIEWED,
          UPSTREAM_JOBS.NAME AS UPSTREAM_JOB_NAME,
          UPSTREAM_JOBS.JOB_URL AS UPSTREAM_JOB_URL,
          PRIORITY_TAGS.VALUE AS PRIORITY,
          FEATURE_TAGS.VALUE AS FEATURE,
          sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
          sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
          sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
          sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
          sum( case when TESTS.STATUS = 'QUEUED' then 1 else 0 end ) AS QUEUED,
          count( TESTS.STATUS ) AS TOTAL,
          sum(EXTRACT(epoch FROM(TESTS.FINISH_TIME - TESTS.START_TIME))/3600)::bigint as TOTAL_HOURS,
	  sum(EXTRACT(epoch FROM (TESTS.FINISH_TIME - TESTS.START_TIME)))::bigint as TOTAL_SECONDS
  FROM TESTS 
    INNER JOIN TEST_RUNS ON TEST_RUNS.ID=TESTS.TEST_RUN_ID
    INNER JOIN TEST_CASES ON TESTS.TEST_CASE_ID=TEST_CASES.ID
    LEFT JOIN TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID 
    LEFT JOIN PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID 
    INNER JOIN JOBS JOBS ON TEST_RUNS.JOB_ID = JOBS.ID
    LEFT JOIN JOBS UPSTREAM_JOBS ON TEST_RUNS.UPSTREAM_JOB_ID = UPSTREAM_JOBS.ID
    INNER JOIN USERS ON TEST_CASES.PRIMARY_OWNER_ID=USERS.ID
    INNER JOIN TEST_SUITES ON TEST_RUNS.TEST_SUITE_ID = TEST_SUITES.ID
    LEFT JOIN TEST_TAGS PRIORITY_TEST_TAGS ON TESTS.ID = PRIORITY_TEST_TAGS.TEST_ID
    LEFT JOIN TAGS PRIORITY_TAGS ON PRIORITY_TEST_TAGS.TAG_ID = PRIORITY_TAGS.ID AND PRIORITY_TAGS.NAME='priority' 
    LEFT JOIN TEST_TAGS FEATURE_TEST_TAGS ON TESTS.ID = FEATURE_TEST_TAGS.TEST_ID
    LEFT JOIN TAGS FEATURE_TAGS ON FEATURE_TEST_TAGS.TAG_ID = FEATURE_TAGS.ID AND FEATURE_TAGS.NAME='feature'
  WHERE TESTS.CREATED_AT > current_date - 32
        AND TEST_RUNS.STARTED_AT > current_date - 32
        AND TEST_RUNS.STARTED_AT < current_date
        AND TESTS.STATUS <> 'IN_PROGRESS'
        AND TESTS.START_TIME IS NOT NULL
        AND TESTS.FINISH_TIME IS NOT NULL
  GROUP BY PROJECTS.NAME, TEST_RUNS.ID, USERS.ID, TEST_CONFIGS.PLATFORM, TEST_CONFIGS.PLATFORM_VERSION, TEST_CONFIGS.BROWSER, TEST_CONFIGS.BROWSER_VERSION,
    TEST_CONFIGS.DEVICE, TEST_CONFIGS.URL, TEST_CONFIGS.LOCALE, TEST_CONFIGS.LANGUAGE, TEST_CONFIGS.APP_VERSION, JOBS.ID, JOBS.JOB_URL, JOBS.NAME,
    UPSTREAM_JOBS.NAME, UPSTREAM_JOBS.JOB_URL, TEST_SUITES.NAME, TEST_SUITES.USER_ID, PRIORITY_TAGS.VALUE, FEATURE_TAGS.VALUE
);


DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_ID_INDEX;
CREATE UNIQUE INDEX THIRTY_DAYS_VIEW_ID_INDEX ON THIRTY_DAYS_VIEW (ID);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_PROJECT_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_PROJECT_INDEX ON THIRTY_DAYS_VIEW (PROJECT);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_ID_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_ID_INDEX ON THIRTY_DAYS_VIEW (OWNER_ID);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_INDEX ON THIRTY_DAYS_VIEW (OWNER_USERNAME);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_EMAIL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_EMAIL_INDEX ON THIRTY_DAYS_VIEW (OWNER_EMAIL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_FIRST_NAME_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_FIRST_NAME_INDEX ON THIRTY_DAYS_VIEW (OWNER_FIRST_NAME);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_LAST_NAME_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_LAST_NAME_INDEX ON THIRTY_DAYS_VIEW (OWNER_LAST_NAME);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_LAST_LOGIN_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_LAST_LOGIN_INDEX ON THIRTY_DAYS_VIEW (OWNER_LAST_LOGIN);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_COVER_PHOTO_URL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_COVER_PHOTO_URL_INDEX ON THIRTY_DAYS_VIEW (OWNER_COVER_PHOTO_URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_OWNER_CREATED_AT_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_OWNER_CREATED_AT_INDEX ON THIRTY_DAYS_VIEW (OWNER_CREATED_AT);
                                                                                          
DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_ENV_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_ENV_INDEX ON THIRTY_DAYS_VIEW (ENV);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_PLATFORM_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_PLATFORM_INDEX ON THIRTY_DAYS_VIEW (PLATFORM);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_PLATFORM_VERSION_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_PLATFORM_VERSION_INDEX ON THIRTY_DAYS_VIEW (PLATFORM_VERSION);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_BROWSER_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_BROWSER_INDEX ON THIRTY_DAYS_VIEW (BROWSER);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_BROWSER_VERSION_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_BROWSER_VERSION_INDEX ON THIRTY_DAYS_VIEW (BROWSER_VERSION);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_APP_VERSION_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_APP_VERSION_INDEX ON THIRTY_DAYS_VIEW (APP_VERSION);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_DEVICE_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_DEVICE_INDEX ON THIRTY_DAYS_VIEW (DEVICE);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_URL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_URL_INDEX ON THIRTY_DAYS_VIEW (URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_LOCALE_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_LOCALE_INDEX ON THIRTY_DAYS_VIEW (LOCALE);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_LANGUAGE_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_LANGUAGE_INDEX ON THIRTY_DAYS_VIEW (LANGUAGE);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_JOB_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_JOB_INDEX ON THIRTY_DAYS_VIEW (JOB_URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_JOB_NAME_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_JOB_NAME_INDEX ON THIRTY_DAYS_VIEW (JOB_NAME);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_JOB_OWNER_ID_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_JOB_OWNER_ID_INDEX ON THIRTY_DAYS_VIEW (JOB_OWNER_ID);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_TEST_SUITE_NAME_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_TEST_SUITE_NAME_INDEX ON THIRTY_DAYS_VIEW (TEST_SUITE_NAME);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_TEST_RUN_ID_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_TEST_RUN_ID_INDEX ON THIRTY_DAYS_VIEW (TEST_RUN_ID);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_TEST_RUN_STATUS_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_TEST_RUN_STATUS_INDEX ON THIRTY_DAYS_VIEW (TEST_RUN_STATUS);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_SCM_URL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_SCM_URL_INDEX ON THIRTY_DAYS_VIEW (SCM_URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_BUILD_NUMBER_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_BUILD_NUMBER_INDEX ON THIRTY_DAYS_VIEW (BUILD_NUMBER);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_ELAPSED_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_ELAPSED_INDEX ON THIRTY_DAYS_VIEW (ELAPSED);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_STARTED_AT_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_STARTED_AT_INDEX ON THIRTY_DAYS_VIEW (STARTED_AT);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_CREATED_AT_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_CREATED_AT_INDEX ON THIRTY_DAYS_VIEW (CREATED_AT);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_ZAFIRA_REPORT_URL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_ZAFIRA_REPORT_URL_INDEX ON THIRTY_DAYS_VIEW (ZAFIRA_REPORT_URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_REBUILD_URL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_REBUILD_URL_INDEX ON THIRTY_DAYS_VIEW (REBUILD_URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_UPSTREAM_JOB_ID_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_UPSTREAM_JOB_ID_INDEX ON THIRTY_DAYS_VIEW (UPSTREAM_JOB_ID);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_UPSTREAM_JOB_BUILD_NUMBER_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_UPSTREAM_JOB_BUILD_NUMBER_INDEX ON THIRTY_DAYS_VIEW (UPSTREAM_JOB_BUILD_NUMBER);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_UPSTREAM_JOB_NAME_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_UPSTREAM_JOB_NAME_INDEX ON THIRTY_DAYS_VIEW (UPSTREAM_JOB_NAME);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_UPSTREAM_JOB_URL_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_UPSTREAM_JOB_URL_INDEX ON THIRTY_DAYS_VIEW (UPSTREAM_JOB_URL);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_PRIORITY_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_PRIORITY_INDEX ON THIRTY_DAYS_VIEW (PRIORITY);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_FEATURE_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_FEATURE_INDEX ON THIRTY_DAYS_VIEW (FEATURE);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_KNOWN_ISSUE_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_KNOWN_ISSUE_INDEX ON THIRTY_DAYS_VIEW (KNOWN_ISSUE);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_BLOCKER_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_BLOCKER_INDEX ON THIRTY_DAYS_VIEW (BLOCKER);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_ETA_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_ETA_INDEX ON THIRTY_DAYS_VIEW (ETA);

DROP INDEX IF EXISTS THIRTY_DAYS_VIEW_REVIEWED_INDEX;
CREATE INDEX THIRTY_DAYS_VIEW_REVIEWED_INDEX ON THIRTY_DAYS_VIEW (REVIEWED);



DROP VIEW IF EXISTS NIGHTLY_VIEW;
CREATE VIEW NIGHTLY_VIEW AS (
SELECT  row_number() OVER () AS ID,
          PROJECTS.NAME AS PROJECT,
          USERS.ID AS OWNER_ID,
          USERS.USERNAME AS OWNER_USERNAME,
          USERS.EMAIL AS OWNER_EMAIL,
          USERS.FIRST_NAME AS OWNER_FIRST_NAME,
          USERS.LAST_NAME AS OWNER_LAST_NAME,
          USERS.LAST_LOGIN AS OWNER_LAST_LOGIN,
          USERS.COVER_PHOTO_URL AS OWNER_COVER_PHOTO_URL,
          USERS.CREATED_AT AS OWNER_CREATED_AT,
          case when (TEST_RUNS.PLATFORM IS NULL OR TEST_RUNS.PLATFORM ='') then 'N/A'
            else TEST_RUNS.PLATFORM end AS PLATFORM,
          TEST_CONFIGS.PLATFORM_VERSION AS PLATFORM_VERSION,
          TEST_CONFIGS.BROWSER AS BROWSER,
          TEST_CONFIGS.BROWSER_VERSION AS BROWSER_VERSION,
          case when (TEST_CONFIGS.APP_VERSION IS NULL) then ''
            else TEST_CONFIGS.APP_VERSION end AS APP_VERSION,
          TEST_CONFIGS.DEVICE AS DEVICE,
          TEST_CONFIGS.URL AS URL,
          TEST_CONFIGS.LOCALE AS LOCALE,
          TEST_CONFIGS.LANGUAGE AS LANGUAGE,
          JOBS.JOB_URL AS JOB_URL,
          JOBS.NAME AS JOB_NAME,
          TEST_SUITES.USER_ID AS JOB_OWNER_ID,
          TEST_SUITES.NAME AS TEST_SUITE_NAME,
          TEST_RUNS.ENV as ENV,
          TEST_RUNS.ID AS TEST_RUN_ID,
          TEST_RUNS.STATUS AS TEST_RUN_STATUS,
          TEST_RUNS.SCM_URL AS SCM_URL,
          TEST_RUNS.BUILD_NUMBER AS BUILD_NUMBER,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/ZafiraReport' || '" target="_blank">' || JOBS.NAME || '</a>' as ZAFIRA_REPORT_URL,
          '<a href="' || JOBS.JOB_URL  || '/' || CAST(TEST_RUNS.BUILD_NUMBER AS text) || '/rebuild/parameterized' || '" target="_blank">Rebuild</a>' as REBUILD_URL,
          TEST_RUNS.ELAPSED AS ELAPSED,
          TEST_RUNS.STARTED_AT AS STARTED_AT,
          TEST_RUNS.CREATED_AT::date AS CREATED_AT,
          TEST_RUNS.UPSTREAM_JOB_ID AS UPSTREAM_JOB_ID,
          TEST_RUNS.UPSTREAM_JOB_BUILD_NUMBER AS UPSTREAM_JOB_BUILD_NUMBER,
          TEST_RUNS.BLOCKER AS BLOCKER,
          TEST_RUNS.ETA AS ETA,
          TEST_RUNS.REVIEWED AS REVIEWED,
          UPSTREAM_JOBS.NAME AS UPSTREAM_JOB_NAME,
          UPSTREAM_JOBS.JOB_URL AS UPSTREAM_JOB_URL,
          PRIORITY_TAGS.VALUE AS PRIORITY,
          FEATURE_TAGS.VALUE AS FEATURE,
          sum( case when TESTS.STATUS = 'PASSED' then 1 else 0 end ) AS PASSED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=FALSE then 1 else 0 end ) AS FAILED,
          sum( case when TESTS.STATUS = 'FAILED' AND TESTS.KNOWN_ISSUE=TRUE then 1 else 0 end ) AS KNOWN_ISSUE,
          sum( case when TESTS.STATUS = 'SKIPPED' then 1 else 0 end ) AS SKIPPED,
          sum( case when TESTS.STATUS = 'ABORTED' then 1 else 0 end ) AS ABORTED,
          sum( case when TESTS.STATUS = 'IN_PROGRESS' then 1 else 0 end ) AS IN_PROGRESS,
          sum( case when TESTS.STATUS = 'QUEUED' then 1 else 0 end ) AS QUEUED,
          count( TESTS.STATUS ) AS TOTAL,
          sum(EXTRACT(epoch FROM(TESTS.FINISH_TIME - TESTS.START_TIME))/3600)::bigint as TOTAL_HOURS,
	  sum(EXTRACT(epoch FROM (TESTS.FINISH_TIME - TESTS.START_TIME)))::bigint as TOTAL_SECONDS
  FROM TESTS INNER JOIN
    TEST_RUNS ON TEST_RUNS.ID=TESTS.TEST_RUN_ID
    INNER JOIN TEST_CASES ON TESTS.TEST_CASE_ID=TEST_CASES.ID
    LEFT JOIN TEST_CONFIGS ON TESTS.TEST_CONFIG_ID = TEST_CONFIGS.ID 
    LEFT JOIN PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID 
    INNER JOIN JOBS JOBS ON TEST_RUNS.JOB_ID = JOBS.ID
    LEFT JOIN JOBS UPSTREAM_JOBS ON TEST_RUNS.UPSTREAM_JOB_ID = UPSTREAM_JOBS.ID
    INNER JOIN USERS ON TEST_CASES.PRIMARY_OWNER_ID=USERS.ID
    INNER JOIN TEST_SUITES ON TEST_RUNS.TEST_SUITE_ID = TEST_SUITES.ID
    LEFT JOIN TEST_TAGS PRIORITY_TEST_TAGS ON TESTS.ID = PRIORITY_TEST_TAGS.TEST_ID
    LEFT JOIN TAGS PRIORITY_TAGS ON PRIORITY_TEST_TAGS.TAG_ID = PRIORITY_TAGS.ID AND PRIORITY_TAGS.NAME='priority' 
    LEFT JOIN TEST_TAGS FEATURE_TEST_TAGS ON TESTS.ID = FEATURE_TEST_TAGS.TEST_ID
    LEFT JOIN TAGS FEATURE_TAGS ON FEATURE_TEST_TAGS.TAG_ID = FEATURE_TAGS.ID AND FEATURE_TAGS.NAME='feature'
  WHERE TESTS.CREATED_AT >= current_date
        AND TEST_RUNS.STARTED_AT >= current_date
  GROUP BY PROJECTS.NAME, TEST_RUNS.ID, USERS.ID, TEST_CONFIGS.PLATFORM, TEST_CONFIGS.PLATFORM_VERSION, TEST_CONFIGS.BROWSER, TEST_CONFIGS.BROWSER_VERSION,
    TEST_CONFIGS.DEVICE, TEST_CONFIGS.URL, TEST_CONFIGS.LOCALE, TEST_CONFIGS.LANGUAGE, TEST_CONFIGS.APP_VERSION, JOBS.ID, JOBS.JOB_URL, JOBS.NAME,
    UPSTREAM_JOBS.NAME, UPSTREAM_JOBS.JOB_URL, TEST_SUITES.NAME, TEST_SUITES.USER_ID, PRIORITY_TAGS.VALUE, FEATURE_TAGS.VALUE
);



DROP VIEW IF EXISTS MONTHLY_VIEW;
CREATE VIEW MONTHLY_VIEW AS (
SELECT * FROM THIRTY_DAYS_VIEW
  WHERE CREATED_AT >= date_trunc('month', current_date)
        AND STARTED_AT >= date_trunc('month', current_date)
UNION
SELECT * FROM NIGHTLY_VIEW
);


DROP VIEW IF EXISTS WEEKLY_VIEW;
CREATE VIEW WEEKLY_VIEW AS (
SELECT * FROM THIRTY_DAYS_VIEW
  WHERE CREATED_AT >= date_trunc('week', current_date)  - interval '2 day'
        AND STARTED_AT >= date_trunc('week', current_date)  - interval '2 day'
UNION
SELECT * FROM NIGHTLY_VIEW
);

