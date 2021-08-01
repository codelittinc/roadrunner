# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Versioning::ReleaseVersionResolver, type: :service do
  describe '#next_version' do
    context 'update QA release' do
      context 'when the last normal release is' do
        it 'a normal RC release it should return an RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'rc.1.v0.2.0'],
            'update'
          )

          expect(flow.next_version.match?(/rc/)).to be_truthy
        end

        it 'a normal STABLE release it should return an RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'v0.2.0'],
            'update'
          )

          expect(flow.next_version.match?(/rc/)).to be_truthy
        end

        it 'a QA RC release it should return an increased RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'rc.1.v0.3.0', 'v0.2.0'],
            'update'
          )

          expect(flow.next_version).to eql('rc.2.v0.3.0')
        end

        it 'a normal STABLE release it returns a first RC release for that STABLE release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'v0.2.3', 'v0.2.0'],
            'update'
          )

          expect(flow.next_version).to eql('rc.1.v0.3.0')
        end
      end

      context 'when there is no release' do
        it 'it should return the default version' do
          flow = described_class.new(
            'qa',
            [],
            'update'
          )

          expect(flow.next_version).to eql('rc.1.v1.0.0')
        end
      end

      context 'when there are hotfix releases' do
        it 'it should ignore all hotfix releases' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'v0.2.3', 'rc.1.v0.2.0'],
            'update'
          )

          expect(flow.next_version).to eql('rc.2.v0.2.0')
        end
      end

      context 'the patch should always be 0 when' do
        it 'the last version is a normal STABLE release ' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'v0.2.3', 'v0.2.0'],
            'update'
          )

          expect(flow.next_version.split('.').last.to_i).to eql(0)
        end

        it 'the last version is a QA release candidate' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'v0.2.3', 'rc.1.v0.2.0'],
            'update'
          )

          expect(flow.next_version.split('.').last.to_i).to eql(0)
        end

        it 'there is no releases it returns a default QA release candidate' do
          flow = described_class.new(
            'qa',
            [],
            'update'
          )

          expect(flow.next_version.split('.').last.to_i).to eql(0)
        end
      end
    end

    context 'update PROD release' do
      context 'when the last version is' do
        it 'a QA release it returns a STABLE release' do
          flow = described_class.new(
            'prod',
            ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'rc.4.v1.5.0', 'rc.1.v0.2.0'],
            'update'
          )

          expect(flow.next_version).to eql('v1.5.0')
        end

        it 'not a QA release it returns nil' do
          flow = described_class.new(
            'prod',
            ['rc.1.v0.2.2', 'v0.2.0'],
            'update'
          )

          expect(flow.next_version).to be_nil
        end
      end

      it 'it should ignore all hotfix releases' do
        flow = described_class.new(
          'prod',
          ['rc.1.v0.2.1', 'rc.1.v0.2.2', 'v0.2.3', 'rc.1.v0.3.0'],
          'update'
        )

        expect(flow.next_version).to eql('v0.3.0')
      end
    end

    context 'hotfix QA release' do
      context 'when the last version is' do
        it 'a hotfix QA release it returns an increased hotfix RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.0', 'rc.1.v1.5.1', 'rc.1.v1.5.0'],
            'hotfix'
          )

          expect(flow.next_version).to eql('rc.2.v1.5.1')
        end

        it 'a hotfix STABLE release it returns a hotfix RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.0', 'v1.5.1', 'rc.4.v1.5.0', 'rc.1.v0.2.0'],
            'hotfix'
          )

          expect(flow.next_version).to eql('rc.1.v1.5.2')
        end

        it 'a normal STABLE release it returns a hotfix RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v1.6.0', 'v1.5.0'],
            'hotfix'
          )

          expect(flow.next_version).to eql('rc.1.v1.5.1')
        end
      end

      context 'when the last STABLE is' do
        it 'a normal STABLE release it returns a hotfix RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.0', 'v1.5.0', 'rc.4.v1.5.0', 'rc.1.v0.2.0'],
            'hotfix'
          )

          expect(flow.next_version).to eql('rc.1.v1.5.1')
        end

        it 'a hotfix STABLE release it returns an increased hotfix RC release' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.0', 'v1.5.1', 'rc.4.v1.5.0', 'rc.1.v0.2.0'],
            'hotfix'
          )

          expect(flow.next_version).to eql('rc.1.v1.5.2')
        end

        it 'not a hotfix QA or a STABLE release it should return nil' do
          flow = described_class.new(
            'qa',
            ['rc.1.v0.2.0'],
            'hotfix'
          )

          expect(flow.next_version).to be_nil
        end
      end
    end

    context 'hotfix PROD release' do
      context 'when the last version is' do
        it 'a hotfix QA release after the last STABLE it returns a hotfix STABLE release' do
          flow = described_class.new(
            'prod',
            ['rc.1.v1.6.0', 'rc.1.v1.5.1', 'v1.4.0'],
            'hotfix'
          )

          expect(flow.next_version).to eql('v1.5.1')
        end

        it 'not a hotfix QA release after the last STABLE it returns nil' do
          flow = described_class.new(
            'prod',
            ['rc.1.v0.2.0', 'rc.1.v1.5.0', 'v1.6.0'],
            'hotfix'
          )

          expect(flow.next_version).to be_nil
        end
      end
    end
  end

  describe '#truth_table for next_version:' do
    [ #    releases                                  environment    action   expected_output    releases_description
      [[],                                             'qa',       'hotfix', nil,               'empty list'],
      [['rc.1.v0.2.0'],                                'qa',       'hotfix', nil,
       'there are no hotfix QA release'],
      [['rc.1.v0.2.0', 'rc.1.v1.5.1'],                 'qa',       'hotfix', 'rc.2.v1.5.1',
       'there is a hotfix QA release'],
      [['rc.1.v0.2.0', 'v1.5.1'],                      'qa',       'hotfix', 'rc.1.v1.5.2',
       'there is a hotfix STABLE release'],
      [['rc.1.v0.2.0', 'v1.5.0'],                      'qa',       'hotfix', 'rc.1.v1.5.1',
       'there is a normal STABLE release'],
      [[],                                             'qa',       'update', 'rc.1.v1.0.0', 'empty list'],
      [['rc.1.v0.2.1', 'rc.1.v0.2.0'],                 'qa',       'update', 'rc.2.v0.2.0',
       'there is a normal RC release'],
      [['v0.2.3', 'v0.2.0'],                           'qa',       'update', 'rc.1.v0.3.0',
       'there is a normal STABLE release'],
      [['v0.2.3'],                                     'qa',       'update', 'rc.1.v1.0.0',
       'there is a hotfix STABLE release'],
      [['rc.1.v0.2.3'],                                'qa',       'update', 'rc.1.v1.0.0',
       'there is a hotfix RC release'],
      [['rc.1.v1.2.1', 'rc.1.v1.1.1', 'v1.2.0'],       'prod',     'hotfix', 'v1.2.1',
       'there is a last hotfix QA release'],
      [['rc.1.v0.2.0', 'rc.1.v1.5.0', 'v1.6.0'],       'prod',     'hotfix', nil,
       'there is no hotfix QA release'],
      [['rc.1.v0.2.0', 'v0.1.0'],                      'prod',     'update', 'v0.2.0',
       'there is a last QA release'],
      [['rc.1.v0.1.1', 'v0.1.0'],                      'prod',     'update', nil,
       'there is no QA release'],
      [['rc.1.v0.1.1', 'v0.1.1'],                      'prod',     'update', nil,
       'there are only hotfix releases']
    ].each do |releases, environment, action, expected_output, releases_description|
      context "when inside the #{environment} environment and #{action} action" do
        it "if #{releases_description}: '#{releases}' it should return '#{expected_output}'" do
          flow = described_class.new(
            environment,
            releases,
            action
          )

          expect(flow.next_version).to eql(expected_output)
        end
      end
    end
  end

  # This test is only to make it easier if we want to try some releases and see the new versions for them
  describe '#truth_table for next_version, specifications:' do
    [ #    releases               environment_action (environment, action, expected_output)
      [[], [['qa', 'hotfix', nil], ['prod', 'hotfix', nil], ['qa', 'update', 'rc.1.v1.0.0'], ['prod', 'update', nil]]]
      # Add your releases array and see what you can expect for all the actions and environments when running the test, follow the example below:
      # [['rc.1.v0.2.0', 'v0.1.0'],             [['qa', 'hotfix', nil], ['prod', 'hotfix', nil], ['qa', 'update', nil], ['prod', 'update', nil]]]
    ].each do |releases, environment_action|
      environment_action.each do |array|
        context "when inside the #{array[0]} environment and #{array[1]} action" do
          it "if releases equal '#{releases}' it should return '#{array[2]}'" do
            flow = described_class.new(
              array[0],
              releases,
              array[1]
            )

            expect(flow.next_version).to eql(array[2])
          end
        end
      end
    end
  end
end
