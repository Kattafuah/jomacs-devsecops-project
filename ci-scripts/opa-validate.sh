#!/bin/bash

set -e  # Exit immediately on failure
set -o pipefail  # Fail script if any command in a pipeline fails

# Define directories
OPA_POLICY_DIR="./opa-policies"
MANIFEST_DIR="./eks-manifest-files"

# Find all YAML files in the eks-manifest-files directory
MANIFEST_FILES=$(find "$MANIFEST_DIR" -name "*.yaml")

# Debugging: List the files found
echo "Found the following manifest files to validate: "
echo "$MANIFEST_FILES"

# Ensure OPA policies directory exists
if [ ! -d "$OPA_POLICY_DIR" ]; then
    echo "Error: OPA policies directory '$OPA_POLICY_DIR' not found."
    exit 1
fi

# Ensure manifest files have correct permissions
chmod -R +r "$MANIFEST_DIR"

# Run OPA evaluation with all the manifest files and the policies in the OPA policies directory
result=$(opa eval --input "$MANIFEST_FILES" --data "$(find $OPA_POLICY_DIR -name '*.rego')" \
    "data.kubernetes.validating.deny" --format json)

# Log the results
echo "OPA evaluation results:"
echo "$result" | jq .

# Check for policy violations
violations=$(echo "$result" | jq '.result[0].expressions[0].value | length')

if [[ "$violations" -gt 0 ]]; then
    echo "❌ OPA validation failed"
    exit 1  # Fail the workflow if violations exist
else
    echo "✅ OPA validation passed"
fi

echo "OPA validation completed successfully."



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
