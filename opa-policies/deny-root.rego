package k8sroot

violation[{"msg": msg}] {
    container := input.review.object.spec.containers[_]
    if container.securityContext.runAsUser == 0 {
    msg := sprintf("Container '%s' must not run as root (runAsUser: 0).", [container.name])
    }
}