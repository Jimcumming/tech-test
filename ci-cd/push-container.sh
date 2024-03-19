APP_VERSION=$(node -p -e "require('./app/package.json').version")
APP_NAME=$(node -p -e "require('./app/package.json').name")

if [[ -z "$AWS_ACCOUNT_ID" ]]; then
    echo "Must provide AWS_ACCOUNT_ID in environment" 1>&2
    exit 1
fi

aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com

docker push $AWS_ACCOUNT_ID.dkr.ecr.eu-west-1.amazonaws.com/$APP_NAME:$APP_VERSION