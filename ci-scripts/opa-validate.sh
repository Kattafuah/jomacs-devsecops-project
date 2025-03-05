#!/bin/bash
set -e  # Exit on error

echo "Validating Kubernetes manifests with OPA..."

# Ensure the log directory exists
mkdir -p opa-logs 

# Run OPA validation using all policies together
opa eval --input eks-manifest-files/app.yaml --data ./opa-policies/ \
    '{restrict-ports: data.k8sports.violation, deny-root: data.k8root.violation, readonly-volumes: data.k8svolumes.violation}' | tee opa-logs/opa-validation.log

# Check if any violations exist
if grep -q "violation" opa-logs/opa-validation.log; then
    echo "❌ Policy violations found! See opa-validation.log for details."
    exit 1  # Fail the pipeline
else
    echo "✅ All policies passed!"
fi

