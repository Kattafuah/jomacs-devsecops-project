package kubernetes.validating.security

deny[msg] if {
    input.request.kind.kind == "Pod"

    some container in input.request.object.spec.containers

    # Check if securityContext exists and `runAsNonRoot` is either missing or set to `false`
    not container.securityContext.runAsNonRoot
    msg := sprintf("Container '%v' must not run as root", [container.name])
}
