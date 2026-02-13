#!/bin/bash
# Automated deployment script
aws cloudformation create-stack \
  --stack-name redshift-quicksight-pipeline \
  --template-body file://cloudformation-template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM
