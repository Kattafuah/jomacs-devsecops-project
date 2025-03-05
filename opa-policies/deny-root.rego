package k8sroot

violation[{"msg": "Containers must not run as root"}] {
    container := input.review.object.spec.containers[_]
    if container.securityContext.runAsUser  == 0 {
        msg := "Containers must not run as root."
    }
}