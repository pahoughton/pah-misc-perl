### paul/gitlab milestones

* gitlab milestones and issues imported from simple markdown file.

  create a project's milestones with issues from a simple markdown file
  with the followig format:
```
##* group/project milestones

* milestone title one

  milestone description

  - issue title one

    issue description

* milestone title two

  - issue title n ...
```

  - install GitLab api perl module
  - write parser
  - validate parser
    ensure the parser translates the markdown file correctly
  - validate gitlab updates
  - deploy

* simple php gitlab web app
  create a simple php app that shows milestones for all gitlab
  projects

  - create web server
  - validate application with selenium
  - create jenkins job to automate validation.
