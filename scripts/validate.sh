#!/bin/bash
# Validate CloudFormation template
aws cloudformation validate-template \
  --template-body file://cloudformation-template.yaml


