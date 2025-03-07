#!/bin/bash

set -e  # Exit immediately on failure
set -o pipefail  # Fail script if any command in a pipeline fails

# Define directories and files
OPA_POLICY_DIR="./opa-policies"
MANIFESTS=(find eks-manifest-files -name "*.yaml")

# Ensure OPA policies directory exists
if [ ! -d "$OPA_POLICY_DIR" ]; then
    echo "Error: OPA policies directory '$OPA_POLICY_DIR' not found."
    exit 1
fi

# Validate each manifest file
for manifest in "${MANIFESTS[@]}"; do
    echo "Validating $manifest..."
    
    # Run OPA evaluation with only .rego files
    result=$(opa eval --input "$manifest" --data "$(find $OPA_POLICY_DIR -name '*.rego')" \
      "data.kubernetes.validating.deny" --format json)

    # Check for policy violations
    violations=$(echo "$result" | jq '.result[0].expressions[0].value | length')

    if [[ "$violations" -gt 0 ]]; then
        echo "❌ OPA validation failed for $manifest"
        echo "$result" | jq .
        exit 1  # Fail the workflow
    else
        echo "✅ OPA validation passed for $manifest"
    fi
done

echo "All manifest files passed OPA validation."


# #!/bin/bash
# set -e  # Exit on error

# echo "Validating Kubernetes manifests with OPA..."

# # Ensure the log directory exists
# mkdir -p opa-logs

# Debugging: Print paths
# echo "Input file: $(realpath eks-manifest-files/app.yaml)"
# echo "Policies directory: $(realpath ./opa-policies/)"

# opa eval --data ./opa-policies/ --input eks-manifest-files/app.yaml 'data.k8s.*'

# # Run OPA validation using all policies together
# opa eval --format=pretty --input eks-manifest-files/opa-test.yaml --data ./opa-policies/ \
#     '{
#         restrict_ports: data.k8sports.violation,
#         deny_root: data.k8sroot.violation,
#         readonly_volumes: data.k8svolumes.violation
#     }' | tee opa-logs/opa-validation.log

# # Check if any violations exist
# if grep -q "violation" opa-logs/opa-validation.log; then
#     echo "❌ Policy violations found! See opa-validation.log for details."
#     exit 1  # Fail the pipeline
# else
#     echo "✅ All policies passed!"
# fi
