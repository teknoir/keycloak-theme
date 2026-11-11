<#import "field.ftl" as field>
<#import "footer.ftl" as loginFooter>
<#macro username>
  <#assign label>
    <#if !realm.loginWithEmailAllowed>${msg("username")}<#elseif !realm.registrationEmailAsUsername>${msg("usernameOrEmail")}<#else>${msg("email")}</#if>
  </#assign>
  <@field.group name="username" label=label>
    <div class="${properties.kcInputGroup}">
      <div class="${properties.kcInputGroupItemClass} ${properties.kcFill}">
        <span class="${properties.kcInputClass} ${properties.kcFormReadOnlyClass}">
          <input id="kc-attempted-username" value="${auth.attemptedUsername}" readonly>
        </span>
      </div>
      <div class="${properties.kcInputGroupItemClass}">
        <button id="reset-login" class="${properties.kcFormPasswordVisibilityButtonClass} kc-login-tooltip" type="button"
              aria-label="${msg('restartLoginTooltip')}" onclick="location.href='${url.loginRestartFlowUrl}'">
            <i class="fa-sync-alt fas" aria-hidden="true"></i>
            <span class="kc-tooltip-text">${msg("restartLoginTooltip")}</span>
        </button>
      </div>
    </div>
  </@field.group>
</#macro>

<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<#local tnClientId = (client.clientId)!"">
<#local tnPage = (pageId)!"">
<#local tnLanding = (tnPage == "login" || tnPage == "login-username") && tnClientId != "security-admin-console">
<#-- The door the user is entering through: the console (oauth2-proxy client) or tnctl. Others get no door. -->
<#local tnDoor = (tnClientId == "teknoir")?then("console", (tnClientId == "teknoir-cli")?then("cli", ""))>
<#local tnTitles = {"login-reset-password": "emailForgotTitle", "login-config-totp": "loginTotpTitle", "login-update-password": "updatePasswordTitle", "logout-confirm": "logoutConfirmTitle", "error": "errorTitle", "login-oauth2-device-verify-user-code": "oauth2DeviceVerificationTitle"}>
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}" lang="${lang}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="color-scheme" content="dark">
    <meta name="theme-color" content="#101010">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    <title><#if tnTitles[tnPage]??>${msg(tnTitles[tnPage])} ${msg("tnTitleSuffix")}<#else>${msg("loginTitle",(realm.displayName!''))}</#if></title>
    <link rel="icon" href="${url.resourcesPath}/img/favicon.ico" />
    <link rel="apple-touch-icon" href="${url.resourcesPath}/img/apple-touch-icon.png">
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
    <script type="importmap">
        {
            "imports": {
                "rfc4648": "${url.resourcesCommonPath}/vendor/rfc4648/rfc4648.js"
            }
        }
    </script>
    <#if darkMode>
      <script type="module" async blocking="render">
          const DARK_MODE_CLASS = "${properties.kcDarkModeClass}";
          const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

          updateDarkMode(mediaQuery.matches);
          mediaQuery.addEventListener("change", (event) => updateDarkMode(event.matches));

          function updateDarkMode(isEnabled) {
            const { classList } = document.documentElement;

            if (isEnabled) {
              classList.add(DARK_MODE_CLASS);
            } else {
              classList.remove(DARK_MODE_CLASS);
            }
          }
      </script>
    </#if>
    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <#if scripts??>
        <#list scripts as script>
            <script src="${script}" type="text/javascript"></script>
        </#list>
    </#if>
    <script type="module" src="${url.resourcesPath}/js/passwordVisibility.js"></script>
    <script type="module">
        <#outputformat "JavaScript">
        import { startSessionPolling } from "${url.resourcesPath}/js/authChecker.js";

        startSessionPolling(
            ${url.ssoLoginInOtherTabsUrl?c}
        );
        </#outputformat>
    </script>
    <script type="module">
        document.addEventListener("click", (event) => {
            const link = event.target.closest("a[data-once-link]");

            if (!link) {
                return;
            }

            if (link.getAttribute("aria-disabled") === "true") {
                event.preventDefault();
                return;
            }

            const { disabledClass } = link.dataset;

            if (disabledClass) {
                link.classList.add(...disabledClass.trim().split(/\s+/));
            }

            link.setAttribute("role", "link");
            link.setAttribute("aria-disabled", "true");
        });
    </script>
    <#if authenticationSession??>
        <script type="module">
             <#outputformat "JavaScript">
            import { checkAuthSession } from "${url.resourcesPath}/js/authChecker.js";

            checkAuthSession(
                ${authenticationSession.authSessionIdHash?c}
            );
            </#outputformat>
        </script>
    </#if>
    <script>
      // Firefox form workaround.
      const isFirefox = true;
    </script>
</head>

<body id="keycloak-bg" class="${properties.kcBodyClass!} tn-body<#if tnLanding> tn-landing</#if>" data-page-id="login-${pageId}">
<div class="tn-backdrop" aria-hidden="true"></div>
<header id="kc-header" class="pf-v5-c-login__header tn-topbar">
  <div id="kc-header-wrapper" class="pf-v5-c-brand tn-brand">
    <img class="tn-logo" src="${url.resourcesPath}/img/teknoir-logo.svg" alt="Teknoir" width="168" height="26">
  </div>
