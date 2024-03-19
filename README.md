# YuLife DevOps Technical Task


## Scenario

This repository contains a ReactJS application, that will be served using a Nginx container, and the corresponding 
infrastructure configuration in Terraform. To keep the task agnostic from CI/CD build tools, the CI/CD processes will
are modelled using bash scripts. Assume that the CI/CD scripts will be executed in the Docker container `ubuntu:latest`.


## Overview

The project has the following folders.

* `app` - a static ReactJS app that will be bundled into a container running Nginx for deployment
* `ci-cd` - a collection of bash scripts that would be called by a CI/CD pipeline to perform key tasks
* `infrastructure` - the Terraform scripts to create the infrastructure to host the app


## Brief

There are many issues with the code presented to you, you will fix one of the most critical and document the others. The
application code itself, that is the contents of `app/public` and `app/src` is out of scope of the task. While the toy 
application doesn't currently serve personally identifiable information, assume that it does.

You are asked to complete the follow tasks:

1. Review the code in its current state and describe any potential issues. Focus on: security, availability and performance. 
You can write your observations in a file called `RECOMMENDATIONS.md` and include it in this repository.
2. Implement, by modifying the Terraform code in this repository, SSL encryption for the application.

Note: you are not expected to purchase a domain name if choose to run the Terraform code, comment out `data.aws_route53_zone.zone` 
and `aws_route53_record.domain` and update your machines DNS resolution instead. On Linux systems this requires updating 
your `/etc/hosts` file.


## Completing the Task

You should spend no more than a couple of hours task. To submit your solution, create a private GitHub respository and 
grant access to the user `yulifelimited`. We will then arrange a time for the review session.