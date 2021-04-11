#!/usr/bin/env bash

# Gather parameters.
DeployCloudwaysPrivateKey="$1"
DeployCloudwaysUsername="$2"
DeployCloudwaysHostname="$3"
DeployCloudwaysPath="$4"

echo "###"
echo "### Add private SSH key from Github Secrets."
echo "###"
mkdir -p ~/.ssh
touch ~/.ssh/deploy_rsa
echo "${DeployCloudwaysPrivateKey}" >> ~/.ssh/deploy_rsa
eval "$(ssh-agent -s)"
chmod 600 ~/.ssh/deploy_rsa
ssh-add ~/.ssh/deploy_rsa
ssh-keyscan -H ${DeployCloudwaysHostname} >> ~/.ssh/known_hosts

echo "###"
echo "### Validate composer file."
echo "###"
# Make sure composer is in consistent state.
composer validate

# @ToDo: Front end tasks.
# @ToDo: Maybe separate build to a hook to allow for custom processes.

echo "###"
echo "### Get all contrib code: composer install."
echo "###"
# Build up the artifact from light repo.
composer install --prefer-dist --no-progress --no-suggest --no-dev

# Call pre-deploy hook.
echo "###"
echo "### Move cloudhooks folder first to make sure we are executing up to date hooks."
echo "###"
rsync -a -e "ssh -i ~/.ssh/deploy_rsa" --stats --human-readable --delete ./cloudways/hooks ${DeployCloudwaysUsername}@${DeployCloudwaysHostname}:${DeployCloudwaysPath}/cloudways/hooks
echo "###"
echo "### Execute pre-deploy.sh."
echo "###"
ssh -i ~/.ssh/deploy_rsa ${DeployCloudwaysUsername}@${DeployCloudwaysHostname} "${DeployCloudwaysPath}/cloudways/hooks/pre-deploy.sh 2>&1 | tee ${DeployCloudwaysPath}/../private_html/logs/pre-deploy_$(date +"%Y-%m-%d-%H-%M-%S").log"

# Deploy artifact.
echo "###"
echo "### Deploy the whole artifact."
echo "###"
rsync -a -e "ssh -i ~/.ssh/deploy_rsa" --stats --human-readable --include-from='./.github/workflows/cloudways_rsync_include.txt' --exclude-from='./.github/workflows/cloudways_rsync_exclude.txt' --delete ./ ${DeployCloudwaysUsername}@${DeployCloudwaysHostname}:${DeployCloudwaysPath}

# Call post-deploy hook.
echo "###"
echo "### Execute post-deploy.sh."
echo "###"
ssh -i ~/.ssh/deploy_rsa ${DeployCloudwaysUsername}@${DeployCloudwaysHostname} "${DeployCloudwaysPath}/cloudways/hooks/post-deploy.sh 2>&1 | tee ${DeployCloudwaysPath}/../private_html/logs/post-deploy_$(date +"%Y-%m-%d-%H-%M-%S").log"
