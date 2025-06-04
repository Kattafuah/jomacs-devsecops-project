# EKS Security Incident Response Runbook

## Overview
This runbook provides specific procedures for handling security incidents in our Amazon EKS environment.

## Prerequisites
- AWS CLI configured with appropriate permissions
- `kubectl` configured with cluster access
- Access to AWS Console
- Access to AWS Secrets Manager

## Common EKS Security Incidents

### 1. Pod Security Policy Violation

#### Detection
```bash
# Check pod security events
kubectl get events --field-selector type=Warning

# Check pod status
kubectl get pods -A | grep -i "error\|crash\|back"
```

#### Response Steps
1. Identify the affected pod and namespace
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```

2. Check security context and policies
   ```bash
   kubectl get psp
   kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Security Context"
   ```

3. Isolate the pod
   ```bash
   kubectl label namespace <namespace> isolation=true
   ```

4. Apply restrictive network policy
   ```bash
   kubectl apply -f security/network-policies/isolate-namespace.yaml
   ```

### 2. Unauthorized Access Attempt

#### Detection
- CloudWatch Alerts for unauthorized API calls
- AWS GuardDuty findings
- EKS control plane logs

#### Response Steps
1. Check authentication logs
   ```bash
   kubectl logs -n kube-system -l k8s-app=aws-iam-authenticator
   ```

2. Review IAM roles and users
   ```bash
   aws iam list-roles | grep -i eks
   aws iam list-users | grep -i eks
   ```

3. Rotate compromised credentials
   ```bash
   aws iam update-access-key --status Inactive --user-name <username> --access-key-id <key-id>
   ```

4. Update AWS Secrets Manager secrets
   ```bash
   aws secretsmanager rotate-secret --secret-id <secret-id>
   ```

### 3. Container Image Security Incident

#### Detection
- ECR scan findings
- Runtime security alerts
- Abnormal container behavior

#### Response Steps
1. Identify affected images
   ```bash
   aws ecr describe-image-scan-findings --repository-name <repo> --image-id imageTag=<tag>
   ```

2. Quarantine affected pods
   ```bash
   kubectl scale deployment <deployment> --replicas=0 -n <namespace>
   ```

3. Block vulnerable images
   ```bash
   # Apply ImagePolicyWebhook to block vulnerable images
   kubectl apply -f security/image-policies/block-vulnerable.yaml
   ```

4. Update to secure image version
   ```bash
   kubectl set image deployment/<deployment> container=<new-image> -n <namespace>
   ```

### 4. Network Policy Violation

#### Detection
- Security group alerts
- Network flow logs
- Pod-to-pod communication alerts

#### Response Steps
1. Review network policies
   ```bash
   kubectl get networkpolicies -A
   ```

2. Apply default deny policy
   ```bash
   kubectl apply -f security/network-policies/default-deny.yaml
   ```

3. Audit network flows
   ```bash
   aws ec2 describe-flow-logs
   ```

4. Update security groups
   ```bash
   aws ec2 update-security-group-rule-descriptions-ingress --group-id <sg-id>
   ```

### 5. Secret Exposure Incident

#### Detection
- AWS Secrets Manager alerts
- Git secrets scanning alerts
- Runtime secret detection

#### Response Steps
1. Identify exposed secrets
   ```bash
   aws secretsmanager list-secrets
   ```

2. Rotate exposed secrets
   ```bash
   aws secretsmanager rotate-secret --secret-id <secret-id>
   ```

3. Update Kubernetes secrets
   ```bash
   kubectl create secret generic <name> --from-literal=key=<new-value> -n <namespace> --dry-run=client -o yaml | kubectl apply -f -
   ```

4. Verify applications
   ```bash
   kubectl rollout restart deployment/<deployment> -n <namespace>
   ```

## Post-Incident Tasks

### 1. Update Security Policies
- Review and update Pod Security Policies
- Update Network Policies
- Strengthen RBAC rules

### 2. Documentation
- Document incident timeline
- Update security baselines
- Review and update runbooks

### 3. Monitoring Improvements
- Add new CloudWatch alerts
- Update GuardDuty findings
- Enhance logging rules

### 4. Training
- Update team training materials
- Conduct incident response drills
- Share lessons learned

## Compliance Requirements

### SOC 2 Controls
- Document all response actions
- Update control effectiveness
- Review access controls
- Update risk assessment

### Evidence Collection
- Save all relevant logs
- Document all commands run
- Capture configuration changes
- Record timeline of events

## Contact Information

### AWS Support
- Premium Support: Open severity 1 case
- Account team: Contact TAM

### Internal Teams
- Security: kattafuah@gmail.com
- DevOps: On-call rotation
- Management: Incident commander 