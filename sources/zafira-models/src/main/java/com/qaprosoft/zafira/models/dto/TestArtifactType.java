package com.qaprosoft.zafira.models.dto;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

@JsonInclude(Include.NON_NULL)
public class TestArtifactType extends AbstractType
{
	private static final long serialVersionUID = 555233394837989532L;
	
	private String name;
	
	private String link;
	
	private Long testId;

	private Date expiresAt;

	public TestArtifactType()
	{
	}
	
	public TestArtifactType(String name, String link)
	{
		this(name, link, null);
	}

	public TestArtifactType(String name, String link, Date expiresAt)
	{
		this.name = name;
		this.link = link;
		this.expiresAt = expiresAt;
	}

	public String getName()
	{
		return name;
	}

	public void setName(String name)
	{
		this.name = name;
	}

	public String getLink()
	{
		return link;
	}

	public void setLink(String link)
	{
		this.link = link;
	}

	public Long getTestId()
	{
		return testId;
	}

	public void setTestId(Long testId)
	{
		this.testId = testId;
	}

	public Date getExpiresAt()
	{
		return expiresAt;
	}

	public void setExpiresAt(Date expiresAt)
	{
		this.expiresAt = expiresAt;
	}
	
	@Override
	public boolean equals(Object obj)
	{
		boolean equals = false;
		if(obj != null && obj instanceof TestArtifactType)
		{
			equals = this.name == ((TestArtifactType)obj).getName();
		}
		return equals;
	}
}