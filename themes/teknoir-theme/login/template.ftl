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
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}" lang="${lang}"<#if realm.internationalizationEnabled> dir="${(locale.rtl)?then('rtl','ltr')}"</#if>>

<head>
    <meta charset="utf-8">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    <meta name="color-scheme" content="dark">
    <meta name="theme-color" content="#000000">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
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
<div class="tn-backdrop" aria-hidden="true">
  <div class="tn-glow"></div>
  <div class="tn-grid"></div>
  <div class="tn-horizon-line"></div>
  <#if tnLanding>
  <div class="tn-sun"></div>
  <ul class="tn-fleet" title="${msg("tnFleetLabel")}">
    <li class="tn-bot tn-bot--ok tn-bot--1"><span class="tn-bot-glyph"></span><span class="tn-bot-name">amr-01</span></li>
    <li class="tn-bot tn-bot--warn tn-bot--2"><span class="tn-bot-glyph"></span><span class="tn-bot-name">amr-02</span></li>
    <li class="tn-bot tn-bot--ok tn-bot--3"><span class="tn-bot-glyph"></span><span class="tn-bot-name">amr-03</span></li>
    <li class="tn-bot tn-bot--ok tn-bot--4"><span class="tn-bot-glyph"></span><span class="tn-bot-name">station-01</span></li>
  </ul>
  </#if>
</div>
<header id="kc-header" class="pf-v5-c-login__header tn-topbar">
  <div id="kc-header-wrapper" class="pf-v5-c-brand tn-brand">
    <img class="tn-logo" src="${url.resourcesPath}/img/teknoir-logo.svg" alt="Teknoir" width="168" height="26">
  </div>
</header>
<div class="tn-shell<#if tnLanding> tn-shell--landing</#if>">
  <#if tnLanding>
  <section class="tn-story" aria-labelledby="tn-headline">
    <h1 id="tn-headline" class="tn-headline">${msg("tnHeadline1")}<br>${msg("tnHeadline2")}</h1>
    <p class="tn-lede">${msg("tnLede")}</p>
    <dl class="tn-verbs">
      <div class="tn-verb tn-verb--manage">
        <dt class="tn-verb-name"><span class="tn-verb-mark" aria-hidden="true"></span>${msg("tnManageKicker")}</dt>
        <dd class="tn-verb-text">${msg("tnManageText")}</dd>
      </div>
      <div class="tn-verb tn-verb--access">
        <dt class="tn-verb-name"><span class="tn-verb-mark" aria-hidden="true"></span>${msg("tnAccessKicker")}</dt>
        <dd class="tn-verb-text">${msg("tnAccessText")} <code class="tn-cmd">${msg("tnAccessProof")}</code></dd>
      </div>
      <div class="tn-verb tn-verb--develop">
        <dt class="tn-verb-name"><span class="tn-verb-mark" aria-hidden="true"></span>${msg("tnDevelopKicker")}</dt>
        <dd class="tn-verb-text">${msg("tnDevelopText")}</dd>
      </div>
    </dl>
  </section>
  </#if>
  <div class="${properties.kcLogin!}">
    <div class="${properties.kcLoginContainer!}">
      <main class="${properties.kcLoginMain!}">
        <div class="${properties.kcLoginMainHeader!}">
          <#if tnLanding>
          <h2 class="${properties.kcLoginMainTitle!} tn-card-title" id="kc-page-title"><#nested "header"></h2>
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
          <p class="tn-card-help">${msg("tnNoAccount")}</p>
          </#if>
      </main>
    </div>
  </div>
</div>
</body>
</html>
</#macro>
