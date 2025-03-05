package k8sports

violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    port := container.ports[_].containerPort
    if port < 1024 {
    msg := sprintf("Container '%s' must not expose port %d (ports below 1024 are not allowed).", [container.name, port])
    }
}