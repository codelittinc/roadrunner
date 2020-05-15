# users
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

# repositories
r1 = Repository.new
s1 = Server.create(link: 'https://roadrunner.codelitt.dev', repository: r1, supports_health_check: true)
sl1 = SlackRepositoryInfo.create(deploy_channel: 'test-gh', repository: r1)


r2 = Repository.new
s2 = Server.create(link: 'https://rolliapp.com', repository: r2, supports_health_check: false)
sl2 = SlackRepositoryInfo.create(deploy_channel: 'test-gh', repository: r2)