# frozen_string_literal: true

module Versioning
  QA_ENVIRONMENT = 'qa'
  PROD_ENVIRONMENT = 'prod'
  DEFAULT_QA_TAG_NAME = 'rc.1.v0.0.0'
  DEFAULT_PROD_TAG_NAME = 'v1.0.0'
  RELEASE_REGEX = /v(\d+)\.(\d+)\.(\d+)/.freeze
  RELEASE_CANDIDATE_VERSION_REGEX = /^rc\.(\d+)\./.freeze
  ACTION_UPDATE = 'update'
  ACTION_HOTFIX = 'hotfix'

  def self.stable?(version)
    !version.match(/rc/)
  end

  def self.release_candidate?(version)
    version.match?(/rc/)
  end

  def self.hotfix?(version)
    version.split('.').last.to_i.positive?
  end

  def self.normal?(version)
    version&.split('.')&.last&.to_i&.zero?
  end

  def self.first_pre_release?(version)
    version.nil?
  end

  def self.release_candidate_version(version)
    version&.scan(RELEASE_CANDIDATE_VERSION_REGEX)&.flatten&.first&.to_i
  end
end
