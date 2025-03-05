package k8sroot

contains violation[{"msg": msg}] if {
    container := input.review.object.spec.containers[_]
    container.securityContext.runAsUser == 0
    msg := sprintf("Container '%s' must not run as root (runAsUser: 0).", [container.name])
}