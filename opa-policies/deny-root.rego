package k8sroot

violation[{"msg": "Container is missing securityContext."}] {
    container := input.review.object.spec.containers[_]
    not container.securityContext
}

violation[{"msg": "Containers must not run as root."}] {
    container := input.review.object.spec.containers[_]
    container.securityContext.runAsUser == 0
}