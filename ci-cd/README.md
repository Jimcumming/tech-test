# CI/CD

All CI/CD scripts are assumed to run from the root of the repository.

This repository contains two scripts:

* `build-container.sh` - This script builds the application in the `app` folder and then builds the subsequent docker container.
* `push-container.sh` - This script logs into ECR and pushes the container built using the previous script.