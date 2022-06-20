# frozen_string_literal: true

require 'rails_helper'
require 'flows_helper'

RSpec.describe Flows::SentryIncidentNotificationFlow, type: :service do
  let(:valid_incident) { load_flow_fixture('sentry_incident.json') }
  let(:valid_incident_with_app_info_by_tags) { load_flow_fixture('sentry_incident_with_app_info_by_tags.json') }
  let(:valid_incident_with_error_caught) { load_flow_fixture('sentry_incident_with_error_caught_tag.json') }
  let(:valid_incident_with_custom_message) { load_flow_fixture('sentry_incident_with_custom_message.json') }
  let(:invalid_incident) { load_flow_fixture('graylogs_incident_big_message.json') }
  let(:valid_incident_of_missing_server) { load_flow_fixture('sentry_incident_with_missing_server.json') }
  let(:valid_incident_without_browser) { load_flow_fixture('sentry_incident_without_browser.json') }

  context 'normal flow' do
    describe '#flow?' do
      context 'returns true' do
        it 'with a valid json' do
          FactoryBot.create(:application, :with_server, external_identifier: 'pia-web-qa')
          flow = described_class.new(valid_incident)
          expect(flow.flow?).to be_truthy
        end

        it 'when there is a server with an external_identifier with the same project_name' do
          FactoryBot.create(:application, :with_server, external_identifier: 'pia-web-qa')
          flow = described_class.new(valid_incident)
          expect(flow.flow?).to be_truthy
        end
      end

      context 'returns false' do
        it 'with a invalid json' do
          FactoryBot.create(:application, :with_server, external_identifier: 'pia-web-qa')
          flow = described_class.new(invalid_incident)
          expect(flow.flow?).to be_falsey
        end

        it 'when there no server with an external identifier with the same project_name' do
          flow = described_class.new(valid_incident)
          expect(flow.flow?).to be_falsey
        end
      end
    end

    describe '#run' do
      it 'calls the ApplicationIncidentService with the right params' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'pia-web-qa')

        flow = described_class.new(valid_incident)
        message = "\n *Error*: This shouldn't happen!\n *Type*: Uncaught Exception\n *File Name*: /static/js/27.chunk.js\n *Function*: onClickSuggestion\n"\
                  " *User*: \n>Id - 9\n>Email - victor.carvalho@codelitt.com\n *Browser*: Chrome\n\n "\
                  '*Link*: <https://sentry.io/organizations/codelitt-7y/issues/1851228751/events/6e54db70e36142d4b300b3389f4ff238/?project=5388450|See issue in Sentry.io>'
        expect_any_instance_of(ApplicationIncidentService).to receive(:register_incident!).with(
          application,
          message,
          nil,
          'sentry'
        )

        flow.run
      end

      it 'update server incident and create server incident instance' do
        application = FactoryBot.create(:application, :with_server, external_identifier: 'pia-web-qa')
        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400', text: "\n *Error*: This shouldn't happen!\n *Type*: Uncaught Exception\n *File Name*: /static/js/27.chunk.js\n"\
                                                                                         " *Function*: onClickSuggestion\n *User*: \n>Id - 9"\
                                                                                         "\n>Email - victor.carvalho@codelitt.com\n"\
                                                                                         " *Browser*: Chrome\n\n"\
                                                                                         ' *Link*: <https://sentry.io/organizations/codelitt-7y/issues/1851228751/events/6e54db70e36142d4b300b3389f4ff238/?project=5388450|'\
                                                                                         'See issue in Sentry.io>')

        FactoryBot.create(:server_incident, application:, message: slack_message.text,
                                            slack_message:)

        flow = described_class.new(valid_incident)

        expect { flow.run }.to change { ServerIncidentInstance.count }.by(1)
      end

      context 'when there is a ignore type for the incident' do
        it 'it does not create a server incident ' do
          FactoryBot.create(:application, :with_server, external_identifier: 'pia-web-qa')
          FactoryBot.create(:server_incident_type, name: 'Php File', regex_identifier: '.php.*')
          invalid_json = valid_incident.deep_dup

          invalid_json[:event][:title] =
            'ActionController::RoutingError (No route matches [GET] "/wp-content/plugins/wp-file-manager/lib/files/badmin1.php"):'

          flow = described_class.new(invalid_json)
          expect { flow.run }.to change { ServerIncident.count }.by(0)
        end
      end

      context 'when it is a dev server incident' do
        it 'it does not send server incident notification to slack' do
          FactoryBot.create(:application, external_identifier: 'pia-web-qa', environment: 'dev')

          flow = described_class.new(valid_incident)

          expect_any_instance_of(Clients::Slack::ChannelMessage).to_not receive(:send)

          expect { flow.run }.to change { ServerIncident.count }.by(1)
        end
      end

      context 'when there is no browser data' do
        it 'it does not send the browser data' do
          application = FactoryBot.create(:application, external_identifier: 'console', environment: 'prod')

          flow = described_class.new(valid_incident_without_browser)

          expect_any_instance_of(ApplicationIncidentService).to receive(:register_incident!).with(
            application,
            "\n *Error*: *errors.withStack: exit status 1\n"\
            " *Type*: Uncaught Exception\n *File Name*: /usr/src/console/cmd/rack/main.go\n"\
            " *Function*: uninstall\n\n *Link*: <https://sentry.io/organizations/codelitt-7y/issues/1627504850/events/65fc9e4950ed4aa2b55d2075eedaa359/?project=1299449|See issue in Sentry.io>",
            nil,
            'sentry'
          )

          flow.run
        end
      end

      context 'when there is an "error caught" tag' do
        it 'it adds to the message error that it was caught by the browser' do
          application = FactoryBot.create(:application, external_identifier: 'pia-web-qa')

          flow = described_class.new(valid_incident_with_error_caught)
          expect_any_instance_of(ApplicationIncidentService).to receive(:register_incident!).with(
            application,
            "\n *Error*: File timeout abstracting\n *Type*: Caught Exception\n *File Name*: services/ErrorsMonitor.ts\n"\
            " *Function*: callback\n *User*: \n>Id - 38\n>Email - carl.caputo@avisonyoung.com\n *Browser*: Chrome\n\n "\
            '*Link*: <https://sentry.io/organizations/codelitt-7y/issues/2052407554/events/25693e1886a940e7801439205bb5337f/?project=5388450|See issue in Sentry.io>',
            nil,
            'sentry'
          )

          flow.run
        end
      end

      context 'when there is a "custom message" extra' do
        it 'adds the content to the message' do
          application = FactoryBot.create(:application, external_identifier: 'pia-web-qa')

          flow = described_class.new(valid_incident_with_custom_message)
          expect_any_instance_of(ApplicationIncidentService).to receive(:register_incident!).with(
            application,
            "\n *Error*: failed to create company \"Avison Young\" (compareName: \"avison young\"). company already exists (ID...\n *Type*: Caught Exception\n *Displayed message*: [undefined]\n"\
            " *File Name*: services/ErrorLogger.ts\n"\
            " *Function*: callback\n *User*: \n>Id - \n>Email - \n *Browser*: Chrome\n\n "\
            '*Link*: <https://sentry.io/organizations/codelitt-7y/issues/2067016219/events/b10521c963414374a4e786d9ab468ade/?project=5388450|See issue in Sentry.io>',
            nil,
            'sentry'
          )

          flow.run
        end
      end
    end
  end

  context 'by tags flow' do
    describe '#flow?' do
      context 'returns true' do
        it 'with a valid json' do
          application = FactoryBot.create(:application, :with_server,
                                          external_identifier: 'appraisal-api-qa.azurewebsites.net')
          FactoryBot.create(:external_identifier, application:, text: 'spaces local')

          flow = described_class.new(valid_incident_with_app_info_by_tags)
          expect(flow.flow?).to be_truthy
        end

        it 'when there is a server with an external_identifier with the same project_name' do
          application = FactoryBot.create(:application, :with_server,
                                          external_identifier: 'appraisal-api-qa.azurewebsites.net')
          FactoryBot.create(:external_identifier, application:, text: 'spaces local')
          flow = described_class.new(valid_incident_with_app_info_by_tags)
          expect(flow.flow?).to be_truthy
        end
      end
    end

    describe '#run' do
      context 'calls the ApplicationIncidentService with the right params' do
        it 'with a repo from Github' do
          application = FactoryBot.create(:application, :with_server,
                                          external_identifier: 'appraisal-api-qa.azurewebsites.net')
          FactoryBot.create(:external_identifier, application:, text: 'spaces local')

          flow = described_class.new(valid_incident_with_app_info_by_tags)
          expected_message = "\n *Error*: TypeError: Cannot read property 'fullName' of undefined\n *Type*: Uncaught"\
                             " Exception\n *File Name*: /spaces/assets/app.js\n *Function*: Explore.PropertyExploreNew._propertyCardHtml\n"\
                             " *User*: \n>Id - \n>Email - Ivan.Trograncic@avisonyoung.com\n *Browser*: Chrome\n\n *Link*: <https://sentry.io/"\
                             'organizations/codelitt-7y/issues/2371765146/events/207cad8681564e41b6c59cde20abcaab/?project=5691309|See issue in Sentry.io>'

          expect_any_instance_of(ApplicationIncidentService).to receive(:register_incident!).with(
            application,
            expected_message,
            nil,
            'sentry'
          )

          flow.run
        end

        it 'with a repo from Azure' do
          repository = FactoryBot.create(:repository, source_control_type: 'azure')
          application = FactoryBot.create(:application, :with_server,
                                          external_identifier: 'appraisal-api-qa.azurewebsites.net', repository:)
          FactoryBot.create(:external_identifier, application:, text: 'spaces local')
          repository.project.customer.update(sentry_name: 'avison-young')

          flow = described_class.new(valid_incident_with_app_info_by_tags)
          expected_message = "\n *Error*: TypeError: Cannot read property 'fullName' of undefined\n *Type*: Uncaught"\
                             " Exception\n *File Name*: /spaces/assets/app.js\n *Function*: Explore.PropertyExploreNew._propertyCardHtml\n"\
                             " *User*: \n>Id - \n>Email - Ivan.Trograncic@avisonyoung.com\n *Browser*: Chrome\n\n *Link*: <https://sentry.io/"\
                             'organizations/avison-young/issues/2371765146/events/207cad8681564e41b6c59cde20abcaab/?project=5691309|See issue in Sentry.io>'

          expect_any_instance_of(ApplicationIncidentService).to receive(:register_incident!).with(
            application,
            expected_message,
            nil,
            'sentry'
          )

          flow.run
        end
      end

      it 'update server incident and create server incident instance' do
        application = FactoryBot.create(:application, :with_server,
                                        external_identifier: 'appraisal-api-qa.azurewebsites.net')
        FactoryBot.create(:external_identifier, application:, text: 'spaces local')

        message = "\n *Error*: TypeError: Cannot read property 'fullName' of undefined\n *Type*: Uncaught Exception\n *File Name*:"\
                  " /spaces/assets/app.js\n *Function*: Explore.PropertyExploreNew._propertyCardHtml\n *User*: \n>Id - \n>Email - Ivan.T"\
                  "rograncic@avisonyoung.com\n *Browser*: Chrome\n\n *Link*: <https://sentry.io/organizations/codelitt-7y/issues/237176514"\
                  '6/events/207cad8681564e41b6c59cde20abcaab/?project=5691309|See issue in Sentry.io>'

        slack_message = FactoryBot.create(:slack_message, ts: '1598981604.000400',
                                                          text: message)

        FactoryBot.create(:server_incident, application:, message: slack_message.text,
                                            slack_message:)

        flow = described_class.new(valid_incident_with_app_info_by_tags)

        expect { flow.run }.to change { ServerIncidentInstance.count }.by(1)
      end

      context 'when there is no server' do
        it 'dont add the link to the slack message' do
          repository = FactoryBot.create(:repository, source_control_type: 'azure')
          FactoryBot.create(:application, external_identifier: 'avant', repository:, environment: 'qa')
          repository.project.customer.update(sentry_name: 'avison-young')

          flow = described_class.new(valid_incident_of_missing_server)

          slack_message = ':droplet: <https://github.com/codelittinc/roadrunner-repository-test|roadrunner-repository-test> environment '\
                          ":droplet:<|QA>:droplet: \n \n *Error*: <unknown>\n *Type*: Caught Exception\n *User*: \n>Id - 37\n>Email - "\
                          "john.sikaitis@avisonyoung.com\n\n *Link*: <https://sentry.io/organizations/avison-young/issues/2403853699"\
                          '/events/fc188ef59c9b46f8a6a970cfe49ac276/?project=5691309|See issue in Sentry.io>'

          expect_any_instance_of(Clients::Slack::ChannelMessage).to receive(:send).with(
            slack_message,
            'feed-test-automations'
          ).and_return(
            { 'notification_id' => '123' }
          )

          flow.run
        end
      end
    end
  end
end
