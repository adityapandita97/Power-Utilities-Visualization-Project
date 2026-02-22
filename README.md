# AWS Data Pipeline for Power and Utilities Analytics 

A complete Infrastructure-as-Code solution for building a data analytics pipeline that ingests CSV files from S3, loads them into Amazon Redshift, and visualizes the data using Amazon QuickSight

S3 → Redshift → QuickSight

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Features](#features)
- [Deployment Guide](#deployment-guide)
- [Post-Deployment Steps](#post-deployment-steps)
- [Connecting QuickSight](#connecting-quicksight)
- [Troubleshooting](#troubleshooting)
- [Cost Estimation](#cost-estimation)
- [Cleanup](#cleanup)
- [Security Considerations](#security-considerations)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This CloudFormation template automates the deployment of a complete data analytics pipeline that:

1. Creates a secure VPC environment with public and private subnets
2. Provisions an Amazon Redshift cluster for data warehousing
3. Sets up an S3 bucket for CSV file storage
4. Automatically creates database tables and loads data from S3
5. Configures QuickSight VPC connection for data visualization

**Use Case**: Perfect for organizations needing to quickly set up a data analytics environment for CSV-based data sources, such as IoT sensor data, meter readings, transaction logs, or any structured data requiring analysis and visualization.

## 🏗️ Architecture

<img width="859" height="481" alt="redshift-project" src="https://github.com/user-attachments/assets/279f996a-5188-4c76-9927-b11fa1660b98" />

## ✅ Prerequisites

Before deploying this solution, ensure you have:

### AWS Account Requirements
- **AWS Account** with administrative access
- **AWS CLI** installed and configured ([Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **QuickSight** subscription enabled in your AWS account
  - Go to [QuickSight Console](https://quicksight.aws.amazon.com/)
  - Sign up for QuickSight if not already enabled
  - Note your QuickSight username

### Technical Requirements
- **IAM Permissions** to create:
  - VPC, Subnets, Security Groups
  - Redshift clusters
  - S3 buckets
  - IAM roles and policies
  - Lambda functions
  - QuickSight VPC connections

### Data Requirements
- **CSV file** with the following structure (or modify the template for your schema):
  ```
  meternumber,readdatetime,loadkw,loadkva,readingkwh,consumptionkwh,readingkvah,consumptionkvah,powerfactor,voltagekv,currentamps
  METER001,2021-01-01 00:00:00,10.5,12.3,100.5,50.2,110.3,55.1,0.95,11.0,45.5
  ```

### Software Requirements
- AWS CLI version 2.x or higher
- Git (for cloning this repository)

## 🚀 Features

- ✅ **Fully Automated Deployment** - One-command infrastructure setup
- ✅ **Secure by Default** - Private Redshift cluster with VPC isolation
- ✅ **Auto Data Loading** - Lambda function automatically creates tables and loads data
- ✅ **Production Ready** - Includes proper IAM roles, security groups, and network configuration
- ✅ **Cost Optimized** - Single-node cluster suitable for testing and small workloads
- ✅ **Reusable** - Parameterized template for easy customization
- ✅ **QuickSight Integration** - Pre-configured VPC connection for seamless visualization

## 📦 Deployment Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/your-username/aws-csv-data-pipeline.git
cd aws-csv-data-pipeline
```

### Step 2: Prepare Your CSV File

Ensure your CSV file matches the expected schema or modify the Lambda function in the CloudFormation template to match your data structure.

**Sample CSV format:**
```csv
meternumber,readdatetime,loadkw,loadkva,readingkwh,consumptionkwh,readingkvah,consumptionkvah,powerfactor,voltagekv,currentamps
METER001,2021-01-01 00:00:00,10.5,12.3,100.5,50.2,110.3,55.1,0.95,11.0,45.5
METER002,2021-01-01 00:15:00,11.2,13.1,105.3,52.1,115.2,57.3,0.96,11.1,46.2
```

### Step 3: Configure Parameters

Create a `parameters.json` file with your specific values:

```json
[
  {
    "ParameterKey": "RedshiftMasterUsername",
    "ParameterValue": "admin"
  },
  {
    "ParameterKey": "RedshiftMasterPassword",
    "ParameterValue": "YourSecurePassword123!"
  },
  {
    "ParameterKey": "RedshiftDatabaseName",
    "ParameterValue": "dev"
  },
  {
    "ParameterKey": "RedshiftClusterIdentifier",
    "ParameterValue": "my-csv-cluster"
  },
  {
    "ParameterKey": "S3BucketName",
    "ParameterValue": "my-unique-bucket-name-12345"
  },
  {
    "ParameterKey": "CSVFileName",
    "ParameterValue": "meter.csv"
  },
  {
    "ParameterKey": "QuickSightUsername",
    "ParameterValue": "your-quicksight-username"
  }
]
```

**Important Notes:**
- **S3BucketName** must be globally unique across all AWS accounts
- **RedshiftMasterPassword** must be 8-64 characters with uppercase, lowercase, and numbers
- **QuickSightUsername** can be found in QuickSight console under "Manage QuickSight" → "Users"

### Step 4: Deploy the CloudFormation Stack

```bash
aws cloudformation create-stack \
  --stack-name redshift-quicksight-pipeline \
  --template-body file://cloudformation-template.yaml \
  --parameters file://parameters.json \
  --capabilities CAPABILITY_NAMED_IAM \
  --region us-east-1
```

**Monitor deployment progress:**

```bash
aws cloudformation describe-stacks \
  --stack-name redshift-quicksight-pipeline \
  --query 'Stacks[0].StackStatus' \
  --region us-east-1
```

Wait until the status shows `CREATE_COMPLETE` (typically 10-15 minutes).

### Step 5: Upload Your CSV File to S3

Once the stack is created, upload your CSV file:

```bash
# Get the bucket name from stack outputs
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name redshift-quicksight-pipeline \
  --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
  --output text \
  --region us-east-1)

# Upload your CSV file
aws s3 cp meter.csv s3://${BUCKET_NAME}/meter.csv
```

### Step 6: Verify Data Loading

The Lambda function automatically triggers after the Redshift cluster is available. Check the logs:

```bash
# Get Lambda function name
FUNCTION_NAME=$(aws cloudformation describe-stack-resources \
  --stack-name redshift-quicksight-pipeline \
  --query 'StackResources[?ResourceType==`AWS::Lambda::Function`].PhysicalResourceId' \
  --output text \
  --region us-east-1)

# View Lambda logs
aws logs tail /aws/lambda/${FUNCTION_NAME} --follow --region us-east-1
```

Look for messages indicating successful table creation and data loading.

## 🔧 Post-Deployment Steps

### Retrieve Connection Information

Get your Redshift cluster details:

```bash
aws cloudformation describe-stacks \
  --stack-name redshift-quicksight-pipeline \
  --query 'Stacks[0].Outputs' \
  --output table \
  --region us-east-1
```

**Key outputs you'll need:**
- `RedshiftClusterEndpoint` - Redshift cluster hostname
- `RedshiftClusterPort` - Port number (5439)
- `RedshiftJDBCURL` - Full JDBC connection string
- `QuickSightVPCConnectionId` - VPC connection ID for QuickSight

### Test Redshift Connection (Optional)

If you want to verify the data manually:

1. **Install a SQL client** (e.g., DBeaver, SQL Workbench/J)
2. **Connect using:**
   - Host: [RedshiftClusterEndpoint from outputs]
   - Port: 5439
   - Database: dev
   - Username: [Your RedshiftMasterUsername]
   - Password: [Your RedshiftMasterPassword]

3. **Run test query:**
   ```sql
   SELECT COUNT(*) FROM interval_reads_2021;
   SELECT * FROM interval_reads_2021 LIMIT 10;
   ```

## 📊 Connecting QuickSight

### Step 1: Access QuickSight Console

1. Navigate to [QuickSight Console](https://quicksight.aws.amazon.com/)
2. Click on **Datasets** in the left navigation
3. Click **New dataset**

### Step 2: Configure Redshift Data your source document. Select **Redshift** as your data your source document. Choose **Use VPC connection**
3. Select the VPC connection created by the stack:
   - Name: `[StackName]-VPCConnection`
   - VPC Connection ID: [From CloudFormation outputs]

### Step 3: Enter Connection Details

Fill in the connection information:

```
Data source name: Meter Data Pipeline
Instance ID: [RedshiftClusterIdentifier]
Database name: dev
Username: [RedshiftMasterUsername]
Password: [RedshiftMasterPassword]
```

Click **Validate connection** to test, then **Create data source**

### Step 4: Select Table

1. Choose **Schema**: `public`
2. Select table: `interval_reads_2021`
3. Choose **Import to SPICE** for faster queries (recommended)
4. Click **Visualize**

### Step 5: Create Visualizations

Now you can create various visualizations:

**Example Visualizations:**
- **Line Chart**: Power consumption over time
- **Bar Chart**: Average load by meter number
- **KPI**: Total consumption KWH
- **Heat Map**: Power factor distribution

## 🔍 Troubleshooting

### Issue: Stack Creation Fails

**Symptoms:** CloudFormation stack shows `CREATE_FAILED` status

**Solutions:**
1. Check CloudFormation events for specific error messages:
   ```bash
   aws cloudformation describe-stack-events \
     --stack-name redshift-quicksight-pipeline \
     --region us-east-1
   ```

2. Common issues:
   - **S3 bucket name already exists**: Choose a different unique bucket name
   - **Insufficient permissions**: Ensure your IAM user has required permissions
   - **QuickSight not enabled**: Enable QuickSight in your account first

### Issue: Lambda Function Fails to Load Data

**Symptoms:** Table exists but no data loaded

**Solutions:**
1. Check Lambda logs:
   ```bash
   aws logs tail /aws/lambda/[FunctionName] --follow
   ```

2. Verify:
   - CSV file is uploaded to S3
   - IAM role has S3 read permissions
   - CSV format matches table schema
   - No special characters or encoding issues in CSV

### Issue: QuickSight Cannot Connect to Redshift

**Symptoms:** Connection validation fails in QuickSight

**Solutions:**
1. Verify security group rules:
   ```bash
   aws ec2 describe-security-groups \
     --filters "Name=tag:Name,Values=*RedshiftSG*" \
     --region us-east-1
   ```

2. Ensure:
   - QuickSight security group has outbound rule to Redshift port 5439
   - Redshift security group allows inbound from QuickSight security group
   - VPC connection is in the same VPC as Redshift cluster

### Issue: Data Not Appearing in QuickSight

**Symptoms:** Connection successful but no data visible

**Solutions:**
1. Verify data in Redshift:
   ```sql
   SELECT COUNT(*) FROM interval_reads_2021;
   ```

2. Check SPICE import status in QuickSight
3. Refresh the dataset manually
4. Verify correct schema and table selected

## 💰 Cost Estimation

**Monthly cost breakdown (us-east-1 region):**

| Service | Configuration | Estimated Monthly Cost |
|---------|--------------|----------------------|
| Amazon Redshift | ra3.large, single-node | ~$2,190 |
| Amazon S3 | 1 GB storage, minimal requests | ~$0.50 |
| AWS Lambda | 10 executions/month | ~$0.20 |
| VPC | NAT Gateway (if needed) | ~$32 |
| QuickSight | Standard Edition, 1 user | ~$9 |
| **Total** | | **~$2,232/month** |

**Cost Optimization Tips:**
- Use Redshift pause/resume for non-production environments
- Consider dc2.large ($180/month) for smaller datasets
- Use S3 lifecycle policies to archive old data
- Enable Redshift concurrency scaling only when needed

## 🧹 Cleanup

To avoid ongoing charges, delete all resources:

### Step 1: Empty S3 Bucket

```bash
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name redshift-quicksight-pipeline \
  --query 'Stacks[0].Outputs[?OutputKey==`S3BucketName`].OutputValue' \
  --output text \
  --region us-east-1)

aws s3 rm s3://${BUCKET_NAME} --recursive
```

### Step 2: Delete CloudFormation Stack

```bash
aws cloudformation delete-stack \
  --stack-name redshift-quicksight-pipeline \
  --region us-east-1
```

### Step 3: Monitor Deletion

```bash
aws cloudformation describe-stacks \
  --stack-name redshift-quicksight-pipeline \
  --query 'Stacks[0].StackStatus' \
  --region us-east-1
```

Wait until the stack is completely deleted (typically 10-15 minutes).

### Step 4: Clean Up QuickSight Resources

Manually delete in QuickSight console:
1. Delete datasets using this data your source document. Delete the Redshift data your source document. VPC connection will be automatically deleted with the stack

## 🔒 Security Considerations

### Network Security
- ✅ Redshift cluster is in private subnet (not publicly accessible)
- ✅ Security groups follow principle of least privilege
- ✅ VPC endpoints can be added for enhanced security

### Data Security
- ✅ S3 bucket has public access blocked
- ✅ Encryption at rest enabled for Redshift
- ✅ IAM roles use minimal required permissions
- ✅ Secrets should be stored in AWS Secrets Manager (enhancement)

### Access Control
- ✅ IAM roles for service-to-service communication
- ✅ Database credentials required for Redshift access
- ✅ QuickSight uses VPC connection (not public internet)

### Recommended Enhancements
1. **Use AWS Secrets Manager** for database credentials
2. **Enable CloudTrail** for audit logging
3. **Implement VPC Flow Logs** for network monitoring
4. **Add AWS WAF** if exposing QuickSight dashboards publicly
5. **Enable GuardDuty** for threat detection

## 🛠️ Customization

### Modify Table Schema

Edit the Lambda function code in the CloudFormation template:

```python
create_table_sql = """
CREATE TABLE IF NOT EXISTS your_table_name (
    column1 VARCHAR(50),
    column2 DECIMAL(10,2),
    -- Add your columns here
);
"""
```

### Change Redshift Node Type

Modify the `NodeType` parameter in the template:

```yaml
NodeType: dc2.large  # Options: dc2.large, ra3.xlplus, ra3.4xlplus, etc.
```

### Add Multiple Tables

Extend the Lambda function to create multiple tables and load from different CSV files.

### Enable Multi-AZ

For production workloads, enable Multi-AZ:

```yaml
MultiAZ: true
NumberOfNodes: 2  # Minimum for Multi-AZ
```

## 📚 Additional Resources

- [Amazon Redshift Documentation](https://docs.aws.amazon.com/redshift/)
- [Amazon QuickSight User Guide](https://docs.aws.amazon.com/quicksight/)
- [AWS CloudFormation Best Practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)
- [Redshift Best Practices](https://docs.aws.amazon.com/redshift/latest/dg/best-practices.html)

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

**Questions or Issues?** Please open an issue on GitHub or contact [adityapandita97@gmail.com]
