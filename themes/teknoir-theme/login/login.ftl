<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta}"/>
        </#list>
    </#if>

    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />

    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
</head>
<body class="${properties.kcBodyClass!}">
    <div class="tn-wrapper">
        <div class="tn-card">
            <#if realm.displayLogoUrl?has_content>
                <div class="tn-logo">
                    <img src="${realm.displayLogoUrl}" alt="${realm.displayName!''}" />
                </div>
            <#elseif realm.displayName?has_content>
                <div class="tn-logo">
                    <span class="tn-logo-text">${realm.displayName}</span>
                </div>
            </#if>

            <#if displayMessage?? && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                <div class="tn-alert tn-alert-${message.type}">
                    <#if message.type = 'success'><span class="tn-alert-icon">&#10003;</span></#if>
                    <#if message.type = 'warning'><span class="tn-alert-icon">&#9888;</span></#if>
                    <#if message.type = 'error'><span class="tn-alert-icon">&#10005;</span></#if>
                    <#if message.type = 'info'><span class="tn-alert-icon">&#8505;</span></#if>
                    <span>${kcSanitize(message.summary)?no_esc}</span>
                </div>
            </#if>

            <form id="kc-form-login" class="tn-form" onsubmit="login.disabled = true; return true;"
                  action="${url.loginAction}" method="post">

                <div class="tn-form-group">
                    <label for="username" class="tn-label">
                        <#if !realm.loginWithEmailAllowed>${msg("username")}
                        <#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}
                        <#else>${msg("email")}
                        </#if>
                    </label>
                    <input tabindex="1" id="username" class="tn-input" name="username" type="text"
                           autofocus autocomplete="username"
                           value="${(login.username!'')?html}"
                           aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                    />
                    <#if messagesPerField.existsError('username','password')>
                        <span class="tn-field-error">${kcSanitize(messagesPerField.getFirstError('username','password'))?no_esc}</span>
                    </#if>
                </div>

                <div class="tn-form-group">
                    <label for="password" class="tn-label">
                        ${msg("password")}
                        <#if realm.resetPasswordAllowed>
                            <a class="tn-forgot-link" href="${url.loginResetCredentialsUrl}">${msg("doForgotPassword")}</a>
                        </#if>
                    </label>
                    <div class="tn-password-wrapper">
                        <input tabindex="2" id="password" class="tn-input" name="password" type="password"
                               autocomplete="current-password"
                               aria-invalid="<#if messagesPerField.existsError('username','password')>true</#if>"
                        />
                    </div>
                </div>

                <#if realm.rememberMe && !usernameEditDisabled??>
                    <div class="tn-form-group tn-remember-me">
                        <label class="tn-checkbox-label">
                            <input tabindex="3" id="rememberMe" name="rememberMe" type="checkbox"
                                   <#if login.rememberMe??>checked</#if>
                            />
                            ${msg("rememberMe")}
                        </label>
                    </div>
                </#if>

                <input type="hidden" id="id-hidden-input" name="credentialId"
                       <#if auth.selectedCredential?has_content>value="${auth.selectedCredential}"</#if>/>

                <div class="tn-form-actions">
                    <input tabindex="4" class="tn-btn tn-btn-primary" name="login" id="kc-login"
                           type="submit" value="${msg("doLogIn")}"/>
                </div>
            </form>

            <#if realm.password && realm.registrationAllowed && !registrationDisabled??>
                <div class="tn-register">
                    ${msg("noAccount")}
                    <a class="tn-register-link" href="${url.registrationUrl}">${msg("doRegister")}</a>
                </div>
            </#if>

            <#if realm.password && social?? && social.providers?has_content>
                <div class="tn-social">
                    <div class="tn-social-divider">
                        <span>${msg("identity-provider-login-label")}</span>
                    </div>
                    <ul class="tn-social-providers">
                        <#list social.providers as p>
                            <li>
                                <a class="tn-social-btn" id="social-${p.alias}" href="${p.loginUrl}">
                                    <#if p.iconClasses?has_content>
                                        <i class="${p.iconClasses!}"></i>
                                    </#if>
                                    <span>${p.displayName!}</span>
                                </a>
                            </li>
                        </#list>
                    </ul>
                </div>
            </#if>
        </div>
    </div>
</body>
</html>
