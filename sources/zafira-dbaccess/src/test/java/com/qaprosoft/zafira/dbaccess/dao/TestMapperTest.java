package com.qaprosoft.zafira.dbaccess.dao;

import static org.testng.Assert.assertEquals;
import static org.testng.Assert.assertNotEquals;
import static org.testng.Assert.assertNull;

import java.util.Date;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.testng.AbstractTestNGSpringContextTests;

import com.qaprosoft.zafira.dbaccess.dao.mysql.TestMapper;
import com.qaprosoft.zafira.dbaccess.model.Test;
import com.qaprosoft.zafira.dbaccess.model.Test.Status;

@org.testng.annotations.Test
@ContextConfiguration("classpath:com/qaprosoft/zafira/dbaccess/dbaccess-test.xml")
public class TestMapperTest extends AbstractTestNGSpringContextTests
{
	/**
	 * Turn this on to enable this test
	 */
	private static final boolean ENABLED = false;
	
	private static final Test TEST = new Test()
	{
		private static final long serialVersionUID = 1L;
		{
			setName("MyTest");
			setStatus(Status.PASSED);
			setTestArgs("<xml>");
			setTestCaseId(1L);
			setTestRunId(1L);
			setMessage("Hm....");
			setStartTime(new Date());
			setFinishTime(new Date());
			setLogURL("http://1");
			setDemoURL("http://1");
		}
	};

	@Autowired
	private TestMapper testMapper;

	@org.testng.annotations.Test(enabled = ENABLED)
	public void createTest()
	{
		testMapper.createTest(TEST);

		assertNotEquals(TEST.getId(), 0, "Test ID must be set up by autogenerated keys");
	}

	@org.testng.annotations.Test(enabled = ENABLED, dependsOnMethods =
	{ "createTest" })
	public void getTestById()
	{
		checkTest(testMapper.getTestById(TEST.getId()));
	}

	@org.testng.annotations.Test(enabled = ENABLED, dependsOnMethods =
	{ "createTest" })
	public void updateTest()
	{
		TEST.setName("MyTest2");
		TEST.setStatus(Status.FAILED);
		TEST.setTestArgs("<xml/>");
		TEST.setTestCaseId(2L);
		TEST.setTestRunId(2L);
		TEST.setMessage("Aha!");
		TEST.setLogURL("http://2");
		TEST.setDemoURL("http://2");
		
		testMapper.updateTest(TEST);

		checkTest(testMapper.getTestById(TEST.getId()));
	}

	/**
	 * Turn this in to delete test after all tests
	 */
	private static final boolean DELETE_ENABLED = true;

	/**
	 * If true, then <code>deleteTest</code> will be used to delete test after all tests, otherwise -
	 * <code>deleteTestById</code>
	 */
	private static final boolean DELETE_BY_TEST = false;

	@org.testng.annotations.Test(enabled = ENABLED && DELETE_ENABLED && DELETE_BY_TEST, dependsOnMethods =
	{ "createTest", "getTestById", "updateTest" })
	public void deleteTest()
	{
		testMapper.deleteTest(TEST);

		assertNull(testMapper.getTestById(TEST.getId()));
	}

	@org.testng.annotations.Test(enabled = ENABLED && DELETE_ENABLED && !DELETE_BY_TEST, dependsOnMethods =
	{ "createTest", "getTestById", "updateTest" })
	public void deleteTestById()
	{
		testMapper.deleteTestById((TEST.getId()));

		assertNull(testMapper.getTestById(TEST.getId()));
	}

	private void checkTest(Test test)
	{
		assertEquals(test.getName(), TEST.getName(), "Name must match");
		assertEquals(test.getStatus(), TEST.getStatus(), "Status must match");
		assertEquals(test.getTestArgs(), TEST.getTestArgs(), "Test args must match");
		assertEquals(test.getTestCaseId(), TEST.getTestCaseId(), "Test case ID must match");
		assertEquals(test.getTestRunId(), TEST.getTestRunId(), "Test run ID must match");
		assertEquals(test.getMessage(), TEST.getMessage(), "Message must match");
		assertEquals(test.getLogURL(), TEST.getLogURL(), "Log URL must match");
		assertEquals(test.getDemoURL(), TEST.getDemoURL(), "Demo URL must match");
	}
}