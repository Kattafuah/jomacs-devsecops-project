# Security Evidence Documentation

This directory contains evidence of security controls and compliance measures implemented in our DevSecOps pipeline.

## Directory Structure

```
evidence/
├── sast/              # Static Application Security Testing results
├── container-scans/   # Container vulnerability scan reports
├── policy-checks/     # OPA policy evaluation results
├── incidents/         # Security incident reports and resolutions
└── audits/           # Compliance audit results
```

## Evidence Types

### 1. SAST Results
- Vulnerability scan reports
- Code quality metrics
- Security hotspots
- Fix verification reports

### 2. Container Scans
- Image vulnerability reports
- Base image security checks
- Package vulnerability lists
- Compliance check results

### 3. Policy Checks
- OPA evaluation logs
- Gatekeeper audit results
- Policy violation reports
- Compliance verification

### 4. Incident Reports
- Incident timelines
- Response documentation
- Resolution evidence
- Post-mortem reports

### 5. Audit Results
- Compliance checks
- Control effectiveness
- Remediation evidence
- Audit findings

## Retention Policy

- SAST results: 90 days
- Container scans: 90 days
- Policy checks: 1 year
- Incident reports: 3 years
- Audit results: 7 years

## Access Control

This directory contains sensitive security information. Access is restricted to:
- Security team members
- Compliance officers
- Authorized auditors

## Evidence Collection

Evidence should be collected:
1. After each pipeline run
2. During security incidents
3. During compliance audits
4. After major system changes

## Naming Convention

Files should follow this naming pattern:
```
YYYY-MM-DD_TYPE_DESCRIPTION.ext
```

Example:
```
2024-03-06_SAST_weekly-scan.pdf
2024-03-06_CONTAINER_nginx-base.json
2024-03-06_POLICY_deployment-check.log
``` 