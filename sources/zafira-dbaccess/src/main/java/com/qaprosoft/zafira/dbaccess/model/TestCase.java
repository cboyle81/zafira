package com.qaprosoft.zafira.dbaccess.model;

public class TestCase extends AbstractEntity
{
	private static final long serialVersionUID = 4877029098773384360L;

	private String testClass;
	private String testMethod;
	private String info;
	private Long testSuiteId;
	private User user = new User();

	public String getTestClass()
	{
		return testClass;
	}

	public void setTestClass(String testClass)
	{
		this.testClass = testClass;
	}

	public String getTestMethod()
	{
		return testMethod;
	}

	public void setTestMethod(String testMethod)
	{
		this.testMethod = testMethod;
	}

	public String getInfo()
	{
		return info;
	}

	public void setInfo(String info)
	{
		this.info = info;
	}

	public Long getTestSuiteId()
	{
		return testSuiteId;
	}

	public void setTestSuiteId(Long testSuiteId)
	{
		this.testSuiteId = testSuiteId;
	}

	public User getUser()
	{
		return user;
	}

	public void setUser(User user)
	{
		this.user = user;
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return (obj != null && obj instanceof TestCase && this.hashCode() == ((TestCase)obj).hashCode());
	}
	
	@Override
	public int hashCode()
	{
		return (testClass + testMethod + testSuiteId + info + user.getId()).hashCode();
	}
}