# users
if ENV['SEED_CREATE_USERS']
  User.create(slack: "matias", jira: "5e6648d0219fb10cf9ed9c8d")
  User.create(slack: "vincent", jira: "5c73e558a610e635fa0fad26")
  User.create(slack: "ian.campelo", jira: "5e67dba377d46c0cf93af7f0", github: "iancampelo")
  User.create(slack: "vicky", jira: "5a0f40fb3f50ba4cff298870")
  User.create(slack: "victor.carvalho", jira: "5db84b746bd41c0c358f6c3b", github: "victor0402")
  User.create(slack: "alex", jira: "5b69bc7185ee4d3d958601f2", github: "alesmit")
  User.create(slack: "manu", jira: "5c73de34ef824a130638f5c4")
  User.create(slack: "kaiomagalhaes", jira: "5bfc2cb5b5881d1b2e50a6da", github: "kaiomagalhaes")
  User.create(slack: "raphael.sattler", jira: "5e0f6ec2800be30d9fb9d25b", github: "raphaelsattler")
  User.create(slack: "pedro.guimaraes", jira: "5e42f0c5ab90210c8de08a1d", github: "pvieiraguimaraes")
  User.create(slack: "pablo", jira: "5b07b8b1a06f955a66946e42", github: "presnizky")
  User.create(slack: "vincent.gschwend", jira: "5cc06a9f2f51be0e56a1b2b8", github: "neonima")
  User.create(slack: "denys.zayets", jira: "5e54a16d4befbd0c96c9eca5")
  User.create(slack: "anthony.scinocco", jira: "5e53d6192a59dc0c8fe5e055", github: "ascinocco")
  User.create(slack: "divjot.mehton", jira: "5e4bef0f052b790c975095e0")
  User.create(slack: "alessandro.alves", jira: "5b167e5dc2fc1b1bc37bb16c", github: "alessandromontividiu03")
  User.create(slack: "manuel.lajo", jira: "5e6aa4e72a0bb00ce03419be", github: "Manuel-Lajo-Salazar")
  User.create(slack: "mauricio.villaalba", jira: "5e6f922e5ffd840c43a99308", github: "mvillalba2016")
  User.create(slack: "ana.marija", jira: "5ca6158010e4f967c3022b24")
end

