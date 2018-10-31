/*******************************************************************************
 * Copyright 2013-2018 QaProSoft (http://www.qaprosoft.com).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/
package com.qaprosoft.zafira.services.services.application.emails;

import com.qaprosoft.zafira.models.db.Attachment;

import java.util.List;

public abstract class AbstractEmail implements IEmailMessage {

    private String subject;
    private String zafiraLogoURL;
    private String companyLogoURL;
    private String workspaceURL;

    public AbstractEmail(String subject, String zafiraLogoURL, String companyLogoURL, String workspaceURL) {
        this.subject = subject;
        this.zafiraLogoURL = zafiraLogoURL;
        this.companyLogoURL = companyLogoURL;
        this.workspaceURL = workspaceURL;
    }

    public String getZafiraLogoURL() {
        return zafiraLogoURL;
    }

    public String getCompanyLogoURL() {
        return companyLogoURL;
    }

    public String getWorkspaceURL() {
        return workspaceURL;
    }

    @Override
    public String getSubject() {
        return subject;
    }

    @Override
    public String getText() {
        return null;
    }

    @Override
    public EmailType getType() {
        return null;
    }

    @Override
    public List<Attachment> getAttachments() {
        return null;
    }
}