deploy.py --defines--> deploy.py::allowed [EXTRACTED] deploy.py:67
deploy.py --defines--> deploy.py::check_paths [EXTRACTED] deploy.py:83
deploy.py --defines--> deploy.py::fail [EXTRACTED] deploy.py:53
deploy.py --defines--> deploy.py::main [EXTRACTED] deploy.py:105
deploy.py --defines--> deploy.py::norm [EXTRACTED] deploy.py:58
deploy.py --defines--> deploy.py::run [EXTRACTED] deploy.py:38
deploy.py --defines--> deploy.py::staged_files [EXTRACTED] deploy.py:77
deploy.py::check_paths --calls--> deploy.py::fail [EXTRACTED] deploy.py:87
deploy.py::check_paths --calls--> deploy.py::norm [EXTRACTED] deploy.py:85
deploy.py::main --calls--> deploy.py::allowed [EXTRACTED] deploy.py:151
deploy.py::main --calls--> deploy.py::check_paths [EXTRACTED] deploy.py:147
deploy.py::main --calls--> deploy.py::fail [EXTRACTED] deploy.py:128
deploy.py::main --calls--> deploy.py::norm [EXTRACTED] deploy.py:131
deploy.py::main --calls--> deploy.py::staged_files [EXTRACTED] deploy.py:164
lib/api/client.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/api/client.dart:11
lib/api/client.dart --imports--> lib/models/models.dart [EXTRACTED] lib/api/client.dart:10
lib/api/client/client_oc_client.dart --defines--> lib/api/client/client_oc_client.dart::ApiException [EXTRACTED] lib/api/client/client_oc_client.dart:3
lib/api/client/client_oc_client.dart --defines--> lib/api/client/client_oc_client.dart::OcClient [EXTRACTED] lib/api/client/client_oc_client.dart:26
lib/api/client/client_oc_client.dart --defines--> lib/api/client/client_oc_client.dart::_parseBytes [EXTRACTED] lib/api/client/client_oc_client.dart:17
lib/api/client/client_oc_client.dart --defines--> lib/api/client/client_oc_client.dart::toString [EXTRACTED] lib/api/client/client_oc_client.dart:13
lib/api/client/client_oc_client_http.dart --calls--> lib/api/client/client_oc_client.dart::ApiException [INFERRED 0.6] lib/api/client/client_oc_client_http.dart:0
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::OcClientHttp [EXTRACTED] lib/api/client/client_oc_client_http.dart:8
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::_decode [EXTRACTED] lib/api/client/client_oc_client_http.dart:35
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::_headers [EXTRACTED] lib/api/client/client_oc_client_http.dart:13
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::_send [EXTRACTED] lib/api/client/client_oc_client_http.dart:126
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::_sendOnce [EXTRACTED] lib/api/client/client_oc_client_http.dart:78
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::_u [EXTRACTED] lib/api/client/client_oc_client_http.dart:21
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::close [EXTRACTED] lib/api/client/client_oc_client_http.dart:208
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::delete [EXTRACTED] lib/api/client/client_oc_client_http.dart:194
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::get [EXTRACTED] lib/api/client/client_oc_client_http.dart:142
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::patch [EXTRACTED] lib/api/client/client_oc_client_http.dart:166
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::post [EXTRACTED] lib/api/client/client_oc_client_http.dart:152
lib/api/client/client_oc_client_http.dart --defines--> lib/api/client/client_oc_client_http.dart::put [EXTRACTED] lib/api/client/client_oc_client_http.dart:180
lib/api/client/client_oc_client_http.dart --calls--> lib/l10n/strings.dart::netTimeout [INFERRED 0.6] lib/api/client/client_oc_client_http.dart:0
lib/api/client/client_oc_client_http.dart --calls--> lib/l10n/strings.dart::netUnreachable [INFERRED 0.6] lib/api/client/client_oc_client_http.dart:0
lib/api/client/client_oc_client_http.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/client/client_oc_client_http.dart:0
lib/api/client/client_oc_client_http.dart --calls--> lib/ui/chat/chat_page.dart::_send [INFERRED 0.35] lib/api/client/client_oc_client_http.dart:0
lib/api/client/client_oc_client_http.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/api/client/client_oc_client_http.dart:0
lib/api/client/client_oc_client_messages.dart --calls--> lib/api/client/client_oc_client_http.dart::post [INFERRED 0.6] lib/api/client/client_oc_client_messages.dart:0
lib/api/client/client_oc_client_messages.dart --defines--> lib/api/client/client_oc_client_messages.dart::OcClientMessages [EXTRACTED] lib/api/client/client_oc_client_messages.dart:8
lib/api/client/client_oc_client_messages.dart --defines--> lib/api/client/client_oc_client_messages.dart::deleteMessage [EXTRACTED] lib/api/client/client_oc_client_messages.dart:59
lib/api/client/client_oc_client_messages.dart --defines--> lib/api/client/client_oc_client_messages.dart::message [EXTRACTED] lib/api/client/client_oc_client_messages.dart:54
lib/api/client/client_oc_client_messages.dart --defines--> lib/api/client/client_oc_client_messages.dart::promptAsync [EXTRACTED] lib/api/client/client_oc_client_messages.dart:65
lib/api/client/client_oc_client_messages.dart --defines--> lib/api/client/client_oc_client_messages.dart::replyPermission [EXTRACTED] lib/api/client/client_oc_client_messages.dart:9
lib/api/client/client_oc_client_messages.dart --defines--> lib/api/client/client_oc_client_messages.dart::replyPermissionV1 [EXTRACTED] lib/api/client/client_oc_client_messages.dart:20
lib/api/client/client_oc_client_messages.dart --calls--> lib/db/chat_db.dart::deleteMessage [INFERRED 0.35] lib/api/client/client_oc_client_messages.dart:0
lib/api/client/client_oc_client_messages.dart --calls--> lib/models/models/models_session_message.dart::asBool [INFERRED 0.6] lib/api/client/client_oc_client_messages.dart:0
lib/api/client/client_oc_client_messages.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/api/client/client_oc_client_messages.dart:0
lib/api/client/client_oc_client_messages.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/client/client_oc_client_messages.dart:0
lib/api/client/client_oc_client_messages.dart --calls--> lib/state/store/store_ocstore_run.dart::runCommand [INFERRED 0.6] lib/api/client/client_oc_client_messages.dart:0
lib/api/client/client_oc_client_server.dart --calls--> lib/api/client/client_oc_client_http.dart::patch [INFERRED 0.6] lib/api/client/client_oc_client_server.dart:0
lib/api/client/client_oc_client_server.dart --calls--> lib/api/client/client_oc_client_http.dart::post [INFERRED 0.6] lib/api/client/client_oc_client_server.dart:0
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::OcClientServer [EXTRACTED] lib/api/client/client_oc_client_server.dart:8
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::agents [EXTRACTED] lib/api/client/client_oc_client_server.dart:90
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::config [EXTRACTED] lib/api/client/client_oc_client_server.dart:38
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::configProviders [EXTRACTED] lib/api/client/client_oc_client_server.dart:43
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::disposeInstance [EXTRACTED] lib/api/client/client_oc_client_server.dart:21
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::log [EXTRACTED] lib/api/client/client_oc_client_server.dart:28
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::patchConfig [EXTRACTED] lib/api/client/client_oc_client_server.dart:40
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::paths [EXTRACTED] lib/api/client/client_oc_client_server.dart:16
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::providerAuthMethods [EXTRACTED] lib/api/client/client_oc_client_server.dart:55
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::providerAuthUrl [EXTRACTED] lib/api/client/client_oc_client_server.dart:66
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::providers [EXTRACTED] lib/api/client/client_oc_client_server.dart:52
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::removeAuth [EXTRACTED] lib/api/client/client_oc_client_server.dart:86
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::setApiKey [EXTRACTED] lib/api/client/client_oc_client_server.dart:78
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::upgrade [EXTRACTED] lib/api/client/client_oc_client_server.dart:24
lib/api/client/client_oc_client_server.dart --defines--> lib/api/client/client_oc_client_server.dart::vcs [EXTRACTED] lib/api/client/client_oc_client_server.dart:19
lib/api/client/client_oc_client_server.dart --calls--> lib/models/models/models_session_message.dart::asBool [INFERRED 0.6] lib/api/client/client_oc_client_server.dart:0
lib/api/client/client_oc_client_server.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/api/client/client_oc_client_server.dart:0
lib/api/client/client_oc_client_server.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/client/client_oc_client_server.dart:0
lib/api/client/client_oc_client_server.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/api/client/client_oc_client_server.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/api/client/client_oc_client_http.dart::patch [INFERRED 0.6] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/api/client/client_oc_client_http.dart::post [INFERRED 0.6] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::OcClientSessions [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:8
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::abort [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:59
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::childSessions [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:46
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::createSession [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:16
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::deleteSession [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:38
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::diff [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:80
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::fork [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:63
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::init [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:85
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::renameSession [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:41
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::revert [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:114
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::session [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:35
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::sessionStatus [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:51
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::sessions [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:11
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::share [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:68
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::summarize [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:102
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::todos [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:54
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::unrevert [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:127
lib/api/client/client_oc_client_sessions.dart --defines--> lib/api/client/client_oc_client_sessions.dart::unshare [EXTRACTED] lib/api/client/client_oc_client_sessions.dart:74
lib/api/client/client_oc_client_sessions.dart --calls--> lib/models/models/models_session_message.dart::asBool [INFERRED 0.6] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/state/store/store_ocstore_run.dart::revert [INFERRED 0.35] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/state/store/store_ocstore_run.dart::summarize [INFERRED 0.35] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/state/store/store_ocstore_run.dart::unrevert [INFERRED 0.35] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/state/store/store_ocstore_sessions.dart::deleteSession [INFERRED 0.35] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_sessions.dart --calls--> lib/state/store/store_ocstore_sessions.dart::renameSession [INFERRED 0.35] lib/api/client/client_oc_client_sessions.dart:0
lib/api/client/client_oc_client_workspace.dart --calls--> lib/api/client/client_oc_client_http.dart::post [INFERRED 0.6] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::OcClientWorkspace [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:8
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::answerQuestion [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:135
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::commands [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:11
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::fileStatus [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:38
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::files [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:28
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::findFiles [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:43
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::formatters [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:122
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::grep [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:55
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::lsp [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:117
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::mcp [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:96
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::mcpAdd [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:101
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::mcpConnect [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:109
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::mcpDisconnect [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:113
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::pendingPermissions [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:132
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::pendingQuestions [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:129
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::readFile [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:33
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::rejectQuestion [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:142
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::skills [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:16
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::symbols [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:64
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::toolIds [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:21
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::tui [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:147
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::vcsApply [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:86
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::vcsDiff [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:74
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::vcsDiffRaw [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:71
lib/api/client/client_oc_client_workspace.dart --defines--> lib/api/client/client_oc_client_workspace.dart::vcsStatus [EXTRACTED] lib/api/client/client_oc_client_workspace.dart:80
lib/api/client/client_oc_client_workspace.dart --calls--> lib/models/models/models_session_message.dart::asBool [INFERRED 0.6] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_oc_client_workspace.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_oc_client_workspace.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_oc_client_workspace.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_oc_client_workspace.dart --calls--> lib/state/store/store_ocstore_prompts.dart::answerQuestion [INFERRED 0.35] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_oc_client_workspace.dart --calls--> lib/state/store/store_ocstore_prompts.dart::rejectQuestion [INFERRED 0.35] lib/api/client/client_oc_client_workspace.dart:0
lib/api/client/client_provider_types.dart --defines--> lib/api/client/client_provider_types.dart::AuthMethod [EXTRACTED] lib/api/client/client_provider_types.dart:72
lib/api/client/client_provider_types.dart --defines--> lib/api/client/client_provider_types.dart::ProviderEntry [EXTRACTED] lib/api/client/client_provider_types.dart:41
lib/api/client/client_provider_types.dart --defines--> lib/api/client/client_provider_types.dart::ProviderInfo [EXTRACTED] lib/api/client/client_provider_types.dart:3
lib/api/client/client_provider_types.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/api/client/client_provider_types.dart:0
lib/api/client/client_provider_types.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/client/client_provider_types.dart:0
lib/api/client/client_provider_types.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/api/client/client_provider_types.dart:0
lib/api/events.dart --defines--> lib/api/events.dart::EventStream [EXTRACTED] lib/api/events.dart:48
lib/api/events.dart --defines--> lib/api/events.dart::OcEvent [EXTRACTED] lib/api/events.dart:12
lib/api/events.dart --defines--> lib/api/events.dart::_checkLiveness [EXTRACTED] lib/api/events.dart:249
lib/api/events.dart --defines--> lib/api/events.dart::_connect [EXTRACTED] lib/api/events.dart:148
lib/api/events.dart --defines--> lib/api/events.dart::_handleFrame [EXTRACTED] lib/api/events.dart:326
lib/api/events.dart --defines--> lib/api/events.dart::_markDown [EXTRACTED] lib/api/events.dart:353
lib/api/events.dart --defines--> lib/api/events.dart::_probeLiveness [EXTRACTED] lib/api/events.dart:261
lib/api/events.dart --defines--> lib/api/events.dart::_scheduleRetry [EXTRACTED] lib/api/events.dart:362
lib/api/events.dart --defines--> lib/api/events.dart::_setConnected [EXTRACTED] lib/api/events.dart:343
lib/api/events.dart --defines--> lib/api/events.dart::_teardown [EXTRACTED] lib/api/events.dart:410
lib/api/events.dart --defines--> lib/api/events.dart::reconnect [EXTRACTED] lib/api/events.dart:136
lib/api/events.dart --defines--> lib/api/events.dart::shutdown [EXTRACTED] lib/api/events.dart:401
lib/api/events.dart --defines--> lib/api/events.dart::start [EXTRACTED] lib/api/events.dart:129
lib/api/events.dart --defines--> lib/api/events.dart::stop [EXTRACTED] lib/api/events.dart:389
lib/api/events.dart --imports--> lib/models/models.dart [EXTRACTED] lib/api/events.dart:9
lib/api/events.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/api/events.dart:0
lib/api/events.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/api/events.dart:0
lib/api/events.dart --calls--> lib/state/store/store_ocstore_history.dart::send [INFERRED 0.6] lib/api/events.dart:0
lib/api/events.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/api/events.dart:0
lib/db/chat_db.dart --calls--> lib/api/client/client_oc_client_messages.dart::deleteMessage [INFERRED 0.35] lib/db/chat_db.dart:0
lib/db/chat_db.dart --calls--> lib/api/client/client_oc_client_sessions.dart::sessions [INFERRED 0.6] lib/db/chat_db.dart:0
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::ChatDB [EXTRACTED] lib/db/chat_db.dart:21
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::_createMessages [EXTRACTED] lib/db/chat_db.dart:65
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::_createSessions [EXTRACTED] lib/db/chat_db.dart:80
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::_enqueue [EXTRACTED] lib/db/chat_db.dart:94
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::_init [EXTRACTED] lib/db/chat_db.dart:42
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::_sortKey [EXTRACTED] lib/db/chat_db.dart:107
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::_writeRow [EXTRACTED] lib/db/chat_db.dart:118
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::clearSession [EXTRACTED] lib/db/chat_db.dart:184
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::deleteMessage [EXTRACTED] lib/db/chat_db.dart:151
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::deleteSessionRow [EXTRACTED] lib/db/chat_db.dart:217
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::loadMessages [EXTRACTED] lib/db/chat_db.dart:163
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::loadSessions [EXTRACTED] lib/db/chat_db.dart:225
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::saveSession [EXTRACTED] lib/db/chat_db.dart:212
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::saveSessions [EXTRACTED] lib/db/chat_db.dart:194
lib/db/chat_db.dart --defines--> lib/db/chat_db.dart::upsertMessages [EXTRACTED] lib/db/chat_db.dart:132
lib/db/chat_db.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/db/chat_db.dart:0
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::S [EXTRACTED] lib/l10n/strings.dart:9
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::added [EXTRACTED] lib/l10n/strings.dart:408
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::agentPrimary [EXTRACTED] lib/l10n/strings.dart:956
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::cmdArgs [EXTRACTED] lib/l10n/strings.dart:308
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::cmdUseLabel [EXTRACTED] lib/l10n/strings.dart:310
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::cmdUseSkill [EXTRACTED] lib/l10n/strings.dart:309
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::composerModelAgent [EXTRACTED] lib/l10n/strings.dart:191
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::composerQueued [EXTRACTED] lib/l10n/strings.dart:518
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::composerWorking [EXTRACTED] lib/l10n/strings.dart:516
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::configInvalidJsonError [EXTRACTED] lib/l10n/strings.dart:704
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::diffAddedRemoved [EXTRACTED] lib/l10n/strings.dart:573
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::diffAppliesTo [EXTRACTED] lib/l10n/strings.dart:328
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::drawerConnectedTo [EXTRACTED] lib/l10n/strings.dart:879
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::drawerPending [EXTRACTED] lib/l10n/strings.dart:876
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::errorText [EXTRACTED] lib/l10n/strings.dart:1153
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::fileStats [EXTRACTED] lib/l10n/strings.dart:555
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesChangedCount [EXTRACTED] lib/l10n/strings.dart:448
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesCount [EXTRACTED] lib/l10n/strings.dart:251
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesDeleteBody [EXTRACTED] lib/l10n/strings.dart:361
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesDeleteFailed [EXTRACTED] lib/l10n/strings.dart:404
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesEmptyName [EXTRACTED] lib/l10n/strings.dart:367
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesExists [EXTRACTED] lib/l10n/strings.dart:403
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesFolderFailed [EXTRACTED] lib/l10n/strings.dart:405
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesItems [EXTRACTED] lib/l10n/strings.dart:944
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesNameHint [EXTRACTED] lib/l10n/strings.dart:369
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesNameLabel [EXTRACTED] lib/l10n/strings.dart:365
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::filesSelected [EXTRACTED] lib/l10n/strings.dart:945
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::forkCreated [EXTRACTED] lib/l10n/strings.dart:523
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::formatContext [EXTRACTED] lib/l10n/strings.dart:960
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::historyDeleteBody [EXTRACTED] lib/l10n/strings.dart:932
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::historyFiles [EXTRACTED] lib/l10n/strings.dart:300
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::jumpUnread [EXTRACTED] lib/l10n/strings.dart:904
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::label [EXTRACTED] lib/l10n/strings.dart:1151
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::mcpCount [EXTRACTED] lib/l10n/strings.dart:717
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::menuServerVersion [EXTRACTED] lib/l10n/strings.dart:894
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::menuWaitingForYou [EXTRACTED] lib/l10n/strings.dart:889
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::messageCount [EXTRACTED] lib/l10n/strings.dart:252
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::modelsContext [EXTRACTED] lib/l10n/strings.dart:474
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::modelsCount [EXTRACTED] lib/l10n/strings.dart:1137
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::modelsProvider [EXTRACTED] lib/l10n/strings.dart:954
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::modelsSelected [EXTRACTED] lib/l10n/strings.dart:475
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::moreToolsCount [EXTRACTED] lib/l10n/strings.dart:205
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::netTimeout [EXTRACTED] lib/l10n/strings.dart:431
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::netUnreachable [EXTRACTED] lib/l10n/strings.dart:432
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::partsAgent [EXTRACTED] lib/l10n/strings.dart:311
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::partsThinkingLines [EXTRACTED] lib/l10n/strings.dart:502
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::partsThoughtFor [EXTRACTED] lib/l10n/strings.dart:500
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::permMorePending [EXTRACTED] lib/l10n/strings.dart:1142
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::permSuggestingRules [EXTRACTED] lib/l10n/strings.dart:438
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::promptInSession [EXTRACTED] lib/l10n/strings.dart:890
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::promptOtherSession [EXTRACTED] lib/l10n/strings.dart:891
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::promptSemantics [EXTRACTED] lib/l10n/strings.dart:514
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::serverOnlineVersion [EXTRACTED] lib/l10n/strings.dart:111
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::sessionsCount [EXTRACTED] lib/l10n/strings.dart:521
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::sessionsCountOne [EXTRACTED] lib/l10n/strings.dart:522
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::sessionsDeleteBody [EXTRACTED] lib/l10n/strings.dart:281
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::setMcpLabel [EXTRACTED] lib/l10n/strings.dart:480
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::setMcpServers [EXTRACTED] lib/l10n/strings.dart:1039
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::setPassword [EXTRACTED] lib/l10n/strings.dart:392
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::setPermExternalBody [EXTRACTED] lib/l10n/strings.dart:388
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::setPermExternalTitle [EXTRACTED] lib/l10n/strings.dart:386
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::settingsConnectedVersion [EXTRACTED] lib/l10n/strings.dart:720
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::skillsCount [EXTRACTED] lib/l10n/strings.dart:718
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::slashCommand [EXTRACTED] lib/l10n/strings.dart:1152
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::statusCached [EXTRACTED] lib/l10n/strings.dart:818
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::termuxSetupNote [EXTRACTED] lib/l10n/strings.dart:1002
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::thinkingGroup [EXTRACTED] lib/l10n/strings.dart:899
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::thinkingSteps [EXTRACTED] lib/l10n/strings.dart:902
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::todosProgress [EXTRACTED] lib/l10n/strings.dart:590
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::todosProgressSemantics [EXTRACTED] lib/l10n/strings.dart:591
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::todosSession [EXTRACTED] lib/l10n/strings.dart:1129
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::tokensUsed [EXTRACTED] lib/l10n/strings.dart:253
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::toolDone [EXTRACTED] lib/l10n/strings.dart:198
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::toolRunning [EXTRACTED] lib/l10n/strings.dart:197
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::toolsCount [EXTRACTED] lib/l10n/strings.dart:719
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::useSkillPrompt [EXTRACTED] lib/l10n/strings.dart:623
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::voiceUtterance [EXTRACTED] lib/l10n/strings.dart:1113
lib/l10n/strings.dart --defines--> lib/l10n/strings.dart::waitingYou [EXTRACTED] lib/l10n/strings.dart:509
lib/main.dart --defines--> lib/main.dart::OpenCodeApp [EXTRACTED] lib/main.dart:18
lib/main.dart --defines--> lib/main.dart::_OpenCodeAppState [EXTRACTED] lib/main.dart:25
lib/main.dart --defines--> lib/main.dart::build [EXTRACTED] lib/main.dart:80
lib/main.dart --defines--> lib/main.dart::createState [EXTRACTED] lib/main.dart:22
lib/main.dart --defines--> lib/main.dart::didChangeAppLifecycleState [EXTRACTED] lib/main.dart:53
lib/main.dart --defines--> lib/main.dart::dispose [EXTRACTED] lib/main.dart:45
lib/main.dart --defines--> lib/main.dart::initState [EXTRACTED] lib/main.dart:34
lib/main.dart --defines--> lib/main.dart::main [EXTRACTED] lib/main.dart:13
lib/main.dart --imports--> lib/state/store.dart [EXTRACTED] lib/main.dart:5
lib/main.dart --calls--> lib/state/store/store_ocstore.dart::OcStore [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/state/store/store_ocstore_connection.dart::boot [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/state/store/store_ocstore_messages.dart::pauseConnections [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/state/store/store_ocstore_messages.dart::reconnectStream [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/state/store/store_ocstore_messages.dart::resumeConnections [INFERRED 0.6] lib/main.dart:0
lib/main.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/main.dart:6
lib/main.dart --calls--> lib/ui/app_scope.dart::AppScope [INFERRED 0.6] lib/main.dart:0
lib/main.dart --imports--> lib/ui/home.dart [EXTRACTED] lib/main.dart:7
lib/main.dart --calls--> lib/ui/home/home_shell.dart::HomeShell [INFERRED 0.6] lib/main.dart:0
lib/main.dart --imports--> lib/ui/prompts.dart [EXTRACTED] lib/main.dart:8
lib/main.dart --calls--> lib/ui/prompts/prompts_permission.dart::PromptOverlay [INFERRED 0.6] lib/main.dart:0
lib/main.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/main.dart:9
lib/main.dart --calls--> lib/ui/theme/theme_radius_typography.dart::buildAppTheme [INFERRED 0.6] lib/main.dart:0
lib/main.dart --imports--> lib/voice/voice_scope.dart [EXTRACTED] lib/main.dart:10
lib/main.dart --calls--> lib/voice/voice_scope.dart::VoiceScope [INFERRED 0.6] lib/main.dart:0
lib/main.dart --imports--> lib/voice/voice_service.dart [EXTRACTED] lib/main.dart:11
lib/main.dart --calls--> lib/voice/voice_service/voice_service_core.dart::VoiceService [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::resume [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::suspend [INFERRED 0.6] lib/main.dart:0
lib/main.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::warmUp [INFERRED 0.6] lib/main.dart:0
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::CommandInfo [EXTRACTED] lib/models/models/models_server_info.dart:123
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::FileDiff [EXTRACTED] lib/models/models/models_server_info.dart:97
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::FileNode [EXTRACTED] lib/models/models/models_server_info.dart:75
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::ModelInfo [EXTRACTED] lib/models/models/models_server_info.dart:3
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::NamedStatus [EXTRACTED] lib/models/models/models_server_info.dart:159
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::PermissionReq [EXTRACTED] lib/models/models/models_server_info.dart:215
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::QuestionItem [EXTRACTED] lib/models/models/models_server_info.dart:350
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::QuestionOption [EXTRACTED] lib/models/models/models_server_info.dart:343
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::QuestionReq [EXTRACTED] lib/models/models/models_server_info.dart:373
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::ServerPaths [EXTRACTED] lib/models/models/models_server_info.dart:194
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::SkillInfo [EXTRACTED] lib/models/models/models_server_info.dart:144
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::Todo [EXTRACTED] lib/models/models/models_server_info.dart:46
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::VcsInfo [EXTRACTED] lib/models/models/models_server_info.dart:182
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::_fmt [EXTRACTED] lib/models/models/models_server_info.dart:336
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::baseName [EXTRACTED] lib/models/models/models_server_info.dart:433
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::dirName [EXTRACTED] lib/models/models/models_server_info.dart:438
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::fmtAge [EXTRACTED] lib/models/models/models_server_info.dart:415
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::fmtBytes [EXTRACTED] lib/models/models/models_server_info.dart:403
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::fmtDuration [EXTRACTED] lib/models/models/models_server_info.dart:425
lib/models/models/models_server_info.dart --defines--> lib/models/models/models_server_info.dart::fmtTime [EXTRACTED] lib/models/models/models_server_info.dart:409
lib/models/models/models_server_info.dart --calls--> lib/models/models/models_session_message.dart::asBool [INFERRED 0.6] lib/models/models/models_server_info.dart:0
lib/models/models/models_server_info.dart --calls--> lib/models/models/models_session_message.dart::asInt [INFERRED 0.6] lib/models/models/models_server_info.dart:0
lib/models/models/models_server_info.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/models/models/models_server_info.dart:0
lib/models/models/models_server_info.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/models/models/models_server_info.dart:0
lib/models/models/models_server_info.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/models/models/models_server_info.dart:0
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::Agent [EXTRACTED] lib/models/models/models_session_message.dart:374
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::Message [EXTRACTED] lib/models/models/models_session_message.dart:158
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::Part [EXTRACTED] lib/models/models/models_session_message.dart:238
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::PendingPrompt [EXTRACTED] lib/models/models/models_session_message.dart:71
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::Session [EXTRACTED] lib/models/models/models_session_message.dart:94
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::SessionSummary [EXTRACTED] lib/models/models/models_session_message.dart:50
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::Tokens [EXTRACTED] lib/models/models/models_session_message.dart:22
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::ToolStatus [EXTRACTED] lib/models/models/models_session_message.dart:236
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::_short [EXTRACTED] lib/models/models/models_session_message.dart:364
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::asBool [EXTRACTED] lib/models/models/models_session_message.dart:18
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::asDouble [EXTRACTED] lib/models/models/models_session_message.dart:15
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::asInt [EXTRACTED] lib/models/models/models_session_message.dart:9
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::asList [EXTRACTED] lib/models/models/models_session_message.dart:7
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::asMap [EXTRACTED] lib/models/models/models_session_message.dart:3
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::asStr [EXTRACTED] lib/models/models/models_session_message.dart:13
lib/models/models/models_session_message.dart --defines--> lib/models/models/models_session_message.dart::toMap [EXTRACTED] lib/models/models/models_session_message.dart:153
lib/state/store.dart --imports--> lib/api/client.dart [EXTRACTED] lib/state/store.dart:8
lib/state/store.dart --imports--> lib/api/events.dart [EXTRACTED] lib/state/store.dart:9
lib/state/store.dart --imports--> lib/db/chat_db.dart [EXTRACTED] lib/state/store.dart:12
lib/state/store.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/state/store.dart:10
lib/state/store.dart --imports--> lib/models/models.dart [EXTRACTED] lib/state/store.dart:11
lib/state/store/store_ocstore.dart --calls--> lib/api/client/client_oc_client.dart::OcClient [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/api/client/client_oc_client_workspace.dart::files [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/api/events.dart::shutdown [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --defines--> lib/state/store/store_ocstore.dart::OcStore [EXTRACTED] lib/state/store/store_ocstore.dart:5
lib/state/store/store_ocstore.dart --defines--> lib/state/store/store_ocstore.dart::_messageText [EXTRACTED] lib/state/store/store_ocstore.dart:129
lib/state/store/store_ocstore.dart --defines--> lib/state/store/store_ocstore.dart::_parentDir [EXTRACTED] lib/state/store/store_ocstore.dart:249
lib/state/store/store_ocstore.dart --defines--> lib/state/store/store_ocstore.dart::_shellQuote [EXTRACTED] lib/state/store/store_ocstore.dart:255
lib/state/store/store_ocstore.dart --defines--> lib/state/store/store_ocstore.dart::_stripEchoedOptimistic [EXTRACTED] lib/state/store/store_ocstore.dart:153
lib/state/store/store_ocstore.dart --defines--> lib/state/store/store_ocstore.dart::dispose [EXTRACTED] lib/state/store/store_ocstore.dart:290
lib/state/store/store_ocstore.dart --calls--> lib/state/store/store_ocstore_cache.dart::_flushHistory [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/state/store/store_ocstore_run.dart::_clearBusyTimer [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/state/store/store_types.dart::MessageListSignal [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/state/store/store_types.dart::TodoListSignal [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/state/store/store_types.dart::notify [INFERRED 0.6] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore.dart --calls--> lib/voice/voice_service/voice_service_core.dart::_messageText [INFERRED 0.35] lib/state/store/store_ocstore.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/db/chat_db.dart::loadMessages [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/db/chat_db.dart::upsertMessages [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/state/store/store_ocstore.dart::_stripEchoedOptimistic [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::OcStoreCache [EXTRACTED] lib/state/store/store_ocstore_cache.dart:9
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_cachedHistory [EXTRACTED] lib/state/store/store_ocstore_cache.dart:113
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_dbRow [EXTRACTED] lib/state/store/store_ocstore_cache.dart:66
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_debouncedTodos [EXTRACTED] lib/state/store/store_ocstore_cache.dart:51
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_flushHistory [EXTRACTED] lib/state/store/store_ocstore_cache.dart:149
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_isCacheable [EXTRACTED] lib/state/store/store_ocstore_cache.dart:77
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_mergeHistory [EXTRACTED] lib/state/store/store_ocstore_cache.dart:92
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_persistHistory [EXTRACTED] lib/state/store/store_ocstore_cache.dart:165
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_scheduleFlush [EXTRACTED] lib/state/store/store_ocstore_cache.dart:131
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_scheduleMessageNotify [EXTRACTED] lib/state/store/store_ocstore_cache.dart:32
lib/state/store/store_ocstore_cache.dart --defines--> lib/state/store/store_ocstore_cache.dart::_scheduleNotify [EXTRACTED] lib/state/store/store_ocstore_cache.dart:17
lib/state/store/store_ocstore_cache.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/state/store/store_types.dart::ChatMessage [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/state/store/store_types.dart::notify [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_cache.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/state/store/store_ocstore_cache.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/client/client_oc_client_server.dart::agents [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/client/client_oc_client_server.dart::paths [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/client/client_oc_client_server.dart::providers [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/events.dart::EventStream [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/events.dart::reconnect [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/events.dart::shutdown [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/api/events.dart::start [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/l10n/strings.dart::netUnreachable [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_cache.dart::_mergeHistory [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_cache.dart::_persistHistory [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::OcStoreConnection [EXTRACTED] lib/state/store/store_ocstore_connection.dart:14
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_healthFailed [EXTRACTED] lib/state/store/store_ocstore_connection.dart:151
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_markAlive [EXTRACTED] lib/state/store/store_ocstore_connection.dart:135
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_offlineMessage [EXTRACTED] lib/state/store/store_ocstore_connection.dart:163
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_onStreamStatus [EXTRACTED] lib/state/store/store_ocstore_connection.dart:265
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_persist [EXTRACTED] lib/state/store/store_ocstore_connection.dart:40
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_resyncMessages [EXTRACTED] lib/state/store/store_ocstore_connection.dart:299
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_startStream [EXTRACTED] lib/state/store/store_ocstore_connection.dart:243
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::_verifyReachability [EXTRACTED] lib/state/store/store_ocstore_connection.dart:172
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::boot [EXTRACTED] lib/state/store/store_ocstore_connection.dart:24
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::connect [EXTRACTED] lib/state/store/store_ocstore_connection.dart:65
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::refreshCatalog [EXTRACTED] lib/state/store/store_ocstore_connection.dart:342
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::refreshServerInfo [EXTRACTED] lib/state/store/store_ocstore_connection.dart:332
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::setAgent [EXTRACTED] lib/state/store/store_ocstore_connection.dart:381
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::setModel [EXTRACTED] lib/state/store/store_ocstore_connection.dart:374
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::setServer [EXTRACTED] lib/state/store/store_ocstore_connection.dart:57
lib/state/store/store_ocstore_connection.dart --defines--> lib/state/store/store_ocstore_connection.dart::toggleTool [EXTRACTED] lib/state/store/store_ocstore_connection.dart:387
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_prompts.dart::resyncPrompts [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_run.dart::_probeBusyState [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_sessions.dart::_restoreSessionsFromCache [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshSessions [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_ocstore_workspace.dart::refreshCommands [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/state/store/store_types.dart::ChatMessage [INFERRED 0.6] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_connection.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_persist [INFERRED 0.35] lib/state/store/store_ocstore_connection.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/db/chat_db.dart::clearSession [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/db/chat_db.dart::deleteSessionRow [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/models/models/models_session_message.dart::asList [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_cache.dart::_debouncedTodos [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_cache.dart::_flushHistory [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_connection.dart::_markAlive [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --defines--> lib/state/store/store_ocstore_events.dart::OcStoreEvents [EXTRACTED] lib/state/store/store_ocstore_events.dart:9
lib/state/store/store_ocstore_events.dart --defines--> lib/state/store/store_ocstore_events.dart::_errorText [EXTRACTED] lib/state/store/store_ocstore_events.dart:264
lib/state/store/store_ocstore_events.dart --defines--> lib/state/store/store_ocstore_events.dart::_handleEvent [EXTRACTED] lib/state/store/store_ocstore_events.dart:49
lib/state/store/store_ocstore_events.dart --defines--> lib/state/store/store_ocstore_events.dart::_promptParseFailed [EXTRACTED] lib/state/store/store_ocstore_events.dart:41
lib/state/store/store_ocstore_events.dart --defines--> lib/state/store/store_ocstore_events.dart::_repliedId [EXTRACTED] lib/state/store/store_ocstore_events.dart:32
lib/state/store/store_ocstore_events.dart --defines--> lib/state/store/store_ocstore_events.dart::handleEvent [EXTRACTED] lib/state/store/store_ocstore_events.dart:14
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_history.dart::_flushQueue [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_applyDelta [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_isCurrent [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_removeMessage [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_removePart [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_upsertMessage [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_upsertPart [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_messages.dart::_upsertSession [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_prompts.dart::resyncPrompts [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_run.dart::_clearBusyTimer [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_run.dart::_settleStuckStreaming [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_run.dart::_startBusyTimer [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_run.dart::_touchActivity [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_sessions.dart::_applyTodosPayload [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshDiff [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshSessions [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_forgetArrival [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_onPromptAdded [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_onPromptRemoved [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_stampArrival [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_events.dart --calls--> lib/state/store/store_types.dart::notify [INFERRED 0.6] lib/state/store/store_ocstore_events.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/models/models/models_session_message.dart::Message [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/models/models/models_session_message.dart::Tokens [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/state/store/store_ocstore.dart::_stripEchoedOptimistic [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/state/store/store_ocstore_cache.dart::_persistHistory [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::OcStoreHistory [EXTRACTED] lib/state/store/store_ocstore_history.dart:9
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::_flushQueue [EXTRACTED] lib/state/store/store_ocstore_history.dart:145
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::_partPayload [EXTRACTED] lib/state/store/store_ocstore_history.dart:113
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::_prependHistory [EXTRACTED] lib/state/store/store_ocstore_history.dart:12
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::_widenHistory [EXTRACTED] lib/state/store/store_ocstore_history.dart:29
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::addAttachment [EXTRACTED] lib/state/store/store_ocstore_history.dart:98
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::clearAttachments [EXTRACTED] lib/state/store/store_ocstore_history.dart:108
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::loadOlderMessages [EXTRACTED] lib/state/store/store_ocstore_history.dart:57
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::removeAttachment [EXTRACTED] lib/state/store/store_ocstore_history.dart:103
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::send [EXTRACTED] lib/state/store/store_ocstore_history.dart:157
lib/state/store/store_ocstore_history.dart --defines--> lib/state/store/store_ocstore_history.dart::sendOrQueue [EXTRACTED] lib/state/store/store_ocstore_history.dart:130
lib/state/store/store_ocstore_history.dart --calls--> lib/state/store/store_ocstore_messages.dart::_clearLocalEcho [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/state/store/store_ocstore_run.dart::_sendParts [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/state/store/store_ocstore_sessions.dart::newSession [INFERRED 0.35] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/state/store/store_types.dart::ChatMessage [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_history.dart --calls--> lib/ui/terminal_page.dart::newSession [INFERRED 0.35] lib/state/store/store_ocstore_history.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/api/client/client_oc_client_messages.dart::deleteMessage [INFERRED 0.35] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/api/events.dart::reconnect [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/api/events.dart::stop [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/db/chat_db.dart::deleteMessage [INFERRED 0.35] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/db/chat_db.dart::saveSession [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/models/models/models_session_message.dart::Message [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/models/models/models_session_message.dart::Tokens [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_cache.dart::_flushHistory [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_cache.dart::_scheduleFlush [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_cache.dart::_scheduleMessageNotify [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_cache.dart::_scheduleNotify [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_connection.dart::_verifyReachability [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::OcStoreMessages [EXTRACTED] lib/state/store/store_ocstore_messages.dart:9
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_applyDelta [EXTRACTED] lib/state/store/store_ocstore_messages.dart:126
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_clearLocalEcho [EXTRACTED] lib/state/store/store_ocstore_messages.dart:31
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_isCurrent [EXTRACTED] lib/state/store/store_ocstore_messages.dart:12
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_messageById [EXTRACTED] lib/state/store/store_ocstore_messages.dart:15
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_optimisticIndex [EXTRACTED] lib/state/store/store_ocstore_messages.dart:23
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_removeMessage [EXTRACTED] lib/state/store/store_ocstore_messages.dart:161
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_removePart [EXTRACTED] lib/state/store/store_ocstore_messages.dart:143
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_toast [EXTRACTED] lib/state/store/store_ocstore_messages.dart:193
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_upsertMessage [EXTRACTED] lib/state/store/store_ocstore_messages.dart:36
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_upsertPart [EXTRACTED] lib/state/store/store_ocstore_messages.dart:63
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::_upsertSession [EXTRACTED] lib/state/store/store_ocstore_messages.dart:177
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::pauseConnections [EXTRACTED] lib/state/store/store_ocstore_messages.dart:210
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::reconnectStream [EXTRACTED] lib/state/store/store_ocstore_messages.dart:201
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::resumeConnections [EXTRACTED] lib/state/store/store_ocstore_messages.dart:229
lib/state/store/store_ocstore_messages.dart --defines--> lib/state/store/store_ocstore_messages.dart::takeToast [EXTRACTED] lib/state/store/store_ocstore_messages.dart:194
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_run.dart::_clearBusyTimer [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_messages.dart --calls--> lib/state/store/store_types.dart::ChatMessage [INFERRED 0.6] lib/state/store/store_ocstore_messages.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/api/client/client_oc_client_messages.dart::replyPermission [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/api/client/client_oc_client_messages.dart::replyPermissionV1 [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/api/client/client_oc_client_workspace.dart::answerQuestion [INFERRED 0.35] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/api/client/client_oc_client_workspace.dart::pendingPermissions [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/api/client/client_oc_client_workspace.dart::pendingQuestions [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/api/client/client_oc_client_workspace.dart::rejectQuestion [INFERRED 0.35] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/state/store/store_ocstore_messages.dart::_toast [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::OcStorePrompts [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:9
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::_resyncPromptsOnce [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:83
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::answerPermission [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:107
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::answerQuestion [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:128
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::loadPending [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:14
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::rejectQuestion [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:141
lib/state/store/store_ocstore_prompts.dart --defines--> lib/state/store/store_ocstore_prompts.dart::resyncPrompts [EXTRACTED] lib/state/store/store_ocstore_prompts.dart:55
lib/state/store/store_ocstore_prompts.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_forgetArrival [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_onPromptRemoved [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_prompts.dart --calls--> lib/state/store/store_ocstore_view_state.dart::_stampArrival [INFERRED 0.6] lib/state/store/store_ocstore_prompts.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/api/client/client_oc_client_http.dart::post [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/api/client/client_oc_client_messages.dart::promptAsync [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/api/client/client_oc_client_sessions.dart::revert [INFERRED 0.35] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/api/client/client_oc_client_sessions.dart::sessionStatus [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/api/client/client_oc_client_sessions.dart::summarize [INFERRED 0.35] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/api/client/client_oc_client_sessions.dart::unrevert [INFERRED 0.35] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/state/store/store_ocstore_connection.dart::_resyncMessages [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/state/store/store_ocstore_history.dart::send [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/state/store/store_ocstore_messages.dart::_toast [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::OcStoreRun [EXTRACTED] lib/state/store/store_ocstore_run.dart:9
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::_clearBusyTimer [EXTRACTED] lib/state/store/store_ocstore_run.dart:95
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::_probeBusyState [EXTRACTED] lib/state/store/store_ocstore_run.dart:47
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::_sendParts [EXTRACTED] lib/state/store/store_ocstore_run.dart:119
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::_settleStuckStreaming [EXTRACTED] lib/state/store/store_ocstore_run.dart:108
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::_startBusyTimer [EXTRACTED] lib/state/store/store_ocstore_run.dart:15
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::_touchActivity [EXTRACTED] lib/state/store/store_ocstore_run.dart:10
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::initAgents [EXTRACTED] lib/state/store/store_ocstore_run.dart:236
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::revert [EXTRACTED] lib/state/store/store_ocstore_run.dart:214
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::runCommand [EXTRACTED] lib/state/store/store_ocstore_run.dart:167
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::summarize [EXTRACTED] lib/state/store/store_ocstore_run.dart:204
lib/state/store/store_ocstore_run.dart --defines--> lib/state/store/store_ocstore_run.dart::unrevert [EXTRACTED] lib/state/store/store_ocstore_run.dart:225
lib/state/store/store_ocstore_run.dart --calls--> lib/state/store/store_ocstore_sessions.dart::newSession [INFERRED 0.35] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/state/store/store_ocstore_sessions.dart::openSession [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [INFERRED 0.6] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_run.dart --calls--> lib/ui/terminal_page.dart::newSession [INFERRED 0.35] lib/state/store/store_ocstore_run.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::abort [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::createSession [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::deleteSession [INFERRED 0.35] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::diff [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::fork [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::renameSession [INFERRED 0.35] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::session [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::sessionStatus [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::sessions [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::share [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::todos [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::unshare [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/db/chat_db.dart::clearSession [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/db/chat_db.dart::deleteSessionRow [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/db/chat_db.dart::loadSessions [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/db/chat_db.dart::saveSessions [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_cache.dart::_cachedHistory [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_cache.dart::_flushHistory [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_cache.dart::_mergeHistory [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_cache.dart::_persistHistory [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_messages.dart::_clearLocalEcho [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_messages.dart::_toast [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_run.dart::_clearBusyTimer [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_run.dart::_settleStuckStreaming [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_ocstore_run.dart::_startBusyTimer [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::OcStoreSessions [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:9
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::_applyTodosPayload [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:280
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::_persistSessions [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:41
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::_restoreSessionsFromCache [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:52
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::_safeSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:148
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::abortSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:214
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::deleteSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:166
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::ensureTodosFresh [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:305
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::forkSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:184
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::newSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:71
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::openSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:89
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::refreshDiff [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:312
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::refreshSessions [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:14
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:242
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::renameSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:157
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::shareSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:195
lib/state/store/store_ocstore_sessions.dart --defines--> lib/state/store/store_ocstore_sessions.dart::unshareSession [EXTRACTED] lib/state/store/store_ocstore_sessions.dart:205
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_types.dart::ChatMessage [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/state/store/store_types.dart::notify [INFERRED 0.6] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_sessions.dart --calls--> lib/ui/terminal_page.dart::newSession [INFERRED 0.35] lib/state/store/store_ocstore_sessions.dart:0
lib/state/store/store_ocstore_view_state.dart --calls--> lib/models/models/models_session_message.dart::PendingPrompt [INFERRED 0.6] lib/state/store/store_ocstore_view_state.dart:0
lib/state/store/store_ocstore_view_state.dart --calls--> lib/state/store/store_ocstore_connection.dart::_persist [INFERRED 0.35] lib/state/store/store_ocstore_view_state.dart:0
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::OcStoreViewState [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:9
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::_forgetArrival [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:65
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::_onPromptAdded [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:94
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::_onPromptRemoved [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:101
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::_stampArrival [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:58
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::dismissPromptSheet [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:86
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::openPromptSheet [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:76
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::sessionLabel [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:109
lib/state/store/store_ocstore_view_state.dart --defines--> lib/state/store/store_ocstore_view_state.dart::setShowTokensInChat [EXTRACTED] lib/state/store/store_ocstore_view_state.dart:15
lib/state/store/store_ocstore_view_state.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_persist [INFERRED 0.35] lib/state/store/store_ocstore_view_state.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client.dart::ApiException [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_server.dart::config [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_server.dart::patchConfig [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_sessions.dart::createSession [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_sessions.dart::session [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_workspace.dart::commands [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_workspace.dart::formatters [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_workspace.dart::mcpAdd [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/api/client/client_oc_client_workspace.dart::skills [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/l10n/strings.dart::added [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/l10n/strings.dart::filesDeleteFailed [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/l10n/strings.dart::filesFolderFailed [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/state/store/store_ocstore.dart::_parentDir [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/state/store/store_ocstore.dart::_shellQuote [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/state/store/store_ocstore_messages.dart::_toast [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshSessions [INFERRED 0.6] lib/state/store/store_ocstore_workspace.dart:0
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::OcStoreWorkspace [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:9
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::_utilSession [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:10
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::addMcp [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:180
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::deleteEntry [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:105
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::enableExternalDirectoryAccess [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:164
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::mkdirEntry [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:116
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::refreshCommands [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:131
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::refreshConfig [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:141
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::saveConfig [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:153
lib/state/store/store_ocstore_workspace.dart --defines--> lib/state/store/store_ocstore_workspace.dart::writeFile [EXTRACTED] lib/state/store/store_ocstore_workspace.dart:65
lib/state/store/store_types.dart --calls--> lib/api/client/client_oc_client_messages.dart::message [INFERRED 0.6] lib/state/store/store_types.dart:0
lib/state/store/store_types.dart --defines--> lib/state/store/store_types.dart::ChatMessage [EXTRACTED] lib/state/store/store_types.dart:3
lib/state/store/store_types.dart --defines--> lib/state/store/store_types.dart::MessageListSignal [EXTRACTED] lib/state/store/store_types.dart:57
lib/state/store/store_types.dart --defines--> lib/state/store/store_types.dart::PendingAttachment [EXTRACTED] lib/state/store/store_types.dart:35
lib/state/store/store_types.dart --defines--> lib/state/store/store_types.dart::TodoListSignal [EXTRACTED] lib/state/store/store_types.dart:72
lib/state/store/store_types.dart --defines--> lib/state/store/store_types.dart::notify [EXTRACTED] lib/state/store/store_types.dart:62
lib/ui/about_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/about_page.dart:3
lib/ui/about_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/about_page.dart:4
lib/ui/about_page.dart --defines--> lib/ui/about_page.dart::AboutPage [EXTRACTED] lib/ui/about_page.dart:11
lib/ui/about_page.dart --defines--> lib/ui/about_page.dart::build [EXTRACTED] lib/ui/about_page.dart:15
lib/ui/about_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/about_page.dart:5
lib/ui/about_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/about_page.dart:6
lib/ui/about_page.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/about_page.dart:0
lib/ui/about_page.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCCard [INFERRED 0.6] lib/ui/about_page.dart:0
lib/ui/about_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/about_page.dart:0
lib/ui/about_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/about_page.dart:7
lib/ui/about_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/about_page.dart:8
lib/ui/about_page.dart --calls--> lib/ui/widgets/widgets_header_button.dart::InfoRow [INFERRED 0.6] lib/ui/about_page.dart:0
lib/ui/about_page.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [INFERRED 0.6] lib/ui/about_page.dart:0
lib/ui/app_scope.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/app_scope.dart:3
lib/ui/app_scope.dart --defines--> lib/ui/app_scope.dart::AppScope [EXTRACTED] lib/ui/app_scope.dart:6
lib/ui/app_scope.dart --defines--> lib/ui/app_scope.dart::of [EXTRACTED] lib/ui/app_scope.dart:10
lib/ui/app_scope.dart --defines--> lib/ui/app_scope.dart::read [EXTRACTED] lib/ui/app_scope.dart:17
lib/ui/app_scope.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/app_scope.dart:0
lib/ui/chat.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/chat.dart:10
lib/ui/chat.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/chat.dart:11
lib/ui/chat.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/chat.dart:12
lib/ui/chat.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/chat.dart:13
lib/ui/chat.dart --imports--> lib/ui/line_icons.dart [EXTRACTED] lib/ui/chat.dart:14
lib/ui/chat.dart --imports--> lib/ui/markdown.dart [EXTRACTED] lib/ui/chat.dart:15
lib/ui/chat.dart --imports--> lib/ui/models_page.dart [EXTRACTED] lib/ui/chat.dart:16
lib/ui/chat.dart --imports--> lib/ui/parts.dart [EXTRACTED] lib/ui/chat.dart:17
lib/ui/chat.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/chat.dart:18
lib/ui/chat.dart --imports--> lib/ui/prompts.dart [EXTRACTED] lib/ui/chat.dart:19
lib/ui/chat.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/chat.dart:20
lib/ui/chat.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/chat.dart:21
lib/ui/chat.dart --imports--> lib/voice/voice_scope.dart [EXTRACTED] lib/ui/chat.dart:22
lib/ui/chat.dart --imports--> lib/voice/voice_service.dart [EXTRACTED] lib/ui/chat.dart:23
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/api/client/client_oc_client_workspace.dart::toolIds [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/l10n/strings.dart::composerModelAgent [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/l10n/strings.dart::moreToolsCount [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/models/models/models_session_message.dart::Agent [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/state/store/store_ocstore_connection.dart::setAgent [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/state/store/store_ocstore_connection.dart::toggleTool [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::_ModelPill [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:16
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::_SheetOption [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:128
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::_pickAgentSheet [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:163
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::_pickToolsSheet [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:205
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::build [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:21
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::showAgentSheet [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:34
lib/ui/chat/chat_agent_sheets.dart --defines--> lib/ui/chat/chat_agent_sheets.dart::showModelSheet [EXTRACTED] lib/ui/chat/chat_agent_sheets.dart:84
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/chat/chat_welcome.dart::OutlinedChip [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/home/home_server_menu.dart::_SheetOption [INFERRED 0.35] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/models_page.dart::ModelsPage [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_agent_sheets.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/chat/chat_agent_sheets.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/api/client/client_oc_client_workspace.dart::readFile [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/l10n/strings.dart::slashCommand [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/models/models/models_server_info.dart::fmtBytes [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/state/store/store_ocstore_history.dart::addAttachment [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/state/store/store_ocstore_history.dart::removeAttachment [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/state/store/store_types.dart::PendingAttachment [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_agent_sheets.dart::_ModelPill [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_AttachmentStrip [EXTRACTED] lib/ui/chat/chat_composer.dart:356
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_Composer [EXTRACTED] lib/ui/chat/chat_composer.dart:56
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_ComposerWidget [EXTRACTED] lib/ui/chat/chat_composer.dart:27
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_mimeFor [EXTRACTED] lib/ui/chat/chat_composer.dart:296
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_pickImage [EXTRACTED] lib/ui/chat/chat_composer.dart:251
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_pickProjectFile [EXTRACTED] lib/ui/chat/chat_composer.dart:271
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_showAttachSheet [EXTRACTED] lib/ui/chat/chat_composer.dart:190
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::_showCommands [EXTRACTED] lib/ui/chat/chat_composer.dart:311
lib/ui/chat/chat_composer.dart --defines--> lib/ui/chat/chat_composer.dart::build [EXTRACTED] lib/ui/chat/chat_composer.dart:39
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_file_picker.dart::_FilePickerSheet [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_input_controls.dart::SlashTextField [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_message_actions.dart::_SheetRow [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_run_progress.dart::_QueuedStrip [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_run_progress.dart::_WorkingStrip [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_send_button.dart::_CircleButton [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_send_button.dart::_SendButton [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_voice_strip.dart::_HandsFreeButton [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_voice_strip.dart::_HandsFreeSheetRow [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/chat/chat_voice_strip.dart::_VoiceStrip [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_composer.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/chat/chat_composer.dart:0
lib/ui/chat/chat_file_picker.dart --calls--> lib/api/client/client_oc_client_workspace.dart::files [INFERRED 0.6] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_file_picker.dart --calls--> lib/models/models/models_server_info.dart::dirName [INFERRED 0.6] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_file_picker.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::_FilePickerSheet [EXTRACTED] lib/ui/chat/chat_file_picker.dart:3
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::_FilePickerSheetState [EXTRACTED] lib/ui/chat/chat_file_picker.dart:10
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::_iconFor [EXTRACTED] lib/ui/chat/chat_file_picker.dart:114
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::_load [EXTRACTED] lib/ui/chat/chat_file_picker.dart:22
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::build [EXTRACTED] lib/ui/chat/chat_file_picker.dart:49
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::createState [EXTRACTED] lib/ui/chat/chat_file_picker.dart:7
lib/ui/chat/chat_file_picker.dart --defines--> lib/ui/chat/chat_file_picker.dart::initState [EXTRACTED] lib/ui/chat/chat_file_picker.dart:17
lib/ui/chat/chat_file_picker.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::Mono [INFERRED 0.6] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_file_picker.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_file_picker.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_file_picker.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_file_picker.dart:0
lib/ui/chat/chat_input_controls.dart --calls--> lib/api/client/client_oc_client_workspace.dart::findFiles [INFERRED 0.6] lib/ui/chat/chat_input_controls.dart:0
lib/ui/chat/chat_input_controls.dart --calls--> lib/models/models/models_server_info.dart::baseName [INFERRED 0.6] lib/ui/chat/chat_input_controls.dart:0
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::SlashTextField [EXTRACTED] lib/ui/chat/chat_input_controls.dart:4
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::_SlashTextFieldState [EXTRACTED] lib/ui/chat/chat_input_controls.dart:23
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::_apply [EXTRACTED] lib/ui/chat/chat_input_controls.dart:107
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::_debouncedSearchFiles [EXTRACTED] lib/ui/chat/chat_input_controls.dart:74
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::_onChanged [EXTRACTED] lib/ui/chat/chat_input_controls.dart:48
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::_searchFiles [EXTRACTED] lib/ui/chat/chat_input_controls.dart:82
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::_set [EXTRACTED] lib/ui/chat/chat_input_controls.dart:95
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::build [EXTRACTED] lib/ui/chat/chat_input_controls.dart:129
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::createState [EXTRACTED] lib/ui/chat/chat_input_controls.dart:20
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::dispose [EXTRACTED] lib/ui/chat/chat_input_controls.dart:41
lib/ui/chat/chat_input_controls.dart --defines--> lib/ui/chat/chat_input_controls.dart::initState [EXTRACTED] lib/ui/chat/chat_input_controls.dart:31
lib/ui/chat/chat_input_controls.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_input_controls.dart:0
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::SuggestionCard [EXTRACTED] lib/ui/chat/chat_message.dart:8
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_MessageTile [EXTRACTED] lib/ui/chat/chat_message.dart:109
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_MessageTileState [EXTRACTED] lib/ui/chat/chat_message.dart:129
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_SuggestionCardState [EXTRACTED] lib/ui/chat/chat_message.dart:24
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_assistantBlock [EXTRACTED] lib/ui/chat/chat_message.dart:297
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_buildContent [EXTRACTED] lib/ui/chat/chat_message.dart:175
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_openMenu [EXTRACTED] lib/ui/chat/chat_message.dart:171
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_signature [EXTRACTED] lib/ui/chat/chat_message.dart:147
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::_userBubble [EXTRACTED] lib/ui/chat/chat_message.dart:239
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::build [EXTRACTED] lib/ui/chat/chat_message.dart:28
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::createState [EXTRACTED] lib/ui/chat/chat_message.dart:21
lib/ui/chat/chat_message.dart --defines--> lib/ui/chat/chat_message.dart::didChangeDependencies [EXTRACTED] lib/ui/chat/chat_message.dart:142
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_message_actions.dart::_IncomingFileChip [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_message_actions.dart::_MessageActions [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_message_actions.dart::showMessageMenu [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_reply_meta.dart::_ReplyActions [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_reply_meta.dart::_ReplyMeta [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_status.dart::_InlineError [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/chat/chat_status.dart::_TypingDots [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/markdown/markdown_renderer.dart::Markdown [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/parts/parts_tool_timeline.dart::ToolTimeline [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::ocReduceMotion [INFERRED 0.6] lib/ui/chat/chat_message.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/api/client/client_oc_client_messages.dart::deleteMessage [INFERRED 0.35] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/api/client/client_oc_client_sessions.dart::revert [INFERRED 0.35] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/db/chat_db.dart::deleteMessage [INFERRED 0.35] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/models/models/models_server_info.dart::baseName [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/state/store/store_ocstore_run.dart::revert [INFERRED 0.35] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/state/store/store_ocstore_sessions.dart::forkSession [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/state/store/store_ocstore_sessions.dart::openSession [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --defines--> lib/ui/chat/chat_message_actions.dart::_ActionDot [EXTRACTED] lib/ui/chat/chat_message_actions.dart:209
lib/ui/chat/chat_message_actions.dart --defines--> lib/ui/chat/chat_message_actions.dart::_IncomingFileChip [EXTRACTED] lib/ui/chat/chat_message_actions.dart:139
lib/ui/chat/chat_message_actions.dart --defines--> lib/ui/chat/chat_message_actions.dart::_MessageActions [EXTRACTED] lib/ui/chat/chat_message_actions.dart:175
lib/ui/chat/chat_message_actions.dart --defines--> lib/ui/chat/chat_message_actions.dart::_SheetRow [EXTRACTED] lib/ui/chat/chat_message_actions.dart:102
lib/ui/chat/chat_message_actions.dart --defines--> lib/ui/chat/chat_message_actions.dart::build [EXTRACTED] lib/ui/chat/chat_message_actions.dart:115
lib/ui/chat/chat_message_actions.dart --defines--> lib/ui/chat/chat_message_actions.dart::showMessageMenu [EXTRACTED] lib/ui/chat/chat_message_actions.dart:8
lib/ui/chat/chat_message_actions.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showUndoSnack [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_message_actions.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::speak [INFERRED 0.6] lib/ui/chat/chat_message_actions.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/api/client/client_oc_client_http.dart::_send [INFERRED 0.35] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/state/store/store_ocstore_history.dart::loadOlderMessages [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/state/store/store_ocstore_history.dart::sendOrQueue [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/state/store/store_ocstore_run.dart::runCommand [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/ui/chat/chat_composer.dart::_ComposerWidget [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::ChatPage [EXTRACTED] lib/ui/chat/chat_page.dart:3
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_ChatPageState [EXTRACTED] lib/ui/chat/chat_page.dart:15
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_bumpUnread [EXTRACTED] lib/ui/chat/chat_page.dart:159
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_chatMessageCount [EXTRACTED] lib/ui/chat/chat_page.dart:136
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_handleNotification [EXTRACTED] lib/ui/chat/chat_page.dart:167
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_insertUtterance [EXTRACTED] lib/ui/chat/chat_page.dart:108
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_jumpToLatest [EXTRACTED] lib/ui/chat/chat_page.dart:225
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_loadOlderMessages [EXTRACTED] lib/ui/chat/chat_page.dart:244
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_onScroll [EXTRACTED] lib/ui/chat/chat_page.dart:147
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_onStoreChange [EXTRACTED] lib/ui/chat/chat_page.dart:123
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_queueAutoScroll [EXTRACTED] lib/ui/chat/chat_page.dart:200
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_runAutoScroll [EXTRACTED] lib/ui/chat/chat_page.dart:214
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_send [EXTRACTED] lib/ui/chat/chat_page.dart:350
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_sendSuggestion [EXTRACTED] lib/ui/chat/chat_page.dart:341
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_setFollow [EXTRACTED] lib/ui/chat/chat_page.dart:190
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::_syncFollow [EXTRACTED] lib/ui/chat/chat_page.dart:267
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::build [EXTRACTED] lib/ui/chat/chat_page.dart:302
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::createState [EXTRACTED] lib/ui/chat/chat_page.dart:7
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::dispose [EXTRACTED] lib/ui/chat/chat_page.dart:89
lib/ui/chat/chat_page.dart --defines--> lib/ui/chat/chat_page.dart::initState [EXTRACTED] lib/ui/chat/chat_page.dart:67
lib/ui/chat/chat_page.dart --calls--> lib/ui/chat/chat_run_progress.dart::_RunProgressLine [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/ui/chat/chat_transcript.dart::_BusyBarWidget [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/ui/chat/chat_transcript.dart::_ChatMessages [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_page.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_page.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/api/client/client_oc_client_sessions.dart::revert [INFERRED 0.35] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/state/store/store_ocstore_run.dart::revert [INFERRED 0.35] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/ui/chat/chat_message_actions.dart::_ActionDot [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/ui/chat/chat_message_actions.dart::showMessageMenu [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::_ActionBtn [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:140
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::_ReadAloudAction [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:105
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::_ReplyActions [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:57
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::_ReplyMeta [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:5
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::_replyText [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:45
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::_turnOf [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:32
lib/ui/chat/chat_reply_meta.dart --defines--> lib/ui/chat/chat_reply_meta.dart::build [EXTRACTED] lib/ui/chat/chat_reply_meta.dart:11
lib/ui/chat/chat_reply_meta.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::speak [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_reply_meta.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::stopSpeaking [INFERRED 0.6] lib/ui/chat/chat_reply_meta.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/l10n/strings.dart::composerQueued [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/l10n/strings.dart::composerWorking [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/l10n/strings.dart::waitingYou [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_BarPainter [EXTRACTED] lib/ui/chat/chat_run_progress.dart:346
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_IndeterminateBar [EXTRACTED] lib/ui/chat/chat_run_progress.dart:309
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_IndeterminateBarState [EXTRACTED] lib/ui/chat/chat_run_progress.dart:317
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_PromptChip [EXTRACTED] lib/ui/chat/chat_run_progress.dart:195
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_QueuedStrip [EXTRACTED] lib/ui/chat/chat_run_progress.dart:235
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_RunProgressLine [EXTRACTED] lib/ui/chat/chat_run_progress.dart:282
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_WorkingStrip [EXTRACTED] lib/ui/chat/chat_run_progress.dart:15
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_WorkingStripState [EXTRACTED] lib/ui/chat/chat_run_progress.dart:24
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::_armSlowTimer [EXTRACTED] lib/ui/chat/chat_run_progress.dart:46
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::build [EXTRACTED] lib/ui/chat/chat_run_progress.dart:62
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::createState [EXTRACTED] lib/ui/chat/chat_run_progress.dart:21
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::dispose [EXTRACTED] lib/ui/chat/chat_run_progress.dart:56
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::initState [EXTRACTED] lib/ui/chat/chat_run_progress.dart:39
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::isFreeModel [EXTRACTED] lib/ui/chat/chat_run_progress.dart:268
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::paint [EXTRACTED] lib/ui/chat/chat_run_progress.dart:352
lib/ui/chat/chat_run_progress.dart --defines--> lib/ui/chat/chat_run_progress.dart::shouldRepaint [EXTRACTED] lib/ui/chat/chat_run_progress.dart:366
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/line_icons/line_icons_painter.dart::paint [INFERRED 0.35] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/line_icons/line_icons_painter.dart::shouldRepaint [INFERRED 0.35] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressRing [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::paint [INFERRED 0.35] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::shouldRepaint [INFERRED 0.35] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/prompts/prompts_permission.dart::showPendingPrompt [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_run_progress.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::ocReduceMotion [INFERRED 0.6] lib/ui/chat/chat_run_progress.dart:0
lib/ui/chat/chat_send_button.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_send_button.dart:0
lib/ui/chat/chat_send_button.dart --defines--> lib/ui/chat/chat_send_button.dart::_CircleButton [EXTRACTED] lib/ui/chat/chat_send_button.dart:117
lib/ui/chat/chat_send_button.dart --defines--> lib/ui/chat/chat_send_button.dart::_SendButton [EXTRACTED] lib/ui/chat/chat_send_button.dart:5
lib/ui/chat/chat_send_button.dart --defines--> lib/ui/chat/chat_send_button.dart::_dictation [EXTRACTED] lib/ui/chat/chat_send_button.dart:104
lib/ui/chat/chat_send_button.dart --defines--> lib/ui/chat/chat_send_button.dart::build [EXTRACTED] lib/ui/chat/chat_send_button.dart:24
lib/ui/chat/chat_send_button.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_send_button.dart:0
lib/ui/chat/chat_send_button.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_send_button.dart:0
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::_BusyBar [EXTRACTED] lib/ui/chat/chat_status.dart:3
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::_InlineError [EXTRACTED] lib/ui/chat/chat_status.dart:20
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::_TypingDots [EXTRACTED] lib/ui/chat/chat_status.dart:81
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::_TypingDotsState [EXTRACTED] lib/ui/chat/chat_status.dart:88
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::_isCancellation [EXTRACTED] lib/ui/chat/chat_status.dart:28
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::build [EXTRACTED] lib/ui/chat/chat_status.dart:8
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::createState [EXTRACTED] lib/ui/chat/chat_status.dart:85
lib/ui/chat/chat_status.dart --defines--> lib/ui/chat/chat_status.dart::dispose [EXTRACTED] lib/ui/chat/chat_status.dart:96
lib/ui/chat/chat_status.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_status.dart:0
lib/ui/chat/chat_status.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIconButton [INFERRED 0.6] lib/ui/chat/chat_status.dart:0
lib/ui/chat/chat_status.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressBar [INFERRED 0.6] lib/ui/chat/chat_status.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/chat/chat_message.dart::_MessageTile [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/chat/chat_status.dart::_BusyBar [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::_BusyBarWidget [EXTRACTED] lib/ui/chat/chat_transcript.dart:4
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::_ChatMessages [EXTRACTED] lib/ui/chat/chat_transcript.dart:26
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::_JumpToLatest [EXTRACTED] lib/ui/chat/chat_transcript.dart:180
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::_LoadOlderButton [EXTRACTED] lib/ui/chat/chat_transcript.dart:248
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::_buildList [EXTRACTED] lib/ui/chat/chat_transcript.dart:59
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::_showsSomething [EXTRACTED] lib/ui/chat/chat_transcript.dart:174
lib/ui/chat/chat_transcript.dart --defines--> lib/ui/chat/chat_transcript.dart::build [EXTRACTED] lib/ui/chat/chat_transcript.dart:8
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/chat/chat_welcome.dart::_Welcome [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressRing [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_transcript.dart --calls--> lib/ui/primitives/primitives_rows_skeleton.dart::OCSkeletonList [INFERRED 0.6] lib/ui/chat/chat_transcript.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/l10n/strings.dart::voiceUtterance [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/chat/chat_message_actions.dart::_SheetRow [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/chat/chat_reply_meta.dart::_ActionBtn [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_HandsFreeButton [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:199
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_HandsFreeSheetRow [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:277
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_LevelDot [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:139
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_LevelDotState [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:149
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_VoiceStrip [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:30
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_VoiceStripState [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:37
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_button [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:213
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::_reportOnce [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:45
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::build [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:68
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::createState [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:34
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::dispose [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:157
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::toggleHandsFree [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:257
lib/ui/chat/chat_voice_strip.dart --defines--> lib/ui/chat/chat_voice_strip.dart::voiceFailureText [EXTRACTED] lib/ui/chat/chat_voice_strip.dart:8
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::ocReduceMotion [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::toggleConversation [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::ackIntro [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_voice_strip.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::clearNotice [INFERRED 0.6] lib/ui/chat/chat_voice_strip.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/models/models/models_server_info.dart::baseName [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/chat/chat_agent_sheets.dart::showAgentSheet [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/chat/chat_agent_sheets.dart::showModelSheet [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/chat/chat_message.dart::SuggestionCard [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/chat/chat_run_progress.dart::isFreeModel [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --defines--> lib/ui/chat/chat_welcome.dart::OutlinedChip [EXTRACTED] lib/ui/chat/chat_welcome.dart:140
lib/ui/chat/chat_welcome.dart --defines--> lib/ui/chat/chat_welcome.dart::_ModelModeChips [EXTRACTED] lib/ui/chat/chat_welcome.dart:105
lib/ui/chat/chat_welcome.dart --defines--> lib/ui/chat/chat_welcome.dart::_ProjectBar [EXTRACTED] lib/ui/chat/chat_welcome.dart:230
lib/ui/chat/chat_welcome.dart --defines--> lib/ui/chat/chat_welcome.dart::_Welcome [EXTRACTED] lib/ui/chat/chat_welcome.dart:7
lib/ui/chat/chat_welcome.dart --defines--> lib/ui/chat/chat_welcome.dart::_showDetails [EXTRACTED] lib/ui/chat/chat_welcome.dart:298
lib/ui/chat/chat_welcome.dart --defines--> lib/ui/chat/chat_welcome.dart::build [EXTRACTED] lib/ui/chat/chat_welcome.dart:22
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/chat/chat_welcome.dart --calls--> lib/ui/widgets/widgets_header_button.dart::InfoRow [INFERRED 0.6] lib/ui/chat/chat_welcome.dart:0
lib/ui/commands_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/commands_page.dart:4
lib/ui/commands_page.dart --calls--> lib/l10n/strings.dart::cmdArgs [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/l10n/strings.dart::cmdUseLabel [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/l10n/strings.dart::cmdUseSkill [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/commands_page.dart:5
lib/ui/commands_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/commands_page.dart:6
lib/ui/commands_page.dart --calls--> lib/state/store/store_ocstore_history.dart::send [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/state/store/store_ocstore_run.dart::runCommand [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/commands_page.dart:7
lib/ui/commands_page.dart --imports--> lib/ui/chat.dart [EXTRACTED] lib/ui/commands_page.dart:8
lib/ui/commands_page.dart --calls--> lib/ui/chat/chat_page.dart::ChatPage [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --defines--> lib/ui/commands_page.dart::CommandsPage [EXTRACTED] lib/ui/commands_page.dart:14
lib/ui/commands_page.dart --defines--> lib/ui/commands_page.dart::SkillsSection [EXTRACTED] lib/ui/commands_page.dart:151
lib/ui/commands_page.dart --defines--> lib/ui/commands_page.dart::_CommandTile [EXTRACTED] lib/ui/commands_page.dart:46
lib/ui/commands_page.dart --defines--> lib/ui/commands_page.dart::build [EXTRACTED] lib/ui/commands_page.dart:18
lib/ui/commands_page.dart --imports--> lib/ui/markdown.dart [EXTRACTED] lib/ui/commands_page.dart:9
lib/ui/commands_page.dart --calls--> lib/ui/markdown/markdown_renderer.dart::Markdown [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/commands_page.dart:10
lib/ui/commands_page.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/commands_page.dart:11
lib/ui/commands_page.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/commands_page.dart:12
lib/ui/commands_page.dart --calls--> lib/ui/widgets/widgets_header_button.dart::InfoRow [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/commands_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::promptText [INFERRED 0.6] lib/ui/commands_page.dart:0
lib/ui/diff_page.dart --imports--> lib/api/client.dart [EXTRACTED] lib/ui/diff_page.dart:3
lib/ui/diff_page.dart --calls--> lib/api/client/client_oc_client_sessions.dart::diff [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/api/client/client_oc_client_workspace.dart::vcsApply [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/api/client/client_oc_client_workspace.dart::vcsDiff [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/api/client/client_oc_client_workspace.dart::vcsStatus [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/diff_page.dart:4
lib/ui/diff_page.dart --calls--> lib/l10n/strings.dart::diffAppliesTo [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/diff_page.dart:5
lib/ui/diff_page.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/models/models/models_session_message.dart::asStr [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/diff_page.dart:6
lib/ui/diff_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/diff_page.dart:7
lib/ui/diff_page.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::DiffPage [EXTRACTED] lib/ui/diff_page.dart:13
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_DiffPageState [EXTRACTED] lib/ui/diff_page.dart:20
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_GitDiffView [EXTRACTED] lib/ui/diff_page.dart:410
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_SessionDiffTile [EXTRACTED] lib/ui/diff_page.dart:207
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_diffOps [EXTRACTED] lib/ui/diff_page.dart:361
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_load [EXTRACTED] lib/ui/diff_page.dart:35
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_split [EXTRACTED] lib/ui/diff_page.dart:357
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_toGitPatch [EXTRACTED] lib/ui/diff_page.dart:407
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::_unifiedPreview [EXTRACTED] lib/ui/diff_page.dart:341
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::build [EXTRACTED] lib/ui/diff_page.dart:82
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::createState [EXTRACTED] lib/ui/diff_page.dart:17
lib/ui/diff_page.dart --defines--> lib/ui/diff_page.dart::initState [EXTRACTED] lib/ui/diff_page.dart:30
lib/ui/diff_page.dart --imports--> lib/ui/parts.dart [EXTRACTED] lib/ui/diff_page.dart:8
lib/ui/diff_page.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::DiffText [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/diff_page.dart:9
lib/ui/diff_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCSegment [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/diff_page.dart:10
lib/ui/diff_page.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/diff_page.dart:11
lib/ui/diff_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/diff_page.dart:0
lib/ui/diff_page.dart --calls--> lib/voice/voice_service/voice_service_core.dart::_split [INFERRED 0.35] lib/ui/diff_page.dart:0
lib/ui/files_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/files_page.dart:3
lib/ui/files_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/files_page.dart:4
lib/ui/files_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/files_page.dart:5
lib/ui/files_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/files_page.dart:6
lib/ui/files_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/files_page.dart:7
lib/ui/files_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/files_page.dart:8
lib/ui/files_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/files_page.dart:9
lib/ui/files_page/files_page_browser.dart --calls--> lib/api/client/client_oc_client_workspace.dart::fileStatus [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/api/client/client_oc_client_workspace.dart::files [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/l10n/strings.dart::filesChangedCount [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/l10n/strings.dart::filesDeleteBody [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/l10n/strings.dart::filesEmptyName [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/l10n/strings.dart::filesExists [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/l10n/strings.dart::filesNameLabel [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/models/models/models_server_info.dart::dirName [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/state/store/store_ocstore_history.dart::send [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/state/store/store_ocstore_workspace.dart::deleteEntry [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/state/store/store_ocstore_workspace.dart::mkdirEntry [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/state/store/store_ocstore_workspace.dart::writeFile [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::FilesPage [EXTRACTED] lib/ui/files_page/files_page_browser.dart:3
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::FilesPageState [EXTRACTED] lib/ui/files_page/files_page_browser.dart:10
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_createMenu [EXTRACTED] lib/ui/files_page/files_page_browser.dart:65
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_load [EXTRACTED] lib/ui/files_page/files_page_browser.dart:142
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_menu [EXTRACTED] lib/ui/files_page/files_page_browser.dart:354
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_newFile [EXTRACTED] lib/ui/files_page/files_page_browser.dart:95
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_newFolder [EXTRACTED] lib/ui/files_page/files_page_browser.dart:126
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_normDir [EXTRACTED] lib/ui/files_page/files_page_browser.dart:41
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_open [EXTRACTED] lib/ui/files_page/files_page_browser.dart:346
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_q [EXTRACTED] lib/ui/files_page/files_page_browser.dart:458
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::_validName [EXTRACTED] lib/ui/files_page/files_page_browser.dart:54
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::build [EXTRACTED] lib/ui/files_page/files_page_browser.dart:180
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::createState [EXTRACTED] lib/ui/files_page/files_page_browser.dart:7
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::dispose [EXTRACTED] lib/ui/files_page/files_page_browser.dart:33
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::initState [EXTRACTED] lib/ui/files_page/files_page_browser.dart:20
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::promptCreate [EXTRACTED] lib/ui/files_page/files_page_browser.dart:30
lib/ui/files_page/files_page_browser.dart --defines--> lib/ui/files_page/files_page_browser.dart::reload [EXTRACTED] lib/ui/files_page/files_page_browser.dart:26
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/files_page/files_page_changed_editor.dart::ChangedFilesPage [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/files_page/files_page_changed_editor.dart::FileEditorPage [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/files_page/files_page_changed_editor.dart::_FileTile [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/files_page/files_page_changed_editor.dart::_pillBorder [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::promptText [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_browser.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/files_page/files_page_browser.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/api/client/client_oc_client_workspace.dart::fileStatus [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/api/client/client_oc_client_workspace.dart::readFile [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/models/models/models_server_info.dart::baseName [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/state/store/store_ocstore_workspace.dart::writeFile [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::ChangedFilesPage [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:13
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::FileEditorPage [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:141
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::_FileEditorPageState [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:149
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::_FileTile [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:63
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::_icon [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:113
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::_load [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:171
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::_pillBorder [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:5
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::_save [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:195
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::build [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:17
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::createState [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:146
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::dispose [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:164
lib/ui/files_page/files_page_changed_editor.dart --defines--> lib/ui/files_page/files_page_changed_editor.dart::initState [EXTRACTED] lib/ui/files_page/files_page_changed_editor.dart:158
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/files_page/files_page_changed_editor.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/files_page/files_page_changed_editor.dart:0
lib/ui/home.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/home.dart:5
lib/ui/home.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/home.dart:6
lib/ui/home.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/home.dart:7
lib/ui/home.dart --imports--> lib/ui/about_page.dart [EXTRACTED] lib/ui/home.dart:9
lib/ui/home.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/home.dart:8
lib/ui/home.dart --imports--> lib/ui/chat.dart [EXTRACTED] lib/ui/home.dart:10
lib/ui/home.dart --imports--> lib/ui/commands_page.dart [EXTRACTED] lib/ui/home.dart:11
lib/ui/home.dart --imports--> lib/ui/diff_page.dart [EXTRACTED] lib/ui/home.dart:12
lib/ui/home.dart --imports--> lib/ui/files_page.dart [EXTRACTED] lib/ui/home.dart:13
lib/ui/home.dart --imports--> lib/ui/line_icons.dart [EXTRACTED] lib/ui/home.dart:14
lib/ui/home.dart --imports--> lib/ui/models_page.dart [EXTRACTED] lib/ui/home.dart:15
lib/ui/home.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/home.dart:16
lib/ui/home.dart --imports--> lib/ui/prompts.dart [EXTRACTED] lib/ui/home.dart:17
lib/ui/home.dart --imports--> lib/ui/sessions_page.dart [EXTRACTED] lib/ui/home.dart:18
lib/ui/home.dart --imports--> lib/ui/settings_page.dart [EXTRACTED] lib/ui/home.dart:19
lib/ui/home.dart --imports--> lib/ui/terminal_page.dart [EXTRACTED] lib/ui/home.dart:20
lib/ui/home.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/home.dart:21
lib/ui/home.dart --imports--> lib/ui/todos_page.dart [EXTRACTED] lib/ui/home.dart:22
lib/ui/home.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/home.dart:23
lib/ui/home/home_avatar_drawer.dart --calls--> lib/api/events.dart::stop [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/l10n/strings.dart::drawerPending [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/l10n/strings.dart::menuWaitingForYou [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/l10n/strings.dart::promptSemantics [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::_AvatarButton [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:5
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::_AvatarButtonState [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:18
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::_Drawer [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:213
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::_DrawerBadge [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:178
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::_PromptCountBadge [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:128
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::_startPulse [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:35
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::build [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:63
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::createState [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:15
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::didUpdateWidget [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:44
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::dispose [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:56
lib/ui/home/home_avatar_drawer.dart --defines--> lib/ui/home/home_avatar_drawer.dart::initState [EXTRACTED] lib/ui/home/home_avatar_drawer.dart:28
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/home/home_drawer_rows.dart::_DrawerFooter [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/home/home_drawer_rows.dart::_DrawerIconButton [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/home/home_drawer_rows.dart::_DrawerNavRow [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/home/home_drawer_rows.dart::_DrawerRecentRow [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/home/home_shell.dart::_worktree [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_avatar_drawer.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/home/home_avatar_drawer.dart:0
lib/ui/home/home_drawer_rows.dart --calls--> lib/l10n/strings.dart::drawerConnectedTo [INFERRED 0.6] lib/ui/home/home_drawer_rows.dart:0
lib/ui/home/home_drawer_rows.dart --calls--> lib/models/models/models_server_info.dart::baseName [INFERRED 0.6] lib/ui/home/home_drawer_rows.dart:0
lib/ui/home/home_drawer_rows.dart --calls--> lib/models/models/models_server_info.dart::fmtAge [INFERRED 0.6] lib/ui/home/home_drawer_rows.dart:0
lib/ui/home/home_drawer_rows.dart --calls--> lib/ui/home/home_avatar_drawer.dart::_DrawerBadge [INFERRED 0.6] lib/ui/home/home_drawer_rows.dart:0
lib/ui/home/home_drawer_rows.dart --defines--> lib/ui/home/home_drawer_rows.dart::_DrawerFooter [EXTRACTED] lib/ui/home/home_drawer_rows.dart:170
lib/ui/home/home_drawer_rows.dart --defines--> lib/ui/home/home_drawer_rows.dart::_DrawerIconButton [EXTRACTED] lib/ui/home/home_drawer_rows.dart:320
lib/ui/home/home_drawer_rows.dart --defines--> lib/ui/home/home_drawer_rows.dart::_DrawerNavRow [EXTRACTED] lib/ui/home/home_drawer_rows.dart:5
lib/ui/home/home_drawer_rows.dart --defines--> lib/ui/home/home_drawer_rows.dart::_DrawerRecentRow [EXTRACTED] lib/ui/home/home_drawer_rows.dart:83
lib/ui/home/home_drawer_rows.dart --defines--> lib/ui/home/home_drawer_rows.dart::build [EXTRACTED] lib/ui/home/home_drawer_rows.dart:23
lib/ui/home/home_drawer_rows.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/home/home_drawer_rows.dart:0
lib/ui/home/home_drawer_rows.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCAvatar [INFERRED 0.6] lib/ui/home/home_drawer_rows.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/l10n/strings.dart::label [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/l10n/strings.dart::menuServerVersion [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/l10n/strings.dart::menuWaitingForYou [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/ui/about_page.dart::AboutPage [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/ui/chat/chat_agent_sheets.dart::_SheetOption [INFERRED 0.35] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/ui/home/home_drawer_rows.dart::_DrawerIconButton [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --defines--> lib/ui/home/home_server_menu.dart::_MenuRow [EXTRACTED] lib/ui/home/home_server_menu.dart:234
lib/ui/home/home_server_menu.dart --defines--> lib/ui/home/home_server_menu.dart::_ServerMenu [EXTRACTED] lib/ui/home/home_server_menu.dart:8
lib/ui/home/home_server_menu.dart --defines--> lib/ui/home/home_server_menu.dart::_ServerMenuHeader [EXTRACTED] lib/ui/home/home_server_menu.dart:122
lib/ui/home/home_server_menu.dart --defines--> lib/ui/home/home_server_menu.dart::_SheetGroup [EXTRACTED] lib/ui/home/home_server_menu.dart:390
lib/ui/home/home_server_menu.dart --defines--> lib/ui/home/home_server_menu.dart::_SheetOption [EXTRACTED] lib/ui/home/home_server_menu.dart:329
lib/ui/home/home_server_menu.dart --defines--> lib/ui/home/home_server_menu.dart::build [EXTRACTED] lib/ui/home/home_server_menu.dart:34
lib/ui/home/home_server_menu.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCAvatar [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_server_menu.dart --calls--> lib/ui/settings_page/settings_page_body.dart::SettingsPage [INFERRED 0.6] lib/ui/home/home_server_menu.dart:0
lib/ui/home/home_shell.dart --calls--> lib/api/client/client_oc_client_sessions.dart::renameSession [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/api/client/client_oc_client_workspace.dart::toolIds [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/l10n/strings.dart::moreToolsCount [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/state/store/store_ocstore_connection.dart::setAgent [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/state/store/store_ocstore_connection.dart::toggleTool [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/state/store/store_ocstore_sessions.dart::newSession [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/state/store/store_ocstore_sessions.dart::openSession [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/state/store/store_ocstore_sessions.dart::renameSession [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/about_page.dart::AboutPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/chat/chat_agent_sheets.dart::_SheetOption [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/chat/chat_page.dart::ChatPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/commands_page.dart::CommandsPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/diff_page.dart::DiffPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/files_page/files_page_browser.dart::FilesPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/files_page/files_page_browser.dart::promptCreate [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/files_page/files_page_browser.dart::reload [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/home/home_avatar_drawer.dart::_AvatarButton [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/home/home_avatar_drawer.dart::_Drawer [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/home/home_server_menu.dart::_ServerMenu [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/home/home_server_menu.dart::_SheetGroup [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/home/home_server_menu.dart::_SheetOption [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::Function [EXTRACTED] lib/ui/home/home_shell.dart:57
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::HomeShell [EXTRACTED] lib/ui/home/home_shell.dart:17
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::HomeShellState [EXTRACTED] lib/ui/home/home_shell.dart:24
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_Tab [EXTRACTED] lib/ui/home/home_shell.dart:4
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_body [EXTRACTED] lib/ui/home/home_shell.dart:355
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_clearTerminal [EXTRACTED] lib/ui/home/home_shell.dart:242
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_createFileOrFolder [EXTRACTED] lib/ui/home/home_shell.dart:239
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_focusHistorySearch [EXTRACTED] lib/ui/home/home_shell.dart:234
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_headerActions [EXTRACTED] lib/ui/home/home_shell.dart:146
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_hostLabel [EXTRACTED] lib/ui/home/home_shell.dart:347
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_navigate [EXTRACTED] lib/ui/home/home_shell.dart:51
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_newTerminalSession [EXTRACTED] lib/ui/home/home_shell.dart:245
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_openSessionScreen [EXTRACTED] lib/ui/home/home_shell.dart:604
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_pickAgent [EXTRACTED] lib/ui/home/home_shell.dart:496
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_pickTools [EXTRACTED] lib/ui/home/home_shell.dart:540
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_pushAndClose [EXTRACTED] lib/ui/home/home_shell.dart:56
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_reloadFiles [EXTRACTED] lib/ui/home/home_shell.dart:237
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_renameSession [EXTRACTED] lib/ui/home/home_shell.dart:637
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_showAvatarMenu [EXTRACTED] lib/ui/home/home_shell.dart:316
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_showDrawer [EXTRACTED] lib/ui/home/home_shell.dart:250
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_showMoreSheet [EXTRACTED] lib/ui/home/home_shell.dart:379
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_todosActions [EXTRACTED] lib/ui/home/home_shell.dart:68
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::_worktree [EXTRACTED] lib/ui/home/home_shell.dart:77
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::build [EXTRACTED] lib/ui/home/home_shell.dart:83
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::createState [EXTRACTED] lib/ui/home/home_shell.dart:21
lib/ui/home/home_shell.dart --defines--> lib/ui/home/home_shell.dart::goTo [EXTRACTED] lib/ui/home/home_shell.dart:47
lib/ui/home/home_shell.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIconButton [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/models_page.dart::ModelsPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/prompts/prompts_permission.dart::showPendingPrompt [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/sessions_page/sessions_page_main.dart::SessionsPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/sessions_page/sessions_page_main.dart::focusSearch [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/sessions_page/sessions_page_main.dart::visibleSessions [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/settings_page/settings_page_body.dart::SettingsPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/terminal_page.dart::TerminalPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/terminal_page.dart::newSession [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/todos_page.dart::TodosPage [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::AppHeader [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::HeaderAction [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::StatusPill [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::ocLinkState [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::ConnectionErrorView [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::promptText [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::pushScreen [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/home/home_shell.dart:0
lib/ui/home/home_shell.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/home/home_shell.dart:0
lib/ui/line_icons.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/line_icons.dart:19
lib/ui/line_icons/line_icons_painter.dart --calls--> lib/ui/chat/chat_run_progress.dart::paint [INFERRED 0.35] lib/ui/line_icons/line_icons_painter.dart:0
lib/ui/line_icons/line_icons_painter.dart --calls--> lib/ui/chat/chat_run_progress.dart::shouldRepaint [INFERRED 0.35] lib/ui/line_icons/line_icons_painter.dart:0
lib/ui/line_icons/line_icons_painter.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/ui/line_icons/line_icons_painter.dart:0
lib/ui/line_icons/line_icons_painter.dart --defines--> lib/ui/line_icons/line_icons_painter.dart::LLinePainter [EXTRACTED] lib/ui/line_icons/line_icons_painter.dart:3
lib/ui/line_icons/line_icons_painter.dart --defines--> lib/ui/line_icons/line_icons_painter.dart::_draw [EXTRACTED] lib/ui/line_icons/line_icons_painter.dart:44
lib/ui/line_icons/line_icons_painter.dart --defines--> lib/ui/line_icons/line_icons_painter.dart::_path [EXTRACTED] lib/ui/line_icons/line_icons_painter.dart:38
lib/ui/line_icons/line_icons_painter.dart --defines--> lib/ui/line_icons/line_icons_painter.dart::paint [EXTRACTED] lib/ui/line_icons/line_icons_painter.dart:17
lib/ui/line_icons/line_icons_painter.dart --defines--> lib/ui/line_icons/line_icons_painter.dart::shouldRepaint [EXTRACTED] lib/ui/line_icons/line_icons_painter.dart:932
lib/ui/line_icons/line_icons_painter.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::paint [INFERRED 0.35] lib/ui/line_icons/line_icons_painter.dart:0
lib/ui/line_icons/line_icons_painter.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::shouldRepaint [INFERRED 0.35] lib/ui/line_icons/line_icons_painter.dart:0
lib/ui/line_icons/line_icons_widgets.dart --calls--> lib/ui/line_icons/line_icons_painter.dart::LLinePainter [INFERRED 0.6] lib/ui/line_icons/line_icons_widgets.dart:0
lib/ui/line_icons/line_icons_widgets.dart --defines--> lib/ui/line_icons/line_icons_widgets.dart::LI [EXTRACTED] lib/ui/line_icons/line_icons_widgets.dart:4
lib/ui/line_icons/line_icons_widgets.dart --defines--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [EXTRACTED] lib/ui/line_icons/line_icons_widgets.dart:158
lib/ui/line_icons/line_icons_widgets.dart --defines--> lib/ui/line_icons/line_icons_widgets.dart::LIconButton [EXTRACTED] lib/ui/line_icons/line_icons_widgets.dart:196
lib/ui/line_icons/line_icons_widgets.dart --defines--> lib/ui/line_icons/line_icons_widgets.dart::build [EXTRACTED] lib/ui/line_icons/line_icons_widgets.dart:173
lib/ui/markdown.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/markdown.dart:16
lib/ui/markdown.dart --imports--> lib/ui/line_icons.dart [EXTRACTED] lib/ui/markdown.dart:18
lib/ui/markdown.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/markdown.dart:17
lib/ui/markdown/markdown_code_block.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/markdown/markdown_code_block.dart:0
lib/ui/markdown/markdown_code_block.dart --defines--> lib/ui/markdown/markdown_code_block.dart::_CodeBlock [EXTRACTED] lib/ui/markdown/markdown_code_block.dart:122
lib/ui/markdown/markdown_code_block.dart --defines--> lib/ui/markdown/markdown_code_block.dart::_parse [EXTRACTED] lib/ui/markdown/markdown_code_block.dart:3
lib/ui/markdown/markdown_code_block.dart --defines--> lib/ui/markdown/markdown_code_block.dart::build [EXTRACTED] lib/ui/markdown/markdown_code_block.dart:127
lib/ui/markdown/markdown_code_block.dart --defines--> lib/ui/markdown/markdown_code_block.dart::flushPara [EXTRACTED] lib/ui/markdown/markdown_code_block.dart:9
lib/ui/markdown/markdown_code_block.dart --calls--> lib/ui/markdown/markdown_renderer.dart::_Block [INFERRED 0.6] lib/ui/markdown/markdown_code_block.dart:0
lib/ui/markdown/markdown_code_block.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/ui/markdown/markdown_code_block.dart:0
lib/ui/markdown/markdown_code_block.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/markdown/markdown_code_block.dart:0
lib/ui/markdown/markdown_renderer.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/ui/markdown/markdown_renderer.dart:0
lib/ui/markdown/markdown_renderer.dart --calls--> lib/ui/markdown/markdown_code_block.dart::_CodeBlock [INFERRED 0.6] lib/ui/markdown/markdown_renderer.dart:0
lib/ui/markdown/markdown_renderer.dart --calls--> lib/ui/markdown/markdown_code_block.dart::_parse [INFERRED 0.6] lib/ui/markdown/markdown_renderer.dart:0
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::Markdown [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:3
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_Block [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:345
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_Kind [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:343
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_buildBlock [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:35
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_bulletMarker [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:132
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_codeStyle [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:323
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_firstFrom [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:218
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_inlineSpans [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:223
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_linkSpan [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:300
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_listBlock [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:98
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_makeSpan [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:267
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_paragraph [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:88
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_parseCached [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:373
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_rich [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:195
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::_table [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:137
lib/ui/markdown/markdown_renderer.dart --defines--> lib/ui/markdown/markdown_renderer.dart::build [EXTRACTED] lib/ui/markdown/markdown_renderer.dart:17
lib/ui/markdown/markdown_renderer.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/markdown/markdown_renderer.dart:0
lib/ui/models_page.dart --imports--> lib/api/client.dart [EXTRACTED] lib/ui/models_page.dart:3
lib/ui/models_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/models_page.dart:4
lib/ui/models_page.dart --calls--> lib/l10n/strings.dart::modelsContext [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --calls--> lib/l10n/strings.dart::modelsSelected [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/models_page.dart:5
lib/ui/models_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/models_page.dart:6
lib/ui/models_page.dart --calls--> lib/state/store/store_ocstore_connection.dart::refreshCatalog [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --calls--> lib/state/store/store_ocstore_connection.dart::setAgent [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --calls--> lib/state/store/store_ocstore_connection.dart::setModel [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/models_page.dart:7
lib/ui/models_page.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/models_page.dart:0
lib/ui/models_page.dart --imports--> lib/ui/chat.dart [EXTRACTED] lib/ui/models_page.dart:8
lib/ui/models_page.dart --calls--> lib/ui/chat/chat_run_progress.dart::isFreeModel [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::ModelsPage [EXTRACTED] lib/ui/models_page.dart:13
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::_AgentDropdown [EXTRACTED] lib/ui/models_page.dart:245
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::_ModelTag [EXTRACTED] lib/ui/models_page.dart:408
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::_ModelsPageState [EXTRACTED] lib/ui/models_page.dart:20
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::_ProviderBlock [EXTRACTED] lib/ui/models_page.dart:278
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::build [EXTRACTED] lib/ui/models_page.dart:40
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::createState [EXTRACTED] lib/ui/models_page.dart:17
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::dispose [EXTRACTED] lib/ui/models_page.dart:34
lib/ui/models_page.dart --defines--> lib/ui/models_page.dart::initState [EXTRACTED] lib/ui/models_page.dart:26
lib/ui/models_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/models_page.dart:9
lib/ui/models_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/models_page.dart:10
lib/ui/models_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/models_page.dart:11
lib/ui/models_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/models_page.dart:0
lib/ui/models_page.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/models_page.dart:0
lib/ui/parts.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/parts.dart:1
lib/ui/parts.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/parts.dart:10
lib/ui/parts.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/parts.dart:11
lib/ui/parts.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/parts.dart:12
lib/ui/parts.dart --imports--> lib/ui/line_icons.dart [EXTRACTED] lib/ui/parts.dart:13
lib/ui/parts.dart --imports--> lib/ui/markdown.dart [EXTRACTED] lib/ui/parts.dart:14
lib/ui/parts.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/parts.dart:15
lib/ui/parts.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/parts.dart:16
lib/ui/parts.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/parts.dart:17
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/l10n/strings.dart::partsAgent [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/l10n/strings.dart::partsThoughtFor [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/models/models/models_server_info.dart::baseName [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/models/models/models_session_message.dart::asInt [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/models/models/models_session_message.dart::asMap [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::DiffText [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:133
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::ThinkingGroup [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:185
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::_AgentPart [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:47
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::_FilePart [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:3
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::_RetryPart [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:69
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::_UnknownPart [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:101
lib/ui/parts/parts_file_agent_diff.dart --defines--> lib/ui/parts/parts_file_agent_diff.dart::build [EXTRACTED] lib/ui/parts/parts_file_agent_diff.dart:8
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/parts/parts_tool_tile.dart::_Collapsible [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/theme/theme_radius_typography.dart::monoSmall [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_file_agent_diff.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/parts/parts_file_agent_diff.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/models/models/models_server_info.dart::fmtDuration [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/state/store/store_ocstore_workspace.dart::enableExternalDirectoryAccess [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::ToolTile [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:183
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_Collapsible [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:3
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_CollapsibleState [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:26
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_InputBlock [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:233
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_OutputBlock [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:302
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_OutputBlockState [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:311
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_buildCompact [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:31
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_isExternalPermissionError [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:266
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::_pretty [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:255
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::build [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:86
lib/ui/parts/parts_tool_tile.dart --defines--> lib/ui/parts/parts_tool_tile.dart::createState [EXTRACTED] lib/ui/parts/parts_tool_tile.dart:23
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_pretty [INFERRED 0.35] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/theme/theme_radius_typography.dart::monoSmall [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/widgets/widgets_header_button.dart::toolColor [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/widgets/widgets_header_button.dart::toolIcon [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_tile.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/parts/parts_tool_tile.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/models/models/models_server_info.dart::fmtDuration [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/markdown/markdown_renderer.dart::Markdown [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::DiffText [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::ThinkingGroup [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::_AgentPart [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::_FilePart [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::_RetryPart [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_file_agent_diff.dart::_UnknownPart [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_tool_tile.dart::ToolTile [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_tool_tile.dart::_Collapsible [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_tool_tile.dart::_InputBlock [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/parts/parts_tool_tile.dart::_OutputBlock [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::PartTile [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:222
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::ToolTimeline [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:10
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::_ToolTimelineState [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:18
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::_buildStep [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:82
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::_firstLine [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:323
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::build [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:23
lib/ui/parts/parts_tool_timeline.dart --defines--> lib/ui/parts/parts_tool_timeline.dart::createState [EXTRACTED] lib/ui/parts/parts_tool_timeline.dart:15
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/parts/parts_tool_timeline.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::Mono [INFERRED 0.6] lib/ui/parts/parts_tool_timeline.dart:0
lib/ui/primitives.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/primitives.dart:17
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::OCAccent [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:6
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:94
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::OCButtonVariant [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:66
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::OCCard [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:352
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::OCCardVariant [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:340
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::_OCButtonState [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:124
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::at [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:59
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::build [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:267
lib/ui/primitives/primitives_buttons_cards.dart --defines--> lib/ui/primitives/primitives_buttons_cards.dart::createState [EXTRACTED] lib/ui/primitives/primitives_buttons_cards.dart:121
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCAvatar [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:137
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCAvatarStack [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:222
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:58
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCInnerCell [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:5
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCSegment [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:406
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCSegmentedControl [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:368
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCStatus [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:132
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::OCToggle [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:295
lib/ui/primitives/primitives_cells_controls.dart --defines--> lib/ui/primitives/primitives_cells_controls.dart::build [EXTRACTED] lib/ui/primitives/primitives_cells_controls.dart:29
lib/ui/primitives/primitives_cells_controls.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::_SegmentItem [INFERRED 0.6] lib/ui/primitives/primitives_cells_controls.dart:0
lib/ui/primitives/primitives_progress_chip.dart --calls--> lib/ui/chat/chat_run_progress.dart::paint [INFERRED 0.35] lib/ui/primitives/primitives_progress_chip.dart:0
lib/ui/primitives/primitives_progress_chip.dart --calls--> lib/ui/chat/chat_run_progress.dart::shouldRepaint [INFERRED 0.35] lib/ui/primitives/primitives_progress_chip.dart:0
lib/ui/primitives/primitives_progress_chip.dart --calls--> lib/ui/line_icons/line_icons_painter.dart::paint [INFERRED 0.35] lib/ui/primitives/primitives_progress_chip.dart:0
lib/ui/primitives/primitives_progress_chip.dart --calls--> lib/ui/line_icons/line_icons_painter.dart::shouldRepaint [INFERRED 0.35] lib/ui/primitives/primitives_progress_chip.dart:0
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::OCChip [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:248
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressBar [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:75
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressRing [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:127
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::_RingPainter [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:192
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::_SegmentItem [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:3
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::build [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:17
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::paint [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:206
lib/ui/primitives/primitives_progress_chip.dart --defines--> lib/ui/primitives/primitives_progress_chip.dart::shouldRepaint [EXTRACTED] lib/ui/primitives/primitives_progress_chip.dart:234
lib/ui/primitives/primitives_rows_skeleton.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/primitives/primitives_rows_skeleton.dart:0
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::OCBreadcrumbs [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:136
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::OCFilterButton [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:246
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::OCListRow [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:10
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::OCSkeleton [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:306
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::OCSkeletonList [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:354
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::_OCSkeletonState [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:322
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::build [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:55
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::createState [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:319
lib/ui/primitives/primitives_rows_skeleton.dart --defines--> lib/ui/primitives/primitives_rows_skeleton.dart::dispose [EXTRACTED] lib/ui/primitives/primitives_rows_skeleton.dart:330
lib/ui/prompts.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/prompts.dart:4
lib/ui/prompts.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/prompts.dart:5
lib/ui/prompts.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/prompts.dart:6
lib/ui/prompts.dart --imports--> lib/ui/line_icons.dart [EXTRACTED] lib/ui/prompts.dart:7
lib/ui/prompts.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/prompts.dart:8
lib/ui/prompts.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/prompts.dart:9
lib/ui/prompts.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/prompts.dart:10
lib/ui/prompts/prompts_permission.dart --calls--> lib/l10n/strings.dart::permMorePending [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/l10n/strings.dart::permSuggestingRules [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/state/store/store_ocstore_prompts.dart::answerPermission [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/state/store/store_ocstore_view_state.dart::openPromptSheet [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCCard [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::PromptOverlay [EXTRACTED] lib/ui/prompts/prompts_permission.dart:11
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::_CommandBox [EXTRACTED] lib/ui/prompts/prompts_permission.dart:74
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::_CommandBoxState [EXTRACTED] lib/ui/prompts/prompts_permission.dart:82
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::_PermissionCard [EXTRACTED] lib/ui/prompts/prompts_permission.dart:245
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::_PermissionFacts [EXTRACTED] lib/ui/prompts/prompts_permission.dart:162
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::build [EXTRACTED] lib/ui/prompts/prompts_permission.dart:15
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::createState [EXTRACTED] lib/ui/prompts/prompts_permission.dart:79
lib/ui/prompts/prompts_permission.dart --defines--> lib/ui/prompts/prompts_permission.dart::showPendingPrompt [EXTRACTED] lib/ui/prompts/prompts_permission.dart:59
lib/ui/prompts/prompts_permission.dart --calls--> lib/ui/prompts/prompts_question.dart::_QuestionCard [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/ui/prompts/prompts_question.dart::_SessionLine [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_permission.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/prompts/prompts_permission.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/api/client/client_oc_client_workspace.dart::answerQuestion [INFERRED 0.35] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/api/client/client_oc_client_workspace.dart::rejectQuestion [INFERRED 0.35] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/l10n/strings.dart::permMorePending [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/l10n/strings.dart::promptInSession [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/l10n/strings.dart::promptOtherSession [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/state/store/store_ocstore_prompts.dart::answerQuestion [INFERRED 0.35] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/state/store/store_ocstore_prompts.dart::rejectQuestion [INFERRED 0.35] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/state/store/store_ocstore_view_state.dart::sessionLabel [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCCard [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::ShareCard [EXTRACTED] lib/ui/prompts/prompts_question.dart:313
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::_QuestionCard [EXTRACTED] lib/ui/prompts/prompts_question.dart:3
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::_QuestionCardState [EXTRACTED] lib/ui/prompts/prompts_question.dart:11
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::_SessionLine [EXTRACTED] lib/ui/prompts/prompts_question.dart:264
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::_question [EXTRACTED] lib/ui/prompts/prompts_question.dart:126
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::_toggle [EXTRACTED] lib/ui/prompts/prompts_question.dart:25
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::build [EXTRACTED] lib/ui/prompts/prompts_question.dart:41
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::createState [EXTRACTED] lib/ui/prompts/prompts_question.dart:8
lib/ui/prompts/prompts_question.dart --defines--> lib/ui/prompts/prompts_question.dart::dispose [EXTRACTED] lib/ui/prompts/prompts_question.dart:18
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/prompts/prompts_question.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/prompts/prompts_question.dart:0
lib/ui/sessions_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/sessions_page.dart:4
lib/ui/sessions_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/sessions_page.dart:5
lib/ui/sessions_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/sessions_page.dart:6
lib/ui/sessions_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/sessions_page.dart:7
lib/ui/sessions_page.dart --imports--> lib/ui/chat.dart [EXTRACTED] lib/ui/sessions_page.dart:8
lib/ui/sessions_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/sessions_page.dart:9
lib/ui/sessions_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/sessions_page.dart:10
lib/ui/sessions_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/sessions_page.dart:11
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/l10n/strings.dart::sessionsCount [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/l10n/strings.dart::sessionsCountOne [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/state/store/store_ocstore_sessions.dart::newSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/chat/chat_page.dart::ChatPage [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCSegment [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/primitives/primitives_rows_skeleton.dart::OCSkeletonList [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::SessionsPage [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:3
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::SessionsPageState [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:10
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_BrokenSessionRow [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:366
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_GuardedSessionTile [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:329
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_GuardedSessionTileState [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:338
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_SessionsHeader [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:63
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_SessionsList [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:188
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_SessionsListState [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:197
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_popTileErrorGuard [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:311
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::_pushTileErrorGuard [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:299
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::build [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:40
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::clearSearch [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:24
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::createState [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:7
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::dispose [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:31
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::focusSearch [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:22
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::initState [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:340
lib/ui/sessions_page/sessions_page_main.dart --defines--> lib/ui/sessions_page/sessions_page_main.dart::visibleSessions [EXTRACTED] lib/ui/sessions_page/sessions_page_main.dart:167
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/sessions_page/sessions_page_tiles.dart::_GroupedSessionList [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/sessions_page/sessions_page_tiles.dart::_SessionTile [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/terminal_page.dart::newSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_main.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/sessions_page/sessions_page_main.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/api/client/client_oc_client_sessions.dart::childSessions [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/api/client/client_oc_client_sessions.dart::deleteSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/api/client/client_oc_client_sessions.dart::renameSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/l10n/strings.dart::forkCreated [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/l10n/strings.dart::historyFiles [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/l10n/strings.dart::sessionsDeleteBody [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/models/models/models_server_info.dart::fmtAge [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::deleteSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::forkSession [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::newSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::openSession [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::renameSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::shareSession [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/state/store/store_ocstore_sessions.dart::unshareSession [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/chat/chat_page.dart::ChatPage [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressRing [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/primitives/primitives_rows_skeleton.dart::OCListRow [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/sessions_page/sessions_page_main.dart::_GuardedSessionTile [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_GroupHeaderDelegate [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:339
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_GroupedSessionList [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:278
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_Row [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:329
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_SessionTile [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:3
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_bucket [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:317
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_showActions [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:119
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::_showChildren [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:214
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::build [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:13
lib/ui/sessions_page/sessions_page_tiles.dart --defines--> lib/ui/sessions_page/sessions_page_tiles.dart::shouldRebuild [EXTRACTED] lib/ui/sessions_page/sessions_page_tiles.dart:371
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/terminal_page.dart::newSession [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::promptText [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showUndoSnack [INFERRED 0.6] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/sessions_page/sessions_page_tiles.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/sessions_page/sessions_page_tiles.dart:0
lib/ui/settings_page.dart --imports--> lib/api/client.dart [EXTRACTED] lib/ui/settings_page.dart:6
lib/ui/settings_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/settings_page.dart:7
lib/ui/settings_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/settings_page.dart:8
lib/ui/settings_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/settings_page.dart:9
lib/ui/settings_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/settings_page.dart:12
lib/ui/settings_page.dart --imports--> lib/ui/chat.dart [EXTRACTED] lib/ui/settings_page.dart:13
lib/ui/settings_page.dart --imports--> lib/ui/commands_page.dart [EXTRACTED] lib/ui/settings_page.dart:14
lib/ui/settings_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/settings_page.dart:15
lib/ui/settings_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/settings_page.dart:16
lib/ui/settings_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/settings_page.dart:17
lib/ui/settings_page.dart --imports--> lib/voice/voice_scope.dart [EXTRACTED] lib/ui/settings_page.dart:10
lib/ui/settings_page.dart --imports--> lib/voice/voice_service.dart [EXTRACTED] lib/ui/settings_page.dart:11
lib/ui/settings_page/settings_page_body.dart --calls--> lib/api/client/client_oc_client_server.dart::disposeInstance [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/api/client/client_oc_client_server.dart::patchConfig [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/api/client/client_oc_client_server.dart::upgrade [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/api/client/client_oc_client_sessions.dart::revert [INFERRED 0.35] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/api/client/client_oc_client_workspace.dart::mcpConnect [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/api/client/client_oc_client_workspace.dart::mcpDisconnect [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/l10n/strings.dart::setMcpLabel [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/l10n/strings.dart::setMcpServers [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/l10n/strings.dart::setPassword [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/l10n/strings.dart::setPermExternalTitle [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/l10n/strings.dart::termuxSetupNote [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_connection.dart::connect [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_connection.dart::refreshCatalog [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_connection.dart::refreshServerInfo [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_connection.dart::setServer [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_run.dart::revert [INFERRED 0.35] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_workspace.dart::addMcp [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/state/store/store_ocstore_workspace.dart::refreshConfig [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/commands_page.dart::SkillsSection [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCSegment [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::SettingsPage [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:3
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::_SettingsPageState [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:10
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::_addMcp [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:430
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::_editServer [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:367
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::build [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:18
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::createState [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:7
lib/ui/settings_page/settings_page_body.dart --defines--> lib/ui/settings_page/settings_page_body.dart::initState [EXTRACTED] lib/ui/settings_page/settings_page_body.dart:12
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_ConfigEditor [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_Group [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_GroupDivider [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_Providers [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_StatusRow [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_sections.dart::_VoiceSettings [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/settings_page/settings_page_voice_tiles.dart::_ActionTile [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/widgets/widgets_header_button.dart::InfoRow [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_body.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/settings_page/settings_page_body.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/api/client/client_oc_client_server.dart::removeAuth [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/api/client/client_oc_client_server.dart::setApiKey [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/l10n/strings.dart::configInvalidJsonError [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/l10n/strings.dart::modelsCount [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/state/store/store_ocstore_connection.dart::refreshCatalog [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/state/store/store_ocstore_workspace.dart::saveConfig [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/parts/parts_tool_tile.dart::_pretty [INFERRED 0.35] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_ConfigEditor [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:170
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_ConfigEditorState [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:178
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_Group [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:14
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_GroupDivider [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:50
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_Providers [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:59
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_StatusRow [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:259
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_VoiceSettings [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:287
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_addKey [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:131
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::_pretty [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:183
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::build [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:19
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::createState [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:175
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::didUpdateWidget [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:193
lib/ui/settings_page/settings_page_sections.dart --defines--> lib/ui/settings_page/settings_page_sections.dart::dispose [EXTRACTED] lib/ui/settings_page/settings_page_sections.dart:199
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/settings_page/settings_page_voice_tiles.dart::_ActionTile [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceEngineTile [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceLanguageTile [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceMicTile [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceRateTile [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showToast [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_sections.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::testVoice [INFERRED 0.6] lib/ui/settings_page/settings_page_sections.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/ui/chat/chat_voice_strip.dart::voiceFailureText [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_ActionTile [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:333
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_RateStep [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:203
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceEngineTile [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:302
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceLanguageTile [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:7
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceLanguageTileState [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:16
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceMicTile [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:253
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_VoiceRateTile [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:133
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_load [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:26
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::_pick [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:86
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::build [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:36
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::createState [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:13
lib/ui/settings_page/settings_page_voice_tiles.dart --defines--> lib/ui/settings_page/settings_page_voice_tiles.dart::initState [EXTRACTED] lib/ui/settings_page/settings_page_voice_tiles.dart:21
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::showToast [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::stopDictation [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::toggleDictation [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::setLanguage [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::setRate [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/voice/voice_service/voice_service_state.dart::locales [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/settings_page/settings_page_voice_tiles.dart --calls--> lib/voice/voice_service/voice_service_state.dart::openMicrophoneSettings [INFERRED 0.6] lib/ui/settings_page/settings_page_voice_tiles.dart:0
lib/ui/terminal_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/terminal_page.dart:4
lib/ui/terminal_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/terminal_page.dart:5
lib/ui/terminal_page.dart --calls--> lib/state/store/store_ocstore_sessions.dart::newSession [INFERRED 0.35] lib/ui/terminal_page.dart:0
lib/ui/terminal_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/terminal_page.dart:6
lib/ui/terminal_page.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/terminal_page.dart:0
lib/ui/terminal_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/terminal_page.dart:7
lib/ui/terminal_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/terminal_page.dart:0
lib/ui/terminal_page.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressBar [INFERRED 0.6] lib/ui/terminal_page.dart:0
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::TerminalPage [EXTRACTED] lib/ui/terminal_page.dart:10
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::TerminalPageState [EXTRACTED] lib/ui/terminal_page.dart:17
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::_append [EXTRACTED] lib/ui/terminal_page.dart:65
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::_run [EXTRACTED] lib/ui/terminal_page.dart:73
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::_terminalStyle [EXTRACTED] lib/ui/terminal_page.dart:302
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::build [EXTRACTED] lib/ui/terminal_page.dart:99
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::clear [EXTRACTED] lib/ui/terminal_page.dart:43
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::createState [EXTRACTED] lib/ui/terminal_page.dart:14
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::dispose [EXTRACTED] lib/ui/terminal_page.dart:58
lib/ui/terminal_page.dart --defines--> lib/ui/terminal_page.dart::newSession [EXTRACTED] lib/ui/terminal_page.dart:50
lib/ui/terminal_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/terminal_page.dart:8
lib/ui/terminal_page.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/terminal_page.dart:0
lib/ui/terminal_page.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/terminal_page.dart:0
lib/ui/theme/theme_build_theme.dart --defines--> lib/ui/theme/theme_build_theme.dart::_buildTheme [EXTRACTED] lib/ui/theme/theme_build_theme.dart:3
lib/ui/theme/theme_build_theme.dart --defines--> lib/ui/theme/theme_build_theme.dart::_fieldBorder [EXTRACTED] lib/ui/theme/theme_build_theme.dart:254
lib/ui/theme/theme_build_theme.dart --defines--> lib/ui/theme/theme_build_theme.dart::_textTheme [EXTRACTED] lib/ui/theme/theme_build_theme.dart:260
lib/ui/theme/theme_colors.dart --defines--> lib/ui/theme/theme_colors.dart::OCColors [EXTRACTED] lib/ui/theme/theme_colors.dart:10
lib/ui/theme/theme_radius_typography.dart --calls--> lib/ui/theme/theme_build_theme.dart::_buildTheme [INFERRED 0.6] lib/ui/theme/theme_radius_typography.dart:0
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::OCMotion [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:57
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::OCRadius [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:4
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::OCTypography [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:94
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::_TextStyleExt [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:332
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::_mono [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:170
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::_sans [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:128
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::_serif [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:152
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::_wght [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:123
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::buildAppTheme [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:345
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::code [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:303
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::codeBlock [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:307
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::mono [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:284
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::monoLarge [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:299
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::monoSmall [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:296
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::numeric [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:271
lib/ui/theme/theme_radius_typography.dart --defines--> lib/ui/theme/theme_radius_typography.dart::withColor [EXTRACTED] lib/ui/theme/theme_radius_typography.dart:333
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::OCGradient [EXTRACTED] lib/ui/theme/theme_tokens.dart:317
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::OCShadow [EXTRACTED] lib/ui/theme/theme_tokens.dart:274
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::OCSpace [EXTRACTED] lib/ui/theme/theme_tokens.dart:353
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::OCTokens [EXTRACTED] lib/ui/theme/theme_tokens.dart:12
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::OCTokensX [EXTRACTED] lib/ui/theme/theme_tokens.dart:348
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::copyWith [EXTRACTED] lib/ui/theme/theme_tokens.dart:156
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::lerp [EXTRACTED] lib/ui/theme/theme_tokens.dart:225
lib/ui/theme/theme_tokens.dart --defines--> lib/ui/theme/theme_tokens.dart::of [EXTRACTED] lib/ui/theme/theme_tokens.dart:152
lib/ui/todos_page.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/todos_page.dart:3
lib/ui/todos_page.dart --calls--> lib/l10n/strings.dart::todosProgress [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/l10n/strings.dart::todosProgressSemantics [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/l10n/strings.dart::todosSession [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/todos_page.dart:4
lib/ui/todos_page.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/todos_page.dart:5
lib/ui/todos_page.dart --calls--> lib/state/store/store_ocstore_sessions.dart::ensureTodosFresh [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/state/store/store_ocstore_sessions.dart::refreshTodos [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --imports--> lib/ui/app_scope.dart [EXTRACTED] lib/ui/todos_page.dart:6
lib/ui/todos_page.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/todos_page.dart:7
lib/ui/todos_page.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressBar [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/todos_page.dart:8
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::TodosPage [EXTRACTED] lib/ui/todos_page.dart:11
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::_ActivePulse [EXTRACTED] lib/ui/todos_page.dart:222
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::_ActivePulseState [EXTRACTED] lib/ui/todos_page.dart:230
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::_TodoTile [EXTRACTED] lib/ui/todos_page.dart:151
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::_TodosBody [EXTRACTED] lib/ui/todos_page.dart:50
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::_TodosPageState [EXTRACTED] lib/ui/todos_page.dart:18
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::_leading [EXTRACTED] lib/ui/todos_page.dart:199
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::build [EXTRACTED] lib/ui/todos_page.dart:32
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::createState [EXTRACTED] lib/ui/todos_page.dart:15
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::dispose [EXTRACTED] lib/ui/todos_page.dart:244
lib/ui/todos_page.dart --defines--> lib/ui/todos_page.dart::initState [EXTRACTED] lib/ui/todos_page.dart:20
lib/ui/todos_page.dart --imports--> lib/ui/widgets.dart [EXTRACTED] lib/ui/todos_page.dart:9
lib/ui/todos_page.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::ocReduceMotion [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [INFERRED 0.6] lib/ui/todos_page.dart:0
lib/ui/todos_page.dart --calls--> lib/voice/voice_scope.dart::read [INFERRED 0.35] lib/ui/todos_page.dart:0
lib/ui/widgets.dart --imports--> lib/l10n/strings.dart [EXTRACTED] lib/ui/widgets.dart:4
lib/ui/widgets.dart --imports--> lib/models/models.dart [EXTRACTED] lib/ui/widgets.dart:5
lib/ui/widgets.dart --imports--> lib/state/store.dart [EXTRACTED] lib/ui/widgets.dart:6
lib/ui/widgets.dart --imports--> lib/ui/line_icons.dart [EXTRACTED] lib/ui/widgets.dart:7
lib/ui/widgets.dart --imports--> lib/ui/primitives.dart [EXTRACTED] lib/ui/widgets.dart:8
lib/ui/widgets.dart --imports--> lib/ui/theme.dart [EXTRACTED] lib/ui/widgets.dart:9
lib/ui/widgets/widgets_header_button.dart --calls--> lib/ui/line_icons/line_icons_widgets.dart::LIcon [INFERRED 0.6] lib/ui/widgets/widgets_header_button.dart:0
lib/ui/widgets/widgets_header_button.dart --defines--> lib/ui/widgets/widgets_header_button.dart::CountBadge [EXTRACTED] lib/ui/widgets/widgets_header_button.dart:57
lib/ui/widgets/widgets_header_button.dart --defines--> lib/ui/widgets/widgets_header_button.dart::HeaderButton [EXTRACTED] lib/ui/widgets/widgets_header_button.dart:4
lib/ui/widgets/widgets_header_button.dart --defines--> lib/ui/widgets/widgets_header_button.dart::InfoRow [EXTRACTED] lib/ui/widgets/widgets_header_button.dart:90
lib/ui/widgets/widgets_header_button.dart --defines--> lib/ui/widgets/widgets_header_button.dart::build [EXTRACTED] lib/ui/widgets/widgets_header_button.dart:21
lib/ui/widgets/widgets_header_button.dart --defines--> lib/ui/widgets/widgets_header_button.dart::toolColor [EXTRACTED] lib/ui/widgets/widgets_header_button.dart:142
lib/ui/widgets/widgets_header_button.dart --defines--> lib/ui/widgets/widgets_header_button.dart::toolIcon [EXTRACTED] lib/ui/widgets/widgets_header_button.dart:128
lib/ui/widgets/widgets_header_button.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::Mono [INFERRED 0.6] lib/ui/widgets/widgets_header_button.dart:0
lib/ui/widgets/widgets_headers_pills.dart --calls--> lib/api/events.dart::stop [INFERRED 0.6] lib/ui/widgets/widgets_headers_pills.dart:0
lib/ui/widgets/widgets_headers_pills.dart --calls--> lib/l10n/strings.dart::statusCached [INFERRED 0.6] lib/ui/widgets/widgets_headers_pills.dart:0
lib/ui/widgets/widgets_headers_pills.dart --calls--> lib/ui/theme/theme_radius_typography.dart::mono [INFERRED 0.6] lib/ui/widgets/widgets_headers_pills.dart:0
lib/ui/widgets/widgets_headers_pills.dart --calls--> lib/ui/widgets/widgets_header_button.dart::HeaderButton [INFERRED 0.6] lib/ui/widgets/widgets_headers_pills.dart:0
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::AppHeader [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:317
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::HeaderAction [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:278
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::Mono [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:35
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::OcLinkState [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:75
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::SectionTitle [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:4
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::StatusPill [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:97
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::_StatusPillState [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:122
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::_sync [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:141
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::build [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:10
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::createState [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:119
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::didUpdateWidget [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:136
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::dispose [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:151
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::initState [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:130
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::ocLinkState [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:261
lib/ui/widgets/widgets_headers_pills.dart --defines--> lib/ui/widgets/widgets_headers_pills.dart::ocReduceMotion [EXTRACTED] lib/ui/widgets/widgets_headers_pills.dart:68
lib/ui/widgets/widgets_navigation_feedback.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCButton [INFERRED 0.6] lib/ui/widgets/widgets_navigation_feedback.dart:0
lib/ui/widgets/widgets_navigation_feedback.dart --calls--> lib/ui/primitives/primitives_buttons_cards.dart::OCCard [INFERRED 0.6] lib/ui/widgets/widgets_navigation_feedback.dart:0
lib/ui/widgets/widgets_navigation_feedback.dart --calls--> lib/ui/primitives/primitives_cells_controls.dart::OCIconTile [INFERRED 0.6] lib/ui/widgets/widgets_navigation_feedback.dart:0
lib/ui/widgets/widgets_navigation_feedback.dart --calls--> lib/ui/primitives/primitives_progress_chip.dart::OCProgressRing [INFERRED 0.6] lib/ui/widgets/widgets_navigation_feedback.dart:0
lib/ui/widgets/widgets_navigation_feedback.dart --calls--> lib/ui/widgets/widgets_headers_pills.dart::Mono [INFERRED 0.6] lib/ui/widgets/widgets_navigation_feedback.dart:0
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::ConnectionErrorView [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:240
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::EmptyHint [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:159
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::LoadingView [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:218
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::_ToastWidget [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:42
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::_ToastWidgetState [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:56
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::build [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:70
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::confirmDialog [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:382
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::copyToClipboard [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:148
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::createState [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:53
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::dispose [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:64
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::promptText [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:343
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::pushScreen [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:9
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::showSnack [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:131
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::showToast [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:25
lib/ui/widgets/widgets_navigation_feedback.dart --defines--> lib/ui/widgets/widgets_navigation_feedback.dart::showUndoSnack [EXTRACTED] lib/ui/widgets/widgets_navigation_feedback.dart:137
lib/voice/voice_scope.dart --calls--> lib/ui/app_scope.dart::read [INFERRED 0.35] lib/voice/voice_scope.dart:0
lib/voice/voice_scope.dart --defines--> lib/voice/voice_scope.dart::VoiceScope [EXTRACTED] lib/voice/voice_scope.dart:12
lib/voice/voice_scope.dart --defines--> lib/voice/voice_scope.dart::of [EXTRACTED] lib/voice/voice_scope.dart:19
lib/voice/voice_scope.dart --defines--> lib/voice/voice_scope.dart::read [EXTRACTED] lib/voice/voice_scope.dart:26
lib/voice/voice_scope.dart --imports--> lib/voice/voice_service.dart [EXTRACTED] lib/voice/voice_scope.dart:3
lib/voice/voice_service.dart --imports--> lib/state/store.dart [EXTRACTED] lib/voice/voice_service.dart:11
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/state/store/store_ocstore.dart::_messageText [INFERRED 0.35] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/state/store/store_ocstore_history.dart::sendOrQueue [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::VoiceServiceConversation [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:9
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_checkInactivity [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:193
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_commitUtterance [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:27
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_finishUtterance [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:10
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_handleTail [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:155
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_lastAssistantMessage [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:185
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_onEmptyUtterance [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:71
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_onSessionChanged [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:138
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_relisten [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:213
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_resumeLoop [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:199
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::_sendAndWait [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:42
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::endConversation [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:117
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::startConversation [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:96
lib/voice/voice_service/voice_service_conversation.dart --defines--> lib/voice/voice_service/voice_service_conversation.dart::toggleConversation [EXTRACTED] lib/voice/voice_service/voice_service_conversation.dart:88
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_core.dart::_messageText [INFERRED 0.35] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_core.dart::_onStore [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_beginListen [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_stopRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_fail [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_forget [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::clearNotice [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::_stopSpeaking [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_conversation.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::speak [INFERRED 0.6] lib/voice/voice_service/voice_service_conversation.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/api/events.dart::stop [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/state/store/store_ocstore.dart::_messageText [INFERRED 0.35] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/ui/diff_page.dart::_split [INFERRED 0.35] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_checkInactivity [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_handleTail [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_onSessionChanged [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_resumeLoop [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::VoiceService [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:15
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::_messageText [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:185
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::_normalize [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:198
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::_onStore [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:144
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::_split [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:250
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::dispose [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:110
lib/voice/voice_service/voice_service_core.dart --defines--> lib/voice/voice_service/voice_service_core.dart::plainSpeech [EXTRACTED] lib/voice/voice_service/voice_service_core.dart:210
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_stopRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_forget [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_core.dart --calls--> lib/voice/voice_service/voice_service_state.dart::_supersedeListen [INFERRED 0.6] lib/voice/voice_service/voice_service_core.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/api/events.dart::stop [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_commitUtterance [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_finishUtterance [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_onEmptyUtterance [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::endConversation [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::VoiceServiceDictation [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:9
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_beginListen [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:99
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_onLevel [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:155
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_onRecognizerError [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:203
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_onResult [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:163
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_onStatus [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:188
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_startRecognizer [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:10
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::_stopRecognizer [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:143
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::stopDictation [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:66
lib/voice/voice_service/voice_service_dictation.dart --defines--> lib/voice/voice_service/voice_service_dictation.dart::toggleDictation [EXTRACTED] lib/voice/voice_service/voice_service_dictation.dart:55
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_ensureRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_fail [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_forget [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::clearNotice [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::_interruptToListen [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::_isEcho [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_state.dart::_supersedeListen [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_dictation.dart --calls--> lib/voice/voice_service/voice_service_state.dart::_superseded [INFERRED 0.6] lib/voice/voice_service/voice_service_dictation.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/state/store/store_ocstore_connection.dart::_persist [INFERRED 0.35] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/ui/home/home_shell.dart::Function [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_resumeLoop [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_startRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_stopRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::VoiceServiceLifecycle [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:9
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_applySpeechSettings [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:118
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_ensureRecognizer [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:162
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_fail [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:34
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_forget [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:46
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_go [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:20
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_initSpeech [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:95
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_loadSettings [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:130
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::_persist [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:144
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::resume [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:72
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::suspend [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:57
lib/voice/voice_service/voice_service_lifecycle.dart --defines--> lib/voice/voice_service/voice_service_lifecycle.dart::warmUp [EXTRACTED] lib/voice/voice_service/voice_service_lifecycle.dart:90
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/voice/voice_service/voice_service_settings.dart::setLanguage [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/voice/voice_service/voice_service_speech.dart::_stopSpeaking [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_lifecycle.dart --calls--> lib/voice/voice_service/voice_service_state.dart::_supersedeListen [INFERRED 0.6] lib/voice/voice_service/voice_service_lifecycle.dart:0
lib/voice/voice_service/voice_service_settings.dart --calls--> lib/state/store/store_ocstore_connection.dart::_persist [INFERRED 0.35] lib/voice/voice_service/voice_service_settings.dart:0
lib/voice/voice_service/voice_service_settings.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_stopRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_settings.dart:0
lib/voice/voice_service/voice_service_settings.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_applySpeechSettings [INFERRED 0.6] lib/voice/voice_service/voice_service_settings.dart:0
lib/voice/voice_service/voice_service_settings.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_persist [INFERRED 0.35] lib/voice/voice_service/voice_service_settings.dart:0
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::VoiceServiceSettings [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:9
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::ackIntro [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:57
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::clearNotice [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:68
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::setAutoSend [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:43
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::setLanguage [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:23
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::setRate [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:30
lib/voice/voice_service/voice_service_settings.dart --defines--> lib/voice/voice_service/voice_service_settings.dart::setReadAloud [EXTRACTED] lib/voice/voice_service/voice_service_settings.dart:37
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/api/events.dart::stop [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/ui/terminal_page.dart::clear [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_conversation.dart::_relisten [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_core.dart::_normalize [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_core.dart::plainSpeech [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_beginListen [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_dictation.dart::_stopRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_fail [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_forget [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::VoiceServiceSpeech [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:9
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_armWatchdog [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:131
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_completePending [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:120
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_finishSpeaking [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:140
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_interruptToListen [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:154
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_isEcho [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:161
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_onSpeakDone [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:113
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_onSpeakError [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:115
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_onSpeakStart [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:107
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_runQueue [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:84
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::_stopSpeaking [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:57
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::speak [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:15
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::stopSpeaking [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:50
lib/voice/voice_service/voice_service_speech.dart --defines--> lib/voice/voice_service/voice_service_speech.dart::testVoice [EXTRACTED] lib/voice/voice_service/voice_service_speech.dart:76
lib/voice/voice_service/voice_service_speech.dart --calls--> lib/voice/voice_service/voice_service_state.dart::_supersedeListen [INFERRED 0.6] lib/voice/voice_service/voice_service_speech.dart:0
lib/voice/voice_service/voice_service_state.dart --calls--> lib/voice/voice_service/voice_service_lifecycle.dart::_ensureRecognizer [INFERRED 0.6] lib/voice/voice_service/voice_service_state.dart:0
lib/voice/voice_service/voice_service_state.dart --defines--> lib/voice/voice_service/voice_service_state.dart::VoiceServiceState [EXTRACTED] lib/voice/voice_service/voice_service_state.dart:9
lib/voice/voice_service/voice_service_state.dart --defines--> lib/voice/voice_service/voice_service_state.dart::_supersedeListen [EXTRACTED] lib/voice/voice_service/voice_service_state.dart:49
lib/voice/voice_service/voice_service_state.dart --defines--> lib/voice/voice_service/voice_service_state.dart::_superseded [EXTRACTED] lib/voice/voice_service/voice_service_state.dart:53
lib/voice/voice_service/voice_service_state.dart --defines--> lib/voice/voice_service/voice_service_state.dart::locales [EXTRACTED] lib/voice/voice_service/voice_service_state.dart:76
lib/voice/voice_service/voice_service_state.dart --defines--> lib/voice/voice_service/voice_service_state.dart::openMicrophoneSettings [EXTRACTED] lib/voice/voice_service/voice_service_state.dart:101
lib/voice/voice_service/voice_service_state.dart --calls--> lib/voice/voice_service/voice_service_types.dart::VoiceLocale [INFERRED 0.6] lib/voice/voice_service/voice_service_state.dart:0
lib/voice/voice_service/voice_service_types.dart --defines--> lib/voice/voice_service/voice_service_types.dart::VoiceFailure [EXTRACTED] lib/voice/voice_service/voice_service_types.dart:52
lib/voice/voice_service/voice_service_types.dart --defines--> lib/voice/voice_service/voice_service_types.dart::VoiceLocale [EXTRACTED] lib/voice/voice_service/voice_service_types.dart:7
lib/voice/voice_service/voice_service_types.dart --defines--> lib/voice/voice_service/voice_service_types.dart::VoicePhase [EXTRACTED] lib/voice/voice_service/voice_service_types.dart:25