if ENV['SEED_CREATE_PROJECTS']
  Project.create!(name: 'Roadrunner', repositories: [
    Repository.new(
      name: 'roadrunner',
      supports_deploy: false,
      servers: [
        Server.new(link: 'https://roadrunner.codelitt.dev', supports_health_check: false, alias: 'prod-roadrunner')
      ],
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@engineers', dev_channel: 'team-automations-dev')
    )
  ])

  Project.create!(name: 'Codelitt website', repositories: [
    Repository.new(
      name: 'codelitt-v2',
      supports_deploy: true,
      deploy_type: Repository::TAG_DEPLOY_TYPE,
      jira_project: 'CW',
      servers: [
        Server.new(link: 'https://codelitt.dev', supports_health_check: false, alias: 'dev-website-codelitt'),
        Server.new(link: 'https://qa.codelitt.dev', supports_health_check: false, alias: 'qa-codelitt-website'),
        Server.new(link: 'https://codelitt.com', supports_health_check: false, alias: 'prod-codelitt-website'),
      ],
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@website-devs', dev_channel: 'team-website-dev', deploy_channel: 'team-website-deploy')
    )
  ])
  
  Project.create!(name: 'Rolli', repositories: [
    Repository.new(
      name: 'rolli',
      supports_deploy: true,
      deploy_type: Repository::TAG_DEPLOY_TYPE,
      servers: [
        Server.new(link: 'https://dev-rolli.codelitt.dev', supports_health_check: false, alias: 'dev-rolli'),
        Server.new(link: 'https://qa-rolli.codelitt.dev', supports_health_check: false, alias: 'qa-rolli'),
        Server.new(link: 'https://rolliapp.com', supports_health_check: false, alias: 'prod-rolli'),
      ],
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@rolli-devs', dev_channel: 'team-rolli-dev', deploy_channel: 'team-rolli-deploy')
    )
  ])
  
  Project.create!(name: 'Team Maker', repositories: [
    Repository.new(
      name: 'team-maker',
      supports_deploy: true,
      deploy_type: Repository::BRANCH_DEPLOY_TYPE,
      servers: [
        Server.new(link: 'https://team-maker.codelitt.dev', supports_health_check: false, alias: 'prod-team-maker'),
      ],
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@team-maker-devs', dev_channel: 'team-teammaker-dev', deploy_channel: 'wg-teammaker-deploy')
    )
  ])
  
  Project.create!(name: 'Zonda', repositories: [
    Repository.new(
      name: 'zonda',
      supports_deploy: true,
      deploy_type: Repository::BRANCH_DEPLOY_TYPE,
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@zonda-devs', dev_channel: 'team-zonda-dev', deploy_channel: 'wg-zonda-deploy')
    )
  ])
  
  Project.create!(name: 'Avison Young', repositories: [
    Repository.new(
      name: 'ay-design-library',
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@ay-devs', dev_channel: 'team-ay-pia-web-dev')
    ),
    Repository.new(
      name: 'ay-properties-api',
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@ay-backend-devs', dev_channel: 'team-ay-dev'),
      jira_project: 'AYAPI'
    ),
    Repository.new(
      name: 'ay-pia-web',
      supports_deploy: true,
      deploy_type: Repository::BRANCH_DEPLOY_TYPE,
      jira_project: 'HUB',
      servers: [
        Server.new(link: 'https://dev-ay-pia-web.herokuapp.com', supports_health_check: false, alias: 'dev-ay-pia-web'),
        Server.new(link: 'https://pia-web-prod.azurewebsites.net', supports_health_check: false),
      ],
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@ay-desktop-devs', dev_channel: 'team-ay-pia-web-dev', deploy_channel: 'team-pia-web-deploy')
    ),
    Repository.new(
      name: 'ay-excel-import-api',
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@ay-backend-devs', dev_channel: 'team-ay-dev'),
      jira_project: 'AYI'
    ),
    Repository.new(
      name: 'ay-property-intelligence',
      supports_deploy: true,
      deploy_type: Repository::BRANCH_DEPLOY_TYPE,
      jira_project: 'AYPI',
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@ay-mobile-devs', dev_channel: 'team-ay-pia-dev', deploy_channel: 'team-ay-pia-deploy')
    ),
    Repository.new(
      name: 'ay-users-api',
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@ay-backend-devs', dev_channel: 'team-ay-dev'),
      jira_project: 'AYAPI'
    )
  ])
  
  Project.create!(name: 'Codelitt Blog', repositories: [
    Repository.new(
      name: 'blog-v2',
      supports_deploy: false,
      servers: [
        Server.new(link: 'https://blog.codelitt.com', supports_health_check: false, alias: 'prod-codelitt-blog'),
      ],
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@website-devs', dev_channel: 'team-website-dev', deploy_channel: 'team-blog-deploy')
    )
  ])
  
  Project.create!(name: 'Codelitt Design System', repositories: [
    Repository.new(
      name: 'codelitt-design-system',
      supports_deploy: false,
      deploy_type: Repository::TAG_DEPLOY_TYPE,
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@engineers', dev_channel: 'team-codelitt-design-system-dev', deploy_channel: 'team-design-system-deploy')
    )
  ])
  Project.create!(name: 'Farm to fork', repositories: [
    Repository.new(
      name: 'foodlitt',
      supports_deploy: false,
      deploy_type: Repository::TAG_DEPLOY_TYPE,
      slack_repository_info: SlackRepositoryInfo.new(dev_group: '@farm-to-fork-devs', dev_channel: 'team-farm-to-fork-dev', deploy_channel: 'team-farm-to-fork-deploy')
    )
  ])
end

# projects
# p1 = Project.create(name: 'Roadrunner')
# p2 = Project.create(name: 'Rolli')
# 
# # repositories
# r1 = Repository.new(project: p1)
# s1 = Server.create(link: 'https://roadrunner.codelitt.dev', repository: r1, supports_health_check: true)
# sl1 = SlackRepositoryInfo.create(deploy_channel: 'test-gh', repository: r1)
# 
# 
# r2 = Repository.new(project: p2)
# s2 = Server.create(link: 'https://rolliapp.com', repository: r2, supports_health_check: false)
# sl2 = SlackRepositoryInfo.create(deploy_channel: 'test-gh', repository: r2)