</header>
<div class="tn-shell<#if tnLanding> tn-shell--landing</#if>"<#if tnLanding && tnDoor?has_content> data-door="${tnDoor}"</#if>>
  <#if tnLanding>
  <div class="tn-head">
    <p class="tn-eyebrow">${msg("tnEyebrow")}</p>
    <h1 id="tn-headline" class="tn-headline">${msg("tnHeadline1")}<br>${msg("tnHeadline2")}<br><span class="tn-gr">${msg("tnHeadline3")}</span></h1>
  </div>
  <p class="tn-sub">${kcSanitize(msg("tnSub"))?no_esc}</p>
  <ul class="tn-doors" aria-label="${msg("tnDoorsLabel")}">
    <li class="tn-door tn-door--console<#if tnDoor == "console"> tn-door--active</#if>"<#if tnDoor == "console"> aria-current="true"</#if>><span class="tn-door-name">${msg("tnDoorConsole")}</span><span class="tn-door-text">${msg("tnDoorConsoleText")}</span><svg class="tn-door-icon" viewBox="0 0 24 24" aria-hidden="true"><rect x="2" y="5" width="20" height="14" rx="3"/><path d="M2 10H22"/></svg></li>
    <li class="tn-door tn-door--bot<#if tnDoor == "bot"> tn-door--active</#if>"<#if tnDoor == "bot"> aria-current="true"</#if>><span class="tn-door-name">${msg("tnDoorBot")}</span><span class="tn-door-text">${msg("tnDoorBotText")}</span><svg class="tn-door-icon" viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 7V12L15.5 14"/></svg></li>
    <li class="tn-door tn-door--cli<#if tnDoor == "cli"> tn-door--active</#if>"<#if tnDoor == "cli"> aria-current="true"</#if>><span class="tn-door-name">${msg("tnDoorCli")}</span><span class="tn-door-text">${msg("tnDoorCliText")}</span><svg class="tn-door-icon" viewBox="0 0 24 24" aria-hidden="true"><path d="M4 6L10 12L4 18M13 18H21"/></svg></li>
  </ul>
  <div class="tn-join" aria-hidden="true">
    <svg class="tn-join-wide" viewBox="0 0 132 192" width="132" height="192">
      <g class="tn-rails"><path class="tn-rail-console" d="M0 28H6L64 86H80" stroke="#3B61BF"/><path class="tn-rail-bot" d="M0 96H80" stroke="#ED6D36"/><path class="tn-rail-cli" d="M0 164H6L64 106H80" stroke="#9B357D"/><path d="M100 96H132" stroke="#E0AD1B"/></g>
      <g class="tn-flow"><path class="tn-rail-console" pathLength="100" d="M0 28H6L64 86H80"/><path class="tn-rail-bot b" pathLength="100" d="M0 96H80"/><path class="tn-rail-cli c" pathLength="100" d="M0 164H6L64 106H80"/><path class="y" pathLength="100" d="M100 96H132"/></g>
    </svg>
    <svg class="tn-join-tall" viewBox="0 0 300 72" preserveAspectRatio="none">
      <g class="tn-rails"><path class="tn-rail-console" d="M50 0V4L140 40H146" stroke="#3B61BF"/><path class="tn-rail-bot" d="M150 0V40" stroke="#ED6D36"/><path class="tn-rail-cli" d="M250 0V4L160 40H154" stroke="#9B357D"/><path d="M150 52V72" stroke="#E0AD1B"/></g>
    </svg>
    <img class="tn-mark" src="${url.resourcesPath}/img/teknoir-mark.svg" alt="" width="44" height="44">
  </div>
  </#if>
  <div class="${properties.kcLogin!}">
    <div class="${properties.kcLoginContainer!}">
      <main class="${properties.kcLoginMain!}">
        <#if tnLanding><p class="tn-card-kicker">${msg("tnCardKicker")}</p></#if>
        <div class="${properties.kcLoginMainHeader!}">
          <#if tnLanding>
          <h2 class="${properties.kcLoginMainTitle!} tn-card-title" id="kc-page-title"><#if tnDoor == "console">${msg("tnTitleConsole")}<#elseif tnDoor == "cli">${msg("tnTitleCli")}<#else><#nested "header"></#if></h2>
          <#if tnDoor == "cli"><p class="tn-card-note">${msg("tnCliReturn")}</p></#if>
          <#else>
          <h1 class="${properties.kcLoginMainTitle!}" id="kc-page-title"><#nested "header"></h1>
          </#if>
          <#if realm.internationalizationEnabled  && locale.supported?size gt 1>
          <div class="${properties.kcLoginMainHeaderUtilities!}">
            <div class="${properties.kcInputClass!}">
              <select
                aria-label="${msg("languages")}"
                id="login-select-toggle"
                onchange="if (this.value) window.location.href=this.value"
              >
                <#list locale.supported?sort_by("label") as l>
                  <option
                    value="${l.url}"
                    ${(l.languageTag == locale.currentLanguageTag)?then('selected','')}
                  >
                    ${l.label}
                  </option>
                </#list>
              </select>
              <span class="${properties.kcFormControlUtilClass}">
                <span class="${properties.kcFormControlToggleIcon!}">
                  <svg
                    class="pf-v5-svg"
                    viewBox="0 0 320 512"
                    fill="currentColor"
                    aria-hidden="true"
                    role="img"
                    width="1em"
                    height="1em"
                  >
                    <path
                      d="M31.3 192h257.3c17.8 0 26.7 21.5 14.1 34.1L174.1 354.8c-7.8 7.8-20.5 7.8-28.3 0L17.2 226.1C4.6 213.5 13.5 192 31.3 192z"
                    >
                    </path>
                  </svg>
                </span>
              </span>
            </div>
          </div>
          </#if>
        </div>
        <div class="${properties.kcLoginMainBody!}">
          <#if !(auth?has_content && auth.showUsername() && !auth.showResetCredentials())>
              <#if displayRequiredFields>
                  <div class="${properties.kcContentWrapperClass!}">
                      <div class="${properties.kcLabelWrapperClass!} subtitle">
                          <span class="${properties.kcInputHelperTextItemTextClass!}">
                            <span class="${properties.kcInputRequiredClass!}">*</span> ${msg("requiredFields")}
                          </span>
                      </div>
                  </div>
              </#if>
          <#else>
              <#if displayRequiredFields>
                  <div class="${properties.kcContentWrapperClass!}">
                      <div class="${properties.kcLabelWrapperClass!} subtitle">
                          <span class="${properties.kcInputHelperTextItemTextClass!}">
                            <span class="${properties.kcInputRequiredClass!}">*</span> ${msg("requiredFields")}
                          </span>
                      </div>
                      <div class="${properties.kcFormClass} ${properties.kcContentWrapperClass}">
                          <#nested "show-username">
                          <@username />
                      </div>
                  </div>
              <#else>
                  <div class="${properties.kcFormClass} ${properties.kcContentWrapperClass}">
                    <#nested "show-username">
                    <@username />
                  </div>
              </#if>
          </#if>

          <#-- App-initiated actions should not see warning messages about the need to complete the action -->
          <#-- during login.                                                                               -->
          <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
              <div class="${properties.kcAlertClass!} pf-m-${(message.type = 'error')?then('danger', message.type)}">
                  <div class="${properties.kcAlertIconClass!}">
                      <#if message.type = 'success'><span class="${properties.kcFeedbackSuccessIcon!}"></span></#if>
                      <#if message.type = 'warning'><span class="${properties.kcFeedbackWarningIcon!}"></span></#if>
                      <#if message.type = 'error'><span class="${properties.kcFeedbackErrorIcon!}"></span></#if>
                      <#if message.type = 'info'><span class="${properties.kcFeedbackInfoIcon!}"></span></#if>
                  </div>
                  <span class="${properties.kcAlertTitleClass!} kc-feedback-text">${message.summary}</span>
              </div>
          </#if>

          <#nested "form">

          <#if auth?has_content && auth.showTryAnotherWayLink()>
            <form id="kc-select-try-another-way-form" action="${url.loginAction}" method="post" novalidate="novalidate">
                <input type="hidden" name="tryAnotherWay" value="on"/>
                <a id="try-another-way" href="javascript:document.forms['kc-select-try-another-way-form'].requestSubmit()"
                    class="${properties.kcButtonSecondaryClass} ${properties.kcButtonBlockClass} ${properties.kcMarginTopClass}">
                      ${msg("doTryAnotherWay")}
                </a>
            </form>
          </#if>

            <div class="${properties.kcLoginMainFooter!}">
                <#nested "socialProviders">

                <#if displayInfo>
                    <div id="kc-info" class="${properties.kcLoginMainFooterBand!} ${properties.kcFormClass}">
                        <div id="kc-info-wrapper" class="${properties.kcLoginMainFooterBandItem!}">
                            <#nested "info">
                        </div>
                    </div>
                </#if>
            </div>
        </div>

          <div class="${properties.kcLoginMainFooter!}">
              <@loginFooter.content/>
          </div>
          <#if tnLanding>
          <p class="tn-card-help">${msg("tnOneAccount")}<#if !(realm.registrationAllowed!false)><span class="tn-card-help-sub">${msg("tnNoAccount")}</span></#if></p>
          </#if>
      </main>
    </div>
  </div>
  <#if tnLanding>
  <ul class="tn-proof">
    <li><span class="tn-proof-t">${msg("tnProof1")}</span>${msg("tnProof1Text")}</li>
    <li><span class="tn-proof-t">${msg("tnProof2")}</span>${msg("tnProof2Text")}</li>
    <li><span class="tn-proof-t">${msg("tnProof3")}</span>${msg("tnProof3Text")}</li>
    <li><span class="tn-proof-t">${msg("tnProof4")}</span>${msg("tnProof4Text")}</li>
  </ul>
  </#if>
</div>
</body>
</html>
</#macro>
