INSERT INTO zafira.SETTINGS (NAME, VALUE, TOOL) VALUES
	('GOOGLE_CLIENT_SECRET_ORIGIN', '', 'GOOGLE'),
  ('GOOGLE_ENABLED', false, 'GOOGLE'),
	('LDAP_DN', '', 'LDAP'),
  ('LDAP_SEARCH_FILTER', '', 'LDAP'),
  ('LDAP_URL', '', 'LDAP'),
  ('LDAP_MANAGER_USER', '', 'LDAP'),
  ('LDAP_MANAGER_PASSWORD', '', 'LDAP'),
  ('LDAP_ENABLED', false, 'LDAP'),
	('JIRA_CLOSED_STATUS', 'CLOSED', 'JIRA'),
	('JIRA_URL', '', 'JIRA'),
	('JIRA_USER', '', 'JIRA'),
	('JIRA_PASSWORD', '', 'JIRA'),
	('JIRA_ENABLED', false, 'JIRA'),
	('JENKINS_URL', '', 'JENKINS'),
	('JENKINS_USER', '', 'JENKINS'),
	('JENKINS_API_TOKEN_OR_PASSWORD', '', 'JENKINS'),
	('JENKINS_ENABLED', false, 'JENKINS'),
	('SLACK_WEB_HOOK_URL', '', 'SLACK'),
	('SLACK_ENABLED', false, 'SLACK'),
	('EMAIL_HOST', '', 'EMAIL'),
	('EMAIL_PORT', '', 'EMAIL'),
	('EMAIL_USER', '', 'EMAIL'),
	('EMAIL_FROM_ADDRESS', '', 'EMAIL'),
	('EMAIL_PASSWORD', '', 'EMAIL'),
	('EMAIL_ENABLED', false, 'EMAIL'),
	('AMAZON_ACCESS_KEY', '', 'AMAZON'),
	('AMAZON_SECRET_KEY', '', 'AMAZON'),
	('AMAZON_REGION', '', 'AMAZON'),
	('AMAZON_BUCKET', '', 'AMAZON'),
	('AMAZON_ENABLED', false, 'AMAZON'),
	('HIPCHAT_ACCESS_TOKEN', '', 'HIPCHAT'),
	('HIPCHAT_ENABLED', false, 'HIPCHAT'),
	('KEY', '', 'CRYPTO'),
	('CRYPTO_KEY_SIZE', '128', 'CRYPTO'),
	('CRYPTO_KEY_TYPE', 'AES', 'CRYPTO'),
	('RABBITMQ_HOST', '', 'RABBITMQ'),
	('RABBITMQ_PORT', '', 'RABBITMQ'),
	('RABBITMQ_USER', '', 'RABBITMQ'),
	('RABBITMQ_PASSWORD', '', 'RABBITMQ'),
	('RABBITMQ_ENABLED', false, 'RABBITMQ'),
	('COMPANY_LOGO_URL', null, null),
	('LAST_ALTER_VERSION', '90', null);

INSERT INTO zafira.PROJECTS (NAME, DESCRIPTION) VALUES ('UNKNOWN', '');


DO $$
DECLARE GROUP_ID zafira.GROUP_PERMISSIONS.id%TYPE;
DECLARE USER_ID zafira.USER_PREFERENCES.id%TYPE;

BEGIN

	INSERT INTO zafira.PERMISSIONS (NAME, BLOCK) VALUES
				('VIEW_HIDDEN_DASHBOARDS', 'DASHBOARDS'),
				('MODIFY_DASHBOARDS', 'DASHBOARDS'),
				('MODIFY_WIDGETS', 'DASHBOARDS'),
				('MODIFY_TEST_RUN_VIEWS', 'TEST_RUNS'),
				('MODIFY_TEST_RUNS', 'TEST_RUNS'),
				('TEST_RUNS_CI', 'TEST_RUNS'),
				('MODIFY_TESTS', 'TEST_RUNS'),
				('MODIFY_USERS', 'USERS'),
				('MODIFY_USER_GROUPS', 'USERS'),
				('VIEW_USERS', 'USERS'),
				('MODIFY_SETTINGS', 'SETTINGS'),
				('VIEW_SETTINGS', 'SETTINGS'),
				('MODIFY_MONITORS', 'MONITORS'),
				('VIEW_MONITORS', 'MONITORS'),
				('MODIFY_PROJECTS', 'PROJECTS'),
				('MODIFY_INTEGRATIONS', 'INTEGRATIONS'),
				('VIEW_INTEGRATIONS', 'INTEGRATIONS');

	INSERT INTO zafira.GROUPS (NAME, ROLE) VALUES ('Super users', 'ROLE_USER') RETURNING id INTO GROUP_ID;

  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 4);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 5);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 6);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 7);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 12);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 14);

	INSERT INTO zafira.GROUPS (NAME, ROLE) VALUES ('Users', 'ROLE_USER') RETURNING id INTO GROUP_ID;

  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 6);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 7);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 14);

	INSERT INTO zafira.GROUPS (NAME, ROLE) VALUES ('Super admins', 'ROLE_ADMIN') RETURNING id INTO GROUP_ID;

	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 1);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 2);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 3);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 4);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 5);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 6);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 7);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 8);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 9);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 10);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 11);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 12);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 13);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 14);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 15);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 16);
	INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 17);

  INSERT INTO zafira.GROUPS (NAME, ROLE) VALUES ('Admins', 'ROLE_ADMIN') RETURNING id INTO GROUP_ID;

  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 1);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 2);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 3);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 4);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 5);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 6);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 7);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 8);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 10);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 12);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 13);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 14);
  INSERT INTO zafira.GROUP_PERMISSIONS (GROUP_ID, PERMISSION_ID) VALUES (GROUP_ID, 15);

	INSERT INTO zafira.users (USERNAME) VALUES ('anonymous') RETURNING id INTO USER_ID;

	INSERT INTO zafira.user_preferences (NAME, VALUE, USER_ID) VALUES
		('REFRESH_INTERVAL', '0', USER_ID),
		('DEFAULT_DASHBOARD', 'General', USER_ID),
		('THEME', '32', USER_ID);

END$$;
