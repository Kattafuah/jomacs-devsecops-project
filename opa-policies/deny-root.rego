package k8sroot

violation[{"msg": "Containers must not run as root"}] {
    input.review.object.spec.containers[_].securityContext.runAsUser == 0
}
