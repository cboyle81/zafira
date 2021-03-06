/*******************************************************************************
 * Copyright 2013-2018 QaProSoft (http://www.qaprosoft.com).
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *******************************************************************************/
package com.qaprosoft.zafira.services.services.application.jmx;

import com.qaprosoft.zafira.models.db.Setting.Tool;
import com.qaprosoft.zafira.services.services.application.jmx.context.AbstractContext;

public interface IJMXService<T extends AbstractContext> {

    void init();

    boolean isConnected();

    default T getContext(Tool tool) {
        return JMXTenancyStorage.<T>getContext(tool);
    }

    default void putContext(Tool tool, T t) {
        JMXTenancyStorage.<T>putContext(tool, t);
    }
}
