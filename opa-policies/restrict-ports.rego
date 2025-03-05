package k8sports

contains violation[{"msg": msg}] if {
    container := input.review.object.spec.containers[_]
    port := container.ports[_].containerPort
    port < 1024
    msg := sprintf("Container '%s' must not expose port %d (ports below 1024 are not allowed).", [container.name, port])
}