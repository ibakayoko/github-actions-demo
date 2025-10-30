#!/bin/bash
# scripts/deploy.sh

environment=$1
stack_name=$2
template_file=$3
parameters_file=$4

# Function to check stack status
check_stack_status() {
    aws cloudformation describe-stacks \
        --stack-name $1 \
        --query 'Stacks[0].StackStatus' \
        --output text
}

# Deploy the stack
aws cloudformation deploy \
    --template-file ${template_file} \
    --stack-name ${environment}-${stack_name} \
    --parameter-overrides file://${parameters_file} \
 #   --tags file://environments/${environment}/tags.json \
    --capabilities CAPABILITY_NAMED_IAM CAPABILITY_AUTO_EXPAND \
    --no-fail-on-empty-changeset

# Wait for stack operation to complete
status=$(check_stack_status ${environment}-${stack_name})
while [[ $status == *"IN_PROGRESS"* ]]; do
    echo "Stack status: $status"
    sleep 30
    status=$(check_stack_status ${environment}-${stack_name})
done

if [[ $status != "CREATE_COMPLETE" && $status != "UPDATE_COMPLETE" ]]; then
    echo "Stack deployment failed with status: $status"
    exit 1
fi

echo "Stack deployment completed successfully"
