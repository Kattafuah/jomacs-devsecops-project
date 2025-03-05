package k8sroot

contains violation[{"msg": "Containers must not run as root."}] if {
container := input.review.object.spec.containers[_]
container.securityContext.runAsUser  == 0
}